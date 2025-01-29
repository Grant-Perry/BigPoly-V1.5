import SwiftUI

struct CityCoords {
   var cityName: String
   var longitude: Double
   var latitude: Double
}

let cityCoords: [String: CityCoords] = [
   "New York": CityCoords(cityName: "New York", longitude: -74.005973, latitude: 40.712776),
   "Los Angeles": CityCoords(cityName: "Los Angeles", longitude: -118.243685, latitude: 34.052234),
   "Chicago": CityCoords(cityName: "Chicago", longitude: -87.629798, latitude: 41.878113),
   "Houston": CityCoords(cityName: "Houston", longitude: -95.369803, latitude: 29.760427),
   "Phoenix": CityCoords(cityName: "Phoenix", longitude: -112.074037, latitude: 33.448377),
   "Philadelphia": CityCoords(cityName: "Philadelphia", longitude: -75.165222, latitude: 39.952583),
   "San Antonio": CityCoords(cityName: "San Antonio", longitude: -98.493628, latitude: 29.424122),
   "San Diego": CityCoords(cityName: "San Diego", longitude: -117.161084, latitude: 32.715738),
   "Dallas": CityCoords(cityName: "Dallas", longitude: -96.7970, latitude: 32.7767),
   "San Jose": CityCoords(cityName: "San Jose", longitude: -121.886329, latitude: 37.338208),
   "Austin": CityCoords(cityName: "Austin", longitude: -97.743061, latitude: 30.267153),
   "Jacksonville": CityCoords(cityName: "Jacksonville", longitude: -81.655651, latitude: 30.332184),
   "Fort Worth": CityCoords(cityName: "Fort Worth", longitude: -97.330766, latitude: 32.755488),
   "Columbus": CityCoords(cityName: "Columbus", longitude: -82.998794, latitude: 39.961176),
   "Charlotte": CityCoords(cityName: "Charlotte", longitude: -80.843127, latitude: 35.227087),
   "San Francisco": CityCoords(cityName: "San Francisco", longitude: -122.419416, latitude: 37.774929),
   "Indianapolis": CityCoords(cityName: "Indianapolis", longitude: -86.158068, latitude: 39.768403),
   "Seattle": CityCoords(cityName: "Seattle", longitude: -122.332071, latitude: 47.606209),
   "Denver": CityCoords(cityName: "Denver", longitude: -104.990251, latitude: 39.739236),
   "Washington": CityCoords(cityName: "Washington D.C.", longitude: -77.036871, latitude: 38.907192)
]
