//
//  Movie.swift
//  MovieFinder
//
//  Created by Samyak Pawar on 17/08/2025.
//

import Foundation

struct Movie: Identifiable {
    let id: Int
    let title: String
    let overview: String
    let poster: String?
    let voteAverage: Float
    let releaseDate: String?
    let genreIds: [GenreId]?
    let genres: [Genre]?
    
    var posterImageData: Data?
}

extension Movie {
    var releaseYear: Int {
        let date = releaseDate.flatMap { Movie.dateFormatter.date(from: $0) } ?? Date()
        return Calendar.current.component(.year, from: date)
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

extension Movie: Equatable {
    static func == (lhs: Movie, rhs: Movie) -> Bool {
        lhs.id == rhs.id
    }
}
