import SwiftUI
import HealthKit
import CoreLocation
import Combine

/// A container for watch-provided metadata
struct WatchMetadata {
   let finalDistance: Double?
   let finalDuration: Double?
   let averageSpeed: Double?
   let weatherCity: String?
   let weatherTemp: String?
   let weatherSymbol: String?
   let windSpeed: String?
   let windDirection: String?
}

class PolyViewModel: ObservableObject {
   @Published var workouts: [HKWorkout] = []
   @Published var isLoading: Bool = false

   // Filter toggles
   @Published var isShortDistanceFilterEnabled: Bool = true

   // Date range
   @Published var startDate: Date = Calendar.current.date(byAdding: .day, value: -14, to: Date()) ?? Date().addingTimeInterval(-14 * 24 * 3600)
   @Published var endDate: Date = Date()

   // Paged loading
   @Published var maxWorkoutCount: Int = 40

   // Caches
   var cityNameCache: [UUID: String] = [:]
   var routeCache: [UUID: [CLLocationCoordinate2D]] = [:]
   var distanceCache: [UUID: Double] = [:]
   var metadataCache: [UUID: WatchMetadata] = [:]

   private let healthStore = HKHealthStore()

   init() {}

   // MARK: - Authorization
   func requestHealthKitPermission() async throws {
	  let typesToRead: Set<HKObjectType> = [
		 HKObjectType.workoutType(),
		 HKSeriesType.workoutRoute()
	  ]
	  try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
   }

   // MARK: - Load
   func loadWorkouts(page: Int) {
	  if isLoading { return }
	  isLoading = true

	  Task {
		 do {
			try await requestHealthKitPermission()
			let fetched = try await fetchPagedWorkouts(startDate: startDate,
													   endDate: endDate,
													   limit: maxWorkoutCount,
													   page: page)
			var finalList: [HKWorkout] = []
			for wk in fetched {
			   let dist = await fetchDistance(for: wk)
			   // If user wants to filter out short workouts
			   if isShortDistanceFilterEnabled {
				  if dist >= 0.1 {
					 finalList.append(wk)
				  }
			   } else {
				  finalList.append(wk)
			   }
			}

			DispatchQueue.main.async {
			   if page == 0 {
				  self.workouts = finalList
			   } else {
				  self.workouts.append(contentsOf: finalList)
			   }
			   self.isLoading = false
			}
		 } catch {
			DispatchQueue.main.async {
			   print("Failed to load workouts: \(error.localizedDescription)")
			   self.isLoading = false
			}
		 }
	  }
   }

   // MARK: - City Name
   func fetchCityName(for workout: HKWorkout) async -> String? {
	  // Check watch metadata first
	  if let meta = await getMetadata(for: workout),
		 let cityFromWatch = meta.weatherCity,
		 !cityFromWatch.isEmpty
	  {
	  cityNameCache[workout.uuid] = cityFromWatch
	  return cityFromWatch
	  }

	  // Fallback to geocode
	  if let cachedCity = cityNameCache[workout.uuid] {
		 return cachedCity
	  }

	  guard let routes = await getWorkoutRoute(workout: workout),
			let route = routes.first else {
		 cityNameCache[workout.uuid] = "Unknown City"
		 return "Unknown City"
	  }

	  let locations = await getCLocationDataForRoute(routeToExtract: route)
	  guard let firstLocation = locations.first else {
		 cityNameCache[workout.uuid] = "Unknown City"
		 return "Unknown City"
	  }

	  let geocoder = CLGeocoder()
	  do {
		 let placemarks = try await geocoder.reverseGeocodeLocation(firstLocation)
		 let foundCity = placemarks.first?.locality ?? "Unknown City"
		 cityNameCache[workout.uuid] = foundCity
		 return foundCity
	  } catch {
		 print("Reverse geocode error: \(error.localizedDescription)")
		 cityNameCache[workout.uuid] = "Unknown City"
		 return "Unknown City"
	  }
   }

   // MARK: - Distance
   func fetchDistance(for workout: HKWorkout) async -> Double {
	  if let cachedDistance = distanceCache[workout.uuid] {
		 return cachedDistance
	  }

	  // Try watch metadata first
	  if let meta = await getMetadata(for: workout),
		 let finalDist = meta.finalDistance {
		 distanceCache[workout.uuid] = finalDist
		 return finalDist
	  }

	  // Fallback => sum route distances
	  guard let routes = await getWorkoutRoute(workout: workout),
			!routes.isEmpty else {
		 distanceCache[workout.uuid] = 0
		 return 0
	  }

	  var totalMiles = 0.0
	  for route in routes {
		 let locs = await getCLocationDataForRoute(routeToExtract: route)
		 let routeDist = locs.calcDistance // this extension returns distance in miles
		 totalMiles += routeDist
	  }

	  distanceCache[workout.uuid] = totalMiles
	  return totalMiles
   }

   // MARK: - Detailed Route
   func fetchDetailedRouteData(for workout: HKWorkout) async -> [CLLocationCoordinate2D]? {
	  if let existing = routeCache[workout.uuid] {
		 return existing
	  }

	  guard let routes = await getWorkoutRoute(workout: workout),
			!routes.isEmpty else {
		 return nil
	  }

	  var combinedCoordinates: [CLLocationCoordinate2D] = []
	  for route in routes {
		 let locs = await getCLocationDataForRoute(routeToExtract: route)
		 combinedCoordinates.append(contentsOf: locs.map { $0.coordinate })
	  }

	  if !combinedCoordinates.isEmpty {
		 routeCache[workout.uuid] = combinedCoordinates
		 return combinedCoordinates
	  } else {
		 return nil
	  }
   }

   // MARK: - Paged Workouts
   func fetchPagedWorkouts(startDate: Date, endDate: Date,
						   limit: Int, page: Int) async throws -> [HKWorkout] {
	  let predicate = HKQuery.predicateForSamples(withStart: startDate,
												  end: endDate,
												  options: [.strictStartDate, .strictEndDate])
	  let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

	  let allWorkouts: [HKWorkout] = try await withCheckedThrowingContinuation { continuation in
		 let query = HKSampleQuery(sampleType: .workoutType(),
								   predicate: predicate,
								   limit: limit,
								   sortDescriptors: [sortDescriptor]) { _, result, error in
			if let err = error {
			   continuation.resume(throwing: err)
			} else if let workoutsList = result as? [HKWorkout] {
			   continuation.resume(returning: workoutsList)
			} else {
			   continuation.resume(returning: [])
			}
		 }
		 healthStore.execute(query)
	  }

	  var finalOutput: [HKWorkout] = []
	  for singleWorkout in allWorkouts {
		 if let routes = await getWorkoutRoute(workout: singleWorkout),
			!routes.isEmpty {
			for rt in routes {
			   let locs = await getCLocationDataForRoute(routeToExtract: rt)
			   if locs.contains(where: { $0.coordinate.latitude != 0 && $0.coordinate.longitude != 0 }) {
				  finalOutput.append(singleWorkout)
				  break
			   }
			}
		 }
	  }

	  return finalOutput
   }

   // MARK: - Route Queries
   func getWorkoutRoute(workout: HKWorkout) async -> [HKWorkoutRoute]? {
	  let byWorkoutPredicate = HKQuery.predicateForObjects(from: workout)
	  let routeSamples = try? await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[HKSample], Error>) in
		 healthStore.execute(HKAnchoredObjectQuery(type: HKSeriesType.workoutRoute(),
												   predicate: byWorkoutPredicate,
												   anchor: nil,
												   limit: HKObjectQueryNoLimit) { _, samples, _, _, err in
			if let e = err {
			   continuation.resume(throwing: e)
			} else {
			   let s = samples ?? []
			   continuation.resume(returning: s)
			}
		 })
	  }
	  guard let wkroutes = routeSamples as? [HKWorkoutRoute], !wkroutes.isEmpty else {
		 return nil
	  }
	  return wkroutes
   }

   func getCLocationDataForRoute(routeToExtract: HKWorkoutRoute) async -> [CLLocation] {
	  do {
		 let allLocations: [CLLocation] = try await withCheckedThrowingContinuation { continuation in
			var merged: [CLLocation] = []
			let locQuery = HKWorkoutRouteQuery(route: routeToExtract) { _, batchLocations, done, queryError in
			   if let someError = queryError {
				  continuation.resume(throwing: someError)
				  return
			   }
			   if let batch = batchLocations {
				  merged.append(contentsOf: batch)
			   }
			   if done {
				  continuation.resume(returning: merged)
			   }
			}
			healthStore.execute(locQuery)
		 }
		 return allLocations
	  } catch {
		 print("Error fetching route location data: \(error.localizedDescription)")
		 return []
	  }
   }

   // MARK: - Metadata
   private func getMetadata(for workout: HKWorkout) async -> WatchMetadata? {
	  if let existing = metadataCache[workout.uuid] {
		 return existing
	  }
	  guard let dict = workout.metadata, !dict.isEmpty else {
		 return nil
	  }
	  let watchMeta = WatchMetadata(
		 finalDistance: parseDouble(dict, key: "finalDistance"),
		 finalDuration: parseDouble(dict, key: "finalDuration"),
		 averageSpeed: parseDouble(dict, key: "averageSpeed"),
		 weatherCity: dict["weatherCity"] as? String,
		 weatherTemp: dict["weatherTemp"] as? String,
		 weatherSymbol: dict["weatherSymbol"] as? String,
		 windSpeed: dict["windSpeed"] as? String,
		 windDirection: dict["windDirection"] as? String
	  )
	  metadataCache[workout.uuid] = watchMeta
	  return watchMeta
   }

   private func parseDouble(_ dictionary: [String: Any], key: String) -> Double? {
	  if let val = dictionary[key] as? Double {
		 return val
	  } else if let str = dictionary[key] as? String, let dbl = Double(str) {
		 return dbl
	  }
	  return nil
   }
}
