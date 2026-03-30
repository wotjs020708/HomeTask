//
//  PreviewContainer.swift
//  HomeTask
//
//  Created by 어재선 on 3/25/26.
//

import Foundation
import SwiftData

// MARK: - Preview용 ModelContainer

@MainActor
enum PreviewContainer {
    
    /// In-memory ModelContainer (Preview 전용)
    static let container: ModelContainer = {
        let schema = Schema([
            Chore.self,
            ShoppingItem.self,
            Place.self,
            PointRecord.self,
            Reward.self
        ])
        
        let config = ModelConfiguration(
            isStoredInMemoryOnly: true
        )
        
        let container = try! ModelContainer(
            for: schema,
            configurations: config
        )
        
        SampleData.insertAll(into: container.mainContext)
        
        return container
    }()
    
    /// mainContext 바로 접근
    static var context: ModelContext {
        container.mainContext
    }
}

// MARK: - 샘플 데이터

private enum SampleData {
    
    @MainActor
    static func insertAll(into context: ModelContext) {
        // ── 장소 ──
        let home = Place(
            name: "우리집",
            latitude: 37.5665,
            longitude: 126.9780,
            radius: 100,
            type: .home
        )
        let mart = Place(
            name: "이마트 강남점",
            latitude: 37.4979,
            longitude: 127.0276,
            radius: 150,
            type: .mart
        )
        context.insert(home)
        context.insert(mart)
        
        // ── 집안일 ──
        let chores: [Chore] = [
            Chore(title: "청소기 돌리기", category: .cleaning, points: 15, dueDate: .now, repeatInterval: .weekly),
            Chore(title: "빨래 돌리기", category: .laundry, points: 10, dueDate: .now, repeatInterval: .daily),
            Chore(title: "설거지", category: .dishes, points: 10, dueDate: .now, repeatInterval: .daily),
            Chore(title: "분리수거", category: .trash, points: 20,
                  dueDate: Calendar.current.date(byAdding: .day, value: 1, to: .now),
                  repeatInterval: .weekly),
            Chore(title: "냉장고 정리", category: .cooking, points: 15,
                  dueDate: Calendar.current.date(byAdding: .day, value: 3, to: .now),
                  repeatInterval: .monthly)
        ]
        chores.forEach { context.insert($0) }
        
        let completedChore = Chore(title: "화장실 청소", category: .cleaning, points: 20)
        completedChore.isCompleted = true
        completedChore.completedAt = Calendar.current.date(byAdding: .hour, value: -2, to: .now)
        context.insert(completedChore)
        
        // ── 장보기 ──
        let shoppingItems: [ShoppingItem] = [
            ShoppingItem(name: "계란", quantity: 1, unit: "판", category: .food, price: 6000, place: mart),
            ShoppingItem(name: "우유", quantity: 2, unit: "L", category: .dairy, price: 3500, place: mart),
            ShoppingItem(name: "양파", quantity: 3, unit: "개", category: .vegetable, price: 1500, place: mart),
            ShoppingItem(name: "삼겹살", quantity: 1, unit: "600g", category: .meat, price: 15000, place: mart),
            ShoppingItem(name: "세제", quantity: 1, unit: "개", category: .household, price: 8000),
            ShoppingItem(name: "냉동만두", quantity: 2, unit: "봉", category: .frozen, price: 5000, place: mart)
        ]
        shoppingItems.forEach { context.insert($0) }
        
        let purchasedItem = ShoppingItem(name: "휴지", quantity: 1, unit: "묶음", category: .household, price: 12000, place: mart)
        purchasedItem.isPurchased = true
        purchasedItem.purchasedAt = Calendar.current.date(byAdding: .hour, value: -5, to: .now)
        context.insert(purchasedItem)
        
        // ── 포인트 기록 ──
        let pointRecords: [PointRecord] = [
            PointRecord(points: 20, type: .earned, reason: "화장실 청소 완료"),
            PointRecord(points: 10, type: .earned, reason: "설거지 완료"),
            PointRecord(points: 15, type: .earned, reason: "청소기 돌리기 완료"),
            PointRecord(points: 10, type: .earned, reason: "빨래 돌리기 완료"),
            PointRecord(points: 20, type: .spent, reason: "커피 한 잔 사용")
        ]
        pointRecords.forEach { context.insert($0) }
        
        // ── 보상 ──
        let rewards: [Reward] = [
            Reward(name: "커피 한 잔", requiredPoints: 20),
            Reward(name: "청소 면제권", requiredPoints: 30),
            Reward(name: "치킨", requiredPoints: 50),
            Reward(name: "영화 보기", requiredPoints: 80),
            Reward(name: "하루 쉬기", requiredPoints: 100)
        ]
        rewards.forEach { context.insert($0) }
        
        let redeemedReward = Reward(name: "아이스크림", requiredPoints: 15)
        redeemedReward.isRedeemed = true
        redeemedReward.redeemedAt = Calendar.current.date(byAdding: .day, value: -1, to: .now)
        context.insert(redeemedReward)
    }
}
