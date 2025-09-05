//
//  CommunityAnnotation.swift
//  PocMapKitBike
//
//  Created by Leticia Bezerra on 26/08/25.
//

import MapKit
import UIKit

class CommunityAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?
    let communityInfo: String

    let image: UIImage?
    let phone: String?
    let websiteURL: URL?
    let instagramUsername: String?
    let whatsappLink: URL?

    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?, communityInfo: String,
         image: UIImage? = nil, phone: String? = nil, websiteURL: URL? = nil,
         instagramUsername: String? = nil, whatsappLink: URL? = nil) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.communityInfo = communityInfo
        self.image = image
        self.phone = phone
        self.websiteURL = websiteURL
        self.instagramUsername = instagramUsername
        self.whatsappLink = whatsappLink
    }
}


