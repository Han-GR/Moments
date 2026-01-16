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
    @AppStorage("isWipingData") private var isWipingData = false
    @State private var searchText = ""
    
    init(selectedBaby: Baby? = nil) {
        self._selectedBaby = State(initialValue: selectedBaby)
    }
    
    private func deleteMoment(_ moment: Moment) {
        modelContext.delete(moment)
        try? modelContext.save()
    }
    
    var moments: [Moment] {
        if isWipingData { return [] }
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
    
    var filteredMoments: [Moment] {
        var result = moments
        if !searchText.isEmpty {
            let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            if !query.isEmpty {
                result = result.filter { m in
                    let contentHit = m.content.localizedCaseInsensitiveContains(query)
                    let babyHit = m.baby?.name.localizedCaseInsensitiveContains(query) ?? false
                    return contentHit || babyHit
                }
            }
        }
        return result
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if isWipingData {
                    ContentUnavailableView("正在清理数据", systemImage: "trash", description: Text("请稍候…"))
                } else {
                    if !babies.isEmpty {
                        BabySelectorView(babies: babies, selectedBaby: $selectedBaby)
                    }
                    
                    if moments.isEmpty {
                        ContentUnavailableView("", systemImage: "bubbles.and.sparkles", description: Text("点击加号添加您的第一个瞬间"))
                    } else if filteredMoments.isEmpty {
                        ContentUnavailableView("没有找到瞬间", systemImage: "magnifyingglass", description: Text("尝试调整搜索条件"))
                    } else {
                        List {
                            ForEach(filteredMoments) { moment in
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
            }
            .navigationTitle("瞬间")
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "搜索瞬间")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if !isWipingData {
                            isAddingMoment = true
                        }
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

struct BabySelectorView: View {
    let babies: [Baby]
    @Binding var selectedBaby: Baby?
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    Button(action: {
                        selectedBaby = nil
                    }) {
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
                        Button(action: {
                            selectedBaby = baby
                        }) {
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
}

struct MomentListItem: View {
    let moment: Moment
    @AppStorage("isWipingData") private var isWipingData = false
    
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

                    if !isWipingData, let items = moment.mediaItems, !items.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                let limited = Array(items.prefix(3))
                                ForEach(limited, id: \.id) { item in
                                    if let uiImage = MediaStore.loadImage(from: item.thumbnailPath ?? item.originalPath, preferThumbnail: true) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .aspectRatio(1, contentMode: .fill)
                                            .frame(width: 80, height: 80)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                        if let items = moment.mediaItems, items.count > 3 {
                            ZStack {
                                Rectangle()
                                    .fill(AppColors.grayBackground)
                                    .frame(width: 80, height: 80)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                
                                Text("+\(items.count - 3)")
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
