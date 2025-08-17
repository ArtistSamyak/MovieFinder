//
//  CDMovie.swift
//  MovieFinder
//
//  Created by Samyak Pawar on 17/08/2025.
//

import CoreData

extension CDMovie {
    convenience init(from movie: Movie, in context: NSManagedObjectContext) {
        self.init(context: context)
        
        // Map simple properties
        self.id = Int64(movie.id)
        self.title = movie.title
        self.overview = movie.overview
        self.posterPath = movie.poster
        self.voteAverage = movie.voteAverage
        self.releaseDate = movie.releaseDate
        
        if let genres = movie.genres {
            if let encodedGenres = try? JSONEncoder().encode(genres) {
                self.genres = encodedGenres
            }
        }
        
        if let imageData = movie.posterImageData {
            self.posterData = imageData
        }

        self.insertionDate = Date()
    }
    
    func toMovie() -> Movie {
        if let genreData = self.genres,
           let genres = try? JSONDecoder().decode([Genre].self, from: genreData){
            return .init(
                id: Int(self.id),
                title: self.title ?? "",
                overview: self.overview ?? "",
                poster: self.posterPath,
                voteAverage: self.voteAverage,
                releaseDate: self.releaseDate,
                genreIds: genres.compactMap({ $0.id }),
                genres: genres,
                posterImageData: self.posterData
            )
        }
        return .init(
            id: Int(self.id),
            title: self.title ?? "",
            overview: self.overview ?? "",
            poster: self.posterPath,
            voteAverage: self.voteAverage,
            releaseDate: self.releaseDate,
            genreIds: nil,
            genres: nil,
            posterImageData: self.posterData
        )
    }
}
