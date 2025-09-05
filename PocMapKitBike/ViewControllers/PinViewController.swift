////
////  PinViewController.swift
////  PocMapKitBike
////
////  Created by Leticia Bezerra on 03/09/25.
////
//
//import MapKit
//import UIKit
//
//func PinViewController(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
//    guard let communityAnnotation = view.annotation as? CommunityAnnotation else { return }
//
//    let alert = UIAlertController(title: communityAnnotation.title, message: communityAnnotation.communityInfo, preferredStyle: .actionSheet)
//
//    if let phone = communityAnnotation.phone, let phoneURL = URL(string: "tel://" + phone) {
//        alert.addAction(UIAlertAction(title: "Ligar: \(phone)", style: .default) { _ in
//            UIApplication.shared.open(phoneURL)
//        })
//    }
//    
//    if let website = communityAnnotation.websiteURL {
//        alert.addAction(UIAlertAction(title: "Visitar site", style: .default) { _ in
//            UIApplication.shared.open(website)
//        })
//    }
//    
//    if let insta = communityAnnotation.instagramUsername, let instaURL = URL(string: "https://instagram.com/\(insta)") {
//        alert.addAction(UIAlertAction(title: "Abrir Instagram", style: .default) { _ in
//            UIApplication.shared.open(instaURL)
//        })
//    }
//
//    if let whatsapp = communityAnnotation.whatsappLink {
//        alert.addAction(UIAlertAction(title: "Abrir WhatsApp", style: .default) { _ in
//            UIApplication.shared.open(whatsapp)
//        })
//    }
//    
//    alert.addAction(UIAlertAction(title: "Fechar", style: .cancel))
//    present(alert, animated: true)
//}
