//
//  AppColors.swift
//  AiBaBy
//
//  Created by han han on 2025/8/24.
//

import SwiftUI

struct AppColors {
    // MARK: - Primary Colors
    static let primaryPink = Color.pink
    static let primaryBlue = Color.blue
    
    // MARK: - Background Colors
    static let pinkBackground = Color.pink.opacity(0.2)
    static let lightPinkBackground = Color.pink.opacity(0.1)
    static let grayBackground = Color.gray.opacity(0.2)
    static let lightGrayBackground = Color.gray.opacity(0.3)
    static let blackOverlay = Color.black.opacity(0.7)
    static let lightBlackOverlay = Color.black.opacity(0.5)
    
    // MARK: - Selection Colors
    static let selectedBlue = Color.blue
    static let unselectedGray = Color.gray.opacity(0.3)
    static let strokeClear = Color.clear
    
    // MARK: - System Colors
    static let primaryText = Color.primary
    static let secondaryText = Color.secondary
    static let clearColor = Color.clear
}

// MARK: - Color Extension for Group Colors
extension Color {
    static let appPink = AppColors.primaryPink
    static let appBlue = AppColors.primaryBlue
    static let appPinkBackground = AppColors.pinkBackground
    static let appLightPinkBackground = AppColors.lightPinkBackground
    static let appGrayBackground = AppColors.grayBackground
    static let appBlackOverlay = AppColors.blackOverlay
}