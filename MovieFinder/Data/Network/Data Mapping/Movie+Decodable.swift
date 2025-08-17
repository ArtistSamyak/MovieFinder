//
//  MovieList.swift
//  MovieFinder
//
//  Created by Samyak Pawar on 17/08/2025.
//

struct MovieList: Decodable {
    let results: [Movie]
}

extension Movie: Decodable {

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        overview = try container.decode(String.self, forKey: .overview)
        poster = try container.decodeIfPresent(String.self, forKey: .poster)
        voteAverage = try container.decode(Float.self, forKey: .voteAverage)
        releaseDate = try container.decodeIfPresent(String.self, forKey: .releaseDate)
        genreIds = try container.decodeIfPresent([GenreId].self, forKey: .genreIds)
        genres = try container.decodeIfPresent([Genre].self, forKey: .genres)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case poster = "poster_path"
        case voteAverage = "vote_average"
        case releaseDate = "release_date"
        case genreIds = "genre_ids"
        case genres = "genres"
    }
}
