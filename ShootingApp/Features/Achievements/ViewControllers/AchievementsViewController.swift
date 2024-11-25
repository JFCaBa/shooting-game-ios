//
//  AchievementsViewController.swift
//  ShootingApp
//
//  Created by Jose on 25/11/2024.
//

import UIKit
import Combine

final class AchievementsViewController: UIViewController {
    // MARK: - Properties
    
    private let viewModel: AchievementsViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    
    private lazy var collectionView: UICollectionView = {
        let layout = createLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.register(AchievementCell.self, forCellWithReuseIdentifier: AchievementCell.reuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Achievements"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Lifecycle
    
    init(viewModel: AchievementsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        displayPlaceholders()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(titleLabel)
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupBindings() {
        viewModel.$achievements
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    private func displayPlaceholders() {
        // Load all possible achievements as placeholders
        let placeholders: [Achievement] = [
            // Kills achievements
            Achievement(id: "kills_10", type: .kills, milestone: 10, progress: 0, walletAddress: "", unlockedAt: nil, nftTokenId: nil),
            Achievement(id: "kills_50", type: .kills, milestone: 50, progress: 0, walletAddress: "", unlockedAt: nil, nftTokenId: nil),
            Achievement(id: "kills_100", type: .kills, milestone: 100, progress: 0, walletAddress: "", unlockedAt: nil, nftTokenId: nil),
            Achievement(id: "kills_500", type: .kills, milestone: 500, progress: 0, walletAddress: "", unlockedAt: nil, nftTokenId: nil),
            Achievement(id: "kills_1000", type: .kills, milestone: 1000, progress: 0, walletAddress: "", unlockedAt: nil, nftTokenId: nil),
            
            // Hits achievements
            Achievement(id: "hits_100", type: .hits, milestone: 100, progress: 0, walletAddress: "", unlockedAt: nil, nftTokenId: nil),
            Achievement(id: "hits_500", type: .hits, milestone: 500, progress: 0, walletAddress: "", unlockedAt: nil, nftTokenId: nil),
            Achievement(id: "hits_1000", type: .hits, milestone: 1000, progress: 0, walletAddress: "", unlockedAt: nil, nftTokenId: nil),
            Achievement(id: "hits_5000", type: .hits, milestone: 5000, progress: 0, walletAddress: "", unlockedAt: nil, nftTokenId: nil),
            
            // Accuracy achievements
            Achievement(id: "accuracy_50", type: .accuracy, milestone: 50, progress: 0, walletAddress: "", unlockedAt: nil, nftTokenId: nil),
            Achievement(id: "accuracy_75", type: .accuracy, milestone: 75, progress: 0, walletAddress: "", unlockedAt: nil, nftTokenId: nil),
            Achievement(id: "accuracy_90", type: .accuracy, milestone: 90, progress: 0, walletAddress: "", unlockedAt: nil, nftTokenId: nil),
            Achievement(id: "accuracy_95", type: .accuracy, milestone: 95, progress: 0, walletAddress: "", unlockedAt: nil, nftTokenId: nil),
            
            // Survival time achievements (in seconds)
            Achievement(id: "survival_3600", type: .survivalTime, milestone: 3600, progress: 0, walletAddress: "", unlockedAt: nil, nftTokenId: nil),
            Achievement(id: "survival_18000", type: .survivalTime, milestone: 18000, progress: 0, walletAddress: "", unlockedAt: nil, nftTokenId: nil),
            Achievement(id: "survival_86400", type: .survivalTime, milestone: 86400, progress: 0, walletAddress: "", unlockedAt: nil, nftTokenId: nil)
        ]
        
        viewModel.setPlaceholders(placeholders)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .absolute(200)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(200)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}

// MARK: - UICollectionViewDataSource

extension AchievementsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.displayAchievements.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: AchievementCell.reuseIdentifier,
            for: indexPath
        ) as? AchievementCell else {
            return UICollectionViewCell()
        }
        
        let achievement = viewModel.displayAchievements[indexPath.item]
        let earnedAchievement = viewModel.achievements.first(where: { $0.id == achievement.id })
        cell.configure(with: achievement, earned: earnedAchievement != nil)
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension AchievementsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let achievement = viewModel.displayAchievements[indexPath.item]
        let isEarned = viewModel.achievements.contains(where: { $0.id == achievement.id })
        
        let description = isEarned ? "Earned!" : "Keep playing to earn this achievement"
        let alert = UIAlertController(
            title: achievement.type.description,
            message: "\(description)\nProgress: \(achievement.progress)/\(achievement.milestone)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
