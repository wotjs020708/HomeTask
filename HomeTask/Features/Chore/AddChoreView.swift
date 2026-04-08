//
//  AddChoreView.swift
//  HomeTask
//
//  Created by 어재선 on 3/25/26.
//

import SwiftUI

struct AddChoreView: View {
    @Environment(HomeTaskModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Form State
    
    @State private var title = ""
    @State private var category: ChoreCategory = .other
    @State private var points = 10
    @State private var hasDueDate = false
    @State private var dueDate: Date = .now
    @State private var hasRepeat = false
    @State private var repeatInterval: RepeatInterval = .weekly
    
    var body: some View {
        VStack {
            Form {
                titleSection
                categorySection
                pointsSection
                optionalSettingsSection
            }
            .navigationTitle("집안일 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        saveChore()
                    }
                    .fontWeight(.semibold)
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
    
    // MARK: - Sections
    
    private var titleSection: some View {
        Section {
            TextField("할 일을 입력하세요", text: $title)
        }
    }
    
    private var categorySection: some View {
        Section("카테고리") {
            CategoryChipGrid(selected: $category)
        }
    }
    
    private var pointsSection: some View {
        Section {
            Stepper("포인트: \(points)", value: $points, in: 1...100, step: 5)
        }
    }
    
    private var optionalSettingsSection: some View {
        Section("추가 설정") {
            Toggle("마감일 설정", isOn: $hasDueDate.animation())
            
            if hasDueDate {
                DatePicker(
                    "날짜",
                    selection: $dueDate,
                    in: Date.now...,
                    displayedComponents: .date
                )
            }
            
            Toggle("반복 설정", isOn: $hasRepeat.animation())
            
            if hasRepeat {
                RepeatIntervalPicker(selected: $repeatInterval)
            }
        }
    }
    
    // MARK: - Actions
    
    private func saveChore() {
        model.createChore(
            title: title.trimmingCharacters(in: .whitespaces),
            category: category,
            points: points,
            dueDate: hasDueDate ? dueDate : nil,
            repeatInterval: hasRepeat ? repeatInterval : nil
        )
        dismiss()
    }
}

// MARK: - 카테고리 칩 그리드

struct CategoryChipGrid: View {
    @Binding var selected: ChoreCategory
    
    private let columns = [
        GridItem(.adaptive(minimum: 80), spacing: 8)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(ChoreCategory.allCases) { category in
                CategoryChip(
                    category: category,
                    isSelected: selected == category
                )
                .onTapGesture { selected = category }
            }
        }
        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
    }
}

struct CategoryChip: View {
    let category: ChoreCategory
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: category.icon)
                .font(.caption)
            Text(category.rawValue)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(isSelected ? category.color.opacity(0.15) : Color(.systemGray6))
        .foregroundStyle(isSelected ? category.color : .secondary)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .strokeBorder(isSelected ? category.color.opacity(0.5) : Color.clear, lineWidth: 1)
        )
    }
}

// MARK: - 반복 주기 칩 Picker

struct RepeatIntervalPicker: View {
    @Binding var selected: RepeatInterval
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(RepeatInterval.allCases) { interval in
                Text(interval.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(selected == interval ? Color.accentColor.opacity(0.15) : Color(.systemGray6))
                    .foregroundStyle(selected == interval ? Color.accentColor : .secondary)
                    .clipShape(Capsule())
                    .onTapGesture { selected = interval }
            }
        }
        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
    }
}

