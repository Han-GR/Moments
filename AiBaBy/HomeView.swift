//
//  HomeView.swift
//  AiBaBy
//
//  Created by han han on 2025/8/24.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var babies: [Baby]
    @State private var searchText = ""
    @State private var isAddingNewBaby = false
    
    var filteredBabies: [Baby] {
        if searchText.isEmpty {
            return babies
        } else {
            return babies.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                if babies.isEmpty {
                    ContentUnavailableView("没有阿贝贝", systemImage: "heart.fill", description: Text("点击加号添加您的第一个阿贝贝"))
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 16) {
                            ForEach(filteredBabies) { baby in
                                NavigationLink(destination: BabyDetailView(baby: baby)) {
                                    BabyGridItem(baby: baby)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("我的阿贝贝")
            .searchable(text: $searchText, prompt: "搜索阿贝贝")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isAddingNewBaby = true }) {
                        Label("添加阿贝贝", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isAddingNewBaby) {
                NavigationStack {
                    BabyEditView()
                }
            }
        }
    }
}

struct BabyGridItem: View {
    let baby: Baby
    
    var body: some View {
        VStack {
            if let photoData = baby.photo, let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 150, height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .shadow(radius: 5)
            } else {
                Image(systemName: "heart.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .foregroundColor(.pink)
                    .frame(width: 150, height: 150)
                    .background(Color.pink.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .shadow(radius: 5)
            }
            
            Text(baby.name)
                .font(.headline)
                .foregroundColor(.primary)
                .lineLimit(1)
            
            if let birthDate = baby.birthDate {
                Text(birthDate, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.bottom, 5)
        .frame(width: 160)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [Baby.self, Moment.self], inMemory: true)
}