//
//  HomeTaskActivityAttributes.swift
//  HomeTask
//

import ActivityKit

struct HomeTaskWidgetAttributes: ActivityAttributes {
    let placeName: String

    struct ContentState: Codable, Hashable {
        var totalChores: Int
        var completedChores: Int
        var pendingChoreTitle: String
    }
}
