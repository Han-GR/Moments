import SwiftUI

struct AsyncDiskImage<Placeholder: View>: View {
    let filename: String
    let preferThumbnail: Bool
    let contentMode: ContentMode
    let placeholder: () -> Placeholder
    
    @State private var image: UIImage?
    
    init(filename: String, preferThumbnail: Bool = true, contentMode: ContentMode = .fit, @ViewBuilder placeholder: @escaping () -> Placeholder) {
        self.filename = filename
        self.preferThumbnail = preferThumbnail
        self.contentMode = contentMode
        self.placeholder = placeholder
    }
    
    var body: some View {
        ZStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else {
                placeholder()
                    .task(id: filename) {
                        await loadImage()
                    }
            }
        }
    }
    
    private func loadImage() async {
        // Run on background thread to avoid blocking main thread
        let loadedImage = await Task.detached(priority: .userInitiated) {
            return MediaStore.loadImage(from: filename, preferThumbnail: preferThumbnail)
        }.value
        
        await MainActor.run {
            self.image = loadedImage
        }
    }
}
