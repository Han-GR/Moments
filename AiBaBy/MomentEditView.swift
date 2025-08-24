//
//  MomentEditView.swift
//  AiBaBy
//
//  Created by han han on 2025/8/24.
//

import SwiftUI
import SwiftData
import PhotosUI

struct MomentEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query private var allBabies: [Baby]
    
    // 如果传入了特定的阿贝贝，则默认选择该阿贝贝
    var baby: Baby?
    
    @State private var title = ""
    @State private var content = ""
    @State private var date = Date()
    @State private var selectedBaby: Baby?
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedPhotosData: [Data] = []
    @State private var isShowingBabyPicker = false
    
    var body: some View {
        Form {
            Section("阿贝贝") {
                HStack {
                    if let selectedBaby = selectedBaby {
                        HStack {
                            if let photoData = selectedBaby.photo, let uiImage = UIImage(data: photoData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fill)
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "heart.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                                    .padding(10)
                                    .background(Color.pink.opacity(0.2))
                                    .clipShape(Circle())
                            }
                            
                            Text(selectedBaby.name)
                                .font(.headline)
                        }
                    } else {
                        Text("选择阿贝贝")
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        isShowingBabyPicker = true
                    }) {
                        Text(selectedBaby == nil ? "选择" : "更改")
                    }
                }
            }
            
            Section("瞬间标题") {
                TextField("输入标题", text: $title)
            }
            
            Section("日期") {
                DatePicker("选择日期", selection: $date, displayedComponents: [.date])
                    .datePickerStyle(.compact)
            }
            
            Section("瞬间内容") {
                TextEditor(text: $content)
                    .frame(minHeight: 100)
            }
            
            Section("照片") {
                PhotosPicker(
                    selection: $selectedItems,
                    matching: .images,
                    photoLibrary: .shared()) {
                        Label("选择照片", systemImage: "photo.on.rectangle.angled")
                    }
                
                if !selectedPhotosData.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(0..<selectedPhotosData.count, id: \.self) { index in
                                if let uiImage = UIImage(data: selectedPhotosData[index]) {
                                    ZStack(alignment: .topTrailing) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .aspectRatio(1, contentMode: .fill)
                                            .frame(width: 100, height: 100)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                        
                                        Button(action: {
                                            selectedPhotosData.remove(at: index)
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.white)
                                                .background(Color.black.opacity(0.7))
                                                .clipShape(Circle())
                                                .padding(4)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
            }
        }
        .navigationTitle("记录生活瞬间")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("取消") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("保存") {
                    saveMoment()
                }
                .disabled(selectedBaby == nil || title.isEmpty)
            }
        }
        .onAppear {
            // 如果传入了特定的阿贝贝，则默认选择该阿贝贝
            if let baby = baby {
                selectedBaby = baby
            } else if let firstBaby = allBabies.first {
                // 如果没有传入特定的阿贝贝，但有阿贝贝存在，则默认选择第一个
                selectedBaby = firstBaby
            }
        }
        .onChange(of: selectedItems) { _, newItems in
            Task {
                for item in newItems {
                    if let data = try? await item.loadTransferable(type: Data.self) {
                        await MainActor.run {
                            selectedPhotosData.append(data)
                        }
                    }
                }
                // 清空选择器状态，以便下次选择
                await MainActor.run {
                    selectedItems = []
                }
            }
        }
        .sheet(isPresented: $isShowingBabyPicker) {
            NavigationStack {
                List(allBabies) { baby in
                    Button(action: {
                        selectedBaby = baby
                        isShowingBabyPicker = false
                    }) {
                        HStack {
                            if let photoData = baby.photo, let uiImage = UIImage(data: photoData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fill)
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "heart.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                                    .padding(10)
                                    .background(Color.pink.opacity(0.2))
                                    .clipShape(Circle())
                            }
                            
                            Text(baby.name)
                                .font(.headline)
                            
                            Spacer()
                            
                            if selectedBaby?.id == baby.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                .navigationTitle("选择阿贝贝")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("取消") {
                            isShowingBabyPicker = false
                        }
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }
    
    private func saveMoment() {
        guard let selectedBaby = selectedBaby else { return }
        
        let moment = Moment(
            title: title,
            content: content,
            date: date,
            photos: selectedPhotosData.isEmpty ? nil : selectedPhotosData
        )
        
        // 设置关系
        moment.baby = selectedBaby
        
        // 添加到数据库
        modelContext.insert(moment)
        
        // 关闭视图
        dismiss()
    }
}

#Preview {
    NavigationStack {
        MomentEditView()
            .modelContainer(for: [Baby.self, Moment.self], inMemory: true)
    }
}