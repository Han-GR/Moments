//
//  MomentEditView.swift
//  Moments
//
//  Created by han han on 2025/8/24.
//

import SwiftUI
import SwiftData
import UIKit

struct MomentEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query private var allBabies: [Baby]
    
    // StateObject for ViewModel
    @StateObject private var viewModel: MomentEditViewModel
    
    @State private var isShowingBabyPicker = false
    @State private var isShowingPhotoPicker = false
    
    init(moment: Moment? = nil, baby: Baby? = nil) {
        _viewModel = StateObject(wrappedValue: MomentEditViewModel(moment: moment, baby: baby))
    }
    
    var body: some View {
        formContent
            .navigationTitle(
                viewModel.isEditing
                ? NSLocalizedString("title_edit_moment", value: "编辑生活瞬间", comment: "")
                : NSLocalizedString("title_record_moment", value: "记录生活瞬间", comment: "")
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(NSLocalizedString("action_cancel", value: "取消", comment: "")) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.isSaving {
                        ProgressView()
                    } else {
                        Button(NSLocalizedString("action_save", value: "保存", comment: "")) {
                            viewModel.save(modelContext: modelContext)
                        }
                        .disabled(viewModel.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && viewModel.selectedMedia.isEmpty)
                    }
                }
            }
            .onAppear {
                viewModel.loadData()
            }
            .onChange(of: viewModel.shouldDismiss) { _, shouldDismiss in
                if shouldDismiss {
                    dismiss()
                }
            }
            .alert(isPresented: Binding<Bool>(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Alert(
                    title: Text(NSLocalizedString("error_title", value: "错误", comment: "")),
                    message: Text(viewModel.errorMessage ?? ""),
                    dismissButton: .default(Text("OK"))
                )
            }
            .sheet(isPresented: $isShowingBabyPicker) {
                BabyPickerSheet(selectedBaby: $viewModel.selectedBaby, isPresented: $isShowingBabyPicker, allBabies: allBabies)
            }
    }
    
    private var formContent: some View {
        Form {
            babySection
            dateSection
            contentSection
            photosSection()
        }
    }
    
    private var babySection: some View {
        Section(NSLocalizedString("field_item_optional", value: "物品（可选）", comment: "")) {
            HStack {
                if let selectedBaby = viewModel.selectedBaby {
                    HStack {
                        BabyAvatarView.medium(baby: selectedBaby)
                        
                        Text(selectedBaby.name)
                            .font(.headline)
                    }
                } else {
                    Text(NSLocalizedString("label_no_item", value: "无物品", comment: ""))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    isShowingBabyPicker = true
                }) {
                    Text(viewModel.selectedBaby == nil
                         ? NSLocalizedString("action_select", value: "选择", comment: "")
                         : NSLocalizedString("action_change", value: "更改", comment: ""))
                }
            }
        }
    }
    
    private var dateSection: some View {
        Section(NSLocalizedString("field_date", value: "日期", comment: "")) {
            CollapsibleDatePickerRow(
                title: NSLocalizedString("field_select_date", value: "选择日期", comment: ""),
                placeholder: NSLocalizedString("label_not_set", value: "未设置", comment: ""),
                date: Binding<Date?>(
                    get: { viewModel.date },
                    set: { newValue in
                        if let value = newValue {
                            viewModel.date = value
                        }
                    }
                ),
                minimumDate: nil,
                maximumDate: Date()
            )
        }
    }
    
    private var contentSection: some View {
        Section(NSLocalizedString("field_moment_content", value: "瞬间内容", comment: "")) {
            TextEditor(text: $viewModel.content)
                .frame(minHeight: 100)
        }
    }
    
    private func photosSection() -> some View {
        let labelText: String = viewModel.selectedMedia.count >= 9
            ? NSLocalizedString("max_photos_reached", value: "已达到最大数量(9张)", comment: "")
            : String(
                format: NSLocalizedString("add_photos_videos_count_format", value: "添加照片/视频 (%d/9)", comment: ""),
                viewModel.selectedMedia.count
            )
        
        return Section(NSLocalizedString("section_photos", value: "照片", comment: "")) {
            Button(action: {
                if viewModel.selectedMedia.count < 9 {
                    isShowingPhotoPicker = true
                }
            }) {
                Label(labelText, systemImage: "plus.circle.fill")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(viewModel.selectedMedia.count >= 9 ? .gray : .blue)
                    .cornerRadius(8)
            }
            .disabled(viewModel.selectedMedia.count >= 9)
            .background(
                MediaPickerSheet(
                    selectedMedia: $viewModel.selectedMedia,
                    isPresented: $isShowingPhotoPicker
                )
            )
            
            if viewModel.isProcessingImages {
                 HStack {
                     Spacer()
                     ProgressView()
                     Spacer()
                 }
                 .padding()
            } else if !viewModel.selectedMedia.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(viewModel.selectedMedia) { item in
                            let imageSize: CGFloat = 100
                            let cornerRadius: CGFloat = 8
                            
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: item.image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: imageSize, height: imageSize)
                                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                                
                                if item.type == .video {
                                    Image(systemName: "play.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                        .shadow(radius: 2)
                                        .padding(4)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                } else if item.type == .livePhoto {
                                    Image(systemName: "livephoto")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                        .shadow(radius: 2)
                                        .padding(4)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                }
                                
                                Button(action: {
                                    if let index = viewModel.selectedMedia.firstIndex(where: { $0.id == item.id }) {
                                        viewModel.selectedMedia.remove(at: index)
                                    }
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.white)
                                        .background(AppColors.blackOverlay)
                                        .clipShape(Circle())
                                        .padding(4)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 5)
                }
            }
        }
    }
}

struct BabyPickerSheet: View {
    @Binding var selectedBaby: Baby?
    @Binding var isPresented: Bool
    let allBabies: [Baby]
    
    var body: some View {
        NavigationStack {
            List {
                Button(action: {
                    selectedBaby = nil
                    isPresented = false
                }) {
                    HStack {
                        Text(NSLocalizedString("label_no_item", value: "无物品", comment: ""))
                            .foregroundColor(.primary)
                        Spacer()
                        if selectedBaby == nil {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                ForEach(allBabies) { baby in
                    Button(action: {
                        selectedBaby = baby
                        isPresented = false
                    }) {
                        HStack {
                            BabyAvatarView.small(baby: baby)
                            Text(baby.name)
                                .foregroundColor(.primary)
                            Spacer()
                            if selectedBaby?.id == baby.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle(NSLocalizedString("title_select_item", value: "选择物品", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(NSLocalizedString("action_cancel", value: "取消", comment: "")) {
                        isPresented = false
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

#Preview {
    NavigationStack {
        MomentEditView()
            .modelContainer(for: [Baby.self, Moment.self], inMemory: true)
    }
}
