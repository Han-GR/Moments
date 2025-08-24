//
//  BabyModel.swift
//  AiBaBy
//
//  Created by han han on 2025/8/24.
//

import Foundation
import SwiftData

@Model
final class Baby {
    var id: UUID
    var name: String
    var birthDate: Date?
    var photo: Data?
    var createdAt: Date
    var notes: String
    
    @Relationship var moments: [Moment]? = []
    
    init(name: String, birthDate: Date? = nil, photo: Data? = nil, notes: String = "") {
        self.id = UUID()
        self.name = name
        self.birthDate = birthDate
        self.photo = photo
        self.createdAt = Date()
        self.notes = notes
        self.moments = []
    }
}

@Model
final class Moment {
    var id: UUID
    var title: String
    var content: String
    var date: Date
    var photos: [Data]?
    
    @Relationship(inverse: \Baby.moments) var baby: Baby?
    
    init(title: String, content: String, date: Date = Date(), photos: [Data]? = nil) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.date = date
        self.photos = photos
    }
}