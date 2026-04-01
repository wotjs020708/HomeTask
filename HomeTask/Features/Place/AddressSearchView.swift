//
//  AddressSearchView.swift
//  HomeTask
//
//  Created by 어재선 on 3/30/26.
//

import SwiftUI
import MapKit

struct AddressSearchView: View {
    let onSelect: (MKMapItem) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var query = ""
    @State private var results: [MKMapItem] = []
    @State private var isSearching = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if results.isEmpty && !query.isEmpty && !isSearching {
                    ContentUnavailableView.search(text: query)
                } else {
                    List {
                        ForEach(results, id: \.self) { item in
                            Button {
                                onSelect(item)
                                dismiss()
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.name ?? "이름 없음")
                                        .font(.body)
                                        .foregroundStyle(.primary)
                                    
                                    if let address = item.address {
                                        Text(address.shortAddress ?? address.fullAddress)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("주소 검색")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
            }
            .searchable(
                text: $query,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "장소 또는 주소 입력"
            )
            .task(id: query) {
                await search(query: query)
            }
            .overlay {
                if isSearching {
                    ProgressView()
                }
            }
        }
    }
    
    // MARK: - Search
    
    private func search(query: String) async {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            results = []
            return
        }
        
        isSearching = true
        defer { isSearching = false }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = trimmed
        request.resultTypes = [.pointOfInterest, .address]
        request.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 36.5, longitude: 127.5),
            latitudinalMeters: 600_000,
            longitudinalMeters: 600_000
        )
        
        do {
            let response = try await MKLocalSearch(request: request).start()
            results = response.mapItems
        } catch {
            results = []
        }
    }
}
