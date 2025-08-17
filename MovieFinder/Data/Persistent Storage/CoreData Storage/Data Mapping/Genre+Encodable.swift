//
//  Genre+Encodable.swift
//  MovieFinder
//
//  Created by Samyak Pawar on 17/08/2025.
//

extension Genre: Encodable {
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id.rawValue, forKey: .id)
        try container.encodeIfPresent(name, forKey: .name)
    }
}
