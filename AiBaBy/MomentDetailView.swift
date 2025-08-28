//
//  MomentDetailView.swift
//  AiBaBy
//
//  Created by han han on 2025/8/24.
//

import SwiftUI
import SwiftData

struct MomentDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let moment: Moment
    @State private var isEditing = false
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // 阿贝贝信息
                if let baby = moment.baby {
                    NavigationLink(destination: BabyDetailView(baby: baby)) {
                        HStack {
                            if let photoData = baby.photo, let uiImage = UIImage(data: photoData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fill)
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "bubbles.and.sparkles")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 25, height: 25)
                                    .padding(12.5)
                                    .background(Color.pink.opacity(0.2))
                                    .clipShape(Circle())
                            }
                            
                            VStack(alignment: .leading) {
                                Text(baby.name)
                                    .font(.headline)
                                
                                Text(moment.date, style: .date)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal)
                }
                
                // 内容
                Text(moment.content)
                    .font(.body)
                    .padding(.horizontal)
                
                // 照片
                if let photos = moment.photos, !photos.isEmpty {
                    VStack(alignment: .leading) {
                        Text("照片")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        PhotoGallery(photos: photos)
                    }
                }
            }
            .padding(.vertical)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle("瞬间详情")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {
                        isEditing = true
                    }) {
                        Label("编辑", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive, action: {
                        showDeleteConfirmation = true
                    }) {
                        Label("删除", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            NavigationStack {
                MomentEditView(baby: moment.baby)
                    .onDisappear {
                        // 刷新视图
                    }
            }
        }
        .alert("确认删除", isPresented: $showDeleteConfirmation) {
            Button("取消", role: .cancel) { }
            Button("删除", role: .destructive) {
                deleteMoment()
            }
        } message: {
            Text("确定要删除这条生活瞬间吗？此操作无法撤销。")
        }
    }
    
    private func deleteMoment() {
        modelContext.delete(moment)
        dismiss()
    }
}

struct PhotoGallery: View {
    let photos: [Data]
    @State private var selectedPhotoIndex: Int? = nil
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100, maximum: 150), spacing: 8)], spacing: 8) {
            ForEach(0..<photos.count, id: \.self) { index in
                if let uiImage = UIImage(data: photos[index]) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(1, contentMode: .fill)
                        .frame(width: 120, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .onTapGesture {
                            selectedPhotoIndex = index
                        }
                }
            }
        }
        .padding(.horizontal)
        .sheet(isPresented: Binding(get: { selectedPhotoIndex != nil }, set: { if !$0 { selectedPhotoIndex = nil } })) {
            if let index = selectedPhotoIndex {
                PhotoDetailView(photos: photos, initialIndex: index)
            }
        }
    }
    
    struct PhotoDetail: Identifiable {
        let id = UUID()
        let index: Int
    }
}

struct PhotoDetailView: View {
    let photos: [Data]
    @State private var currentIndex: Int
    @Environment(\.dismiss) private var dismiss
    
    init(photos: [Data], initialIndex: Int) {
        self.photos = photos
        _currentIndex = State(initialValue: initialIndex)
    }
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            TabView(selection: $currentIndex) {
                ForEach(0..<photos.count, id: \.self) { index in
                    if let uiImage = UIImage(data: photos[index]) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .tag(index)
                            .pinchToZoom()
                    }
                }
            }
            .tabViewStyle(PageTabViewStyle())
            
            VStack {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .padding()
                            .background(Circle().fill(Color.black.opacity(0.5)))
                    }
                    
                    Spacer()
                }
                
                Spacer()
                
                Text("\(currentIndex + 1) / \(photos.count)")
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Capsule().fill(Color.black.opacity(0.5)))
            }
            .padding()
        }
    }
}

// 图片缩放功能
struct PinchToZoom: ViewModifier {
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .offset(offset)
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        let delta = value / lastScale
                        lastScale = value
                        scale = min(max(scale * delta, 1), 5)
                    }
                    .onEnded { _ in
                        lastScale = 1.0
                    }
            )
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if scale > 1 {
                            offset = CGSize(
                                width: lastOffset.width + value.translation.width,
                                height: lastOffset.height + value.translation.height
                            )
                        }
                    }
                    .onEnded { _ in
                        lastOffset = offset
                        if scale <= 1 {
                            withAnimation {
                                offset = .zero
                            }
                        }
                    }
            )
            .gesture(
                TapGesture(count: 2)
                    .onEnded {
                        withAnimation {
                            if scale > 1 {
                                scale = 1
                                offset = .zero
                                lastOffset = .zero
                            } else {
                                scale = 2
                            }
                        }
                    }
            )
    }
}

extension View {
    func pinchToZoom() -> some View {
        modifier(PinchToZoom())
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Baby.self, Moment.self, configurations: config)
    
    // 创建示例数据
    let baby = Baby(name: "小贝贝", birthDate: Date(), photo: nil, notes: "可爱的小贝贝")
    let moment = Moment(content: "今天小贝贝第一次对我笑了，真是太可爱了！", date: Date(), photos: nil)
    moment.baby = baby
    
    return NavigationStack {
        MomentDetailView(moment: moment)
            .modelContainer(container)
    }
}