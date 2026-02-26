//
//  BabyEditViewModel.swift
//  Moments
//
//  Created by han han on 2025/8/24.
//

import SwiftUI
import SwiftData
import PhotosUI

@MainActor
class BabyEditViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var name = ""
    @Published var birthDate: Date? = nil
    @Published var notes = ""
    @Published var photoPath: String? = nil
    @Published var selectedImage: UIImage? = nil
    @Published var selectedGroup: Group? = nil
    
    @Published var isShowingPhotoPicker = false
    @Published var showingDuplicateAlert = false
    @Published var showingAddGroup = false
    @Published var showingGroupManagement = false
    @Published var errorMessage: String?
    @Published var shouldDismiss = false
    
    // MARK: - Private Properties
    private var originalBaby: Baby?
    
    var isEditing: Bool { originalBaby != nil }
    
    // MARK: - Initialization
    init(baby: Baby?) {
        self.originalBaby = baby
        
        if let baby = baby {
            self.name = baby.name
            self.birthDate = baby.birthDate
            self.notes = baby.notes
            self.photoPath = baby.photoPath
            self.selectedGroup = baby.group
        }
    }
    
    // MARK: - Actions
    func save(modelContext: ModelContext, existingBabies: [Baby]) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check for duplicates
        let isDuplicate: Bool
        if let currentBaby = originalBaby {
            // Edit mode: check if any other baby has the same name
            isDuplicate = existingBabies.contains { $0.id != currentBaby.id && $0.name == trimmedName }
        } else {
            // Add mode: check if any baby has the same name
            isDuplicate = existingBabies.contains { $0.name == trimmedName }
        }
        
        if isDuplicate {
            showingDuplicateAlert = true
            return
        }
        
        // Perform save logic
        do {
            if let baby = originalBaby {
                try updateBaby(baby)
            } else {
                try createBaby(modelContext: modelContext, name: trimmedName)
            }
            
            try modelContext.save()
            shouldDismiss = true
        } catch {
            errorMessage = NSLocalizedString("error_save_failed", value: "保存失败", comment: "")
        }
    }
    
    // MARK: - Private Helpers
    private func updateBaby(_ baby: Baby) throws {
        baby.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        baby.birthDate = birthDate
        baby.notes = notes
        baby.group = selectedGroup
        
        if let selectedImage = selectedImage {
            if let filename = MediaStore.saveImage(selectedImage, quality: 0.85) {
                _ = MediaStore.saveThumbnail(of: selectedImage, basedOn: filename)
                baby.photoPath = filename
            }
        }
    }
    
    private func createBaby(modelContext: ModelContext, name: String) throws {
        var finalPath: String? = nil
        if let selectedImage = selectedImage {
            finalPath = MediaStore.saveImage(selectedImage, quality: 0.85)
            if let path = finalPath {
                _ = MediaStore.saveThumbnail(of: selectedImage, basedOn: path)
            }
        }
        
        let newBaby = Baby(name: name, birthDate: birthDate, photoPath: finalPath, notes: notes)
        newBaby.group = selectedGroup
        modelContext.insert(newBaby)
    }
}
