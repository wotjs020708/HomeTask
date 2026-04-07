//
//  Place.swift
//  HomeTask
//
//  Created by 어재선 on 3/22/26.
//

import Foundation
import SwiftData

@Model
final class Place {
    var id: UUID = UUID()
    var name: String
    var latitude: Double
    var longitude: Double
    var radius: Double
    var type: PlaceType
    var createdAt: Date
    
    @Relationship(deleteRule: .nullify, inverse: \ShoppingItem.place)
    var shoppingItems: [ShoppingItem]?
    
    init(
        name: String,
        latitude: Double,
        longitude: Double,
        radius: Double = 100,
        type: PlaceType
    ) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.radius = radius
        self.type = type
        self.createdAt = .now
    }
}

enum PlaceType: String, Codable, CaseIterable, Identifiable {
    case home = "집"
    case mart = "마트"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .home: "house.fill"
        case .mart: "cart.fill"
        }
    }
}
