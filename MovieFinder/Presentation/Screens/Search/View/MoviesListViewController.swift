//
//  MoviesListViewController.swift
//  MovieFinder
//
//  Created by Samyak Pawar on 17/08/2025.
//

import UIKit

class MoviesListViewController: UIViewController {

    private var viewModel: MoviesListViewModelType
    private var state: MoviesListState = .idle
    private var collectionView: UICollectionView!
    private var searchController: UISearchController!
    private var activityIndicator: UIActivityIndicatorView!
    private var activityOverlay: UIView!

    //  MARK: Init
    init(viewModel: MoviesListViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //  MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Movie Finder"
        viewModel.delegate = self
        setupSearchController()
        setupCollectionView()
        setupActivityIndicatorOverlay()
        viewModel.getPopularMovies()
    }

    private func setupSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Search Movies"
        searchController.searchBar.delegate = self

        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10

        let itemWidth = (view.frame.width - 30) / 2
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth * 1.8)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.showsVerticalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MoviesListItemCell.self, forCellWithReuseIdentifier: MoviesListItemCell.reuseIdentifier)
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
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

        activityOverlay.isHidden = true
    }

    //  MARK: Helpers

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
}

//  MARK: UISearchBarDelegate

extension MoviesListViewController: UISearchBarDelegate {

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        viewModel.getPopularMovies()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.searchMovies(with: searchText)
    }
}

//  MARK: UICollectionViewDataSource & UICollectionViewDelegate

extension MoviesListViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if case .success(let movies) = state {
            return movies.count
        }
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MoviesListItemCell.reuseIdentifier, for: indexPath) as? MoviesListItemCell else {
            return UICollectionViewCell()
        }
        if case .success(let movies) = state {
            cell.configure(with: movies[indexPath.row], viewModel: viewModel.getMovieListItemViewModel())
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if case .success(let movies) = state {
            viewModel.showDetails(forMovie: movies[indexPath.row].id)
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchController.searchBar.resignFirstResponder()
    }
}

//  MARK: MoviesListViewModelDelegate

extension MoviesListViewController: MoviesListViewModelDelegate {
    func didUpdateState(_ state: MoviesListState) {
        switch state {
        case .idle:
            viewModel.getPopularMovies()
            hideActivityOverlay()
        case .loading:
            showActivityOverlay()
        case .success(let movies):
            self.state = .success(movies)
            collectionView.reloadData()
            hideActivityOverlay()
        case .noResults:
            self.state = .noResults
            collectionView.reloadData()
            hideActivityOverlay()
        case .failure(let error):
            hideActivityOverlay()
            showAlert(message: error.localizedDescription)
        }
    }
}
