//
//  ImagePicker.swift
//  Moments
//
//  Created by han han on 2025/8/24.
//

import SwiftUI
import UIKit
import PhotosUI

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImages: [UIImage]
    @Environment(\.presentationMode) var presentationMode
    
    var sourceType: UIImagePickerController.SourceType
    var allowsMultipleSelection: Bool
    
    func makeUIViewController(context: Context) -> UIViewController {
        if sourceType == .camera {
            let picker = UIImagePickerController()
            picker.sourceType = sourceType
            picker.delegate = context.coordinator
            picker.allowsEditing = false
            picker.cameraFlashMode = .off  // 禁用闪光灯
            return picker
        } else {
            var config = PHPickerConfiguration()
            config.filter = .images
            config.selectionLimit = allowsMultipleSelection ? 0 : 1
            
            let picker = PHPickerViewController(configuration: config)
            picker.delegate = context.coordinator
            return picker
        }
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        // UIImagePickerController delegate (for camera)
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            var imageToSave: UIImage?
            
            if let editedImage = info[.editedImage] as? UIImage {
                parent.selectedImages.append(editedImage)
                imageToSave = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.selectedImages.append(originalImage)
                imageToSave = originalImage
            }
            
            // 保存照片到相册（仅当使用相机拍照时）
            if picker.sourceType == .camera, let image = imageToSave {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            }
            
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        // PHPickerViewController delegate (for photo library)
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.presentationMode.wrappedValue.dismiss()
            
            for result in results {
                result.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                    if let image = image as? UIImage {
                        DispatchQueue.main.async {
                            self.parent.selectedImages.append(image)
                        }
                    }
                }
            }
        }
    }
}

struct PhotoPickerSheet: View {
    @Binding var selectedImages: [UIImage]
    @Binding var isPresented: Bool
    
    @State private var showingImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var showingCameraAlert = false
    
    var body: some View {
        AppColors.clearColor
            .confirmationDialog("选择照片", isPresented: $isPresented, titleVisibility: .visible) {
                Button("拍照") {
                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                        sourceType = .camera
                        showingImagePicker = true
                    } else {
                        showingCameraAlert = true
                    }
                }
                
                Button("从相册选择") {
                    sourceType = .photoLibrary
                    showingImagePicker = true
                }
                
                Button("取消", role: .cancel) {
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
            .alert("相机不可用", isPresented: $showingCameraAlert) {
                Button("确定", role: .cancel) { }
            } message: {
                Text("此设备不支持相机功能")
            }
    }
}

#Preview {
    PhotoPickerSheet(
        selectedImages: .constant([]),
        isPresented: .constant(true)
    )
}