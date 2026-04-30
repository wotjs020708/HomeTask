//
//  HomeTaskModel.swift
//  HomeTask
//
//  Created by 어재선 on 3/23/26.
//

import SwiftUI
import SwiftData
import CoreLocation

@Observable
class HomeTaskModel {
    private let modelContext: ModelContext
    let geofenceManager = GeofenceManager()
    let liveActivityManager = LiveActivityManager()
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func startGeofencing() async {
        switch geofenceManager.authorizationStatus {
        case .notDetermined:
            geofenceManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            geofenceManager.requestAlwaysAuthorization()
        default:
            break
        }

        geofenceManager.requestNotificationAuthorization()

        // 집 도착/이탈 콜백 등록
        geofenceManager.onHomeArrival = { [weak self] in
            self?.startLiveActivity()
        }
        geofenceManager.onHomeDeparture = { [weak self] in
            guard let self else { return }
            Task { await self.liveActivityManager.endActivity() }
        }

        let descriptor = FetchDescriptor<Place>()
        let places = (try? modelContext.fetch(descriptor)) ?? []
        await geofenceManager.startMonitoring(places: places)
    }

    // MARK: - Live Activity

    private func startLiveActivity() {
        let descriptor = FetchDescriptor<Chore>()
        let allChores = (try? modelContext.fetch(descriptor)) ?? []
        let total = allChores.count
        let completed = allChores.filter(\.isCompleted).count
        let nextPending = allChores.first(where: { !$0.isCompleted })?.title ?? "할 일 없음"

        let homePlaceDescriptor = FetchDescriptor<Place>()
        let homeName = (try? modelContext.fetch(homePlaceDescriptor))?.first(where: { $0.type == .home })?.name ?? "우리집"

        liveActivityManager.startActivity(
            placeName: homeName,
            totalChores: total,
            completedChores: completed,
            pendingChoreTitle: nextPending
        )
    }
    
    // MARK: - Chore CRUD
    
    @discardableResult
    func createChore(
        title: String,
        category: ChoreCategory = .other,
        dueDate: Date? = nil,
        repeatInterval: RepeatInterval? = nil
    ) -> Chore {
        let chore = Chore(
            title: title,
            category: category,
            dueDate: dueDate,
            repeatInterval: repeatInterval
        )
        modelContext.insert(chore)
        Task { await updateLiveActivity() }
        return chore
    }

    func completeChore(_ chore: Chore) {
        chore.isCompleted = true
        chore.completedAt = .now

        
        if let interval = chore.repeatInterval {
            let nextDueDate = calculateNextDueDate(
                from: chore.dueDate ?? .now,
                interval: interval
            )
            createChore(
                title: chore.title,
                category: chore.category,
                dueDate: nextDueDate,
                repeatInterval: interval
            )
        }
        try? modelContext.save()
        
        let descriptor = FetchDescriptor<Chore>()
           let allChores = (try? modelContext.fetch(descriptor)) ?? []
           let total = allChores.count
           let completed = allChores.filter(\.isCompleted).count
           let nextPending = allChores.first(where: { !$0.isCompleted })?.title ?? "모두 완료!"

           Task {
               await liveActivityManager.updateActivity(
                   completedChores: completed,
                   totalChores: total,
                   pendingChoreTitle: nextPending
               )
           }
    }

    func uncompleteChore(_ chore: Chore) {
        chore.isCompleted = false
        chore.completedAt = nil
        
        Task { await updateLiveActivity() }
        try? modelContext.save()
    }

    func updateChore(
        _ chore: Chore,
        title: String? = nil,
        category: ChoreCategory? = nil,
        dueDate: Date? = nil,
        repeatInterval: RepeatInterval? = nil
    ) {
        if let title { chore.title = title }
        if let category { chore.category = category }
        if let dueDate { chore.dueDate = dueDate }
        if let repeatInterval { chore.repeatInterval = repeatInterval }
        try? modelContext.save()
    }
    
    func deleteChore(_ chore: Chore) {
        modelContext.delete(chore)
        try? modelContext.save()
    }
    
    // MARK: - Private Helpers
    
    private func updateLiveActivity() async {
        let allChores = (try? modelContext.fetch(FetchDescriptor<Chore>())) ?? []
        let total = allChores.count
        let completed = allChores.filter(\.isCompleted).count
        let pending = allChores.first(where: { !$0.isCompleted })?.title ?? "모두완료"
        
        await liveActivityManager.updateActivity(
                completedChores: completed,
                totalChores: total,
                pendingChoreTitle: pending
            )
    }
    
    private func calculateNextDueDate(from date: Date, interval: RepeatInterval) -> Date {
        let calendar = Calendar.current
        switch interval {
        case .daily:
            return calendar.date(byAdding: .day, value: 1, to: date) ?? date
        case .weekly:
            return calendar.date(byAdding: .weekOfYear, value: 1, to: date) ?? date
        case .biweekly:
            return calendar.date(byAdding: .weekOfYear, value: 2, to: date) ?? date
        case .monthly:
            return calendar.date(byAdding: .month, value: 1, to: date) ?? date
        }
    }
    
    // MARK: - Place CRUD
    
    @discardableResult
    func createPlace(
        name: String,
        latitude: Double,
        longitude: Double,
        radius: Double = 100,
        type: PlaceType
    ) -> Place {
        let place = Place(
            name: name,
            latitude: latitude,
            longitude: longitude,
            radius: radius,
            type: type
        )
        modelContext.insert(place)
        try? modelContext.save()
        Task { await geofenceManager.updateMonitoring(for: place) }
        return place
    }
    
    func deletePlace(_ place: Place) {
        Task { await geofenceManager.removeMonitoring(for: place)}
        modelContext.delete(place)
        try? modelContext.save()
    }
}
