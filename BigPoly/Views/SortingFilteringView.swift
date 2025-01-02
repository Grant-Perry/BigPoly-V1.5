import SwiftUI

struct SortingFilteringView: View {
   @ObservedObject var polyViewModel: PolyViewModel
   @Environment(\.dismiss) private var dismissEnvironment

   var body: some View {
	  Form {
		 Section(header: Text("Filters")) {
			// Replaced cbFilter with isShortDistanceFilterEnabled
			Toggle("Filter < 0.1 miles", isOn: $polyViewModel.isShortDistanceFilterEnabled)
		 }

		 Section(header: Text("Date Range")) {
			// Keeping startDate / endDate references unless told otherwise
			DatePicker("Start Date", selection: $polyViewModel.startDate, displayedComponents: .date)
			DatePicker("End Date", selection: $polyViewModel.endDate, displayedComponents: .date)
		 }

		 Button("Apply Filters") {
			// Clear existing workouts so the new filter applies
			polyViewModel.workouts.removeAll()
			polyViewModel.loadWorkouts(page: 0)
			dismissEnvironment()
		 }
	  }
	  .navigationTitle("Sort & Filter")
   }
}
