//
//  CommunityAnnotation.swift
//  PocMapKitBike
//
//  Created by Leticia Bezerra on 26/08/25.
//

import MapKit

class CommunityAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?
    let communityInfo: String

    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?, communityInfo: String) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.communityInfo = communityInfo
        super.init()
    }
}

