//
//  BabyModel.swift
//  Moments
//
//  Created by han han on 2025/8/24.
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class Baby {
    var id: UUID
    var name: String
    var birthDate: Date?
    var photoPath: String?
    var createdAt: Date
    var notes: String
    
    @Relationship var moments: [Moment]? = []
    @Relationship(inverse: \Group.babies) var group: Group?
    
    init(name: String, birthDate: Date? = nil, photoPath: String? = nil, notes: String = "") {
        self.id = UUID()
        self.name = name
        self.birthDate = birthDate
        self.photoPath = photoPath
        self.createdAt = Date()
        self.notes = notes
        self.moments = []
    }
}

@Model
final class MomentMedia {
    enum MediaType: Int, Codable {
        case photo
        case video
        case livePhoto
    }
    
    var id: UUID
    var type: MediaType
    var originalPath: String
    var thumbnailPath: String?
    var duration: Double?
    
    @Relationship var moment: Moment?
    
    init(type: MediaType,
         originalPath: String,
         thumbnailPath: String? = nil,
         duration: Double? = nil) {
        self.id = UUID()
        self.type = type
        self.originalPath = originalPath
        self.thumbnailPath = thumbnailPath
        self.duration = duration
    }
}

@Model
final class Moment {
    var id: UUID
    var content: String
    var date: Date
    
    @Relationship(inverse: \Baby.moments) var baby: Baby?
    @Relationship(inverse: \MomentMedia.moment) var mediaItems: [MomentMedia]? = []
    
    init(content: String, date: Date = Date()) {
        self.id = UUID()
        self.content = content
        self.date = date
        self.mediaItems = []
    }
}

@Model
final class Group {
    var id: UUID
    var name: String
    var color: String // 存储颜色的十六进制字符串
    var createdAt: Date
    
    @Relationship var babies: [Baby]? = []
    
    init(name: String, color: String = "#FF69B4") {
        self.id = UUID()
        self.name = name
        self.color = color
        self.createdAt = Date()
        self.babies = []
    }
    
    var displayColor: Color {
        Color(hex: color) ?? .pink
    }
}

// Color扩展，用于从十六进制字符串创建颜色
extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
