//   SortingFilteringView.swift
//   BigPoly
//
//   Created by: Grant Perry on 2/14/24 at 11:58 AM
//     Modified: 
//
//  Copyright © 2024 Delicious Studios, LLC. - Grant Perry
//
import SwiftUI

struct SortingFilteringView: View {
	@Environment(\.presentationMode) var presentationMode

	@Binding var startDate: Date
	@Binding var endDate: Date
	@Binding var limit: Int
	var applyFilters: () -> Void

	var body: some View {
		Form {
			DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
			DatePicker("End Date", selection: $endDate, displayedComponents: .date)

			Stepper("Limit: \(limit)", value: $limit, in: 1...100)

			Button("Apply Filters") {
				applyFilters() // This will reload the workouts
				presentationMode.wrappedValue.dismiss() // Dismiss the SortingFilteringView
			}
		}
		.navigationTitle("Sort & Filter")
	}
}
