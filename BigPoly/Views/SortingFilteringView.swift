import SwiftUI

struct SortingFilteringView: View {
   @ObservedObject var polyViewModel: PolyViewModel
   @Environment(\.dismiss) private var dismiss

   var body: some View {
	  Form {
		 Toggle("Filter < 0.1 miles", isOn: $polyViewModel.shortRouteFilter)

		 DatePicker("Start Date", selection: $polyViewModel.startDate, displayedComponents: .date)
		 DatePicker("End Date", selection: $polyViewModel.endDate, displayedComponents: .date)

		 /// Changed step increments to 10
		 Stepper("Limit: \(polyViewModel.limit)",
				 value: $polyViewModel.limit,
				 in: 1...100,
				 step: 10)

		 Button("Apply Filters") {
			polyViewModel.loadWorkouts(page: 0)
			dismiss()
		 }
	  }
	  .navigationTitle("Sort & Filter")
   }
}
