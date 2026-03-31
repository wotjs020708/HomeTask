//
//  PlacesListView.swift
//  HomeTask
//
//  Created by 어재선 on 3/31/26.
//

import SwiftUI
import SwiftData

struct PlacesListView: View {
    @Environment(HomeTaskModel.self) private var model
    @Query(sort: \Place.createdAt) private var places: [Place]

    @State private var showAddPlace = false

    var body: some View {
        NavigationStack {
            Group {
                if places.isEmpty {
                    emptyView
                } else {
                    list
                }
            }
            .navigationTitle("장소 관리")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddPlace = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddPlace) {
                AddPlaceView()
            }
        }
    }

    // MARK: - List

    private var list: some View {
        List {
            ForEach(places) { place in
                PlaceRow(place: place)
            }
            .onDelete { indexSet in
                indexSet.map { places[$0] }.forEach(model.deletePlace)
            }
        }
    }

    // MARK: - Empty

    private var emptyView: some View {
        ContentUnavailableView(
            "등록된 장소가 없어요",
            systemImage: "mappin.slash",
            description: Text("+ 버튼을 눌러 집이나 마트를 등록해보세요")
        )
    }
}

// MARK: - Place Row

struct PlaceRow: View {
    let place: Place

    var body: some View {
        HStack(spacing: 14) {
            // 아이콘
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.12))
                    .frame(width: 40, height: 40)
                Image(systemName: place.type.icon)
                    .foregroundStyle(Color.accentColor)
            }

            // 정보
            VStack(alignment: .leading, spacing: 3) {
                Text(place.name)
                    .font(.body)
                    .fontWeight(.medium)
                Text("\(place.type.rawValue) · 반경 \(Int(place.radius))m")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
