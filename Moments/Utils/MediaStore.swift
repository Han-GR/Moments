import Foundation
import UIKit

struct MediaStore {
    static func imagesDirectoryURL() -> URL {
        let base = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dir = base.appendingPathComponent("Images", isDirectory: true)
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }
    
    static func deleteAllImages() {
        let dir = imagesDirectoryURL()
        if FileManager.default.fileExists(atPath: dir.path) {
            do {
                let contents = try FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil)
                for url in contents {
                    try? FileManager.default.removeItem(at: url)
                }
            } catch {
                // ignore
            }
        }
    }

    static func saveImage(_ image: UIImage, filename: String? = nil, quality: CGFloat = 0.85) -> String? {
        let name = filename ?? "\(UUID().uuidString).jpg"
        let url = imagesDirectoryURL().appendingPathComponent(name)
        guard let data = image.jpegData(compressionQuality: quality) else { return nil }
        do {
            try data.write(to: url)
            return name
        } catch {
            return nil
        }
    }
    
    static func saveThumbnail(of image: UIImage, basedOn originalFilename: String, maxDimension: CGFloat = 300) -> String? {
        let ratio = max(image.size.width, image.size.height) / maxDimension
        let targetSize = ratio > 1 ? CGSize(width: image.size.width / ratio, height: image.size.height / ratio) : image.size
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 0.0)
        image.draw(in: CGRect(origin: .zero, size: targetSize))
        let resized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let resized = resized else { return nil }
        let thumbName = thumbnailName(for: originalFilename)
        return saveImage(resized, filename: thumbName, quality: 0.8)
    }
    
    static func loadImage(from filename: String, preferThumbnail: Bool = false) -> UIImage? {
        let url = imagesDirectoryURL().appendingPathComponent(filename)
        if preferThumbnail {
            let thumbName = thumbnailName(for: filename)
            let thumbURL = imagesDirectoryURL().appendingPathComponent(thumbName)
            if FileManager.default.fileExists(atPath: thumbURL.path), let data = try? Data(contentsOf: thumbURL) {
                return UIImage(data: data)
            }
        }
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }
    
    static func thumbnailName(for filename: String) -> String {
        if filename.hasSuffix(".jpg") {
            return filename.replacingOccurrences(of: ".jpg", with: "_thumb.jpg")
        } else if filename.hasSuffix(".jpeg") {
            return filename.replacingOccurrences(of: ".jpeg", with: "_thumb.jpg")
        } else if filename.hasSuffix(".png") {
            return filename.replacingOccurrences(of: ".png", with: "_thumb.jpg")
        } else {
            return "\(filename)_thumb"
        }
    }
}
