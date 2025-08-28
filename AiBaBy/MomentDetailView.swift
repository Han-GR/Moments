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
        .navigationDestination(isPresented: Binding(get: { selectedPhotoIndex != nil }, set: { if !$0 { selectedPhotoIndex = nil } })) {
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
}

struct PhotoDetailView: View {
    let photos: [Data]
    @State private var currentIndex: Int
    
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
                        ZoomableScrollView(
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
                
                Text("\(currentIndex + 1) / \(photos.count)")
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