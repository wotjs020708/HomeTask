//
//  HomeTaskApp.swift
//  HomeTask
//
//  Created by 어재선 on 3/14/26.
//

import SwiftUI
import SwiftData
@main
struct HomeTaskApp: App {
    let container: ModelContainer
    @State private var homeTaskModel: HomeTaskModel
    
    init() {
        let container = try! ModelContainer(
            for: Chore.self
        )
        self.container = container
        self._homeTaskModel = State(
            initialValue: HomeTaskModel(modelContext: container.mainContext)
        )
    }
    var body: some Scene {
        WindowGroup {
            ChoreView()
                .environment(homeTaskModel)
        }
        .modelContainer(container)
    }
}
