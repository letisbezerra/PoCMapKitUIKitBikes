////
////  OSMGeoJson.swift
////  PocMapKitBike
////
////  Created by Leticia Bezerra on 26/08/25.
////
//
//import CoreLocation
//import Foundation
//import MapKit
//
//func loadCoordinatesFromGeoJSON() -> [[[CLLocationCoordinate2D]]] {
//    return loadCoordinatesFromQuickTypeJSON(named: "fortaleza-ciclovias")
//}
//
//// QuickType structs
//struct Result: Codable {
//    let type, generator, copyright: String
//    let timestamp: String
//    let features: [Feature]
//}
//
//// FeatureType para o campo 'type' da feature
//enum FeatureType: String, Codable {
//    case feature = "Feature"
//}
//
//struct Feature: Codable {
//    let type: FeatureType
//    let properties: Properties
//    let geometry: Geometry
//    let id: String?
//    
//    private enum CodingKeys: String, CodingKey {
//        case type, properties, geometry
//        case id = "@id"
//    }
//}
//
//struct Geometry: Codable {
//    let type: GeometryType
//    let coordinates: [[Coordinate]]
//}
//
//enum Coordinate: Codable {
//    case double(Double)
//    case doubleArrayArray([[Double]])
//
//    init(from decoder: Decoder) throws {
//        let container = try decoder.singleValueContainer()
//        if let x = try? container.decode([[Double]].self) {
//            self = .doubleArrayArray(x)
//            return
//        }
//        if let x = try? container.decode(Double.self) {
//            self = .double(x)
//            return
//        }
//        throw DecodingError.typeMismatch(Coordinate.self,
//                                         DecodingError.Context(codingPath: decoder.codingPath,
//                                                               debugDescription: "Wrong type for Coordinate"))
//    }
//
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.singleValueContainer()
//        switch self {
//        case .double(let x):
//            try container.encode(x)
//        case .doubleArrayArray(let x):
//            try container.encode(x)
//        }
//    }
//}
//
//enum GeometryType: String, Codable {
//    case lineString = "LineString"
//    case multiPolygon = "MultiPolygon"
//}
//
//struct Properties: Codable {
//    let id: String?
//    let highway: String?
//    let area: String?
//    let type: String?
//}
//
//// Funções auxiliares
//func loadQuickTypeGeoJSON(named filename: String) -> Result? {
//    guard let url = Bundle.main.url(forResource: filename, withExtension: "json"),
//          let data = try? Data(contentsOf: url) else {
//        print("Não encontrou ou não pôde carregar o arquivo \(filename).json")
//        return nil
//    }
//    
//    do {
//        let geoJson = try JSONDecoder().decode(Result.self, from: data)
//        return geoJson
//    } catch {
//        print("Erro ao decodificar JSON: \(error)")
//        return nil
//    }
//}
//
//func extractCoordinates(from result: Result) -> [[[CLLocationCoordinate2D]]] {
//    var polygons: [[[CLLocationCoordinate2D]]] = []
//
//    for feature in result.features {
//        guard feature.geometry.type == .multiPolygon else { continue }
//        
//        var multiPolygonArray: [[CLLocationCoordinate2D]] = []
//        
//        for coordinateItem in feature.geometry.coordinates {
//            switch coordinateItem.first {
//            case .doubleArrayArray(let coordsArray):
//                var coordArray: [CLLocationCoordinate2D] = []
//                for coordPair in coordsArray {
//                    if coordPair.count >= 2 {
//                        let location = CLLocationCoordinate2D(latitude: coordPair[1], longitude: coordPair[0])
//                        coordArray.append(location)
//                    }
//                }
//                multiPolygonArray.append(coordArray)
//            default:
//                continue
//            }
//        }
//        polygons.append(multiPolygonArray)
//    }
//    
//    return polygons
//}
//
//func loadCoordinatesFromQuickTypeJSON(named filename: String) -> [[[CLLocationCoordinate2D]]] {
//    if let result = loadQuickTypeGeoJSON(named: filename) {
//        return extractCoordinates(from: result)
//    }
//    return []
//}
