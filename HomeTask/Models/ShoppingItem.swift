//
//  ShoppingItem.swift
//  HomeTask
//
//  Created by 어재선 on 3/22/26.
//

import Foundation
import SwiftData

@Model
final class ShoppingItem {
    var name: String
    var quantity: Int
    var unit: String?
    var isPurchased: Bool
    var purchasedAt: Date?
    var category: ShoppingCategory
    var price: Int?
    var createdAt: Date
    
    var place: Place?
    
    init(
        name: String,
        quantity: Int = 1,
        unit: String? = nil,
        category: ShoppingCategory = .other,
        price: Int? = nil,
        place: Place? = nil
    ) {
        self.name = name
        self.quantity = quantity
        self.unit = unit
        self.isPurchased = false
        self.purchasedAt = nil
        self.category = category
        self.price = price
        self.place = place
        self.createdAt = .now
    }
}

enum ShoppingCategory: String, Codable, CaseIterable, Identifiable {
    case food = "식품"
    case dairy = "유제품"
    case meat = "정육"
    case vegetable = "채소/과일"
    case frozen = "냉동"
    case household = "생활용품"
    case other = "기타"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .food: "fork.knife"
        case .dairy: "cup.and.saucer"
        case .meat: "fish"
        case .vegetable: "carrot"
        case .frozen: "snowflake"
        case .household: "house"
        case .other: "cart"
        }
    }
}
