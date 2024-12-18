//   HKActivityTypeEXT.swift
//   BigPoly
//
//   Created by: Grant Perry on 2/14/24 at 11:21 AM
//     Modified: 
//
//  Copyright © 2024 Delicious Studios, LLC. - Grant Perry
//

import SwiftUI
import HealthKit

extension HKWorkoutActivityType {
	var name: String {
		switch self {
			case.walking: return "Walking"
			case .running: return "Running"
			case .cycling: return "Cycling"
			default: return "Other"
		}
	}
}

