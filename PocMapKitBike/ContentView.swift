//
//  ContentView.swift
//  PocMapKitBike
//
//  Created by Leticia Bezerra on 25/08/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        UIViewControllerPreview {
            return MapViewController()
        }
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    ContentView()
}
