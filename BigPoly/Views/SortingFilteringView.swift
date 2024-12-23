import SwiftUI

struct SortingFilteringView: View {
   @ObservedObject var polyViewModel: PolyViewModel
   @Environment(\.dismiss) private var dismiss

   var body: some View {
	  Form {
		 Section(header: Text("Filters")) {
			Toggle("Filter < 0.1 miles", isOn: $polyViewModel.cbFilter)
			//			.toggleStyle(.checkbox)

			Toggle("Filter Points Above \(Int(polyViewModel.speedCollectLimit)) MPH", isOn: $polyViewModel.useSpeedFilter)
			   .onChange(of: polyViewModel.useSpeedFilter) { _ in
				  polyViewModel.routeCache.removeAll()
				  polyViewModel.distanceCache.removeAll()
			   }
			Stepper("Speed Limit: \(Int(polyViewModel.speedCollectLimit)) MPH",
					value: $polyViewModel.speedCollectLimit,
					in: 5...50,
					step: 5)
			.onChange(of: polyViewModel.speedCollectLimit) { _ in
			   polyViewModel.routeCache.removeAll()
			   polyViewModel.distanceCache.removeAll()
			}
		 }

		 Section(header: Text("Date Range")) {
			DatePicker("Start Date", selection: $polyViewModel.startDate, displayedComponents: .date)
			DatePicker("End Date", selection: $polyViewModel.endDate, displayedComponents: .date)
		 }

		 Button("Apply Filters") {
			polyViewModel.workouts.removeAll()
			// Load workouts with updated filters
			polyViewModel.loadWorkouts(page: 0)
			// Immediately dismiss this view after applying
			dismiss()
		 }
	  }
	  .navigationTitle("Sort & Filter")
   }
}
