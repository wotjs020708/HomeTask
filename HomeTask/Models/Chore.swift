//
//  Chore.swift
//  HomeTask
//
//  Created by 어재선 on 3/22/26.
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class Chore {
    var title: String
    var category: ChoreCategory
    var isCompleted: Bool
    var completedAt: Date?
    var points: Int
    var dueDate: Date??
    var repeatInterval: RepeatInterval?
    var createdAt: Date
    
    init(
        title: String,
        category: ChoreCategory = .trash,
        points: Int = 10,
        dueDate: Date? = nil,
        repeatInterval: RepeatInterval? = nil
    ) {
        self.title = title
        self.category = category
        self.isCompleted = false
        self.completedAt = nil
        self.points = points
        self.dueDate = dueDate
        self.repeatInterval = repeatInterval
        self.createdAt = .now
    }
}


enum ChoreCategory: String, Codable, CaseIterable, Identifiable {
    case cleaning = "청소"
    case laundry = "빨래"
    case dishes = "설거지"
    case cooking = "요리"
    case trash = "분리수거"
    case other = "기타"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .cleaning: "sparkles"
        case .laundry: "washer.fill"
        case .dishes: "sink.fill"
        case .cooking: "frying.pan.fill"
        case .trash: "trash.fill"
        case .other: "ellipsis.circle.fill"
        }
    }
    
    var color: Color {
        switch self{
        case .cleaning:
            return .blue
        case .laundry:
            return .purple
        case .dishes:
            return .green
        case .cooking:
            return .orange
        case .trash:
            return .red
        case .other:
            return .gray
        }
    }    
}

enum RepeatInterval: String, Codable, CaseIterable, Identifiable {
    case daily = "매일"
    case weekly = "매주"
    case biweekly = "격주"
    case monthly = "매월"
    
    var id: String { rawValue }
}
