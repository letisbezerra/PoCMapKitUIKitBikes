//
//   ViewController.swift
//  PocMapKitBike
//
//  Created by Leticia Bezerra on 25/08/25.
//

import UIKit
import MapKit
import SwiftUI

class MapViewCiboController: UIViewController {
    var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Inicia o mapa
        mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        // Adiciona a view principal
        view.addSubview(mapView)
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        // Configura região inicial
        let initialLocation = CLLocationCoordinate2D(
            latitude: -3.71722,
            longitude: -38.5434
        )
        let region = MKCoordinateRegion(center: initialLocation, latitudinalMeters: 10000, longitudinalMeters: 10000)
        mapView.setRegion(region, animated: true)
        
        // ENTENDER COMO FUNCIONA
        ///Adicionar anotação inicial no mapa
        let annotation = MKPointAnnotation()
        annotation.coordinate = initialLocation
        annotation.title = "Cibo"
        mapView.addAnnotation(annotation)
    }
}

// Preview no Xcode usando SwiftUI
struct MapViewCiboController_Previews: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreview {
            return MapViewCiboController()
        }
        .edgesIgnoringSafeArea(.all)
    }
}

// Helper para mostrar UIViewController no preview do SwiftUI
struct UIViewControllerPreview<ViewController: UIViewController>: UIViewControllerRepresentable {
    
    let viewControllerBuilder: () -> ViewController

    init(_ builder: @escaping () -> ViewController) {
        viewControllerBuilder = builder
    }

    func makeUIViewController(context: Context) -> ViewController {
        return viewControllerBuilder()
    }

    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
        // Update necessário para preview simples
    }
}


