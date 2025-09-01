//
//  MomentsView.swift
//  Moments
//
//  Created by han han on 2025/8/24.
//

import SwiftUI
import SwiftData

struct MomentsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var babies: [Baby]
    @Query private var allMoments: [Moment]
    @State private var selectedBaby: Baby?
    @State private var isAddingMoment = false
    
    init(selectedBaby: Baby? = nil) {
        self._selectedBaby = State(initialValue: selectedBaby)
    }
    
    private func deleteMoment(_ moment: Moment) {
        modelContext.delete(moment)
        try? modelContext.save()
    }
    
    var moments: [Moment] {
        if let selectedBaby = selectedBaby {
            if selectedBaby.id.uuidString == "00000000-0000-0000-0000-000000000000" {
                // 显示自由瞬间
                return allMoments.filter { $0.baby == nil }.sorted(by: { $0.date > $1.date })
            } else if let moments = selectedBaby.moments {
                return moments.sorted(by: { $0.date > $1.date })
            } else {
                return []
            }
        } else {
            // 获取所有瞬间，包括没有绑定物品的瞬间，并按日期排序
            return allMoments.sorted(by: { $0.date > $1.date })
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // 物品选择器
                if !babies.isEmpty {
                    ScrollViewReader { proxy in
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                Button(action: { selectedBaby = nil }) {
                                    VStack {
                                        Image(systemName: "rectangle.grid.2x2.fill")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 30, height: 30)
                                            .padding(10)
                                            .background(selectedBaby == nil ? AppColors.selectedBlue : AppColors.lightGrayBackground)
                                            .clipShape(Circle())
                                            .foregroundColor(.white)
                                        
                                        Text("全部")
                                            .font(.caption)
                                    }
                                }
                                .id("all")
                                
                                // 自由瞬间选项
                                Button(action: { 
                                    let unboundBaby = Baby(name: "自由瞬间", birthDate: nil, notes: "")
                                    unboundBaby.id = UUID(uuidString: "00000000-0000-0000-0000-000000000000") ?? UUID()
                                    selectedBaby = unboundBaby
                                }) {
                                    VStack {
                                        Image(systemName: "bubbles.and.sparkles")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 30, height: 30)
                                            .padding(10)
                                            .background(selectedBaby?.id.uuidString == "00000000-0000-0000-0000-000000000000" ? AppColors.selectedBlue : AppColors.lightGrayBackground)
                                            .clipShape(Circle())
                                            .foregroundColor(.white)
                                        
                                        Text("自由瞬间")
                                            .font(.caption)
                                    }
                                }
                                .id("unbound")
                                
                                ForEach(babies) { baby in
                                    Button(action: { selectedBaby = baby }) {
                                        VStack {
                                            BabyAvatarView.large(
                                                baby: baby,
                                                showBorder: true,
                                                borderColor: selectedBaby?.id == baby.id ? AppColors.selectedBlue : AppColors.strokeClear
                                            )
                                            
                                            Text(baby.name)
                                                .font(.caption)
                                                .lineLimit(1)
                                        }
                                        .frame(width: 60)
                                    }
                                    .id(baby.id)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .onAppear {
                            if let selectedBaby = selectedBaby {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    proxy.scrollTo(selectedBaby.id, anchor: .center)
                                }
                            }
                        }
                        .onChange(of: selectedBaby) { _, newValue in
                            if let newBaby = newValue {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    if newBaby.id.uuidString == "00000000-0000-0000-0000-000000000000" {
                                        proxy.scrollTo("unbound", anchor: .center)
                                    } else {
                                        proxy.scrollTo(newBaby.id, anchor: .center)
                                    }
                                }
                            } else {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    proxy.scrollTo("all", anchor: .center)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 10)
                    .background(Color(.secondarySystemBackground))
                }
                
                if moments.isEmpty {
                    ContentUnavailableView("暂无生活瞬间", systemImage: "book.closed", description: Text("点击添加按钮记录物品的生活点滴"))
                } else {
                    List {
                        ForEach(moments) { moment in
                            NavigationLink(destination: MomentDetailView(moment: moment)) {
                                MomentListItem(moment: moment)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button("删除", role: .destructive) {
                                    deleteMoment(moment)
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("生活瞬间")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isAddingMoment = true
                    }) {
                        Label("添加瞬间", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isAddingMoment) {
                NavigationStack {
                    MomentEditView(baby: selectedBaby)
                }
            }

        }
    }
}

struct MomentListItem: View {
    let moment: Moment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                // 物品头像
                BabyAvatarView.medium(baby: moment.baby)
                
                VStack(alignment: .leading, spacing: 4) {

                    if let baby = moment.baby {
                        Text(baby.name)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text(moment.date, style: .date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                    
                    
                    Text(moment.content)
                        .font(.body)
                        .lineLimit(2)
                        .padding(.top, 2)

                    // 照片预览
                    if let photos = moment.photos, !photos.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(0..<min(photos.count, 3), id: \.self) { index in
                                    if let uiImage = UIImage(data: photos[index]) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .aspectRatio(1, contentMode: .fill)
                                            .frame(width: 80, height: 80)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                        
                        if photos.count > 3 {
                            ZStack {
                                Rectangle()
                                    .fill(AppColors.grayBackground)
                                    .frame(width: 80, height: 80)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                
                                Text("+\(photos.count - 3)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .allowsHitTesting(false)
            }
                }
                .padding(.leading, 4)
            }
            
            
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    MomentsView()
        .modelContainer(for: [Baby.self, Moment.self], inMemory: true)
}