import Foundation
import UIKit
import AVFoundation

struct MediaStore {
    // MARK: - Caching
    private static let imageCache = NSCache<NSString, UIImage>()
    
    // MARK: - Image Management
    static func imagesDirectoryURL() -> URL {
        let base = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dir = base.appendingPathComponent("Images", isDirectory: true)
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }
    
    // MARK: - Video Management
    static func videosDirectoryURL() -> URL {
        let base = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dir = base.appendingPathComponent("Videos", isDirectory: true)
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
        // 1. Check Cache
        let cacheKey = (preferThumbnail ? "thumb_" : "orig_") + filename
        if let cachedImage = imageCache.object(forKey: cacheKey as NSString) {
            return cachedImage
        }
        
        // 2. Load from disk
        var loadedImage: UIImage?
        
        let url = imagesDirectoryURL().appendingPathComponent(filename)
        
        if preferThumbnail {
            let thumbName = thumbnailName(for: filename)
            let thumbURL = imagesDirectoryURL().appendingPathComponent(thumbName)
            if FileManager.default.fileExists(atPath: thumbURL.path), 
               let data = try? Data(contentsOf: thumbURL),
               let image = UIImage(data: data) {
                loadedImage = image
            }
        }
        
        // Fallback to original if thumbnail not found or not requested
        if loadedImage == nil {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                loadedImage = image
            }
        }
        
        // 3. Cache and return
        if let image = loadedImage {
            imageCache.setObject(image, forKey: cacheKey as NSString)
            return image
        }
        
        return nil
    }
    
    static func thumbnailName(for filename: String) -> String {
        if filename.hasSuffix(".jpg") {
            return filename.replacingOccurrences(of: ".jpg", with: "_thumb.jpg")
        } else if filename.hasSuffix(".jpeg") {
            return filename.replacingOccurrences(of: ".jpeg", with: "_thumb.jpg")
        } else if filename.hasSuffix(".png") {
            return filename.replacingOccurrences(of: ".png", with: "_thumb.jpg")
        } else {
            return "\(filename)_thumb.jpg"
        }
    }
    
    // MARK: - Video Helpers
    
    static func saveVideo(from sourceURL: URL, filename: String? = nil) -> String? {
        let name = filename ?? "\(UUID().uuidString).mov"
        let destinationURL = videosDirectoryURL().appendingPathComponent(name)
        
        // If source is already there (unlikely but possible), return name
        if sourceURL == destinationURL { return name }
        
        do {
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
            return name
        } catch {
            print("Failed to save video: \(error)")
            return nil
        }
    }
    
    static func generateVideoThumbnail(for videoFilename: String) -> String? {
        let videoURL = videosDirectoryURL().appendingPathComponent(videoFilename)
        let asset = AVAsset(url: videoURL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        do {
            let time = CMTime(seconds: 0.0, preferredTimescale: 600) // First frame
            let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            let image = UIImage(cgImage: cgImage)
            
            // Generate thumbnail name using the same convention
            let thumbName = thumbnailName(for: videoFilename)
            // Save using existing image saving logic (which saves to Images directory)
            // Note: saveImage saves to Images directory, which is what we want for thumbnails
            return saveImage(image, filename: thumbName, quality: 0.6)
        } catch {
            print("Error generating thumbnail: \(error)")
            return nil
        }
    }
    
    static func deleteAllVideos() {
        let dir = videosDirectoryURL()
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
    
    static func videoURL(for filename: String) -> URL {
        return videosDirectoryURL().appendingPathComponent(filename)
    }
}
