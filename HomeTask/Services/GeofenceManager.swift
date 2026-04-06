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

    // MARK: - PlaceInfo
    fileprivate struct PlaceInfo: Sendable {
        let name: String
        let type: PlaceType
    }

    // MARK: - 상태 (View에서 관찰 가능)
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var isMonitoring: Bool = false

    // MARK: - Private
    private var monitor: CLMonitor?
    private let locationManager = CLLocationManager()
    private var monitorTask: Task<Void, Never>?
    private var monitoredPlaces: [String: PlaceInfo] = [:]

    // MARK: - Init
    override init() {
        super.init()
        locationManager.delegate = self
        authorizationStatus = locationManager.authorizationStatus
    }

    // MARK: - 위치 권한 요청
    func requestAlwaysAuthorization() {
        locationManager.requestAlwaysAuthorization()
    }

    // MARK: - 알림 권한 요청
    func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, error in
            if let error {
                print("[GeofenceManager] 알림 권한 요청 오류: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - 모니터링 시작
    func startMonitoring(places: [Place]) async {
        await stopMonitoring()

        let m = await CLMonitor("HomeTaskGeofenceMonitor")
        self.monitor = m

        for identifier in await m.identifiers {
            await m.remove(identifier)
        }

        var placesDict: [String: PlaceInfo] = [:]
        for place in places {
            let condition = CLMonitor.CircularGeographicCondition(
                center: CLLocationCoordinate2D(
                    latitude: place.latitude,
                    longitude: place.longitude
                ),
                radius: place.radius
            )
            await m.add(condition, identifier: place.id.uuidString)
            placesDict[place.id.uuidString] = PlaceInfo(name: place.name, type: place.type)
        }

        await MainActor.run {
            self.monitoredPlaces = placesDict
            self.isMonitoring = true
        }

        startEventLoop(monitor: m)
    }

    // MARK: - 모니터링 종료
    func stopMonitoring() async {
        monitorTask?.cancel()
        monitorTask = nil

        if let m = monitor {
            for identifier in await m.identifiers {
                await m.remove(identifier)
            }
            monitor = nil
        }

        await MainActor.run {
            monitoredPlaces = [:]
            isMonitoring = false
        }
    }

    // MARK: - 단일 장소 업데이트 (장소 추가/편집 시 호출)
    func updateMonitoring(for place: Place) async {
        guard let m = monitor else { return }
        let condition = CLMonitor.CircularGeographicCondition(
            center: CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude),
            radius: place.radius
        )
        await m.add(condition, identifier: place.id.uuidString)
        await MainActor.run {
            monitoredPlaces[place.id.uuidString] = PlaceInfo(name: place.name, type: place.type)
        }
    }

    // MARK: - 단일 장소 제거
    func removeMonitoring(for place: Place) async {
        let identifier = place.id.uuidString
        guard let m = monitor else { return }
        await m.remove(identifier)
        _ = await MainActor.run { monitoredPlaces.removeValue(forKey: identifier) }
    }
}

// MARK: - 이벤트 루프
private extension GeofenceManager {

    func startEventLoop(monitor: CLMonitor) {
        monitorTask = Task { [weak self] in
            do {
                for try await event in await monitor.events {
                    guard let self else { return }
                    await self.handleGeofenceEvent(event)
                }
            } catch {
                print("[GeofenceManager] 이벤트 루프 오류: \(error.localizedDescription)")
            }
        }
    }

    @MainActor
    func handleGeofenceEvent(_ event: CLMonitor.Event) async {
        guard let info = monitoredPlaces[event.identifier] else { return }

        switch event.state {
        case .satisfied:
            handleArrival(identifier: event.identifier, info: info)
        case .unsatisfied:
            handleDeparture(info: info)
        default:
            break
        }
    }
}

// MARK: - 도착/이탈 처리
private extension GeofenceManager {

    @MainActor
    func handleArrival(identifier: String, info: PlaceInfo) {
        switch info.type {
        case .home:
            print("[GeofenceManager] 🏠 집 도착 감지")
            // TODO: - 라이브엑티비티 실행

        case .mart:
            print("[GeofenceManager] 🛒 마트 도착 감지 → 장보기 알림 전송")
            sendShoppingNotification(identifier: identifier, name: info.name)
        }
    }

    @MainActor
    func handleDeparture(info: PlaceInfo) {
        switch info.type {
        case .home:
            print("[GeofenceManager] 🏠 집 이탈 감지")
        case .mart:
            print("[GeofenceManager] 🛒 마트 이탈 감지")
        }
    }
}

// MARK: - 장보기 로컬 알림
private extension GeofenceManager {

    func sendShoppingNotification(identifier: String, name: String) {
        let content = UNMutableNotificationContent()
        content.title = "🛒 장보기 알림"
        content.body = "'\(name)'에 도착했어요! 장볼 목록을 확인해보세요."
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "geofence-shopping-\(identifier)",
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

// MARK: - CLLocationManagerDelegate
extension GeofenceManager: CLLocationManagerDelegate {

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }
}
