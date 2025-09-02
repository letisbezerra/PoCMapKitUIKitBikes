//
//  ViewController.swift
//  PocMapKitBike
//
//  Created by Leticia Bezerra on 25/08/25.
//

import UIKit
import MapKit
import CoreLocation
import SwiftUI

class MapViewController: UIViewController, MKMapViewDelegate {
    var mapView: MKMapView!
    var locationManager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D?

    var start = CLLocationCoordinate2D(latitude: -3.71722, longitude: -38.5434)
    var end = CLLocationCoordinate2D(latitude: -3.72000, longitude: -38.5465)

//    // Ciclovia fixa
//    let bikePathCoordinates = [
//        CLLocationCoordinate2D(latitude: -3.71722, longitude: -38.5434),
//        CLLocationCoordinate2D(latitude: -3.71850, longitude: -38.5450),
//        CLLocationCoordinate2D(latitude: -3.72000, longitude: -38.5465)
//    ]

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

        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        let region = MKCoordinateRegion(center: start, latitudinalMeters: 10000, longitudinalMeters: 10000)
        mapView.setRegion(region, animated: true)

        // Anotação inicial
        let annotation = CommunityAnnotation(coordinate: start, title: "Byques", subtitle: "De boas", communityInfo: "Informações detalhadas sobre a comunidade Byques.")
        mapView.addAnnotation(annotation)

//        // Adicionar ciclovia fixa
//        let bikePath = MKPolyline(coordinates: bikePathCoordinates, count: bikePathCoordinates.count)
//        mapView.addOverlay(bikePath)

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

    @objc func calculateBikeRoute() {
        let inputVC = RouteInputViewController()
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

            self.mapView.removeOverlays(self.mapView.overlays)
//
//            let bikePath = MKPolyline(coordinates: self.bikePathCoordinates, count: self.bikePathCoordinates.count)
//            self.mapView.addOverlay(bikePath)
            self.mapView.addOverlay(route.polyline)

            self.mapView.setVisibleMapRect(route.polyline.boundingMapRect,
                                          edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 100, right: 50),
                                          animated: true)
        }
    }

    // Customiza a anotação para usar imagem e botão info
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }

        let identifier = "CommunityPin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true

            if let originalImage = UIImage(named: "imagepin") {
                let size = CGSize(width: 40, height: 40)
                UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
                originalImage.draw(in: CGRect(origin: .zero, size: size))
                let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                annotationView?.image = resizedImage
            }

            let infoButton = UIButton(type: .detailDisclosure)
            annotationView?.rightCalloutAccessoryView = infoButton
        } else {
            annotationView?.annotation = annotation
        }
        return annotationView
    }

    // Tocar no botão de info abre alerta com informações da comunidade
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        guard let communityAnnotation = view.annotation as? CommunityAnnotation else { return }

        let alert = UIAlertController(title: communityAnnotation.title,
                                      message: communityAnnotation.communityInfo,
                                      preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Fechar", style: .cancel))
        present(alert, animated: true)
    }

    // Renderiza overlays — rota e ciclovia com cores diferentes
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)

            if polyline.pointCount > 3 {
                renderer.strokeColor = UIColor.systemBlue.withAlphaComponent(0.8) // rota calculada
                renderer.lineWidth = 6
            } else {
                renderer.strokeColor = UIColor.systemGreen.withAlphaComponent(0.7) // ciclovia fixa
                renderer.lineWidth = 4
            }
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }

    // Atualiza localização atual e pode centralizar o mapa
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location.coordinate

        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
        mapView.setRegion(region, animated: true)

        locationManager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Falha ao obter localização: \(error)")
    }
}

// Preview no Xcode com SwiftUI
struct MapViewCiboController_Previews: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreview {
            return MapViewController()
        }
        .edgesIgnoringSafeArea(.all)
    }
}

// Helper para mostrar UIViewController no preview SwiftUI
struct UIViewControllerPreview<ViewController: UIViewController>: UIViewControllerRepresentable {

    let viewControllerBuilder: () -> ViewController

    init(_ builder: @escaping () -> ViewController) {
        viewControllerBuilder = builder
    }

    func makeUIViewController(context: Context) -> ViewController {
        return viewControllerBuilder()
    }

    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
        // Sem atualização necessária
    }
}
