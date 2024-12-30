//
//  ModeSelectorView.swift
//  ShootingApp
//
//  Created by Jose on 29/12/2024.
//

import UIKit

final class ModeSelectorView: UIView {
    // MARK: - Constants
    
    private let modes = Mode.modes
    private var selectedIndex: Int = 0
    
    // MARK: - UI Properties
    
    private lazy var collectionView: UICollectionView = {
        let layout = CenterAlignedCollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 15
        layout.minimumInteritemSpacing = 15
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.backgroundColor = .clear
        collection.showsHorizontalScrollIndicator = false
        collection.delegate = self
        collection.dataSource = self
        collection.decelerationRate = .fast
        collection.register(ModeCell.self, forCellWithReuseIdentifier: "ModeCell")
        return collection
    }()
    
    // MARK: - Properties
    
    private var isLayoutComplete: Bool {
        return collectionView.frame.width > 0
    }
    private var initialScrollDone = false
    private var initialCenterIndex: Int = 0
    private var onModeSelect: ((ModeSelectorView.Mode) -> Void)?
    private var currentCenteredIndex: Int = -1
    private let cellSpacing: CGFloat = 15
    
    // MARK: - init(frame:)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    // MARK: - init?(coder:)
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - layoutsubviews()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if !initialScrollDone && isLayoutComplete {
            centerItemAtIndex(initialCenterIndex, animated: false)
            initialScrollDone = true
        }
    }
    
    // MARK: - Public functions
    
    func setInitialCenteredIndex(_ index: Int) {
        initialCenterIndex = max(0, min(index, modes.count - 1))
        if isLayoutComplete {
            centerItemAtIndex(initialCenterIndex, animated: false)
        }
    }
    
    func setOnModeSelect(_ callback: @escaping (ModeSelectorView.Mode) -> Void) {
        onModeSelect = callback
    }
    
    // MARK: - Private functions
    
    private func setupUI() {
        backgroundColor = .black.withAlphaComponent(0.8)
        
        addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            collectionView.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func centerItemAtIndex(_ index: Int, animated: Bool = true) {
        let indexPath = IndexPath(item: index, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.isSelected = true
    }
    
    private func findCenteredCellIndex() -> Int? {
        let centerX = collectionView.contentOffset.x + collectionView.bounds.width / 2
        
        // Get visible rect
        let visibleRect = CGRect(x: collectionView.contentOffset.x,
                                y: collectionView.contentOffset.y,
                                width: collectionView.bounds.width,
                                height: collectionView.bounds.height)
        
        // Get layout attributes through the collection view's layout
        guard let layoutAttributes = (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?
            .layoutAttributesForElements(in: visibleRect) else {
            return nil
        }
        
        // Find the cell closest to center
        var closestCell: (index: Int, distance: CGFloat)?
        
        for attributes in layoutAttributes {
            let distance = abs(attributes.center.x - centerX)
            if let closest = closestCell {
                if distance < closest.distance {
                    closestCell = (attributes.indexPath.item, distance)
                }
            } else {
                closestCell = (attributes.indexPath.item, distance)
            }
        }
        
        return closestCell?.index
    }
    
    private func updateCellStates() {
        for i in 0..<modes.count {
            if let cell = collectionView.cellForItem(at: IndexPath(item: i, section: 0)) as? ModeCell {
                cell.setSelected(i == currentCenteredIndex)
            }
        }
    }
}

// MARK: - UISCrollView delegate

extension ModeSelectorView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
            if let centeredIndex = findCenteredCellIndex(),
               centeredIndex != currentCenteredIndex {
                currentCenteredIndex = centeredIndex
                updateCellStates()
            }
        }
        
        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            if let centeredIndex = findCenteredCellIndex() {
                let mode = ModeSelectorView.Mode.modes[centeredIndex]
                onModeSelect?(mode)
            }
        }
        
        func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            if !decelerate {
                if let centeredIndex = findCenteredCellIndex() {
                    let mode = ModeSelectorView.Mode.modes[centeredIndex]
                    onModeSelect?(mode)
                }
            }
        }
}

// MARK: - Custom Flow Layout

class CenterAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
        }
        
        // Get the layout attributes for all cells in the target rectangle
        let targetRect = CGRect(x: proposedContentOffset.x,
                              y: 0,
                              width: collectionView.bounds.width,
                              height: collectionView.bounds.height)
        
        guard let attributesArray = layoutAttributesForElements(in: targetRect) else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
        }
        
        // Find the center-most cell
        let horizontalCenter = proposedContentOffset.x + collectionView.bounds.width / 2
        var bestMatchAttributes: UICollectionViewLayoutAttributes?
        var bestMatchDistance: CGFloat = .greatestFiniteMagnitude
        
        for attributes in attributesArray {
            let distance = abs(attributes.center.x - horizontalCenter)
            if distance < bestMatchDistance {
                bestMatchDistance = distance
                bestMatchAttributes = attributes
            }
        }
        
        guard let targetAttributes = bestMatchAttributes else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
        }
        
        // Calculate the final offset to center the target cell
        let targetOffset = targetAttributes.center.x - collectionView.bounds.width / 2
        return CGPoint(x: targetOffset, y: proposedContentOffset.y)
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)
        return attributes
    }
}

// MARK: - UICollectionView DataSource & Delegate

extension ModeSelectorView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return modes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ModeCell", for: indexPath) as! ModeCell
        cell.configure(with: modes[indexPath.item].rawValue)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Center the selected cell
        centerItemAtIndex(indexPath.item)
        
        // Unselect cell after animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // Trigger callback
            let mode = ModeSelectorView.Mode.modes[indexPath.item]
            self.onModeSelect?(mode)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let mode = modes[indexPath.item].rawValue
        let font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        let attributes = [NSAttributedString.Key.font: font]
        let size = (mode as NSString).size(withAttributes: attributes)
        return CGSize(width: size.width + 20, height: collectionView.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        // Calculate the total width needed for all cells
        let totalWidth = (0..<modes.count).reduce(0) { result, index in
            let indexPath = IndexPath(item: index, section: 0)
            let cellSize = self.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath)
            return result + cellSize.width
        }
        
        // Add the spacing between cells
        let totalSpacing = CGFloat(modes.count - 1) * 15
        
        // Calculate the insets needed to center the content
        let horizontalInset = (collectionView.bounds.width - totalWidth - totalSpacing) / 2
        
        // For the first and last items to be able to center, we need at least half the collection view width as inset
        let minimumInset = collectionView.bounds.width / 2
        
        // Use the larger of the two insets
        let inset = max(horizontalInset, minimumInset)
        
        return UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
    }
}
