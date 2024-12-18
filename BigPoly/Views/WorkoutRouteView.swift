//   WorkoutRouteView.swift
//   BigPoly
//
//   Created by: Grant Perry on 2/10/24 at 2:42 PM
//     Modified:
//
//  Copyright © 2024 Delicious Studios, LLC. - Grant Perry
//


import SwiftUI
import CoreLocation
import MapKit
import HealthKit

struct WorkoutRouteView: View {
	@State var workout: HKWorkout
	@State var address: Address? = nil
	@State var date: Date = Date()
	@State var latitude: Double = 37.000914
	@State var longitude: Double = -76.442160
	@State var isLoading = true
	@State var locations: [CLLocation]? = nil
	@State private var position: MapCameraPosition = .automatic
	 var heights = 125.0

	var body: some View {
		VStack(alignment: .leading, spacing: 0) {
			HStack(spacing: 0) {
				if isLoading {
					ProgressView()
						.frame(maxWidth: .infinity, maxHeight: .infinity)
						.background(Color.blue.gradient)
						.cornerRadius(10)
				} else {
// MARK: - Address Container
					VStack {
						Text(workout.startDate.formatted(as: "MMM d, yy"))
							.font(.system(size: 15))
							.foregroundColor(.white)
							.rightJustify()
							.padding(EdgeInsets(top: 3, leading: 0, bottom: 0, trailing: 26))

//						Spacer()
						Text(address?.city ?? "Loading...")
							.font(.system(size: 22)).bold()
							.foregroundColor(.white)
							.padding(.leading)
							.leftJustify()

						VStack(alignment: .leading, spacing: 1) {
							Text(address?.address ?? "Loading...")
								.font(.system(size: 17))
								.frame(width: 120, height: 16)
							Spacer()
							Text("Distance: \(String(format: "%.2f", WorkoutCore.shared.distance))")
								.rightJustify()
								.padding(.trailing, 30)
								.font(.system(size: 18).bold())

							HStack {
								HStack {
									// the date was here
								}

								HStack {
									Text("miles")
										.rightJustify()
										.padding(.trailing, 30)
										.font(.system(size: 8))
								}
							}
						}
						.foregroundColor(.white)
						.padding(.leading, 20) // indent the text
						.leftJustify()
						Spacer()
					}
					.onAppear() {
						Task {
							await fetchAndUpdateAddress(latitude: self.latitude, 
																 longitude: self.longitude)
							
							// update the cityName to the workout id for the detail view
						   let workoutID = workout.uuid
						   WorkoutCore.shared.updateCityName(for: workoutID,
															 with: address?.city ?? "Unknown City")
						}
					}
					.frame(width: UIScreen.main.bounds.width * 0.5, height: heights)
					.background(.blue.gradient)
					.cornerRadius(10, corners: [.topLeft, .bottomLeft])
					.leftJustify()

// MARK: -> Map container
					if let coordinate = locations?.first?.coordinate {
						Map(position: $position) {
							Annotation(
								"❤️",
								coordinate: coordinate,
								anchor: .bottom
							) {
//								Image(systemName: "")
							}
						}
						.mapControlVisibility(.hidden)
						.mapStyle(.hybrid(elevation: .realistic ))
						.disabled(true)
						.frame(width: UIScreen.main.bounds.width * 0.35, height: heights)
						.cornerRadius(10, corners: [.topRight, .bottomRight])

						.padding(.leading, -20)
					} else {
						Text("No Map Data")
							.frame(width: UIScreen.main.bounds.width * 0.5, height: heights)
							.background(Color.gray)
							.cornerRadius(10)
					}
				}
			}
// MARK: - Full Container
			.frame(width: UIScreen.main.bounds.width * 0.65, height: heights)
//			.frame(width: UIScreen.main.bounds.width * 0.9, height: heights)
			.padding([.top, .horizontal])
			.onAppear() {
				Task {
					print("TASK # 2: Get the routes")
					guard let routes = await WorkoutCore.shared.getWorkoutRoute(workout: workout),
							let firstRoute = routes.first else { return }

					print("TASK # 3: Get the CLLocations for the routes\n")
					locations = await WorkoutCore.shared.getCLocationDataForRoute(routeToExtract: firstRoute)
					guard let firstLocation = locations?.first else {
						print("No locations available in the route.")
						return
					}
					print("finished locations\n")
					// Now you have your first location from which you can get latitude and longitude
					self.latitude = firstLocation.coordinate.latitude
					self.longitude = firstLocation.coordinate.longitude

					// calculate this workout's distance
					print("TASK # 4: Calculate distance\n")
					WorkoutCore.shared.distance = locations?.calcDistance ?? 99

					print("lat: \(latitude)  long: \(longitude)")

					// close the loading window
					self.isLoading = false
				}
			}

		}
		.preferredColorScheme(.light)
	}
}

extension WorkoutRouteView {
	
}
