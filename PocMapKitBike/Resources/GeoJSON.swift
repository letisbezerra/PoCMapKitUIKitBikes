////
////  OSMGeoJson.swift
////  PocMapKitBike
////
////  Created by Leticia Bezerra on 26/08/25.
////
//
//import CoreLocation
//
//// Define as structs para decodificar o GeoJSON
//struct GeoJSON: Codable {
//    let type: String
//    let features: [Feature]
//}
//
//struct Feature: Codable {
//    let type: String
//    let properties: Properties
//    let geometry: Geometry
//}
//
//struct Properties: Codable {
//    let id: String? // para "@id", use CodingKeys para mapear se quiser
//    let area: String?
//    let highway: String?
//    let type: String?
//    
//    private enum CodingKeys: String, CodingKey {
//        case id = "@id"
//        case area, highway, type
//    }
//}
//
//struct Geometry: Codable {
//    let type: String
//    let coordinates: [[[[Double]]]]  // Para MultiPolygon é quadra dimensional: [[[[]]]]
//}
//
//// Função que abre e decodifica o JSON para GeoJSON
//func loadGeoJsonFromFile(named filename: String) -> GeoJSON? {
//    guard let url = Bundle.main.url(forResource: filename, withExtension: "json"),
//          let data = try? Data(contentsOf: url) else {
//        print("Não encontrou ou não pôde carregar o arquivo \(filename).json")
//        return nil
//    }
//
//    do {
//        let geoJson = try JSONDecoder().decode(GeoJSON.self, from: data)
//        return geoJson
//    } catch {
//        print("Erro ao decodificar JSON: \(error)")
//        return nil
//    }
//}
//
//// Função que extrai as coordenadas de MultiPolygon do GeoJSON decodificado
//func extractMultiPolygonCoordinates(from geoJSON: GeoJSON) -> [[[CLLocationCoordinate2D]]] {
//    var polygons: [[[CLLocationCoordinate2D]]] = []
//
//    for feature in geoJSON.features {
//        guard feature.geometry.type == "MultiPolygon" else { continue }
//        let multiPolygonCoords = feature.geometry.coordinates
//
//        var polygonArray: [[CLLocationCoordinate2D]] = []
//        for polygonCoords in multiPolygonCoords {
//            var coordArray: [CLLocationCoordinate2D] = []
//            for coordPair in polygonCoords {
//                print(type(of: coordPair))
//                print(coordPair)
//                let location = CLLocationCoordinate2D(latitude: coordPair[1], longitude: coordPair[0])
//                coordArray.append(location)
//            }
//            polygonArray.append(coordArray)
//        }
//        polygons.append(polygonArray)
//    }
//    return polygons
//}
//
//// Função para carregar e retornar as coordenadas do arquivo JSON diretamente
//func loadCoordinatesFromGeoJSON() -> [[[CLLocationCoordinate2D]]] {
//    if let geoJson = loadGeoJsonFromFile(named: "fortaleza_ciclovias") {
//        return extractMultiPolygonCoordinates(from: geoJson)
//    }
//    return []
//}
//
//
