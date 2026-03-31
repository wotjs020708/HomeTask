//
//  AddPlaceView.swift
//  HomeTask
//
//  Created by 어재선 on 3/31/26.
//

import SwiftUI
import MapKit

struct AddPlaceView: View {
    @Environment(HomeTaskModel.self) private var model
    @Environment(\.dismiss) private var dismiss

    @State private var placeType: PlaceType = .home
    @State private var placeName = ""
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var selectedAddress = ""
    @State private var radius: Double = 100
    @State private var showAddressSearch = false

    private let radiusOptions: [Double] = [100, 200, 300, 500]

    private var canSave: Bool {
        selectedCoordinate != nil && !placeName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    placeTypeSection
                    addressSection
                    nameSection

                    if selectedCoordinate != nil {
                        mapPreviewSection
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }

                    radiusSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
                .padding(.bottom, 80)
                .animation(.spring(duration: 0.3), value: selectedCoordinate != nil)
            }
            .navigationTitle("장소 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") { saveAndDismiss() }
                        .fontWeight(.semibold)
                        .disabled(!canSave)
                }
            }
            .sheet(isPresented: $showAddressSearch) {
                AddressSearchView { item in
                    selectedAddress = item.name ?? ""
                    placeName = item.name ?? ""
                    selectedCoordinate = item.location.coordinate
                }
            }
        }
    }

    // MARK: - Sections (OnboardingView와 동일)

    private var placeTypeSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("장소 유형", systemImage: "tag")
                .font(.subheadline).fontWeight(.semibold)
                .foregroundStyle(.secondary)

            HStack(spacing: 10) {
                ForEach(PlaceType.allCases) { type in
                    PlaceTypeChip(type: type, isSelected: placeType == type)
                        .onTapGesture {
                            withAnimation(.spring(duration: 0.2)) { placeType = type }
                        }
                }
                Spacer()
            }
        }
    }

    private var addressSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("주소", systemImage: "magnifyingglass")
                .font(.subheadline).fontWeight(.semibold)
                .foregroundStyle(.secondary)

            Button { showAddressSearch = true } label: {
                HStack {
                    Text(selectedAddress.isEmpty ? "주소를 검색하세요" : selectedAddress)
                        .foregroundStyle(selectedAddress.isEmpty ? .secondary : .primary)
                        .lineLimit(1)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(14)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("장소 이름", systemImage: "pencil")
                .font(.subheadline).fontWeight(.semibold)
                .foregroundStyle(.secondary)

            TextField("예: 우리집, 이마트 홍대점", text: $placeName)
                .padding(14)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var mapPreviewSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("위치 확인", systemImage: "map")
                .font(.subheadline).fontWeight(.semibold)
                .foregroundStyle(.secondary)

            if let coordinate = selectedCoordinate {
                MapPreview(coordinate: coordinate, radius: radius)
                    .frame(height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private var radiusSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("알림 반경", systemImage: "circle.dashed")
                .font(.subheadline).fontWeight(.semibold)
                .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                ForEach(radiusOptions, id: \.self) { option in
                    RadiusChip(label: "\(Int(option))m", isSelected: radius == option)
                        .onTapGesture {
                            withAnimation(.spring(duration: 0.2)) { radius = option }
                        }
                }
                Spacer()
            }
        }
    }

    // MARK: - Actions

    private func saveAndDismiss() {
        guard let coordinate = selectedCoordinate else { return }
        model.createPlace(
            name: placeName.trimmingCharacters(in: .whitespaces),
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            radius: radius,
            type: placeType
        )
        dismiss()
    }
}
