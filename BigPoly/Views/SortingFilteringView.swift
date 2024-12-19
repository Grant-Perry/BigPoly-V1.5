import SwiftUI

struct SortingFilteringView: View {
   @ObservedObject var polyViewModel: PolyViewModel
   @Environment(\.dismiss) private var dismiss

   var body: some View {
	  Form {
		 Toggle("Filter < 0.1 miles", isOn: $polyViewModel.cbFilter)
//			.toggleStyle(.checkbox)

		 DatePicker("Start Date", selection: $polyViewModel.startDate, displayedComponents: .date)
		 DatePicker("End Date", selection: $polyViewModel.endDate, displayedComponents: .date)
		 Stepper("Limit: \(polyViewModel.limit)", value: $polyViewModel.limit, in: 1...100)

		 Button("Apply Filters") {
			// Load workouts with updated filters
			polyViewModel.loadWorkouts(page: 0)
			// Immediately dismiss this view after applying
			dismiss()
		 }
	  }
	  .navigationTitle("Sort & Filter")
   }
}
