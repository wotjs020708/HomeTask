//
//  Reward.swift
//  HomeTask
//
//  Created by 어재선 on 3/22/26.
//

import Foundation
import SwiftData

@Model
final class Reward {
    var name: String
    var requiredPoints: Int
    var isRedeemed: Bool
    var redeemedAt: Date?
    var createdAt: Date
    
    init(
        name: String,
        requiredPoints: Int
    ) {
        self.name = name
        self.requiredPoints = requiredPoints
        self.isRedeemed = false
        self.redeemedAt = nil
        self.createdAt = .now
    }
}
