//
//  MomentDetailViewModel.swift
//  Moments
//
//  Created by han han on 2025/8/24.
//

import SwiftUI
import SwiftData

@MainActor
class MomentDetailViewModel: ObservableObject {
    let moment: Moment
    
    @Published var isEditing = false
    @Published var showDeleteConfirmation = false
    @Published var shouldDismiss = false
    @Published var errorMessage: String?
    
    init(moment: Moment) {
        self.moment = moment
    }
    
    func deleteMoment(modelContext: ModelContext) {
        modelContext.delete(moment)
        
        do {
            try modelContext.save()
            shouldDismiss = true
        } catch {
            errorMessage = NSLocalizedString("error_delete_failed", value: "删除失败", comment: "")
            print("Error deleting moment: \(error)")
        }
    }
}
