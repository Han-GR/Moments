//
//  Item.swift
//  AiBaBy
//
//  Created by han han on 2025/8/24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
