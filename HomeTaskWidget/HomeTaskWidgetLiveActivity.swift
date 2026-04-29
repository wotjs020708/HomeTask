//
//  HomeTaskWidgetLiveActivity.swift
//  HomeTaskWidget
//
//  Created by 어재선 on 3/19/26.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct HomeTaskWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: HomeTaskWidgetAttributes.self) { context in
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("🏠 \(context.attributes.placeName) 도착!")
                        .font(.caption).foregroundStyle(.secondary)
                    Text(context.state.pendingChoreTitle)
                        .font(.headline).bold()
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(context.state.completedChores)/\(context.state.totalChores)")
                        .font(.title2).bold()
                    ProgressView(
                        value: Double(context.state.completedChores),
                        total: Double(context.state.totalChores)
                    )
                    .tint(.green)
                    .frame(width: 60)
                }
            }
            .padding()
            .activityBackgroundTint(Color(.systemBackground))
            
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Label("집안일", systemImage: "house.fill")
                        .font(.caption)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("\(context.state.completedChores)/\(context.state.totalChores)")
                        .font(.headline).bold()
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Text(context.state.pendingChoreTitle)
                        Spacer()
                            .foregroundStyle(.orange)
                    }
                    .font(.caption)
                }
            } compactLeading: {
                Image(systemName: "house.fill")
                    .foregroundStyle(.blue)
            } compactTrailing: {
                Text("\(context.state.completedChores)/\(context.state.totalChores)")
                    .font(.caption2).bold()
            } minimal: {
                Image(systemName: "house.fill")
            }
        }
    }
}
