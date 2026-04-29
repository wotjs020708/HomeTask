//
//  SettingsView.swift
//  HomeTask
//
//  Created by 어재선 on 4/7/26.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        List {
            NavigationLink("위치 관리", destination: PlacesListView())
        }
    }
}

