//
//  Genre+Decodable.swift
//  MovieFinder
//
//  Created by Samyak Pawar on 17/08/2025.
//

extension Genre: Decodable {

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(GenreId.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
    }
}

extension GenreId: Decodable {}
