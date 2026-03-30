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
    var dueDate: Date?
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


// MARK: - Chore Mock Data

extension Chore {
    static let mockData: [Chore] = {
        let calendar = Calendar.current
        let now = Date.now
        
        // MARK: 미완료 - 오늘 마감
        let chore1 = Chore(
            title: "청소기 돌리기",
            category: .cleaning,
            points: 15,
            dueDate: now,
            repeatInterval: .weekly
        )
        
        let chore2 = Chore(
            title: "설거지",
            category: .dishes,
            points: 10,
            dueDate: now,
            repeatInterval: .daily
        )
        
        let chore3 = Chore(
            title: "분리수거 내놓기",
            category: .trash,
            points: 10,
            dueDate: now
        )
        
        // MARK: 미완료 - 내일 마감
        let chore4 = Chore(
            title: "빨래 돌리기",
            category: .laundry,
            points: 10,
            dueDate: calendar.date(byAdding: .day, value: 1, to: now),
            repeatInterval: .weekly
        )
        
        // MARK: 미완료 - 이번 주 내
        let chore5 = Chore(
            title: "화장실 청소",
            category: .cleaning,
            points: 20,
            dueDate: calendar.date(byAdding: .day, value: 3, to: now),
            repeatInterval: .weekly
        )
        
        let chore6 = Chore(
            title: "냉장고 정리",
            category: .other,
            points: 15,
            dueDate: calendar.date(byAdding: .day, value: 5, to: now),
            repeatInterval: .biweekly
        )
        
        // MARK: 미완료 - 마감 없음
        let chore7 = Chore(
            title: "에어컨 필터 청소",
            category: .cleaning,
            points: 25,
            dueDate: nil,
            repeatInterval: .monthly
        )
        
        let chore8 = Chore(
            title: "밀프렙 (닭가슴살 + 현미밥)",
            category: .cooking,
            points: 20
        )
        
        // MARK: 완료된 항목
        let chore9 = Chore(
            title: "침대 정리",
            category: .cleaning,
            points: 5,
            dueDate: now,
            repeatInterval: .daily
        )
        chore9.isCompleted = true
        chore9.completedAt = calendar.date(byAdding: .hour, value: -2, to: now)
        
        let chore10 = Chore(
            title: "빨래 개기",
            category: .laundry,
            points: 10,
            dueDate: now
        )
        chore10.isCompleted = true
        chore10.completedAt = calendar.date(byAdding: .hour, value: -5, to: now)
        
        let chore11 = Chore(
            title: "배수구 청소",
            category: .cleaning,
            points: 20,
            dueDate: calendar.date(byAdding: .day, value: -1, to: now),
            repeatInterval: .monthly
        )
        chore11.isCompleted = true
        chore11.completedAt = calendar.date(byAdding: .day, value: -1, to: now)
        
        // MARK: 미완료 - 마감 지남 (overdue)
        let chore12 = Chore(
            title: "다림질",
            category: .laundry,
            points: 15,
            dueDate: calendar.date(byAdding: .day, value: -2, to: now)
        )
        
        return [
            chore1, chore2, chore3, chore4, chore5, chore6,
            chore7, chore8, chore9, chore10, chore11, chore12
        ]
    }()
}
