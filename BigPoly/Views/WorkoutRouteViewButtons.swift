////   WorkoutRouteViewButtons.swift
////   BigPoly
////
////   Created by: Grant Perry on 2/12/24 at 10:23 AM
////     Modified:
////
////  Copyright © 2024 Delicious Studios, LLC. - Grant Perry
////
//
//import SwiftUI
//import MapKit
//
//struct WorkoutRouteViewButtons: View {
//	@Binding var searchResults: [MKMapItem]
//
//	var body: some View {
//			HStack {
//				Button {
//
//				} label: { search (for: "playground")
//					Label("Playgrounds" , systemImage: "figure.and.child.holdinghands")
//			}
//				.buttonStyle(.borderedProminent)
//
//				Button {
//					search (for: "beach")
//				} label: {
//					Label ("Beaches" , systemImage: "beach.umbrella")
//				}
//				.buttonStyle(.borderedProminent)
//
//				.labelStyle(.iconOnly)
//			}
//		}
//
//	func search(for query: String) {
//		let request = MKLocalSearch.Request ()
//		request.naturalLanguageQuery = query
//		request.resultTypes = .pointOfInterest
//		request.region = MKCoordinateRegion(
//			center: .home,
//			span: MKCoordinateSpan(latitudeDelta: 0.0125, longitudeDelta: 0.0125))
//
//		Task {
//			let search = MKLocalSearch(request: request)
//			let response = try? await search.start()
//			searchResults = response?.mapItems ?? []
//
//		}
//	}
//
//}
//
//extension CLLocationCoordinate2D {
//	static let home = CLLocationCoordinate2D(latitude: 37.000914, longitude: -76.442160)
//}
//
////		#Preview {
////			WorkoutRouteViewButtons()
////		}
