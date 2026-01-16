//
//  MomentDetailView.swift
//  Moments
//
//  Created by han han on 2025/8/24.
//

import SwiftUI
import SwiftData
import AVKit

struct MomentDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @AppStorage("isWipingData") private var isWipingData = false
    
    let moment: Moment
    @State private var isEditing = false
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        if isWipingData {
            ContentUnavailableView("数据已清理", systemImage: "trash", description: Text("该内容已被删除"))
        } else {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // 物品信息
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
                } else {
                    // 没有物品时只显示日期
                    HStack {
                        Text(moment.date, style: .date)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal)
                }
                
                // 内容
                Text(moment.content)
                    .font(.body)
                    .padding(.horizontal)
                
                if let items = moment.mediaItems, !items.isEmpty {
                    VStack(alignment: .leading) {
                        Text("照片")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        PhotoGallery(mediaItems: items)
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
    }
    
    private func deleteMoment() {
        modelContext.delete(moment)
        dismiss()
    }
}

struct PhotoGallery: View {
    let mediaItems: [MomentMedia]
    @State private var selectedPhotoIndex: Int? = nil
    @AppStorage("isWipingData") private var isWipingData = false
    
    var body: some View {
        if isWipingData {
            AppColors.clearColor
        } else {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width - 32
            let minItemWidth: CGFloat = 100
            let maxItemWidth: CGFloat = 150
            let spacing: CGFloat = 8
            
            let safeWidth = max(screenWidth, minItemWidth * 2 + spacing)
            let itemsPerRow = max(2, Int(safeWidth / (minItemWidth + spacing)))
            let rawItemWidth = (safeWidth - CGFloat(itemsPerRow - 1) * spacing) / CGFloat(itemsPerRow)
            let actualItemWidth = max(minItemWidth, rawItemWidth)
            let finalItemWidth = min(maxItemWidth, actualItemWidth)
            
            LazyVGrid(columns: Array(repeating: GridItem(.fixed(finalItemWidth), spacing: spacing), count: itemsPerRow), spacing: spacing) {
                ForEach(Array(mediaItems.enumerated()), id: \.element.id) { index, item in
                    if let uiImage = MediaStore.loadImage(from: item.thumbnailPath ?? item.originalPath, preferThumbnail: true) {
                        ZStack(alignment: .center) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(1, contentMode: .fill)
                            
                            if item.type == .video {
                                Image(systemName: "play.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .shadow(radius: 2)
                            } else if item.type == .livePhoto {
                                Image(systemName: "livephoto")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .shadow(radius: 2)
                                    .padding(4)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                            }
                        }
                        .frame(width: finalItemWidth, height: finalItemWidth)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .onTapGesture {
                            selectedPhotoIndex = index
                        }
                    }
                }
            }
        }
        .frame(height: calculateGridHeight())
        .padding(.horizontal)
        .navigationDestination(isPresented: Binding(get: { selectedPhotoIndex != nil }, set: { if !$0 { selectedPhotoIndex = nil } })) {
            if let index = selectedPhotoIndex {
                PhotoDetailView(mediaItems: mediaItems, initialIndex: index)
            }
        }
        }
    }
    
    private func calculateGridHeight() -> CGFloat {
        let itemsPerRow = 3
        let rows = ceil(Double(mediaItems.count) / Double(itemsPerRow))
        let itemHeight: CGFloat = 150
        let spacing: CGFloat = 8
        return CGFloat(rows) * itemHeight + CGFloat(max(0, rows - 1)) * spacing
    }
}

struct PhotoDetailView: View {
    let mediaItems: [MomentMedia]
    @State private var currentIndex: Int
    
    init(mediaItems: [MomentMedia], initialIndex: Int) {
        self.mediaItems = mediaItems
        _currentIndex = State(initialValue: initialIndex)
    }
    
    var body: some View {
        ZStack {
            AppColors.blackOverlay.edgesIgnoringSafeArea(.all)
            
            TabView(selection: $currentIndex) {
                ForEach(0..<mediaItems.count, id: \.self) { index in
                    let item = mediaItems[index]
                    if item.type == .video {
                        VideoPlayerItemView(url: MediaStore.videoURL(for: item.originalPath), isPlaying: currentIndex == index)
                            .tag(index)
                    } else if let uiImage = MediaStore.loadImage(from: item.originalPath) {
                        ZoomableScrollView(
                            onSwipeLeft: {
                                withAnimation {
                                    if currentIndex < mediaItems.count - 1 {
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
                        ) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }
                        .tag(index)
                    }
                }
            }
            .tabViewStyle(PageTabViewStyle())
            
            VStack {
                Spacer()
                
                Text("\(currentIndex + 1) / \(mediaItems.count)")
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Capsule().fill(AppColors.lightBlackOverlay))
            }
            .padding()
        }
        .navigationTitle("照片预览")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// 原生缩放滚动视图
struct ZoomableScrollView<Content: View>: UIViewRepresentable {
    private var content: Content
    private let onSwipeLeft: (() -> Void)?
    private let onSwipeRight: (() -> Void)?
    
    init(onSwipeLeft: (() -> Void)? = nil, onSwipeRight: (() -> Void)? = nil, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.onSwipeLeft = onSwipeLeft
        self.onSwipeRight = onSwipeRight
    }
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.maximumZoomScale = 5.0
        scrollView.minimumZoomScale = 1.0
        scrollView.bouncesZoom = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = UIColor.clear
        
        // 创建承载SwiftUI内容的视图控制器
        let hostedView = context.coordinator.hostingController.view!
        hostedView.translatesAutoresizingMaskIntoConstraints = true
        hostedView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hostedView.frame = scrollView.bounds
        hostedView.backgroundColor = UIColor.clear
        scrollView.addSubview(hostedView)
        
        // 添加滑动手势识别器
        let leftSwipeGesture = UISwipeGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleLeftSwipe))
        leftSwipeGesture.direction = .left
        leftSwipeGesture.delegate = context.coordinator
        scrollView.addGestureRecognizer(leftSwipeGesture)
        
        let rightSwipeGesture = UISwipeGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleRightSwipe))
        rightSwipeGesture.direction = .right
        rightSwipeGesture.delegate = context.coordinator
        scrollView.addGestureRecognizer(rightSwipeGesture)
        
        // 添加双击手势
        let doubleTapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        doubleTapGesture.delegate = context.coordinator
        scrollView.addGestureRecognizer(doubleTapGesture)
        
        return scrollView
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(hostingController: UIHostingController(rootView: self.content), onSwipeLeft: onSwipeLeft, onSwipeRight: onSwipeRight)
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        context.coordinator.hostingController.rootView = self.content
        assert(context.coordinator.hostingController.view.superview == uiView)
    }
    
    class Coordinator: NSObject, UIScrollViewDelegate, UIGestureRecognizerDelegate {
        var hostingController: UIHostingController<Content>
        private let onSwipeLeft: (() -> Void)?
        private let onSwipeRight: (() -> Void)?
        
        init(hostingController: UIHostingController<Content>, onSwipeLeft: (() -> Void)?, onSwipeRight: (() -> Void)?) {
            self.hostingController = hostingController
            self.onSwipeLeft = onSwipeLeft
            self.onSwipeRight = onSwipeRight
        }
        
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return hostingController.view
        }
        

        
        @objc func handleLeftSwipe() {
            // 只有在未缩放状态下才响应滑动
            if let scrollView = hostingController.view.superview as? UIScrollView,
               scrollView.zoomScale <= scrollView.minimumZoomScale {
                onSwipeLeft?()
            }
        }
        
        @objc func handleRightSwipe() {
            // 只有在未缩放状态下才响应滑动
            if let scrollView = hostingController.view.superview as? UIScrollView,
               scrollView.zoomScale <= scrollView.minimumZoomScale {
                onSwipeRight?()
            }
        }
        
        @objc func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
            guard let scrollView = hostingController.view.superview as? UIScrollView else { return }
            
            if scrollView.zoomScale > scrollView.minimumZoomScale {
                // 如果已经缩放，则重置到原始大小
                scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
            } else {
                // 如果未缩放，则放大到双击位置
                let location = gesture.location(in: hostingController.view)
                let zoomRect = zoomRectForScale(scrollView.maximumZoomScale / 2, center: location, scrollView: scrollView)
                scrollView.zoom(to: zoomRect, animated: true)
            }
        }
        
        private func zoomRectForScale(_ scale: CGFloat, center: CGPoint, scrollView: UIScrollView) -> CGRect {
            let size = CGSize(
                width: scrollView.frame.size.width / scale,
                height: scrollView.frame.size.height / scale
            )
            let origin = CGPoint(
                x: center.x - size.width / 2,
                y: center.y - size.height / 2
            )
            return CGRect(origin: origin, size: size)
        }
        
        // 手势识别器代理方法，允许同时识别多个手势
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return false
        }
        
        // 只有在未缩放状态下才允许滑动手势
        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            if gestureRecognizer is UISwipeGestureRecognizer {
                if let scrollView = hostingController.view.superview as? UIScrollView {
                    return scrollView.zoomScale <= scrollView.minimumZoomScale
                }
            }
            return true
        }
    }
}

#Preview {
    NavigationStack {
        MomentDetailView(moment: Moment(content: "示例内容", date: Date()))
    }
    .modelContainer(for: [Baby.self, Moment.self], inMemory: true)
}
