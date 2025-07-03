// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let welcome = try? newJSONDecoder().decode(Welcome.self, from: jsonData)

import Foundation

// MARK: - Welcome
struct GooglePlacesResult: Codable {
    let results: [Result]
    let status: String
}

// MARK: - Result
struct Result: Codable {
    let addressComponents: [AddressComponent]
    let formattedAddress: String
    let geometry: Geometry
    let placeID: String
    let types: [String]

    enum CodingKeys: String, CodingKey {
        case addressComponents = "address_components"
        case formattedAddress = "formatted_address"
        case geometry
        case placeID = "place_id"
        case types
    }
}

// MARK: - AddressComponent
struct AddressComponent: Codable {
    let longName, shortName: String
    let types: [String]

    enum CodingKeys: String, CodingKey {
        case longName = "long_name"
        case shortName = "short_name"
        case types
    }
}

// MARK: - Geometry
struct Geometry: Codable {
    let bounds: Bounds
    let location: Location
    let locationType: String
    let viewport: Bounds

    enum CodingKeys: String, CodingKey {
        case bounds, location
        case locationType = "location_type"
        case viewport
    }
}

// MARK: - Bounds
struct Bounds: Codable {
    let northeast, southwest: Location
}

// MARK: - Location
struct Location: Codable {
    let lat, lng: Double
}

