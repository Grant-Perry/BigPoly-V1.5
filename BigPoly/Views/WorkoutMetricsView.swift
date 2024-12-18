//   WorkoutMetricsView.swift
//   BigPoly
//
//   Created by: Grant Perry on 2/14/24 at 12:20 PM
//     Modified: 
//
//  Copyright © 2024 Delicious Studios, LLC. - Grant Perry
//
import SwiftUI

struct WorkoutMetricsView: View {
	var cityName: String
	var workoutDate: Date

	var body: some View {
		HStack {
			VStack(alignment: .leading) {
				Text("\(cityName)")
					.font(.title)
					.bold()
				Text("  \(workoutDate, formatter: dateFormatter)")
			}
			Spacer()
			Text("Distance: \(String(format: "%.2f", WorkoutCore.shared.distance))")
				.bold()
		}
		.padding()
		.frame(maxWidth: .infinity)
		.background(.blue.gradient)
//		.background(LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing))
		.foregroundColor(.white)
		.cornerRadius(8)
		.shadow(color: .gray, radius: 5, x: 0, y: 2)
	}

	private var dateFormatter: DateFormatter {
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		return formatter
	}
}


#Preview {
	WorkoutMetricsView(cityName: "Luray", workoutDate: Date())
}
