////   WorkoutRouteEXT.swift
////   BigPoly
////
////   Created by: Grant Perry on 2/13/24 at 3:03 PM
////     Modified: 
////
////  Copyright © 2024 Delicious Studios, LLC. - Grant Perry
////
//
//import SwiftUI
//import MapKit
//
//extension WorkoutRouteView {
//	func fetchAndUpdateAddress(latitude: Double, longitude: Double) async {
//		let geocoder = CLGeocoder()
//		let location = CLLocation(latitude: latitude, longitude: longitude)
//
//		do {
//			let placemarks = try await geocoder.reverseGeocodeLocation(location)
//			if let placemark = placemarks.first {
//				// Update the address state
//				address = Address(
//					address: placemark.thoroughfare ?? "",
//					city: placemark.locality ?? "",
//					zipCode: placemark.postalCode ?? "",
//					state: placemark.administrativeArea ?? "",
//					latitude: latitude,
//					longitude: longitude,
//					name: placemark.name
//				)
//			}
//		} catch let error {
//			print("Address not found: \(error.localizedDescription)")
//		}
//	}
//}
//
