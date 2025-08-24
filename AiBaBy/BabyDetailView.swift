//
//  BabyDetailView.swift
//  AiBaBy
//
//  Created by han han on 2025/8/24.
//

import SwiftUI
import SwiftData

struct BabyDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var isEditing = false
    @State private var isAddingMoment = false
    let baby: Baby
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 头部照片区域
                ZStack(alignment: .bottom) {
                    if let photoData = baby.photo, let uiImage = UIImage(data: photoData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 300)
                            .frame(maxWidth: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .padding(.horizontal)
                    } else {
                        Rectangle()
                            .fill(Color.pink.opacity(0.2))
                            .frame(height: 300)
                            .frame(maxWidth: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .overlay(
                                Image(systemName: "heart.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.pink)
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
                    
                    if let moments = baby.moments, !moments.isEmpty {
                        ForEach(moments.sorted(by: { $0.date > $1.date })) { moment in
                            NavigationLink(destination: MomentDetailView(moment: moment)) {
                                MomentRow(moment: moment)
                            }
                            .buttonStyle(.plain)
                        }
                    } else {
                        ContentUnavailableView("暂无生活瞬间", systemImage: "book.closed", description: Text("点击添加按钮记录阿贝贝的生活点滴"))
                            .frame(height: 200)
                    }
                }
            }
            .padding(.bottom, 30)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("编辑") {
                    isEditing = true
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
    }
}

struct MomentRow: View {
    let moment: Moment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(moment.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(moment.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(moment.content)
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            if let photos = moment.photos, !photos.isEmpty, let firstPhoto = photos.first, let uiImage = UIImage(data: firstPhoto) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 150)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        .padding(.horizontal)
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Baby.self, Moment.self, configurations: config)
        
        let sampleBaby = Baby(name: "小可爱", birthDate: Date(), notes: "这是一个测试笔记")
        container.mainContext.insert(sampleBaby)
        
        let moment1 = Moment(title: "第一次见面", content: "今天第一次见到小可爱，非常开心！")
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