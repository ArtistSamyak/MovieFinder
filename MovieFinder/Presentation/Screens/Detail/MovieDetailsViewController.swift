//
//  MovieDetailsViewController.swift
//  MovieFinder
//
//  Created by Samyak Pawar on 17/08/2025.
//

import UIKit

class MovieDetailsViewController: UIViewController {

    private var viewModel: MovieDetailsViewModelType
    
    // MARK: - UI Elements
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsVerticalScrollIndicator = false
        return scroll
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let releaseDateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .systemYellow
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let genreLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.textAlignment = .left
        label.textColor = .systemBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var activityIndicator: UIActivityIndicatorView!
    private var activityOverlay: UIView!
    
    // MARK: - Life Cycle
    
    init(viewModel: MovieDetailsViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupViews()
        layoutUI()
        setupActivityIndicatorOverlay()
        viewModel.delegate = self
        viewModel.getMovieDetails()
    }
    
    // MARK: - Setup Views
    private func setupViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [posterImageView, titleLabel, releaseDateLabel, ratingLabel, genreLabel, descriptionLabel].forEach { contentView.addSubview($0) }
    }
    
    // MARK: - Layout UI
    private func layoutUI() {
        // Constraints for scrollView
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Constraints for contentView
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            // Ensure contentView's width matches the scrollView's width
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // Poster ImageView constraints
        NSLayoutConstraint.activate([
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            posterImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            posterImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.6),
            posterImageView.heightAnchor.constraint(equalTo: posterImageView.widthAnchor, multiplier: 1.5)
        ])
        
        // ReleaseDate label constraints
        NSLayoutConstraint.activate([
            releaseDateLabel.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: 16),
            releaseDateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            releaseDateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
        
        // Title label constraints
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: releaseDateLabel.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: releaseDateLabel.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)
        ])
        
        // Rating label constraints
        NSLayoutConstraint.activate([
            ratingLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            ratingLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor)
        ])
        
        // Genre label constraints
        NSLayoutConstraint.activate([
            genreLabel.centerYAnchor.constraint(equalTo: ratingLabel.centerYAnchor),
            genreLabel.leadingAnchor.constraint(equalTo: ratingLabel.trailingAnchor, constant: 16),
            genreLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
        
        // Description label constraints
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: ratingLabel.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupActivityIndicatorOverlay() {
        activityOverlay = UIView()
        activityOverlay.translatesAutoresizingMaskIntoConstraints = false
        activityOverlay.backgroundColor = .systemBackground
        view.addSubview(activityOverlay)
        
        NSLayoutConstraint.activate([
            activityOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            activityOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            activityOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            activityOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        activityOverlay.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: activityOverlay.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: activityOverlay.centerYAnchor)
        ])
        
        // Hide the overlay by default
        activityOverlay.isHidden = true
    }
    
    // MARK: Helpers
    
    private func showActivityOverlay() {
        activityOverlay.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideActivityOverlay() {
        activityIndicator.stopAnimating()
        activityOverlay.isHidden = true
    }
    
    private func showAlert(title: String = "", message: String, preferredStyle: UIAlertController.Style = .alert, completion: (() -> Void)? = nil
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: completion)
    }
    
    func configure(with movie: Movie) {
        titleLabel.text = movie.title
        releaseDateLabel.text = String(movie.releaseYear)
        ratingLabel.text = "⭐️ \(String(format: "%.1f", movie.voteAverage)) / 10"
        genreLabel.text = movie.genres?.compactMap({ $0.name }).joined(separator: " | ")
        descriptionLabel.text = movie.overview
        if let posterImageData = movie.posterImageData {
            posterImageView.image = UIImage(data: posterImageData)
        } else {
            posterImageView.image = UIImage(systemName: "photo")?.withTintColor(.systemGray, renderingMode: .alwaysOriginal)
        }
    }
}

// MARK: MovieDetailsViewModelDelegate

extension MovieDetailsViewController: MovieDetailsViewModelDelegate {
    func didUpdateState(_ state: MovieDetailsState) {
        switch state {
        case .idle:
            hideActivityOverlay()
        case .loading:
            showActivityOverlay()
        case .success(let movie):
            hideActivityOverlay()
            configure(with: movie)
        case .failure(let error):
            hideActivityOverlay()
            showAlert(message: error.localizedDescription)
        }
    }
}
