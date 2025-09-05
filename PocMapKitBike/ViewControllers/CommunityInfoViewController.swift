//
//  CommunityInfoViewController .swift
//  PocMapKitBike
//
//  Created by Leticia Bezerra on 04/09/25.
//

import UIKit

class CommunityInfoViewController: UIViewController {

    let annotation: CommunityAnnotation

    init(annotation: CommunityAnnotation) {
        self.annotation = annotation
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .pageSheet
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupUI()
    }

    private func setupUI() {
        let titleLabel = UILabel()
        titleLabel.text = annotation.title
        titleLabel.font = .boldSystemFont(ofSize: 24)
        titleLabel.textAlignment = .center

        let descriptionLabel = UILabel()
        descriptionLabel.text = annotation.communityInfo
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])

        // Botões de ação
        // Botões de ação
        var buttons: [UIButton] = []

        if annotation.phone != nil {
            let button = UIButton(type: .system)
            button.setTitle("Ligar: \(annotation.phone!)", for: .normal)
            button.addTarget(self, action: #selector(callPhone), for: .touchUpInside)
            buttons.append(button)
        }

        if annotation.websiteURL != nil {
            let button = UIButton(type: .system)
            button.setTitle("Visitar site", for: .normal)
            button.addTarget(self, action: #selector(openWebsite), for: .touchUpInside)
            buttons.append(button)
        }

        if annotation.instagramUsername != nil {
            let button = UIButton(type: .system)
            button.setTitle("Abrir Instagram", for: .normal)
            button.addTarget(self, action: #selector(openInstagram), for: .touchUpInside)
            buttons.append(button)
        }

        if annotation.whatsappLink != nil {
            let button = UIButton(type: .system)
            button.setTitle("Abrir WhatsApp", for: .normal)
            button.addTarget(self, action: #selector(openWhatsApp), for: .touchUpInside)
            buttons.append(button)
        }

        let buttonsStack = UIStackView(arrangedSubviews: buttons)
        buttonsStack.axis = .vertical
        buttonsStack.spacing = 10
        buttonsStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonsStack)

        NSLayoutConstraint.activate([
            buttonsStack.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: 20),
            buttonsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            buttonsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }

    @objc private func callPhone() {
        guard let phone = annotation.phone,
              let url = URL(string: "tel://" + phone) else { return }
        UIApplication.shared.open(url)
    }

    @objc private func openWebsite() {
        guard let url = annotation.websiteURL else { return }
        UIApplication.shared.open(url)
    }

    @objc private func openInstagram() {
        guard let insta = annotation.instagramUsername,
              let url = URL(string: "https://instagram.com/\(insta)") else { return }
        UIApplication.shared.open(url)
    }

    @objc private func openWhatsApp() {
        guard let url = annotation.whatsappLink else { return }
        UIApplication.shared.open(url)
    }
}
