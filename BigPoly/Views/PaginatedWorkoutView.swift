//   PaginatedWorkoutView.swift
//   BigPoly
//
//   Created by: Grant Perry on 2/14/24 at 11:17 AM
//     Modified: 
//
//  Copyright © 2024 Delicious Studios, LLC. - Grant Perry
//

import SwiftUI
import HealthKit

struct PaginatedWorkoutsView: View {
	@State private var workouts: [HKWorkout] = []
	@State private var isLoading = false
	@State private var startDate = Calendar.current.date(byAdding: .year, value: -1, to: Date())!
	@State private var endDate = Date()
	@State private var limit = 20 // Default limit
	@State private var currentPage = 0

	var body: some View {
		NavigationView {
			VStack {
				NavigationLink("Sort & Filter", destination: SortingFilteringView(
					startDate: $startDate,
					endDate: $endDate,
					limit: $limit,
					applyFilters: {
						currentPage = 0 // Reset to the first page
						loadWorkouts() // Reload workouts with the new filters
					}
				))

				List(workouts, id: \.uuid) { workout in
					NavigationLink(destination: FullMapView(workout: workout)) {
						WorkoutRouteView(workout: workout)
					}
				}
				.navigationTitle("Workouts")
				if isLoading {
					ProgressView()
				}

				Button("Load More") {
					currentPage += 1
					loadWorkouts()
				}
			}
			.navigationTitle("Workouts")
		}
		.onAppear {
			loadWorkouts()
		}
	}


	private func loadWorkouts() {
		guard !isLoading else { return }
		isLoading = true

		Task {
			do {
				let newWorkouts = try await WorkoutCore.shared.fetchPagedWorkouts(startDate: startDate, endDate: endDate, limit: limit, page: currentPage)
				if currentPage == 0 {
					workouts = newWorkouts
				} else {
					workouts.append(contentsOf: newWorkouts)
				}
				isLoading = false
			} catch {
				print("Failed to load workouts: \(error)")
				isLoading = false
			}
		}
	}

}



#Preview {
	PaginatedWorkoutsView()
}
