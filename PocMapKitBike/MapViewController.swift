//
//   ViewController.swift
//  PocMapKitBike
//
//  Created by Leticia Bezerra on 25/08/25.
//

import UIKit
import MapKit
import SwiftUI

class MapViewController: UIViewController, MKMapViewDelegate {
    var mapView: MKMapView!

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

        let initialLocation = CLLocationCoordinate2D(latitude: -3.71722, longitude: -38.5434)
        let region = MKCoordinateRegion(center: initialLocation, latitudinalMeters: 10000, longitudinalMeters: 10000)
        mapView.setRegion(region, animated: true)

        // Criar uma comunidade e a anotação
        let annotation = CommunityAnnotation(
            coordinate: initialLocation,
            title: "Byques",
            subtitle: "De boas",
            communityInfo: "Informações detalhadas sobre a comunidade Byques."
        )
        mapView.addAnnotation(annotation)
    }

    // Delegate - para customizar pin com imagem
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
            
            // Botão para abrir sheet
            let infoButton = UIButton(type: .detailDisclosure)
            annotationView?.rightCalloutAccessoryView = infoButton
        } else {
            annotationView?.annotation = annotation
        }
        return annotationView
    }

    // Delegate - Detecta toque no botão para abrir sheet
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {

        guard let communityAnnotation = view.annotation as? CommunityAnnotation else { return }

        let alert = UIAlertController(title: communityAnnotation.title,
                                      message: communityAnnotation.communityInfo,
                                      preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Fechar", style: .cancel))
        present(alert, animated: true)
    }
}


// Preview no Xcode usando SwiftUI
struct MapViewCiboController_Previews: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreview {
            return MapViewController()
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


