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

        let descriptor = FetchDescriptor<Place>()
        let places = (try? modelContext.fetch(descriptor)) ?? []
        await geofenceManager.startMonitoring(places: places)
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
    }

    func uncompleteChore(_ chore: Chore) {
        chore.isCompleted = false
        chore.completedAt = nil
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
