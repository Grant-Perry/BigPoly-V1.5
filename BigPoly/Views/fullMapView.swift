//   fullMapView.swift
//   BigPoly
//
//   Created by: Grant Perry on 2/8/24 at 9:56 AM
//     Modified: Tuesday February 13, 2024 at 3:21:42 PM (on the plane to ATL)
//
//  Copyright © 2024 Delicious Studios, LLC. - Grant Perry

import SwiftUI
import MapKit
import HealthKit

/// This is the full map view when the user selects the NavigatiponLink on the list view from WorkoutRouteView
///
struct FullMapView: View {
	let workout: HKWorkout
	@State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
	@State private var identifiableRouteCoordinates: [IdentifiableCoordinate] = [] // Updated to use IdentifiableCoordinate
	@State private var holdCoords: [CLLocationCoordinate2D] = []
	@State private var isLoading = true
	@State var poly: MKPolyline = MKPolyline(coordinates: [], count: 0)
	@State var startWorkout = CLLocationCoordinate2D(latitude: 37.000914, longitude: -76.442160)
	@State var endWorkout = CLLocationCoordinate2D(latitude: 37.000914, longitude: -76.2442360)
	
	@State private var cityName: String = "Fetching..."
	@State private var workoutDate: Date = Date()
	
	var position: MapCameraPosition = .automatic
//	var searchResults: [MKMapItem]
//	var visibleRegion: MKCoordinateRegion?


	let gradient = LinearGradient(
		colors: [.gpBlue, .gpYellow, .gpGreen],
		startPoint: .leading,
		endPoint: .trailing)
	
	let stroke = StrokeStyle(
		lineWidth: 6,
		lineCap: .round,
		lineJoin: .round)
	//,
//		dash: [15, 10])

	var body: some View {
//
//		Text("Distance: \(String(format: "%.2f", WorkoutCore.shared.distance))")
//			.rightJustify()
//			.padding(.trailing, 30)
//			.font(.system(size: 18).bold())
		
		Map {
			MapPolyline(coordinates: holdCoords)
				.stroke(gradient, style: stroke)

			Annotation(
				"Start",
				coordinate: startWorkout,
				anchor: .bottom
			) {
				Image(systemName: "figure.walk.departure")
					.imageScale(.small)
					.padding(4)
					.foregroundStyle(.white)
					.background(Color.gpGreen)
					.cornerRadius(4)
			}
		
			Annotation(
				"End",
				coordinate: endWorkout,
				anchor: .bottom
			) {
				Image(systemName: "figure.walk.arrival")
					.imageScale(.small)
					.padding(4)
					.foregroundStyle(.white)
					.background(Color.gpRed)
					.cornerRadius(4)
			}

//			Marker("Start", coordinate: startWorkout)
//			Marker("End", coordinate: endWorkout)
		}
		.onAppear {
			Task {
				// let's async get all the route data
				await loadRouteData()
			}
		}
		
// MARK: - safeArea for the metrics
		.safeAreaInset(edge: .top) {


			WorkoutMetricsView(cityName: cityName,
									 workoutDate: workoutDate)
		}
		.navigationTitle("Workout Map")
		.navigationBarTitleDisplayMode(.inline)
		.mapStyle(.imagery(elevation: .realistic))
		.background(.clear)

	}



	private func loadRouteData() async {
		do {
			let coordinates = try await WorkoutCore.shared.fetchRouteData(for: workout)
			if !coordinates.isEmpty {
				holdCoords = coordinates
				poly = MKPolyline(coordinates: coordinates, count: coordinates.count)
				startWorkout = coordinates.first!
				endWorkout = coordinates.last!
				identifiableRouteCoordinates = coordinates.map { IdentifiableCoordinate(coordinate: $0) }
				region.center = coordinates.first ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
			}
			isLoading = false
		} catch {
			print("Error fetching route data: \(error)")
			isLoading = false
		}
	}
}


