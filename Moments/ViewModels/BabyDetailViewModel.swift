//
//  BabyDetailViewModel.swift
//  Moments
//
//  Created by han han on 2025/8/24.
//

import SwiftUI
import SwiftData

@MainActor
class BabyDetailViewModel: ObservableObject {
    let baby: Baby
    
    @Published var isEditing = false
    @Published var isAddingMoment = false
    @Published var showDeleteConfirmation = false
    @Published var shouldDismiss = false
    @Published var errorMessage: String?
    
    init(baby: Baby) {
        self.baby = baby
    }
    
    func deleteBaby(modelContext: ModelContext) {
        // Delete the baby (related moments will be cascade deleted)
        modelContext.delete(baby)
        
        do {
            try modelContext.save()
            shouldDismiss = true
        } catch {
            errorMessage = NSLocalizedString("error_delete_failed", value: "删除失败", comment: "")
            print("Error deleting baby: \(error)")
        }
    }
}
