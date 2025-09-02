//
//  RouteCauculate.swift
//  PocMapKitBike
//
//  Created by Leticia Bezerra on 02/09/25.
//

import UIKit
import MapKit
import CoreLocation
import SwiftUI

class RouteInputViewController: UIViewController {
    var onLocationsSelected: ((CLLocationCoordinate2D, CLLocationCoordinate2D) -> Void)?

    private let startTextField = UITextField()
    private let endTextField = UITextField()
    private let confirmButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        startTextField.placeholder = "Endereço de partida"
        endTextField.placeholder = "Endereço do destino"
        startTextField.borderStyle = .roundedRect
        endTextField.borderStyle = .roundedRect

        confirmButton.setTitle("Confirmar", for: .normal)
        confirmButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [startTextField, endTextField, confirmButton])
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc private func confirmTapped() {
        guard
            let startAddress = startTextField.text,
            let endAddress = endTextField.text
        else {
            showAlert()
            return
        }
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(startAddress) { [weak self] startPlacemarks, error in
            guard let self = self, error == nil, let startLocation = startPlacemarks?.first?.location else {
                self?.showAlert()
                return
            }

            geocoder.geocodeAddressString(endAddress) { endPlacemarks, error in
                guard error == nil, let endLocation = endPlacemarks?.first?.location else {
                    self.showAlert()
                    return
                }

                self.onLocationsSelected?(startLocation.coordinate, endLocation.coordinate)
                self.dismiss(animated: true)
            }
        }
    }

    private func showAlert() {
        let alert = UIAlertController(title: "Erro", message: "Endereço inválido ou não encontrado.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func parseCoordinates(from text: String) -> CLLocationCoordinate2D? {
        let parts = text.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        guard parts.count == 2,
              let lat = Double(parts[0]),
              let lon = Double(parts[1]) else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}

