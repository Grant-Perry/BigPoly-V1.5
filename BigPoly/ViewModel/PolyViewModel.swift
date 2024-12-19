import SwiftUI
import HealthKit
import CoreLocation
import Combine

class PolyViewModel: ObservableObject {
   @Published var workouts: [HKWorkout] = []
   @Published var isLoading: Bool = false
   @Published var endDate: Date = Date() // Today
   @Published var startDate: Date = Calendar.current.date(byAdding: .day, value: -14, to: Date()) ?? Date().addingTimeInterval(-14 * 24 * 3600)//   @Published var startDate: Date = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
//   @Published var endDate: Date = Date()
   @Published var limit: Int = 40
   @Published var cbFilter: Bool = true


   var cityNameCache: [UUID: String] = [:]
   var routeCache: [UUID: [CLLocationCoordinate2D]] = [:]
   var distanceCache: [UUID: Double] = [:]

   private let healthStore = HKHealthStore()

   init() {}

   func requestHealthKitPermission() async throws {
	  let typesToRead: Set<HKObjectType> = [
		 HKObjectType.workoutType(),
		 HKSeriesType.workoutRoute()
	  ]
	  try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
   }

   func loadWorkouts(page: Int) {
	  guard !isLoading else { return }
	  isLoading = true

	  Task { [weak self] in
		 guard let self = self else { return }

		 do {
			try await self.requestHealthKitPermission()
			let fetched = try await self.fetchPagedWorkouts(startDate: self.startDate, endDate: self.endDate, limit: self.limit, page: page)

			var filtered: [HKWorkout] = []
			if self.cbFilter {
			   for workout in fetched {
				  if let distance = await self.fetchDistance(for: workout), distance >= 0.1 {
					 filtered.append(workout)
				  }
			   }
			} else {
			   filtered = fetched
			}

			DispatchQueue.main.async { [weak self] in
			   guard let self = self else { return }
			   if page == 0 {
				  self.workouts = filtered
			   } else {
				  self.workouts.append(contentsOf: filtered)
			   }
			   self.isLoading = false
			}
		 } catch {
			DispatchQueue.main.async { [weak self] in
			   guard let self = self else { return }
			   print("Failed to load workouts: \(error)")
			   self.isLoading = false
			}
		 }
	  }
   }

   func fetchCityName(for workout: HKWorkout) async -> String? {
	  if let cachedCity = cityNameCache[workout.uuid] {
		 return cachedCity
	  }

	  guard let routes = await getWorkoutRoute(workout: workout), let route = routes.first else {
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

   func fetchDistance(for workout: HKWorkout) async -> Double? {
	  if let cached = distanceCache[workout.uuid] {
		 return cached
	  }
	  // Need full route to compute distance
	  guard let coords = await fetchDetailedRouteData(for: workout), !coords.isEmpty else {
		 distanceCache[workout.uuid] = 0
		 return 0
	  }

	  let distance = coords.map { $0.location }.calcDistance
	  distanceCache[workout.uuid] = distance
	  return distance
   }

   func distanceForWorkout(_ workout: HKWorkout) -> Double {
	  distanceCache[workout.uuid] ?? 0
   }

   func fetchDetailedRouteData(for workout: HKWorkout) async -> [CLLocationCoordinate2D]? {
	  if let cachedRoute = routeCache[workout.uuid] {
		 return cachedRoute
	  }

	  guard let routes = await getWorkoutRoute(workout: workout), !routes.isEmpty else {
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
		 return allCoordinates
	  } else {
		 return nil
	  }
   }

   func fetchPagedWorkouts(startDate: Date, endDate: Date, limit: Int, page: Int) async throws -> [HKWorkout] {
	  let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [.strictStartDate, .strictEndDate])
	  let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false) // If you want chronological order from start to end

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

	  return filteredWorkouts
   }

   func getWorkoutRoute(workout: HKWorkout) async -> [HKWorkoutRoute]? {
	  let byWorkout = HKQuery.predicateForObjects(from: workout)
	  let samples = try? await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[HKSample], Error>) in
		 healthStore.execute(HKAnchoredObjectQuery(type: HKSeriesType.workoutRoute(),
												   predicate: byWorkout,
												   anchor: nil,
												   limit: HKObjectQueryNoLimit) { _, samples, _, _, error in
			if let error = error {
			   continuation.resume(throwing: error)
			   return
			}
			let s = samples ?? []
			continuation.resume(returning: s)
		 })
	  }
	  guard let workouts = samples as? [HKWorkoutRoute] else { return nil }
	  return workouts
   }

   func getCLocationDataForRoute(routeToExtract: HKWorkoutRoute) async -> [CLLocation] {
	  do {
		 let locations: [CLLocation] = try await withCheckedThrowingContinuation { continuation in
			var allLocations: [CLLocation] = []
			let query = HKWorkoutRouteQuery(route: routeToExtract) { _, locationsOrNil, done, errorOrNil in
			   if let error = errorOrNil {
				  continuation.resume(throwing: error)
				  return
			   }
			   if let locationsOrNil = locationsOrNil {
				  allLocations.append(contentsOf: locationsOrNil)
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
