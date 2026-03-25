//
//  ChoreView.swift
//  HomeTask
//
//  Created by 어재선 on 3/24/26.
//

import SwiftUI

struct ChoreView: View {
    @State var chores: [Chore] = Chore.mockData
    
    var completedCount: Int {
        chores.filter(\.isCompleted).count
    }
    var totalCount: Int {
        chores.count
    }

    var body: some View {
        NavigationStack {
            List {
            
                if totalCount > 0 {
                    ProgressView(value: Double(completedCount),
                                 total: Double(totalCount)) {
                    } currentValueLabel: {
                        HStack {
                            Spacer()
                            Text("\(completedCount)/\(totalCount) 완료")
                        }
                    }
                    .tint(.green)
                    .listRowSeparator(.hidden)
                }
                
                Section("미완료"){
                    ForEach(chores, id: \.id) { chore in
                        if chore.isCompleted {
                            ChoreListView(chore: chore)
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        
                                    } label: {
                                        Label("삭제", systemImage: "trash")
                                    }
                                }
                                .swipeActions(edge: .leading) {
                                    Button {
                                        
                                    } label: {
                                        Label("완료", systemImage: "checkmark").tint(.green)
                                    }
                                }
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 7, leading: 14, bottom: 7, trailing: 14))
                            
                        }
                    }
                }
                Section("완료") {
                    ForEach(chores, id: \.id) { chore in
                        if !chore.isCompleted {
                            ChoreListView(chore: chore)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 7, leading: 14, bottom: 7, trailing: 14))
                            
                        }
                    }
                }
            }
            .listStyle(.plain)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        // 추가 화면 열기
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
    }
}



struct ChoreListView: View{
    let chore: Chore
    
    init(chore: Chore) {
        self.chore = chore
    }
    
    var body: some View {
        HStack(spacing: 12) {
            if chore.isCompleted {
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
                    .strikethrough(!chore.isCompleted)
                    .foregroundStyle(chore.isCompleted ? .textPrimary : .textTertiary)
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
        }
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(.htSeparator, lineWidth: 0.5)
        }
        .opacity(chore.isCompleted ? 1 : 0.5)
        
    }
}


#Preview {
    
    ChoreView()
    
}
