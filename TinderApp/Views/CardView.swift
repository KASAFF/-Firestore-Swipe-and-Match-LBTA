//
//  CardView.swift
//  TinderApp
//
//  Created by Aleksey Kosov on 21.12.2022.
//

import UIKit
import SDWebImage

protocol CardViewDelegate: AnyObject {
    func didTapMoreInfo(cardViewModel: CardViewModel)
    func didRemoveCard(cardView: CardView)
    
}

class CardView: UIView {

    var nextCardView: CardView?

    var delegate: CardViewDelegate?
    var cardViewModel: CardViewModel! {
        didSet {
            // let imageName = cardViewModel.imageUrls.first ?? ""
            // load our image using some kind of url instead
//            if let url = URL(string: imageName) {
//                imageView.sd_setImage(with: url,
//                                      placeholderImage: UIImage(named: "photo_placeholder"),
//                                      options: .continueInBackground)
//            }
            swipingPhotosController.cardViewModel = self.cardViewModel
            informationLabel.attributedText = cardViewModel.attributedString
            informationLabel.textAlignment = cardViewModel.textAlignment
            (0..<cardViewModel.imageUrls.count).forEach { _ in
                let barView = UIView()
                barView.backgroundColor = barDeselectedColor
                barsStackView.addArrangedSubview(barView)
            }
            barsStackView.arrangedSubviews.first?.backgroundColor = .white
            setupImageIndexObserver()
        }
    }
    fileprivate func setupImageIndexObserver() {
        cardViewModel.imageIndexObserver = { [weak self] index, _ in
            self?.barsStackView.arrangedSubviews.forEach { view in
                view.backgroundColor = self?.barDeselectedColor
            }
            self?.barsStackView.arrangedSubviews[index].backgroundColor = .white
        }
    }
    // encapsulation
    // fileprivate let imageView = UIImageView()
    // replace it with UIPageViewController component whis is our SwipingPhotosController
    fileprivate let swipingPhotosController = SwipingPhotosController(isCardViewMode: true)
    fileprivate let informationLabel = UILabel()
    fileprivate let gradientLayer = CAGradientLayer()
    // Configurations
    fileprivate let threshold: CGFloat = 80
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        addGestureRecognizer(panGesture)
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }
    // var imageIndex: Int = 0
    fileprivate let barDeselectedColor = UIColor(white: 0, alpha: 0.1)
    @objc fileprivate func handleTap(gesture: UITapGestureRecognizer) {
        let tapLocation = gesture.location(in: nil)
        let shouldAdvanceNextPhoto = tapLocation.x > frame.width / 2 ? true : false
        if shouldAdvanceNextPhoto {
            cardViewModel.advanceToNextPhoto()
        } else {
            cardViewModel.goToPreviousPhoto()
        }
    }
    fileprivate lazy var moreInfoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "info_icon")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleMoreInfo), for: .touchUpInside)
        return button
    }()
    @objc fileprivate func handleMoreInfo() {
        // use delegate instead, much more delegate
        delegate?.didTapMoreInfo(cardViewModel: self.cardViewModel)
    }
    fileprivate func setupLayout() {
        // custom drawing code
        layer.cornerRadius = 10
        clipsToBounds = true
        let swipingPhotosView = swipingPhotosController.view!
        addSubview(swipingPhotosView)
        swipingPhotosView.fillSuperview()
        // setupBarsStackView()
        // add a gradient layer somehow
        setupGradientLayer()
        addSubview(informationLabel)
        informationLabel.anchor(top: nil, leading: leadingAnchor, bottom: bottomAnchor,
                                trailing: trailingAnchor, padding: .init(top: 0, left: 16, bottom: 16, right: 16))
        informationLabel.textColor = .white
        informationLabel.numberOfLines = 0
        addSubview(moreInfoButton)
        moreInfoButton.anchor(top: nil, leading: nil, bottom: bottomAnchor,
                              trailing: trailingAnchor, padding:
                .init(top: 0, left: 0, bottom: 16, right: 16), size: .init(width: 44, height: 44))
    }
    fileprivate let barsStackView = UIStackView()
    fileprivate func setupBarsStackView() {
        addSubview(barsStackView)
        barsStackView.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor,
                             padding: .init(top: 8, left: 8, bottom: 0, right: 8), size: .init(width: 0, height: 4))
        barsStackView.spacing = 4
        barsStackView.distribution = .fillEqually
    }
    fileprivate func setupGradientLayer() {
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradientLayer.locations = [0.5, 1.1]
        layer.addSublayer(gradientLayer)
    }
    override func layoutSubviews() {
        gradientLayer.frame = self.frame
    }
    fileprivate func handleChanged(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: nil)
        // rotation
        let degrees: CGFloat = translation.x / 20
        let angle = degrees * .pi / 180
        let rotationalTransforamtion = CGAffineTransform(rotationAngle: angle)
        self.transform = rotationalTransforamtion.translatedBy(x: translation.x, y: translation.y)
    }
    fileprivate func handleEnded(_ gesture: UIPanGestureRecognizer) {
        let translationDirection: CGFloat = gesture.translation(in: nil).x > 0 ? 1 : -1
        let shouldDismissCard = abs(gesture.translation(in: nil).x) > threshold

        if shouldDismissCard {

            //hack solution
            guard let homeController = self.delegate as? HomeController else { return }

            if translationDirection == 1 {
                homeController.handleLike()
            } else {
                homeController.handleDislike()
            }
        } else {
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: .curveEaseOut) {
                self.transform = .identity
            }

        }
//        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.6,
//                       initialSpringVelocity: 0.1, options: .curveEaseOut, animations: {
//            if shouldDismissCard {
//                self.center = CGPoint(x: 600 * translationDirection, y: self.center.y)
//            } else {
//                self.transform = .identity
//            }
//        }, completion: { _ in
//            self.transform = .identity
//            if shouldDismissCard {
//                self.removeFromSuperview()
//                self.delegate?.didRemoveCard(cardView: self)
//            }
//        })
    }
    @objc fileprivate func handlePan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            superview?.subviews.forEach({ subview in
                subview.layer.removeAllAnimations()
            })
        case .changed:
            handleChanged(gesture)
        case  .ended:
            handleEnded(gesture)
        default:
            break
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
