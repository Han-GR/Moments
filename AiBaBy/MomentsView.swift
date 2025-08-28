//
//  MomentsView.swift
//  AiBaBy
//
//  Created by han han on 2025/8/24.
//

import SwiftUI
import SwiftData

struct MomentsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var babies: [Baby]
    @State private var selectedBaby: Baby? = nil
    @State private var isAddingMoment = false
    
    var moments: [Moment] {
        if let selectedBaby = selectedBaby, let moments = selectedBaby.moments {
            return moments.sorted(by: { $0.date > $1.date })
        } else {
            // 获取所有阿贝贝的所有瞬间，并按日期排序
            var allMoments: [Moment] = []
            for baby in babies {
                if let moments = baby.moments {
                    allMoments.append(contentsOf: moments)
                }
            }
            return allMoments.sorted(by: { $0.date > $1.date })
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // 阿贝贝选择器
                if !babies.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            Button(action: { selectedBaby = nil }) {
                                VStack {
                                    Image(systemName: "rectangle.grid.2x2.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 30, height: 30)
                                        .padding(10)
                                        .background(selectedBaby == nil ? Color.blue : Color.gray.opacity(0.3))
                                        .clipShape(Circle())
                                        .foregroundColor(.white)
                                    
                                    Text("全部")
                                        .font(.caption)
                                }
                            }
                            
                            ForEach(babies) { baby in
                                Button(action: { selectedBaby = baby }) {
                                    VStack {
                                        if let photoData = baby.photo, let uiImage = UIImage(data: photoData) {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .aspectRatio(1, contentMode: .fill)
                                                .frame(width: 50, height: 50)
                                                .clipShape(Circle())
                                                .overlay(
                                                    Circle()
                                                        .stroke(selectedBaby?.id == baby.id ? Color.blue : Color.clear, lineWidth: 3)
                                                )
                                        } else {
                                            Image(systemName: "bubbles.and.sparkles")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 25, height: 25)
                                                .padding(12.5)
                                                .background(Color.pink.opacity(0.2))
                                                .clipShape(Circle())
                                                .overlay(
                                                    Circle()
                                                        .stroke(selectedBaby?.id == baby.id ? Color.blue : Color.clear, lineWidth: 3)
                                                )
                                        }
                                        
                                        Text(baby.name)
                                            .font(.caption)
                                            .lineLimit(1)
                                    }
                                    .frame(width: 60)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 10)
                    .background(Color(.secondarySystemBackground))
                }
                
                if moments.isEmpty {
                    ContentUnavailableView("暂无生活瞬间", systemImage: "book.closed", description: Text("点击添加按钮记录阿贝贝的生活点滴"))
                } else {
                    List {
                        ForEach(moments) { moment in
                            NavigationLink(destination: MomentDetailView(moment: moment)) {
                                MomentListItem(moment: moment)
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
                        if babies.isEmpty {
                            // 如果没有阿贝贝，提示用户先添加阿贝贝
                        } else {
                            isAddingMoment = true
                        }
                    }) {
                        Label("添加瞬间", systemImage: "plus")
                    }
                    .disabled(babies.isEmpty)
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
                // 阿贝贝头像
                if let baby = moment.baby {
                    if let photoData = baby.photo, let uiImage = UIImage(data: photoData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(1, contentMode: .fill)
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "bubbles.and.sparkles")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                            .padding(10)
                            .background(Color.pink.opacity(0.2))
                            .clipShape(Circle())
                    }
                }
                
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
                                    .fill(Color.gray.opacity(0.2))
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