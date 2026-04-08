//
//  OnboardingView.swift
//  HomeTask
//
//  Created by 어재선 on 3/30/26.
//

import SwiftUI
import MapKit

struct OnboardingView: View {
    let onComplete: () -> Void
    
    @Environment(HomeTaskModel.self) private var model
    
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
                VStack(spacing: 28) {
                    headerSection
                    formSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 32)
                .padding(.bottom, 120)
            }
        }
        .safeAreaInset(edge: .bottom) {
            startButton
        }
        .sheet(isPresented: $showAddressSearch) {
            
            AddressSearchView { item in
                selectedAddress = item.name ?? ""
                placeName = item.name ?? ""
                selectedCoordinate = item.placemark.location?.coordinate
            }
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "mappin.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.tint)
            
            Text("첫 장소를 등록해요")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("집이나 마트 위치를 등록하면\n근처에서 알림을 받을 수 있어요")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Form
    
    private var formSection: some View {
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
        .animation(.spring(duration: 0.3), value: selectedCoordinate != nil)
    }
    
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
                .background(Color(.backgroundSecondary))
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
                .background(Color(.backgroundSecondary))
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
    
    // MARK: - Start Button
    
    private var startButton: some View {
        Button {
            saveAndComplete()
        } label: {
            Text("시작하기")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(canSave ? Color.accentColor : Color(.systemGray4))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(!canSave)
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
        .background(.clear)
    }
    
    // MARK: - Actions
    
    private func saveAndComplete() {
        guard let coordinate = selectedCoordinate else { return }
        model.createPlace(
            name: placeName.trimmingCharacters(in: .whitespaces),
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            radius: radius,
            type: placeType
        )
        withAnimation { onComplete() }
    }
}

// MARK: - PlaceType Chip

struct PlaceTypeChip: View {
    let type: PlaceType
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: type.icon)
            Text(type.rawValue)
                .fontWeight(.medium)
        }
        .font(.subheadline)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(isSelected ? Color.accentColor.opacity(0.15) : Color(.systemGray6))
        .foregroundStyle(isSelected ? Color.accentColor : .secondary)
        .clipShape(Capsule())
        .overlay(Capsule().strokeBorder(
            isSelected ? Color.accentColor.opacity(0.5) : .clear, lineWidth: 1
        ))
    }
}

// MARK: - Radius Chip

struct RadiusChip: View {
    let label: String
    let isSelected: Bool
    
    var body: some View {
        Text(label)
            .font(.subheadline)
            .fontWeight(.medium)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? Color.accentColor.opacity(0.15) : Color(.systemGray6))
            .foregroundStyle(isSelected ? Color.accentColor : .secondary)
            .clipShape(Capsule())
            .overlay(Capsule().strokeBorder(
                isSelected ? Color.accentColor.opacity(0.5) : .clear, lineWidth: 1
            ))
    }
}

// MARK: - Map Preview

struct MapPreview: View {
    let coordinate: CLLocationCoordinate2D
    let radius: Double
    
    @State private var position: MapCameraPosition = .automatic
    
    var body: some View {
        Map(position: $position) {
            Annotation("", coordinate: coordinate) {
                Image(systemName: "mappin.circle.fill")
                    .font(.title)
                    .foregroundStyle(.red)
            }
            MapCircle(center: coordinate, radius: radius)
                .foregroundStyle(.blue.opacity(0.15))
                .stroke(.blue.opacity(0.4), lineWidth: 1.5)
        }
        .disabled(true)
        .onAppear {
            position = makeRegion(radius: radius)
        }
        .onChange(of: coordinate.latitude) { _, _ in
            withAnimation {
                position = makeRegion(radius: radius)
            }
        }
        .onChange(of: coordinate.longitude) { _, _ in
            withAnimation {
                position = makeRegion(radius: radius)
            }
        }
        .onChange(of: radius) { _, newRadius in
            withAnimation {
                position = makeRegion(radius: newRadius)
            }
        }
    }
    
    private func makeRegion(radius: Double) -> MapCameraPosition {
        .region(MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: radius * 6,
            longitudinalMeters: radius * 6
        ))
    }
}
