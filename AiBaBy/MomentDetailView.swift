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
                            BabyAvatarView(baby: baby, size: 50)
                            
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
                MomentEditView(moment: moment)
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
        GeometryReader { geometry in
            let screenWidth = geometry.size.width - 32 // 减去左右padding
            let isIPad = UIDevice.current.userInterfaceIdiom == .pad
            let minItemWidth: CGFloat = isIPad ? 150 : 100
            let maxItemWidth: CGFloat = isIPad ? 200 : 150
            let spacing: CGFloat = isIPad ? 12 : 8
            
            // 计算每行可以放置的图片数量
            let itemsPerRow = max(2, Int(screenWidth / (minItemWidth + spacing)))
            let actualItemWidth = (screenWidth - CGFloat(itemsPerRow - 1) * spacing) / CGFloat(itemsPerRow)
            let finalItemWidth = min(maxItemWidth, actualItemWidth)
            
            LazyVGrid(columns: Array(repeating: GridItem(.fixed(finalItemWidth), spacing: spacing), count: itemsPerRow), spacing: spacing) {
                ForEach(0..<photos.count, id: \.self) { index in
                    if let uiImage = UIImage(data: photos[index]) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(1, contentMode: .fill)
                            .frame(width: finalItemWidth, height: finalItemWidth)
                            .clipShape(RoundedRectangle(cornerRadius: isIPad ? 12 : 8))
                            .onTapGesture {
                                selectedPhotoIndex = index
                            }
                    }
                }
            }
        }
        .frame(height: calculateGridHeight())
        .padding(.horizontal)
        .sheet(isPresented: Binding(get: { selectedPhotoIndex != nil }, set: { if !$0 { selectedPhotoIndex = nil } })) {
            if let index = selectedPhotoIndex {
                PhotoDetailView(photos: photos, initialIndex: index)
            }
        }
    }
    
    private func calculateGridHeight() -> CGFloat {
        let isIPad = UIDevice.current.userInterfaceIdiom == .pad
        let itemsPerRow = isIPad ? 4 : 3 // 估算值
        let rows = ceil(Double(photos.count) / Double(itemsPerRow))
        let itemHeight: CGFloat = isIPad ? 200 : 150
        let spacing: CGFloat = isIPad ? 12 : 8
        return CGFloat(rows) * itemHeight + CGFloat(max(0, rows - 1)) * spacing
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
            AppColors.blackOverlay.edgesIgnoringSafeArea(.all)
            
            TabView(selection: $currentIndex) {
                ForEach(0..<photos.count, id: \.self) { index in
                    if let uiImage = UIImage(data: photos[index]) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .tag(index)
                            .pinchToZoom(
                                onSwipeLeft: {
                                    withAnimation {
                                        if currentIndex < photos.count - 1 {
                                            currentIndex += 1
                                        }
                                    }
                                },
                                onSwipeRight: {
                                    withAnimation {
                                        if currentIndex > 0 {
                                            currentIndex -= 1
                                        }
                                    }
                                }
                            )
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
                            .background(Circle().fill(AppColors.lightBlackOverlay))
                    }
                    
                    Spacer()
                }
                
                Spacer()
                
                Text("\(currentIndex + 1) / \(photos.count)")
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Capsule().fill(AppColors.lightBlackOverlay))
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
    
    let onSwipeLeft: (() -> Void)?
    let onSwipeRight: (() -> Void)?
    
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
                    .onEnded { value in
                        lastOffset = offset
                        if scale <= 1 {
                            withAnimation {
                                offset = .zero
                            }
                            
                            // 检测水平滑动手势
                            let horizontalDistance = abs(value.translation.width)
                            let verticalDistance = abs(value.translation.height)
                            
                            // 如果水平滑动距离大于垂直滑动距离且超过阈值，则触发图片切换
                            if horizontalDistance > verticalDistance && horizontalDistance > 50 {
                                if value.translation.width > 0 {
                                    // 向右滑动，显示上一张图片
                                    onSwipeRight?()
                                } else {
                                    // 向左滑动，显示下一张图片
                                    onSwipeLeft?()
                                }
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
    func pinchToZoom(onSwipeLeft: (() -> Void)? = nil, onSwipeRight: (() -> Void)? = nil) -> some View {
        modifier(PinchToZoom(onSwipeLeft: onSwipeLeft, onSwipeRight: onSwipeRight))
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