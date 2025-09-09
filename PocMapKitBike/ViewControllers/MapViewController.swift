//
//  MapViewController.swift
//  PocMapKitBike
//
//  Created by Leticia Bezerra on 25/08/25.
//

import UIKit
import MapKit
import CoreLocation
import SwiftUI

struct BikeLane {
    let coordinates: [CLLocationCoordinate2D]
}

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    var mapView: MKMapView!
    var locationManager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D?

    var start = CLLocationCoordinate2D(latitude: -3.71722, longitude: -38.5434)
    var end = CLLocationCoordinate2D(latitude: -3.72000, longitude: -38.5465)
    
//    var allBikeLanes: [MKPolyline] = []
    
    var allBikeLanes: [BikeLane] = []
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:  // Location services are available.
            manager.startUpdatingLocation()
            break
            
        case .restricted, .denied:  // Location services currently unavailable.
//            disableLocationFeatures()
            break
            
        case .notDetermined:        // Authorization not determined yet.
           manager.requestWhenInUseAuthorization()
            break
            
        default:
            break
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        mapView.delegate = self
        locationManager.delegate = self
        locationManagerDidChangeAuthorization(locationManager)
//        locationManager.startUpdatingLocation()
//
        let region = MKCoordinateRegion(center: start, latitudinalMeters: 10000, longitudinalMeters: 10000)
        mapView.setRegion(region, animated: true)

        // Anotação inicial
        let annotation = CommunityAnnotation(
            coordinate: start,
            title: "Byques",
            subtitle: "De boas",
            communityInfo: "Informações detalhadas sobre a comunidade Byques.",
            phone: "123456789",
            websiteURL: URL(string: "https://example.com"),
            instagramUsername: "byques",
            whatsappLink: URL(string: "https://wa.me/123456789")
        )
        mapView.addAnnotation(annotation)

        // Desenha as ciclofaixas do JSON
        drawBikeLanes()

        // Botão calcular rota
        let button = UIButton(type: .system)
        button.setTitle("Calcular rota", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(calculateBikeRoute), for: .touchUpInside)
        view.addSubview(button)
        NSLayoutConstraint.activate([
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.widthAnchor.constraint(equalToConstant: 220),
            button.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    // Ciclofaixas
    func drawBikeLanes() {
        guard let json = FortalezaJSON.loadQuickTypeGeoJSON(named: "fortaleza-ciclovias") else {
            print("Erro: não foi possível carregar o JSON de ciclofaixas")
            return
        }

        allBikeLanes.removeAll()

        for feature in json.features {
            let coordinates = feature.geometry.coordinates.map {
                CLLocationCoordinate2D(latitude: $0[1], longitude: $0[0])
            }

            guard !coordinates.isEmpty else { continue }

//            let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
//            polyline.title = "bikeLane"
            allBikeLanes.append(BikeLane(coordinates: coordinates))
        }
    }

    // Rotas
    @objc func calculateBikeRoute() {
        let inputVC = RouteInputViewController()
        inputVC.setText()
        inputVC.modalPresentationStyle = .pageSheet
        inputVC.onLocationsSelected = { [weak self] newStart, newEnd in
            guard let self = self else { return }
            self.start = newStart
            self.end = newEnd
            self.performRouteCalculation()
        }
        present(inputVC, animated: true)
    }

    func performRouteCalculation() {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: start))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: end))
        request.transportType = .walking
        request.requestsAlternateRoutes = false

        let directions = MKDirections(request: request)
        directions.calculate { [weak self] response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Erro ao calcular rota: \(error)")
                return
            }
            
            guard let route = response?.routes.first else {
                print("Nenhuma rota encontrada")
                return
            }

            // Converte a rota em array de coordenadas
            let routeCoords: [CLLocationCoordinate2D] = (0..<route.polyline.pointCount).map {
                route.polyline.points()[$0].coordinate
            }

            // Remove overlays antigos de ciclofaixas
            for overlay in self.mapView.overlays {
                if let polyline = overlay as? MKPolyline, polyline.title == "bikeLane" {
                    self.mapView.removeOverlay(polyline)
                }
            }

            // Adiciona a rota do MapKit
            self.mapView.addOverlay(route.polyline)
            self.mapView.setVisibleMapRect(
                route.polyline.boundingMapRect,
                edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 100, right: 50),
                animated: true
            )
            
            // Filtra e adiciona apenas ciclofaixas próximas da rota
            for bikeLane in self.allBikeLanes {
                let bikeCoords = bikeLane.coordinates
                
                let distance = self.minDistanceBetween(routeCoords: routeCoords, bikeCoords: bikeCoords)
                if distance <= 120 { // 20 metros do percurso
                    let coordinates = bikeLane.coordinates.filter { coordinate in
                        let isCloseToRoute = routeCoords.contains { routeCoordinate in
                            self.distanceInMeters(a: coordinate, b: routeCoordinate) <= 100
                        }
                        return isCloseToRoute
                    }
//                    var coordinates: [CLLocationCoordinate2D] = []
//                    print(bikeLane.coordinates.count)
//                    if bikeLane.coordinates.count == 19 {
//                        coordinates = Array(bikeLane.coordinates[15...])
//                    } else {
//                        coordinates = bikeLane.coordinates
//                    }
                    let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
                    polyline.title = "bikeLane"
                    self.mapView.addOverlay(polyline)
                }
            }
        }
    }
    
    func distanceInMeters(a: CLLocationCoordinate2D, b: CLLocationCoordinate2D) -> CLLocationDistance {
        let locA = CLLocation(latitude: a.latitude, longitude: a.longitude)
        let locB = CLLocation(latitude: b.latitude, longitude: b.longitude)
        return locA.distance(from: locB)
    }
    
    // Função auxiliar: calcula distância mínima de uma polyline até outra
    func minDistanceBetween(routeCoords: [CLLocationCoordinate2D], bikeCoords: [CLLocationCoordinate2D], step: Int = 3) -> CLLocationDistance {
        var minDistance = CLLocationDistance.greatestFiniteMagnitude
        
        for bikeCoord in bikeCoords {
            let bikeLoc = CLLocation(latitude: bikeCoord.latitude, longitude: bikeCoord.longitude)
            for j in stride(from: 0, to: routeCoords.count, by: step) {
                let routeLoc = CLLocation(latitude: routeCoords[j].latitude, longitude: routeCoords[j].longitude)
                let distance = bikeLoc.distance(from: routeLoc)
                if distance < minDistance {
                    minDistance = distance
                }
            }
        }
        
        return minDistance
    }

    // MapView Delegate
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }

        let identifier = "Annotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }

        return annotationView
    }
    
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        guard !(annotation is MKUserLocation) else { return nil }
//
//        let identifier = "CommunityPin"
//        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
//        if annotationView == nil {
//            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
//            annotationView?.canShowCallout = true
//
//            if let originalImage = UIImage(named: "imagepin") {
//                let size = CGSize(width: 40, height: 40)
//                UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
//                originalImage.draw(in: CGRect(origin: .zero, size: size))
//                let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
//                UIGraphicsEndImageContext()
//                annotationView?.image = resizedImage
//            }
//
//            let infoButton = UIButton(type: .detailDisclosure)
//            annotationView?.rightCalloutAccessoryView = infoButton
//        } else {
//            annotationView?.annotation = annotation
//        }
//        return annotationView
//    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        guard let annotation = view.annotation as? CommunityAnnotation else { return }

        let sheetVC = CommunityInfoViewController(annotation: annotation)
        if let sheet = sheetVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        present(sheetVC, animated: true)
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            if polyline.title == "bikeLane" {
                renderer.strokeColor = UIColor.systemGreen
                renderer.lineWidth = 5
            } else {
                renderer.strokeColor = UIColor.systemBlue.withAlphaComponent(0.8)
                renderer.lineWidth = 6
            }

            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }

    // Location Manager Delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location.coordinate
        
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
        mapView.setRegion(region, animated: true)

        locationManager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Falha ao obter localização: \(error.localizedDescription)")
    }
}

// Preview antiga que a View é SwiftUI
//struct MapViewController_Previews: PreviewProvider {
//    static var previews: some View {
//        UIViewControllerPreview {
//            MapViewController()
//        }
//        .edgesIgnoringSafeArea(.all)
//    }
//}

#Preview {
    MapViewController()
}


// Transforma UIKit -> SwiftUI
struct UIViewControllerPreview<ViewController: UIViewController>: UIViewControllerRepresentable {

    let viewControllerBuilder: () -> ViewController

    init(_ builder: @escaping () -> ViewController) {
        viewControllerBuilder = builder
    }

    func makeUIViewController(context: Context) -> ViewController {
        return viewControllerBuilder()
    }

    func updateUIViewController(_ uiViewController: ViewController, context: Context) {}
}
