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
    @State private var isEditing = false
    @State private var isAddingMoment = false
    @State private var showDeleteConfirmation = false
    let baby: Baby
    

    @Query private var allMoments: [Moment]
    
    var moments: [Moment] {
        allMoments.filter { $0.baby?.id == baby.id }.sorted(by: { $0.date > $1.date })
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 头部照片区域
                ZStack(alignment: .bottom) {
                    let isIPad = UIDevice.current.userInterfaceIdiom == .pad
                    let headerHeight: CGFloat = isIPad ? 400 : 300
                    let iconSize: CGFloat = isIPad ? 140 : 100
                    let cornerRadius: CGFloat = isIPad ? 25 : 20
                    
                    if let photoData = baby.photo, let uiImage = UIImage(data: photoData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
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
                    Text("笔记")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if baby.notes.isEmpty {
                        Text("暂无笔记")
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
                        Text("生活瞬间")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button(action: { isAddingMoment = true }) {
                            Label("添加瞬间", systemImage: "plus")
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
                                Text("共有 \(moments.count) 条瞬间")
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                
                                Text("点击查看所有瞬间")
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
                         isEditing = true
                     }) {
                         Label("编辑", systemImage: "pencil")
                     }
                     
                     Button(role: .destructive, action: {
                         showDeleteConfirmation = true
                     }) {
                         Label("删除", systemImage: "trash")
                     }
                 } label: {
                     Image(systemName: "ellipsis.circle")
                 }
            }
        }
        .sheet(isPresented: $isEditing) {
            NavigationStack {
                BabyEditView(baby: baby)
            }
        }
        .sheet(isPresented: $isAddingMoment) {
            NavigationStack {
                MomentEditView(baby: baby)
            }
        }
        .alert("删除物品", isPresented: $showDeleteConfirmation) {
             Button("取消", role: .cancel) { }
             Button("删除", role: .destructive) {
                 deleteBaby()
             }
         } message: {
             Text("确定要删除 \(baby.name) 吗？此操作无法撤销。")
         }
     }
     
     private func deleteBaby() {
          // 删除与该物品相关的所有瞬间
          for moment in moments {
              modelContext.delete(moment)
          }
          
          // 删除物品
          modelContext.delete(baby)
          
          // 保存更改
          do {
              try modelContext.save()
              // 删除成功后返回上一页
              dismiss()
          } catch {
              print("删除物品时出错: \(error)")
          }
      }
 }



#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Baby.self, Moment.self, configurations: config)
        
        let sampleBaby = Baby(name: "小可爱", birthDate: Date(), notes: "这是一个测试笔记")
        container.mainContext.insert(sampleBaby)
        
        let moment1 = Moment(content: "今天第一次见到小可爱，非常开心！")
        moment1.baby = sampleBaby
        container.mainContext.insert(moment1)
        
        return NavigationStack {
            BabyDetailView(baby: sampleBaby)
        }
        .modelContainer(container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}