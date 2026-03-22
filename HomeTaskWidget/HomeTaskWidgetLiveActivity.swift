//
//  HomeTaskWidgetLiveActivity.swift
//  HomeTaskWidget
//
//  Created by 어재선 on 3/19/26.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct HomeTaskWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct HomeTaskWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: HomeTaskWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension HomeTaskWidgetAttributes {
    fileprivate static var preview: HomeTaskWidgetAttributes {
        HomeTaskWidgetAttributes(name: "World")
    }
}

extension HomeTaskWidgetAttributes.ContentState {
    fileprivate static var smiley: HomeTaskWidgetAttributes.ContentState {
        HomeTaskWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: HomeTaskWidgetAttributes.ContentState {
         HomeTaskWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: HomeTaskWidgetAttributes.preview) {
   HomeTaskWidgetLiveActivity()
} contentStates: {
    HomeTaskWidgetAttributes.ContentState.smiley
    HomeTaskWidgetAttributes.ContentState.starEyes
}
