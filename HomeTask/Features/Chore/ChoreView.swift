//
//  ChoreView.swift
//  HomeTask
//
//  Created by 어재선 on 3/24/26.
//

import SwiftUI
import SwiftData

struct ChoreView: View {
    @Query(sort: \Chore.createdAt, order: .reverse)
    var chores: [Chore]
    
    @Environment(HomeTaskModel.self) private var model
    @State private var showingSeet: Bool = false
    var completedChores: [Chore] {
        chores.filter(\.isCompleted)
    }
    var incompleteChores: [Chore] {
        chores.filter { !$0.isCompleted }
    }
    
    var body: some View {
        NavigationStack {
            List {
                if !chores.isEmpty {
                    ProgressView(value: Double(completedChores.count),
                                 total: Double(chores.count)) {
                    } currentValueLabel: {
                        HStack {
                            Spacer()
                            Text("\(completedChores.count)/\(chores.count) 완료")
                        }
                    }
                    .tint(.green)
                    .animation(.smooth, value: completedChores.count)
                    .listRowSeparator(.hidden)
                }
                
                Section("미완료"){
                    ForEach(incompleteChores) { chore in
                        ChoreListView(chore: chore)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    model.deleteChore(chore)
                                } label: {
                                    Label("삭제", systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .leading) {
                                Button {
                                    model.completeChore(chore)
                                } label: {
                                    Label("완료", systemImage: "checkmark").tint(.green)
                                }
                            }
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 7, leading: 14, bottom: 7, trailing: 14))
                    }
                }
                Section("완료") {
                    ForEach(completedChores) { chore in
                        ChoreListView(chore: chore)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    model.deleteChore(chore)
                                } label: {
                                    Label("삭제", systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .leading) {
                                Button {
                                    model.uncompleteChore(chore)
                                } label: {
                                    Label("취소", systemImage: "arrow.uturn.backward")
                                        .tint(.orange)
                                }
                            }
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 7, leading: 14, bottom: 7, trailing: 14))
                    }
                }
            }
            .listStyle(.plain)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingSeet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .scrollIndicators(.hidden)
            .navigationTitle("집안일")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingSeet) {
            AddChoreView()
        }
    }
}



struct ChoreListView: View{
    let chore: Chore
    
    init(chore: Chore) {
        self.chore = chore
    }
    
    var body: some View {
        HStack(spacing: 12) {
            if !chore.isCompleted {
                Image(systemName: "circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(.htSeparator)
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(.green)
                
            }
            
            
            ZStack(alignment: .center) {
                RoundedRectangle(cornerRadius: 8)
                    .frame(width: 36, height: 36)
                    .foregroundStyle(chore.category.color.opacity(0.1))
                Image(systemName: chore.category.icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
                    .foregroundStyle(chore.category.color)
                
            }
            VStack(alignment: .leading, spacing: 0){
                
                Text(chore.title)
                    .font(.headline)
                    .strikethrough(chore.isCompleted)
                    .foregroundStyle(chore.isCompleted ?  .textTertiary: .textPrimary)
                    .lineLimit(1)
                HStack(alignment: .center,spacing: 4) {
                    if chore.repeatInterval != nil {
                        Image(systemName: "arrow.clockwise")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 8)
                            .foregroundStyle(.textSecondary)
                    }
                    Text(chore.repeatInterval?.rawValue ?? "기한 없음")
                        .foregroundStyle(.textSecondary)
                        .font(.caption2)
                }
                
            }
            Spacer()
            
        }
        .padding(14)
        .background{
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(.backgroundPrimary)
                .shadow(color: .gray.opacity(0.3), radius: 5, x:0, y: 2)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(.htSeparator, lineWidth: 0.5)
        }
        .opacity(chore.isCompleted ? 0.5 : 1)
        
    }
}


#Preview {
    ChoreView()
        .environment(HomeTaskModel(modelContext: PreviewContainer.context))
        .modelContainer(PreviewContainer.container)
}
