//
//  BabyEditView.swift
//  AiBaBy
//
//  Created by han han on 2025/8/24.
//

import SwiftUI
import SwiftData
import PhotosUI

struct BabyEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var birthDate: Date? = nil
    @State private var notes = ""
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var photoData: Data? = nil
    @State private var showDatePicker = false
    
    var baby: Baby? = nil
    
    var isEditing: Bool {
        baby != nil
    }
    
    var body: some View {
        Form {
            Section("照片") {
                VStack {
                    if let photoData = photoData, let uiImage = UIImage(data: photoData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 200, height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                    } else {
                        Image(systemName: "heart.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                            .foregroundColor(.pink)
                            .frame(width: 200, height: 200)
                            .background(Color.pink.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                    }
                    
                    PhotosPicker(
                        selection: $selectedItem,
                        matching: .images,
                        photoLibrary: .shared()) {
                            Text("选择照片")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                        .padding(.top, 8)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
            
            Section("基本信息") {
                TextField("名字", text: $name)
                
                HStack {
                    Text("生日")
                    Spacer()
                    if let birthDate = birthDate {
                        Text(birthDate, style: .date)
                            .foregroundColor(.secondary)
                    } else {
                        Text("未设置")
                            .foregroundColor(.secondary)
                    }
                    Button(action: { showDatePicker.toggle() }) {
                        Image(systemName: "calendar")
                    }
                }
                
                if showDatePicker {
                    DatePicker(
                        "选择生日",
                        selection: Binding(
                            get: { birthDate ?? Date() },
                            set: { birthDate = $0 }
                        ),
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                }
            }
            
            Section("笔记") {
                TextEditor(text: $notes)
                    .frame(minHeight: 100)
            }
            
            if isEditing {
                Section {
                    Button("删除", role: .destructive) {
                        if let baby = baby {
                            modelContext.delete(baby)
                            dismiss()
                        }
                    }
                }
            }
        }
        .navigationTitle(isEditing ? "编辑阿贝贝" : "添加阿贝贝")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("取消") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("保存") {
                    saveBaby()
                    dismiss()
                }
                .disabled(name.isEmpty)
            }
        }
        .onAppear {
            if let baby = baby {
                name = baby.name
                birthDate = baby.birthDate
                notes = baby.notes
                photoData = baby.photo
            }
        }
        .onChange(of: selectedItem) { _, newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self) {
                    photoData = data
                }
            }
        }
    }
    
    private func saveBaby() {
        if let baby = baby {
            // 更新现有的阿贝贝
            baby.name = name
            baby.birthDate = birthDate
            baby.notes = notes
            baby.photo = photoData
        } else {
            // 创建新的阿贝贝
            let newBaby = Baby(name: name, birthDate: birthDate, photo: photoData, notes: notes)
            modelContext.insert(newBaby)
        }
    }
}

#Preview {
    NavigationStack {
        BabyEditView()
            .modelContainer(for: [Baby.self, Moment.self], inMemory: true)
    }
}