//
//  BabyDetailView.swift
//  Moments
//
//  Created by han han on 2025/8/24.
//

import SwiftUI
import SwiftData

struct BabyDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var viewModel: BabyDetailViewModel
    
    let baby: Baby
    
    init(baby: Baby) {
        self.baby = baby
        _viewModel = StateObject(wrappedValue: BabyDetailViewModel(baby: baby))
    }
    
    var moments: [Moment] {
        (baby.moments ?? []).sorted(by: { $0.date > $1.date })
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ZStack(alignment: .bottom) {
                    let headerHeight: CGFloat = 300
                    let iconSize: CGFloat = 100
                    let cornerRadius: CGFloat = 20
                    
                    if let path = baby.photoPath {
                        AsyncDiskImage(filename: path, preferThumbnail: false) {
                            Rectangle()
                                .fill(AppColors.pinkBackground)
                                .frame(height: headerHeight)
                                .frame(maxWidth: .infinity)
                                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                                .overlay(
                                    Image(systemName: "bubbles.and.sparkles")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: iconSize, height: iconSize)
                                        .foregroundColor(AppColors.primaryPink)
                                )
                                .padding(.horizontal)
                        }
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                        .padding(.horizontal)
                    } else {
                        Rectangle()
                            .fill(AppColors.pinkBackground)
                            .frame(height: headerHeight)
                            .frame(maxWidth: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                            .overlay(
                                Image(systemName: "bubbles.and.sparkles")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: iconSize, height: iconSize)
                                    .foregroundColor(AppColors.primaryPink)
                            )
                            .padding(.horizontal)
                    }
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text(baby.name)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            if let birthDate = baby.birthDate {
                                Text(birthDate, style: .date)
                                    .font(.headline)
                                    .foregroundColor(.white.opacity(0.9))
                            }
                        }
                        .padding()
                        
                        Spacer()
                    }
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [.black.opacity(0.7), .clear]),
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(.horizontal)
                }
                
                    // 笔记区域
                    VStack(alignment: .leading, spacing: 10) {
                    Text(
                        NSLocalizedString("section_notes", value: "笔记", comment: "")
                    )
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if baby.notes.isEmpty {
                        Text(NSLocalizedString("no_notes", value: "暂无笔记", comment: ""))
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                    } else {
                        Text(baby.notes)
                            .padding(.horizontal)
                    }
                }
                
                    // 生活瞬间区域
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                        Text(NSLocalizedString("moments_section_title", value: "生活瞬间", comment: ""))
                            .font(.headline)
                        
                        Spacer()
                        
                        Button(action: { viewModel.isAddingMoment = true }) {
                            Label(
                                NSLocalizedString("action_add_moment", value: "添加瞬间", comment: ""),
                                systemImage: "plus"
                            )
                                .font(.caption)
                        }
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.capsule)
                    }
                    .padding(.horizontal)
                    
                    // 瞬间数量提示和跳转按钮
                    NavigationLink(destination: MomentsView(selectedBaby: baby)) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(String(format: NSLocalizedString("moments_count_format", value: "共有 %d 条瞬间", comment: ""), moments.count))
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                
                                Text(
                                    NSLocalizedString(
                                        "tap_to_view_all_moments",
                                        value: "点击查看所有瞬间",
                                        comment: ""
                                    )
                                )
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.bottom, 30)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                     Button(action: {
                         viewModel.isEditing = true
                     }) {
                         Label(
                             NSLocalizedString("action_edit", value: "编辑", comment: ""),
                             systemImage: "pencil"
                         )
                     }
                     
                     Button(role: .destructive, action: {
                         viewModel.showDeleteConfirmation = true
                     }) {
                         Label(
                             NSLocalizedString("action_delete", value: "删除", comment: ""),
                             systemImage: "trash"
                         )
                     }
                 } label: {
                     Image(systemName: "ellipsis.circle")
                 }
            }
        }
        .sheet(isPresented: $viewModel.isEditing) {
            NavigationStack {
                BabyEditView(baby: baby)
            }
        }
        .sheet(isPresented: $viewModel.isAddingMoment) {
            NavigationStack {
                MomentEditView(baby: baby)
            }
        }
        .alert(
            NSLocalizedString("title_delete_item", value: "删除物品", comment: ""),
            isPresented: $viewModel.showDeleteConfirmation
        ) {
             Button(
                NSLocalizedString("action_cancel", value: "取消", comment: ""),
                role: .cancel
             ) { }
             Button(
                NSLocalizedString("action_delete", value: "删除", comment: ""),
                role: .destructive
             ) {
                 viewModel.deleteBaby(modelContext: modelContext)
             }
         } message: {
             Text(String(format: NSLocalizedString("delete_baby_confirmation", value: "确定要删除 %@ 吗？此操作无法撤销。", comment: ""), baby.name))
         }
         .onChange(of: viewModel.shouldDismiss) { _, shouldDismiss in
             if shouldDismiss {
                 dismiss()
             }
         }
         .alert(isPresented: Binding<Bool>(
             get: { viewModel.errorMessage != nil },
             set: { if !$0 { viewModel.errorMessage = nil } }
         )) {
             Alert(
                 title: Text(NSLocalizedString("error_title", value: "错误", comment: "")),
                 message: Text(viewModel.errorMessage ?? ""),
                 dismissButton: .default(Text("OK"))
             )
         }
     }
 }



#Preview {
    // 使用包装视图来处理异常
    PreviewWrapper()
}

struct PreviewWrapper: View {
    var body: some View {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: Baby.self, Moment.self, configurations: config)
            
            let sampleBaby = Baby(name: "小可爱", birthDate: Date(), notes: "这是一个测试笔记")
            container.mainContext.insert(sampleBaby)
            
            let moment1 = Moment(content: "今天第一次见到小可爱，非常开心！")
            moment1.baby = sampleBaby
            container.mainContext.insert(moment1)
            
            return AnyView(NavigationStack {
                BabyDetailView(baby: sampleBaby)
            }
            .modelContainer(container))
        } catch {
            return AnyView(Text("Failed to create preview: \(error.localizedDescription)"))
        }
    }
}
