//
//  LiveActivityManager.swift
//  HomeTask
//
//  Created by 어재선 on 4/14/26.
//

import ActivityKit
import Foundation

@MainActor
final class LiveActivityManager {

    private var currentActivity: Activity<HomeTaskWidgetAttributes>?

    private func restoreCurrentActivity() -> Activity<HomeTaskWidgetAttributes>? {
        if let currentActivity { return currentActivity }
        currentActivity = Activity<HomeTaskWidgetAttributes>.activities.first
        return currentActivity
    }
    
    // MARK: - 라이브 액티비티 시작 (집 도착 시)

    func startActivity(
        placeName: String,
        totalChores: Int,
        completedChores: Int,
        pendingChoreTitle: String
    ) {
        
       
        
        
        if let existing = restoreCurrentActivity() {
                    Task {
                        await existing.update(
                            ActivityContent(
                                state: .init(
                                    totalChores: totalChores,
                                    completedChores: completedChores,
                                    pendingChoreTitle: pendingChoreTitle
                                ),
                                staleDate: nil
                            )
                        )
                    }
                    print("[LiveActivityManager] 기존 Activity 복원")
                    return
                }
        
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("[LiveActivityManager] 라이브 액티비티 비활성화 상태")
            return
        }

        let attributes = HomeTaskWidgetAttributes(placeName: placeName)
        let contentState = HomeTaskWidgetAttributes.ContentState(
            totalChores: totalChores,
            completedChores: completedChores,
            pendingChoreTitle: pendingChoreTitle
        )
        let content = ActivityContent(state: contentState, staleDate: nil)

        do {
            currentActivity = try Activity.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )
            print("[LiveActivityManager] ✅ 시작: \(currentActivity?.id ?? "")")
        } catch {
            print("[LiveActivityManager] ❌ 시작 실패: \(error.localizedDescription)")
        }
    }

    // MARK: - 상태 업데이트 (집안일 완료 시)

    func updateActivity(
        completedChores: Int,
        totalChores: Int,
        pendingChoreTitle: String
    ) async {
        guard let activity = restoreCurrentActivity() else { return }

        let newState = HomeTaskWidgetAttributes.ContentState(
            totalChores: totalChores,
            completedChores: completedChores,
            pendingChoreTitle: pendingChoreTitle
        )
        await activity.update(ActivityContent(state: newState, staleDate: nil))
        print("[LiveActivityManager] 🔄 업데이트: \(completedChores)/\(totalChores)")
    }

    // MARK: - 종료 (집 이탈 또는 모든 집안일 완료 시)

    func endActivity() async {
        guard let activity = restoreCurrentActivity() else { return }
        await activity.end(
            ActivityContent(state: activity.content.state, staleDate: nil),
            dismissalPolicy: .after(.now + 3)
        )
        currentActivity = nil
        print("[LiveActivityManager] 🏁 종료")
    }
}
