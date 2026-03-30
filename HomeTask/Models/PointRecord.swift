//
//  PointRecord.swift
//  HomeTask
//
//  Created by 어재선 on 3/22/26.
//

import Foundation

import Foundation
import SwiftData

@Model
final class PointRecord {
    var points: Int
    var type: PointType
    var reason: String
    var createdAt: Date
    
    
    init(
        points: Int,
        type: PointType,
        reason: String
    ) {
        self.points = points
        self.type = type
        self.reason = reason
        self.createdAt = .now
    }
}

enum PointType: String, Codable {
    case earned = "적립"
    case spent = "사용"
}
