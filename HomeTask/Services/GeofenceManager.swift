//
//  GeofenceManager.swift
//  HomeTask
//
//  Created by 어재선 on 4/6/26.
//

import CoreLocation
import Foundation
import Observation
import UserNotifications

@Observable
final class GeofenceManager: NSObject {

    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var isMonitoring: Bool = false

    private var monitor: CLMonitor?
    private let locationManager = CLLocationManager()
    private var monitorTask: Task<Void, Never>?

    override init() {
        super.init()
        locationManager.delegate = self
        authorizationStatus = locationManager.authorizationStatus
    }

    func requestAlwaysAuthorization() {
        locationManager.requestAlwaysAuthorization()
    }

    func startMonitoring(places: [Place]) async {
        await stopMonitoring()

        let m = await CLMonitor("HomeTaskGeofenceMonitor")
        self.monitor = m

        for identifier in await m.identifiers {
            await m.remove(identifier)
        }

        for place in places {
            let condition = CLMonitor.CircularGeographicCondition(
                center: CLLocationCoordinate2D(
                    latitude: place.latitude,
                    longitude: place.longitude
                ),
                radius: place.radius
            )
            await m.add(condition, identifier: place.id.uuidString)
        }

        await MainActor.run { isMonitoring = true }
        startEventLoop(monitor: m, places: places)
    }

    func stopMonitoring() async {
        monitorTask?.cancel()
        monitorTask = nil

        if let m = monitor {
            for identifier in await m.identifiers {
                await m.remove(identifier)
            }
            monitor = nil
        }

        await MainActor.run { isMonitoring = false }
    }

    func updateMonitoring(for place: Place) async {
        guard let m = monitor else { return }
        let condition = CLMonitor.CircularGeographicCondition(
            center: CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude),
            radius: place.radius
        )
        await m.add(condition, identifier: place.id.uuidString)
    }

    func removeMonitoring(for place: Place) async {
        guard let m = monitor else { return }
        await m.remove(place.id.uuidString)
    }
}

private extension GeofenceManager {

    func startEventLoop(monitor: CLMonitor, places: [Place]) {
        monitorTask = Task { [weak self] in
            do {
                for try await event in await monitor.events {
                    guard let self else { return }
                    await self.handleGeofenceEvent(event, places: places)
                }
            } catch {
                print("[GeofenceManager] 이벤트 루프 오류: \(error.localizedDescription)")
            }
        }
    }

    @MainActor
    func handleGeofenceEvent(_ event: CLMonitor.Event, places: [Place]) async {
        guard let place = places.first(where: { $0.id.uuidString == event.identifier }) else { return }

        switch event.state {
        case .satisfied:
            handleArrival(at: place)
        case .unsatisfied:
            handleDeparture(from: place)
        default:
            break
        }
    }
}

private extension GeofenceManager {

    @MainActor
    func handleArrival(at place: Place) {
        switch place.type {
        case .home:
            // liveActivityManager?.startTodayActivity(chores: todayChores)
            break
        case .mart:
            sendShoppingNotification(for: place)
        }
    }

    @MainActor
    func handleDeparture(from place: Place) {
        switch place.type {
        case .home:
            break
        case .mart:
            break
        }
    }
}

private extension GeofenceManager {

    func sendShoppingNotification(for place: Place) {
        let content = UNMutableNotificationContent()
        content.title = "🛒 장보기 알림"
        content.body = "'\(place.name)'에 도착했어요! 장볼 목록을 확인해보세요."
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "geofence-shopping-\(place.id.uuidString)",
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("[GeofenceManager] 알림 전송 실패: \(error.localizedDescription)")
            }
        }
    }
}

extension GeofenceManager: CLLocationManagerDelegate {

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }
}
