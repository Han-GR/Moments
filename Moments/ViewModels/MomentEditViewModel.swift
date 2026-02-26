//
//  MomentEditViewModel.swift
//  Moments
//
//  Created by han han on 2025/8/24.
//

import SwiftUI
import SwiftData
import PhotosUI

@MainActor
class MomentEditViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var content = ""
    @Published var date = Date()
    @Published var selectedBaby: Baby?
    @Published var selectedMedia: [PickerMediaItem] = []
    @Published var isProcessingImages = false
    @Published var isSaving = false
    @Published var errorMessage: String?
    @Published var shouldDismiss = false
    
    var isEditing: Bool { originalMoment != nil }
    
    // MARK: - Private Properties
    private var originalMoment: Moment?
    
    // MARK: - Initialization
    init(moment: Moment?, baby: Baby?) {
        self.originalMoment = moment
        
        if let moment = moment {
            self.content = moment.content
            self.date = moment.date
            self.selectedBaby = moment.baby
            // Media will be loaded asynchronously in loadData()
        } else {
            // New moment mode
            self.selectedBaby = baby
            self.date = Date()
        }
    }
    
    // MARK: - Data Loading
    func loadData() {
        guard let moment = originalMoment, let items = moment.mediaItems else { return }
        
        isProcessingImages = true
        
        Task.detached(priority: .userInitiated) {
            let mediaItems = items.compactMap { media -> PickerMediaItem? in
                // Load thumbnail or original image for display
                // Note: MediaStore.loadImage is synchronous but we are in a detached task
                if let image = MediaStore.loadImage(from: media.thumbnailPath ?? media.originalPath, preferThumbnail: true) {
                    var videoURL: URL? = nil
                    if media.type == .video {
                        videoURL = MediaStore.videoURL(for: media.originalPath)
                    }
                    
                    return PickerMediaItem(
                        image: image,
                        type: media.type,
                        videoURL: videoURL,
                        originalFilename: media.originalPath
                    )
                }
                return nil
            }
            
            await MainActor.run {
                self.selectedMedia = mediaItems
                self.isProcessingImages = false
            }
        }
    }
    
    // MARK: - Actions
    func save(modelContext: ModelContext) {
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !selectedMedia.isEmpty else {
            return
        }
        
        isSaving = true
        
        // Perform saving in a background task to avoid blocking UI
        Task {
            do {
                if let existingMoment = originalMoment {
                    try await updateMoment(existingMoment, modelContext: modelContext)
                } else {
                    try await createMoment(modelContext: modelContext)
                }
                
                await MainActor.run {
                    do {
                        try modelContext.save()
                        self.isSaving = false
                        self.shouldDismiss = true
                    } catch {
                        self.isSaving = false
                        self.errorMessage = NSLocalizedString("error_save_failed", value: "保存失败", comment: "")
                    }
                }
            } catch {
                await MainActor.run {
                    self.isSaving = false
                    self.errorMessage = NSLocalizedString("error_save_failed", value: "保存失败", comment: "")
                }
            }
        }
    }
    
    // MARK: - Private Helpers
    private func updateMoment(_ moment: Moment, modelContext: ModelContext) async throws {
        // Update basic properties
        moment.content = content
        moment.date = date
        moment.baby = selectedBaby
        
        // Handle media updates
        // First, identify which existing items are kept and which are removed
        let currentMediaIds = Set(selectedMedia.compactMap { $0.originalFilename })
        
        // Remove deleted media items from context and storage
        if let existingItems = moment.mediaItems {
            for item in existingItems {
                if !currentMediaIds.contains(item.originalPath) {
                    modelContext.delete(item)
                    // Optional: Delete file from disk if no other moment uses it (ref counting is complex, skipping for now)
                }
            }
        }
        
        // Create new media items list
        var newItems: [MomentMedia] = []
        
        for item in selectedMedia {
            if let originalFilename = item.originalFilename {
                // Reuse existing file
                // We need to find if there is an existing MomentMedia object for this file in the current moment
                // Or create a new one if it was re-added (simpler to recreate object but reuse file)
                
                // Check if we can reuse the existing MomentMedia object to preserve ID?
                // For simplicity, we can recreate the relationship or find the existing one.
                // But the View logic previously was: delete all old items, create new ones.
                // Let's try to be smarter or stick to the previous logic if it was safe.
                // Previous logic:
                // existingMoment.mediaItems = [] (implies removal from relationship, but not necessarily deletion from context if not cascaded?)
                // Actually SwiftData relationships: if we replace the array, old items might be orphaned.
                // The previous code explicitly called modelContext.delete(item).
                
                // Let's follow the previous logic of clearing and recreating to ensure consistency,
                // but we must be careful not to delete the files from disk if we are reusing them.
                
                let thumb = MediaStore.thumbnailName(for: originalFilename)
                let media = MomentMedia(type: item.type, originalPath: originalFilename, thumbnailPath: thumb)
                newItems.append(media)
            } else {
                // New file
                if let (type, originalPath, thumbnailPath) = await saveNewMedia(item) {
                    let newMedia = MomentMedia(type: type, originalPath: originalPath, thumbnailPath: thumbnailPath)
                    newItems.append(newMedia)
                }
            }
        }
        
        // Update relationship
        // We need to clear old items first
        if let oldItems = moment.mediaItems {
            for item in oldItems {
                modelContext.delete(item)
            }
        }
        moment.mediaItems = newItems
        
        // Save context
        // Note: modelContext.save() is not async but we are in a Task.
        // It should be safe to call on background thread if ModelContext is created properly (it is actor-isolated in SwiftData).
        // Wait, ModelContext is not thread-safe across threads unless using Actor isolation.
        // SwiftData ModelContext is bound to the actor that created it (MainActor usually for View).
        // So we should probably run the context updates on MainActor.
    }
    
    private func createMoment(modelContext: ModelContext) async throws {
        let newMoment = Moment(content: content, date: date)
        newMoment.baby = selectedBaby
        
        var newItems: [MomentMedia] = []
        for item in selectedMedia {
            if let (type, originalPath, thumbnailPath) = await saveNewMedia(item) {
                let newMedia = MomentMedia(type: type, originalPath: originalPath, thumbnailPath: thumbnailPath)
                newItems.append(newMedia)
            }
        }
        newMoment.mediaItems = newItems
        
        // We must insert into context on MainActor if context is from View
        await MainActor.run {
            modelContext.insert(newMoment)
        }
    }
    
    private func saveNewMedia(_ item: PickerMediaItem) async -> (MomentMedia.MediaType, String, String?)? {
        // Use detached task to perform file I/O off the main thread
        return await Task.detached {
            if item.type == .video, let videoURL = item.videoURL {
                guard let filename = MediaStore.saveVideo(from: videoURL) else { return nil }
                _ = MediaStore.generateVideoThumbnail(for: filename)
                let thumb = MediaStore.thumbnailName(for: filename)
                return (.video, filename, thumb)
            } else {
                guard let filename = MediaStore.saveImage(item.image, quality: 0.85) else { return nil }
                let thumb = MediaStore.saveThumbnail(of: item.image, basedOn: filename)
                let finalType: MomentMedia.MediaType = (item.type == .livePhoto) ? .livePhoto : .photo
                return (finalType, filename, thumb)
            }
        }.value
    }
}
