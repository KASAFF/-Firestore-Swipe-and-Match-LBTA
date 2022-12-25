//
//  CardViewModel.swift
//  TinderApp
//
//  Created by Aleksey Kosov on 21.12.2022.
//

import UIKit

protocol ProducesCardViewModel {
    func toCardViewModel() -> CardViewModel
}

// View model is supposed represent the state of our view
class CardViewModel {
    // we'll define the properties that are view will display/render out
    let uid: String
    let imageUrls: [String]
    let attributedString: NSAttributedString
    let textAlignment: NSTextAlignment

    init(uid: String, imageNames: [String], attributedString: NSAttributedString, textAlignment: NSTextAlignment) {
        self.uid = uid
        self.imageUrls = imageNames
        self.attributedString = attributedString
        self.textAlignment = textAlignment
    }

    fileprivate var imageIndex = 0 {
        didSet {
            let imageUrl = imageUrls[imageIndex]
            imageIndexObserver?(imageIndex, imageUrl)
        }
    }

    // Reactive Programming
    var imageIndexObserver: ((Int, String?) -> Void)?

    func advanceToNextPhoto() {
        imageIndex = min(imageIndex + 1, imageUrls.count - 1)
    }
    func goToPreviousPhoto() {
        imageIndex = max(0, imageIndex - 1)
    }
}

// what exactly do we do with this card view model thing??
