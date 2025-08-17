//
//  MoviesListItemCell.swift
//  MovieFinder
//
//  Created by Samyak Pawar on 17/08/2025.
//

import UIKit

class MoviesListItemCell: UICollectionViewCell {
    static let reuseIdentifier = "MoviesListItemCell"
    
    private var viewModel: MovieListItemViewModelType?

    //  MARK: Init
    
    override init(frame: CGRect) {
         super.init(frame: frame)
         contentView.backgroundColor = .secondarySystemBackground
         contentView.layer.cornerRadius = 8
         contentView.clipsToBounds = true
         setupViews()
    }
    
    required init?(coder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
    }
    
    //  MARK: Views
    
    let posterImageView: UIImageView = {
         let iv = UIImageView()
         iv.translatesAutoresizingMaskIntoConstraints = false
         iv.contentMode = .scaleAspectFill
         iv.clipsToBounds = true
         iv.layer.cornerRadius = 8
         return iv
    }()
    
    let titleLabel: UILabel = {
         let label = UILabel()
         label.translatesAutoresizingMaskIntoConstraints = false
         label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
         label.textColor = .label
         label.numberOfLines = 2
         label.textAlignment = .center
         return label
    }()
    
    let yearLabel: UILabel = {
         let label = UILabel()
         label.translatesAutoresizingMaskIntoConstraints = false
         label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
         label.textColor = .secondaryLabel
         label.textAlignment = .center
         return label
    }()
    
    private func setupViews() {
        contentView.addSubview(posterImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(yearLabel)
        
        NSLayoutConstraint.activate([
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            posterImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            posterImageView.heightAnchor.constraint(equalTo: posterImageView.widthAnchor, multiplier: 1.5),
            
            titleLabel.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: 4),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            
            yearLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            yearLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            yearLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            yearLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(with movie: Movie, viewModel: MovieListItemViewModelType) {
        self.viewModel = viewModel
        titleLabel.text = movie.title
        yearLabel.text = String(movie.releaseYear)
        
        posterImageView.image = UIImage(systemName: "photo")?.withTintColor(.systemGray, renderingMode: .alwaysOriginal)
        if let poster = movie.poster {
            fetchImageData(path: poster)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        viewModel?.cancelImageDownload()
    }
    
    //  MARK: Helper
    
    private func fetchImageData(path: String) {
        Task { [weak self] in
            guard let viewModel = self?.viewModel else { return }

            do {
                let imageData = try await viewModel.fetchImage(path)
                let image = UIImage(data: imageData)
                await MainActor.run {
                    self?.posterImageView.image = image
                }
            } catch is CancellationError {
                
            } catch {
                debugPrint("Image loading failed: \(error)")
            }
        }
    }
}
