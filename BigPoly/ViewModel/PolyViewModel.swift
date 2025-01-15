import SwiftUI
import HealthKit
import CoreLocation
import Combine

class PolyViewModel: ObservableObject {
   @Published var workouts: [HKWorkout] = []
   @Published var isLoading: Bool = false
   @Published var endDate: Date = Date() // Today
   @Published var startDate: Date = Calendar.current.date(byAdding: .day, value: -14, to: Date())
   ?? Date().addingTimeInterval(-14 * 24 * 3600)
   @Published var limit: Int = 15
   @Published var shortRouteFilter: Bool = true

   /// Cache for city names keyed by workout UUID.
   var cityNameCache: [UUID: String] = [:]

   /// Cache for entire route (coordinates) keyed by workout UUID.
   var routeCache: [UUID: [CLLocationCoordinate2D]] = [:]

   /// Cache for computed or metadata-derived distance keyed by workout UUID.
   var distanceCache: [UUID: Double] = [:]

   /// Cache for weather info keyed by workout UUID. (temp, symbol)
   var weatherCache: [UUID: (String?, String?)] = [:]

   /// NEW: Cache for full CLLocation data, used to fetch timestamps.
   var locationDataCache: [UUID: [CLLocation]] = [:]

   private let healthStore = HKHealthStore()

   /// Common user-defined metadata keys you might store in the watch app
   private let METADATA_KEY_FINAL_DISTANCE = "finalDistance"
   private let METADATA_KEY_FINAL_DURATION = "finalDuration"
   private let METADATA_KEY_AVERAGE_SPEED  = "averageSpeed"
   private let METADATA_KEY_WEATHER_TEMP   = "weatherTemp"
   private let METADATA_KEY_WEATHER_SYMBOL = "weatherSymbol"

   init() {}

   func requestHealthKitPermission() async throws {
	  let typesToRead: Set<HKObjectType> = [
		 HKObjectType.workoutType(),
		 HKSeriesType.workoutRoute()
	  ]
	  try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
   }

   /// Loads workouts in pages, applying filtering if cbFilter is true.
   func loadWorkouts(page: Int) {
	  guard !isLoading else { return }
	  isLoading = true

	  Task { [weak self] in
		 guard let self = self else { return }
		 do {
			try await self.requestHealthKitPermission()
			let fetched = try await self.fetchPagedWorkouts(
			   startDate: self.startDate,
			   endDate: self.endDate,
			   limit: self.limit,
			   page: page
			)

			var filtered: [HKWorkout] = []
			if self.shortRouteFilter {
			   for workout in fetched {
				  if let distance = await self.fetchDistance(for: workout), distance >= 0.1 {
					 filtered.append(workout)
				  }
			   }
			} else {
			   filtered = fetched
			}

			DispatchQueue.main.async {
			   if page == 0 {
				  self.workouts = filtered
			   } else {
				  self.workouts.append(contentsOf: filtered)
			   }
			   self.isLoading = false
			}
		 } catch {
			DispatchQueue.main.async {
			   print("Failed to load workouts: \(error)")
			   self.isLoading = false
			}
		 }
	  }
   }

   /// Gets city name from cache or fallback geocoding
   func fetchCityName(for workout: HKWorkout) async -> String? {
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
		 let city = placemarks.first?.locality ?? "Unknown City"
		 cityNameCache[workout.uuid] = city
		 return city
	  } catch {
		 print("Address not found: \(error.localizedDescription)")
		 cityNameCache[workout.uuid] = "Unknown City"
		 return "Unknown City"
	  }
   }

   /// Fetch distance from metadata if available; else route-based calculation.
   func fetchDistance(for workout: HKWorkout) async -> Double? {
	  if let cached = distanceCache[workout.uuid] {
		 return cached
	  }

	  // DP: Print entire metadata for debugging
	  print("DP - Checking METADATA for workout \(workout.uuid): META: \(String(describing: workout.metadata))")

	  // finalDistance can be stored as string or double
	  if let metaDistStr = workout.metadata?[METADATA_KEY_FINAL_DISTANCE] as? String,
		 let distDouble = Double(metaDistStr) {
		 print("DP - Found finalDistance as String: \(distDouble)")
		 distanceCache[workout.uuid] = distDouble
		 return distDouble
	  } else if let numericDist = workout.metadata?[METADATA_KEY_FINAL_DISTANCE] as? Double {
		 print("DP - Found finalDistance as Double: \(numericDist)")
		 distanceCache[workout.uuid] = numericDist
		 return numericDist
	  }

	  // fallback: compute from route
	  guard let coords = await fetchDetailedRouteData(for: workout), !coords.isEmpty else {
		 print("DP - No route coords or empty route for workout \(workout.uuid), distance = 0")
		 distanceCache[workout.uuid] = 0
		 return 0
	  }

	  let distance = coords.map { $0.location }.calcDistance
	  print("DP - Calculated distance from route: \(distance)")
	  distanceCache[workout.uuid] = distance
	  return distance
   }

   /// If watch wrote finalDuration in metadata, use it; else default to workout.duration
   func fetchDuration(for workout: HKWorkout) -> TimeInterval {
	  if let metaDurStr = workout.metadata?[METADATA_KEY_FINAL_DURATION] as? String,
		 let metaDurVal = Double(metaDurStr) {
		 print("DP - Found finalDuration as String: \(metaDurVal)")
		 return metaDurVal
	  }
	  if let metaDurDouble = workout.metadata?[METADATA_KEY_FINAL_DURATION] as? Double {
		 print("DP - Found finalDuration as Double: \(metaDurDouble)")
		 return metaDurDouble
	  }
	  print("DP - No finalDuration in metadata, using workout.duration: \(workout.duration)")
	  return workout.duration
   }

   /// If the watch wrote averageSpeed, read it. Otherwise return nil.
   func fetchAverageSpeed(for workout: HKWorkout) -> Double? {
	  if let metaSpeedStr = workout.metadata?[METADATA_KEY_AVERAGE_SPEED] as? String,
		 let metaSpeedVal = Double(metaSpeedStr) {
		 print("DP - Found averageSpeed as String: \(metaSpeedVal) mph")
		 return metaSpeedVal
	  }
	  if let metaSpeedDouble = workout.metadata?[METADATA_KEY_AVERAGE_SPEED] as? Double {
		 print("DP - Found averageSpeed as Double: \(metaSpeedDouble) mph")
		 return metaSpeedDouble
	  }
	  print("DP - No averageSpeed in metadata for workout \(workout.uuid)")
	  return nil
   }

   /// Fetch weather from metadata. If missing, attempt a fallback approach (currently none).
   func fetchWeather(for workout: HKWorkout) async -> (String?, String?)? {
	  if let cached = weatherCache[workout.uuid] {
		 print("DP - Found weather in weatherCache for \(workout.uuid): \(cached)")
		 return cached
	  }

	  // If watch wrote weather metadata, use it
	  let metaTemp = workout.metadata?[METADATA_KEY_WEATHER_TEMP] as? String
	  let metaSymbol = workout.metadata?[METADATA_KEY_WEATHER_SYMBOL] as? String
	  if let tempVal = metaTemp, let symbolVal = metaSymbol {
		 print("DP - Found weather metadata => Temp: \(tempVal), Symbol: \(symbolVal)")
		 weatherCache[workout.uuid] = (tempVal, symbolVal)
		 return (tempVal, symbolVal)
	  }

	  print("DP - No watch-based weather found for \(workout.uuid). Fallback not implemented.")
	  weatherCache[workout.uuid] = (nil, nil)
	  return nil
   }

   /// Returns the entire array of location data for the given workout, for time-based display, etc.
   func fetchFullLocationData(for workout: HKWorkout) async -> [CLLocation]? {
	  if let existing = locationDataCache[workout.uuid] {
		 return existing
	  }

	  guard let routes = await getWorkoutRoute(workout: workout), !routes.isEmpty else {
		 locationDataCache[workout.uuid] = []
		 return []
	  }

	  var fullData: [CLLocation] = []
	  for route in routes {
		 let locs = await getCLocationDataForRoute(routeToExtract: route)
		 fullData.append(contentsOf: locs)
	  }
	  locationDataCache[workout.uuid] = fullData
	  print("DP - fetchFullLocationData => Found \(fullData.count) location points for workout \(workout.uuid)")
	  return fullData
   }

   /// Return just the coordinate array (cached).
   func fetchDetailedRouteData(for workout: HKWorkout) async -> [CLLocationCoordinate2D]? {
	  if let cachedRoute = routeCache[workout.uuid] {
		 return cachedRoute
	  }

	  guard let routes = await getWorkoutRoute(workout: workout), !routes.isEmpty else {
		 print("\nDP - getWorkoutRoute => no route or empty for workout \(workout.uuid)")
		 return nil
	  }

	  var allCoordinates: [CLLocationCoordinate2D] = []
	  for route in routes {
		 let locations = await getCLocationDataForRoute(routeToExtract: route)
		 if !locations.isEmpty {
			allCoordinates.append(contentsOf: locations.map { $0.coordinate })
		 }
	  }

	  if !allCoordinates.isEmpty {
		 routeCache[workout.uuid] = allCoordinates
		 print("DP - fetchDetailedRouteData => Found \(allCoordinates.count) coords for \(workout.uuid)")
		 return allCoordinates
	  } else {
		 print("DP - fetchDetailedRouteData => No valid coords for \(workout.uuid)")
		 return nil
	  }
   }

   func fetchPagedWorkouts(startDate: Date,
						   endDate: Date,
						   limit: Int,
						   page: Int) async throws -> [HKWorkout] {
	  let predicate = HKQuery.predicateForSamples(withStart: startDate,
												  end: endDate,
												  options: [.strictStartDate, .strictEndDate])
	  let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

	  let allWorkouts: [HKWorkout] = try await withCheckedThrowingContinuation { continuation in
		 let query = HKSampleQuery(sampleType: HKObjectType.workoutType(),
								   predicate: predicate,
								   limit: limit,
								   sortDescriptors: [sortDescriptor]) { _, result, error in
			if let error = error {
			   continuation.resume(throwing: error)
			} else if let workouts = result as? [HKWorkout] {
			   continuation.resume(returning: workouts)
			} else {
			   continuation.resume(returning: [])
			}
		 }
		 self.healthStore.execute(query)
	  }

	  var filteredWorkouts: [HKWorkout] = []
	  for w in allWorkouts {
		 if let routes = await getWorkoutRoute(workout: w), !routes.isEmpty {
			for route in routes {
			   let locations = await getCLocationDataForRoute(routeToExtract: route)
			   if locations.contains(where: { $0.coordinate.latitude != 0 && $0.coordinate.longitude != 0 }) {
				  filteredWorkouts.append(w)
				  break
			   }
			}
		 }
	  }

	  print("DP - fetchPagedWorkouts => returning \(filteredWorkouts.count) workouts after route filter.")
	  return filteredWorkouts
   }

   /// Fetches route objects from HealthKit for a given workout.
   func getWorkoutRoute(workout: HKWorkout) async -> [HKWorkoutRoute]? {
	  let byWorkout = HKQuery.predicateForObjects(from: workout)
	  let samples = try? await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[HKSample], Error>) in
		 healthStore.execute(
			HKAnchoredObjectQuery(
			   type: HKSeriesType.workoutRoute(),
			   predicate: byWorkout,
			   anchor: nil,
			   limit: HKObjectQueryNoLimit
			) { _, samples, _, _, error in
			   if let error = error {
				  continuation.resume(throwing: error)
				  return
			   }
			   let s = samples ?? []
			   continuation.resume(returning: s)
			}
		 )
	  }
	  guard let workouts = samples as? [HKWorkoutRoute] else {
		 print("\nDP - getWorkoutRoute => no HKWorkoutRoute found for \(workout.uuid)")
		 return nil
	  }
	  print("\nDP - getWorkoutRoute => \(workouts.count) route(s) for \(workout.uuid)")
	  return workouts
   }

   /// Fetches the CLLocation data from a single HKWorkoutRoute
   func getCLocationDataForRoute(routeToExtract: HKWorkoutRoute) async -> [CLLocation] {
	  do {
		 let locations: [CLLocation] = try await withCheckedThrowingContinuation { continuation in
			var allLocations: [CLLocation] = []
			let query = HKWorkoutRouteQuery(route: routeToExtract) { _, locsOrNil, done, errOrNil in
			   if let err = errOrNil {
				  continuation.resume(throwing: err)
				  return
			   }
			   if let locsOrNil = locsOrNil {
				  allLocations.append(contentsOf: locsOrNil)
				  if done {
					 continuation.resume(returning: allLocations)
				  }
			   } else {
				  continuation.resume(returning: [])
			   }
			}
			self.healthStore.execute(query)
		 }
		 return locations
	  } catch {
		 print("Error fetching location data: \(error.localizedDescription)")
		 return []
	  }
   }
}
