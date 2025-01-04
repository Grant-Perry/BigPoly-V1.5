//   WorkoutRouteView.swift
//   BigPoly
//
//   Created by: Grant Perry on 2/10/24 at 2:42 PM
//     Modified:
//
//  Copyright 2024 Delicious Studios, LLC. - Grant Perry


import SwiftUI
import CoreLocation
import MapKit
import HealthKit

struct WorkoutRouteView: View {
   
   @State var workout: [HKWorkout]
   @State var address: Address? = nil
   @State var date: Date = Date()
   @State var latitude: Double = 37.000914
   @State var longitude: Double = -76.442160
   @State var isLoading = false
   //	@State private var address = Address(address: "", city: "", zipCode: "", state: "", latitude: 0.0, longitude: 0.0, name: "Home")
   
   var body: some View {
	  
	  if isLoading {
		 ProgressView("Loading Workouts...")
	  } else {
		 VStack(spacing: 4) {
			// Header row with city and date
			HStack {
			   if let address = address {
				  Text(address.city)
					 .font(.system(size: 25))
					 .bold()
					 .lineLimit(1)
					 .minimumScaleFactor(0.5)
			   } else {
				  Text("Loading...")
					 .font(.system(size: 25))
					 .bold()
			   }
			   Spacer()
			   Text(date, style: .date)
				  .lineLimit(1)
				  .minimumScaleFactor(0.5)
			}
			.foregroundColor(.white)
			
			// Weather information
			if let address = address {
			   HStack {
				  Text("\(address.city), \(address.state)")
					 .font(.footnote)
					 .foregroundColor(.white)
				  Spacer()
			   }
			}
			
			// Time
			Text(date, style: .time)
			   .font(.system(size: 16))
			   .foregroundColor(.white)
			   .frame(maxWidth: .infinity, alignment: .leading)
			
			// Distance
			if let workout = workout.first {
			   let distance = workout.totalDistance?.doubleValue(for: .mile()) ?? 0.0
			   Text("Dist: \(String(format: "%.2f", distance)) mi")
				  .font(.system(size: 14))
				  .foregroundColor(.white)
				  .frame(maxWidth: .infinity, alignment: .leading)
			}
			
			Spacer()
		 }
		 .padding()
		 .task {
			await fetchAndUpdateAddress(latitude: latitude, longitude: longitude)
			isLoading = false
		 }
		 .onAppear {
			// Update weather information when view appears
			if let workout = workout.first,
			   let metadata = workout.metadata,
			   let weatherTemp = metadata["weatherTemp"] as? String,
			   let weatherSymbol = metadata["weatherSymbol"] as? String {
			   // Update the weather display
			   // You can add weather-specific UI elements here
			}
		 }
	  }
   }
   
   // Example async function to fetch address
   func fetchAndUpdateAddress(latitude: Double, longitude: Double) async {
	  let retrievedAddress = await fetchAddress(latitude: latitude, longitude: longitude)
	  //		self.address = retrievedAddress
   }
   
   func fetchAddress(latitude: Double, longitude: Double) async {
	  let geocoder = CLGeocoder()
	  let location = CLLocation(latitude: latitude, longitude: longitude)
	  
	  geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
		 if let error = error {
			address
			self.address?.address = "Address not found: \(error.localizedDescription)"
			return
		 }
		 
		 if let placemark = placemarks?.first {
			//				self.address = [placemark.thoroughfare, placemark.locality, placemark.administrativeArea, placemark.postalCode].compactMap { $0 }.joined(separator: ", ")
			
			// Setting the address property - may not be necessary because of address: Address
			address?.address = placemark.thoroughfare ?? ""
			address?.city = placemark.locality ?? ""
			address?.zipCode = placemark.postalCode ?? ""
			address?.state = placemark.administrativeArea ?? ""
			address?.latitude = latitude
			address?.longitude = longitude
			address?.name = placemark.name
		 }
	  }
   }
}

// Mock asynchronous function to fetch address
//	func fetchAddress(latitude: Double, longitude: Double) async -> Address {
//		// Your asynchronous fetching logic here
//		// For demonstration, returning a dummy Address
//		return Address(city: "Sample City")
//	}

struct Address {
   var address: String
   var city: String
   var zipCode: String
   var state: String
   var latitude: Double
   var longitude: Double
   var name: String?
}
