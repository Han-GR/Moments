import SwiftUI
import UIKit

struct PhotoPickerSheet: View {
    @Binding var selectedImages: [UIImage]
    @Binding var isPresented: Bool
    
    @State private var showingImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var showingCameraAlert = false
    
    var body: some View {
        AppColors.clearColor
            .confirmationDialog(
                NSLocalizedString("dialog_select_photo_title", value: "选择照片", comment: ""),
                isPresented: $isPresented,
            ) {
                Button(NSLocalizedString("action_take_photo", value: "拍照", comment: "")) {
                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                        sourceType = .camera
                        showingImagePicker = true
                    } else {
                        showingCameraAlert = true
                    }
                }
                
                Button(NSLocalizedString("action_choose_from_library", value: "从相册选择", comment: "")) {
                    sourceType = .photoLibrary
                    showingImagePicker = true
                }
                
                Button(NSLocalizedString("action_cancel", value: "取消", comment: ""), role: .cancel) {
                    isPresented = false
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(
                    selectedImages: $selectedImages,
                    sourceType: sourceType,
                    allowsMultipleSelection: sourceType == .photoLibrary
                )
            }
            .alert(NSLocalizedString("camera_unavailable_title", value: "相机不可用", comment: ""), isPresented: $showingCameraAlert) {
                Button(NSLocalizedString("action_ok", value: "确定", comment: ""), role: .cancel) { }
            } message: {
                Text(NSLocalizedString("camera_not_supported_message", value: "此设备不支持相机功能", comment: ""))
            }
    }
}

struct MediaPickerSheet: View {
    @Binding var selectedMedia: [PickerMediaItem]
    @Binding var isPresented: Bool
    
    @State private var showingImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var showingCameraAlert = false
    
    var body: some View {
        AppColors.clearColor
            .confirmationDialog(
                NSLocalizedString("dialog_select_photo_title", value: "选择照片", comment: ""),
                isPresented: $isPresented
            ) {
                Button(NSLocalizedString("action_take_photo", value: "拍照", comment: "")) {
                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                        sourceType = .camera
                        showingImagePicker = true
                    } else {
                        showingCameraAlert = true
                    }
                }
                
                Button(NSLocalizedString("action_choose_from_library", value: "从相册选择", comment: "")) {
                    sourceType = .photoLibrary
                    showingImagePicker = true
                }
                
                Button(NSLocalizedString("action_cancel", value: "取消", comment: ""), role: .cancel) {
                    isPresented = false
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(
                    selectedMedia: $selectedMedia,
                    sourceType: sourceType,
                    allowsMultipleSelection: sourceType == .photoLibrary
                )
            }
            .alert(NSLocalizedString("camera_unavailable_title", value: "相机不可用", comment: ""), isPresented: $showingCameraAlert) {
                Button(NSLocalizedString("action_ok", value: "确定", comment: ""), role: .cancel) { }
            } message: {
                Text(NSLocalizedString("camera_not_supported_message", value: "此设备不支持相机功能", comment: ""))
            }
    }
}

