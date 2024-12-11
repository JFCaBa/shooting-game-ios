//
//  OnboardingSheetViewController+ScrollView.swift
//  ShootingApp
//
//  Created by Jose on 29/11/2024.
//

import UIKit

extension OnboardingSheetViewController {
    class ScrollView: UIScrollView {
        override var intrinsicContentSize: CGSize {
            return contentSize
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            invalidateIntrinsicContentSize()
        }
    }
}
