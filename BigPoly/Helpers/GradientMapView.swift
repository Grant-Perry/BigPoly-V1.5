import SwiftUI
import MapKit

struct GradientMapView: UIViewRepresentable {
   var coordinates: [CLLocationCoordinate2D]
   @Binding var mapType: MKMapType // Add a binding for map type selection
   
   func makeUIView(context: Context) -> MKMapView {
	  let mapView = MKMapView()
	  mapView.delegate = context.coordinator
	  mapView.isZoomEnabled = true
	  mapView.isScrollEnabled = true
	  mapView.isRotateEnabled = true
	  mapView.mapType = mapType // Use the selected map type
	  
	  // Add polyline
	  let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
	  mapView.addOverlay(polyline)
	  
	  // Add start and end annotations
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
	  
	  // Calculate the bounding box for all coordinates
	  var minLat = coordinates.map { $0.latitude }.min() ?? 0
	  var maxLat = coordinates.map { $0.latitude }.max() ?? 0
	  var minLon = coordinates.map { $0.longitude }.min() ?? 0
	  var maxLon = coordinates.map { $0.longitude }.max() ?? 0
	  
	  // Add padding to the bounding box (20%)
	  let latPadding = (maxLat - minLat) * 0.2
	  let lonPadding = (maxLon - minLon) * 0.2
	  minLat -= latPadding
	  maxLat += latPadding
	  minLon -= lonPadding
	  maxLon += lonPadding
	  
	  // Create region that encompasses all points
	  let center = CLLocationCoordinate2D(
		 latitude: (minLat + maxLat) / 2,
		 longitude: (minLon + maxLon) / 2
	  )
	  let span = MKCoordinateSpan(
		 latitudeDelta: maxLat - minLat,
		 longitudeDelta: maxLon - minLon
	  )
	  let region = MKCoordinateRegion(center: center, span: span)
	  
	  // Set the region with animation disabled
	  mapView.setRegion(region, animated: false)
	  
	  return mapView
   }
   
   func updateUIView(_ uiView: MKMapView, context: Context) {
	  uiView.mapType = mapType // Dynamically update the map type
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
			
			let renderer = GradientPathRenderer(polyline: polyline)
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
