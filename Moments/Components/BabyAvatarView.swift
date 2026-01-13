//
//  BabyAvatarView.swift
//  Moments
//
//  Created by han han on 2025/8/24.
//

import SwiftUI
import UIKit
 

struct BabyAvatarView: View {
    let baby: Baby?
    let size: CGFloat
    let showBorder: Bool
    let borderColor: Color
    let borderWidth: CGFloat
    
    init(
        baby: Baby?,
        size: CGFloat = 40,
        showBorder: Bool = false,
        borderColor: Color = .blue,
        borderWidth: CGFloat = 3
    ) {
        self.baby = baby
        self.size = size
        self.showBorder = showBorder
        self.borderColor = borderColor
        self.borderWidth = borderWidth
    }
    
    var body: some View {
        ZStack {
            if let baby = baby {
                if let path = baby.photoPath, let uiImage = MediaStore.loadImage(from: path, preferThumbnail: true) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(1, contentMode: .fill)
                        .frame(width: size, height: size)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "bubbles.and.sparkles")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: size * 0.5, height: size * 0.5)
                        .padding(size * 0.25)
                        .background(AppColors.pinkBackground)
                        .clipShape(Circle())
                }
            } else {
                Circle()
                    .fill(AppColors.lightGrayBackground)
                    .frame(width: size, height: size)
                    .overlay(
                        Image(systemName: "bubbles.and.sparkles")
                            .foregroundColor(.secondary)
                            .font(.system(size: size * 0.4))
                    )
            }
        }
        .overlay(
            showBorder ? Circle().stroke(borderColor, lineWidth: borderWidth) : nil
        )
    }
}

// MARK: - Convenience Initializers
extension BabyAvatarView {
    /// 小尺寸头像 (30x30)
    static func small(baby: Baby?, showBorder: Bool = false, borderColor: Color = .blue) -> BabyAvatarView {
        BabyAvatarView(baby: baby, size: 30, showBorder: showBorder, borderColor: borderColor)
    }
    
    /// 中等尺寸头像 (40x40)
    static func medium(baby: Baby?, showBorder: Bool = false, borderColor: Color = .blue) -> BabyAvatarView {
        BabyAvatarView(baby: baby, size: 40, showBorder: showBorder, borderColor: borderColor)
    }
    
    /// 大尺寸头像 (50x50)
    static func large(baby: Baby?, showBorder: Bool = false, borderColor: Color = .blue) -> BabyAvatarView {
        BabyAvatarView(baby: baby, size: 50, showBorder: showBorder, borderColor: borderColor)
    }
    
    /// 超大尺寸头像 (80x80)
    static func extraLarge(baby: Baby?, showBorder: Bool = false, borderColor: Color = .blue) -> BabyAvatarView {
        BabyAvatarView(baby: baby, size: 80, showBorder: showBorder, borderColor: borderColor)
    }
}

#Preview {
    VStack(spacing: 20) {
        HStack(spacing: 20) {
            BabyAvatarView.small(baby: nil)
            BabyAvatarView.medium(baby: nil)
            BabyAvatarView.large(baby: nil)
            BabyAvatarView.extraLarge(baby: nil)
        }
        
        HStack(spacing: 20) {
            BabyAvatarView.small(baby: nil, showBorder: true)
            BabyAvatarView.medium(baby: nil, showBorder: true)
            BabyAvatarView.large(baby: nil, showBorder: true)
            BabyAvatarView.extraLarge(baby: nil, showBorder: true)
        }
    }
    .padding()
}
