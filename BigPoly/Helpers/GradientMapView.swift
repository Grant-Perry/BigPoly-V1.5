import SwiftUI
import MapKit

struct GradientMapView: UIViewRepresentable {
   var coordinates: [CLLocationCoordinate2D]

   func makeUIView(context: Context) -> MKMapView {
	  let mapView = MKMapView()
	  mapView.delegate = context.coordinator
	  mapView.isZoomEnabled = true
	  mapView.isScrollEnabled = true
	  mapView.isRotateEnabled = true

	  // Add polyline
	  let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
	  mapView.addOverlay(polyline)

	  // Add annotations for start and end points if available
	  if let start = coordinates.first {
		 let startAnnotation = MKPointAnnotation()
		 startAnnotation.coordinate = start
		 startAnnotation.title = "Start"
		 mapView.addAnnotation(startAnnotation)
	  }

	  if let end = coordinates.last {
		 let endAnnotation = MKPointAnnotation()
		 endAnnotation.coordinate = end
		 endAnnotation.title = "End"
		 mapView.addAnnotation(endAnnotation)
	  }

	  // Set region to show entire route
	  if let first = coordinates.first, let last = coordinates.last {
		 let latDelta = abs(first.latitude - last.latitude) * 1.5
		 let lonDelta = abs(first.longitude - last.longitude) * 1.5
		 let region = MKCoordinateRegion(
			center: CLLocationCoordinate2D(latitude: (first.latitude+last.latitude)/2,
										   longitude: (first.longitude+last.longitude)/2),
			span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
		 )
		 mapView.setRegion(region, animated: false)
	  }

	  return mapView
   }

   func updateUIView(_ uiView: MKMapView, context: Context) {
	  // No dynamic updates needed
   }

   func makeCoordinator() -> Coordinator {
	  Coordinator(self)
   }

   class Coordinator: NSObject, MKMapViewDelegate {
	  var parent: GradientMapView

	  init(_ parent: GradientMapView) {
		 self.parent = parent
	  }

	  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
		 if let polyline = overlay as? MKPolyline {
			// Currently, it's green->yellow->red evenly spaced.
			// To make the end more pronounced red, add another red stop at the end.
			// This ensures more of the latter part remains solidly red.
			let colors = [
			   UIColor.green.cgColor,
			   UIColor.yellow.cgColor,
			   UIColor.red.cgColor,
			   UIColor.red.cgColor // Adding another red to emphasize the end portion as red
			]

			let renderer = GradientPathRenderer(polyline: polyline, colors: colors)
			renderer.lineWidth = 6
			renderer.lineCap = .round
			renderer.lineJoin = .round
			return renderer
		 }
		 return MKOverlayRenderer()
	  }

	  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		 let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: nil)
		 if annotation.title == "Start" {
			annotationView.markerTintColor = .green
			annotationView.glyphImage = UIImage(systemName: "figure.walk.departure")
		 } else if annotation.title == "End" {
			annotationView.markerTintColor = .red
			annotationView.glyphImage = UIImage(systemName: "figure.walk.arrival")
		 }
		 return annotationView
	  }
   }
}
