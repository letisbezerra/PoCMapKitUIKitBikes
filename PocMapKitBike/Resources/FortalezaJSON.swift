//
//  FortalezaJSON.swift
//  PocMapKitBike
//
//  Created by Leticia Bezerra on 04/09/25.
//

import Foundation

enum FortalezaJSON {
    
    static func loadQuickTypeGeoJSON(named filename: String) -> Result? {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("Não encontrou ou não pôde carregar o arquivo \(filename).json")
            return nil
        }
        
        do {
            let geoJson = try JSONDecoder().decode(Result.self, from: data)
            return geoJson
        } catch {
            print("Erro ao decodificar JSON: \(error)")
            return nil
        }
    }
    
    struct Result: Codable {
        let type, name: String
        let crs: CRS
        let features: [Feature]
    }

    struct CRS: Codable {
        let type: String
        let properties: Properties
    }

    struct Properties: Codable {
        let name: String
    }

    struct Feature: Codable {
        let type: FeatureType
        let properties: [String: String?]
        let geometry: Geometry
    }

    struct Geometry: Codable {
        let type: GeometryType
        let coordinates: [[Double]]
    }

    enum GeometryType: String, Codable {
        case lineString = "LineString"
    }

    enum FeatureType: String, Codable {
        case feature = "Feature"
    }
    
}
