//
//  UserDetailsController.swift
//  TinderApp
//
//  Created by Aleksey Kosov on 24.12.2022.
//

import UIKit

class UserDetailsController: UIViewController, UIScrollViewDelegate {
    // you should really create a different viewmodel object for user Details
    // ie UserDetailsViewModel

    var cardViewModel: CardViewModel! {
        didSet {
            infoLabel.attributedText = cardViewModel.attributedString
            swipingPhotosController.cardViewModel = cardViewModel
        }
    }

    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.delegate = self
        return scrollView
    }()

    // how do i swap out uiimageview with a uiview controller component
    let swipingPhotosController = SwipingPhotosController(isCardViewMode: false)
    let infoLabel: UILabel = {
        let label = UILabel()
        label.text = "User name 30\nDoctor\nSome bio text down below"
        label.numberOfLines = 0
        return label
    }()
    lazy var dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "dismiss_down_arrow")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleTapDismiss), for: .touchUpInside)
        return button
    }()
    // 3 bottom control buttons
    lazy var dislikeButton = self.createButton(image: #imageLiteral(resourceName: "dismiss_circle"), selector: #selector(handleDislike))
    lazy var superLikeButton = self.createButton(image: #imageLiteral(resourceName: "super_like_circle"), selector: #selector(handleDislike))
    lazy var likeButton = self.createButton(image: #imageLiteral(resourceName: "like_circle"), selector: #selector(handleDislike))
    @objc fileprivate func handleDislike() {

    }
    fileprivate func setupBottomControls() {

        let stackView = UIStackView(arrangedSubviews: [dislikeButton, superLikeButton,
                                                      likeButton])
        stackView.distribution = .fillEqually
        stackView.spacing = -32
        view.addSubview(stackView)
        stackView.anchor(top: nil, leading: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: nil,
                         padding: .init(top: 0, left: 0, bottom: 0, right: 0), size: .init(width: 300, height: 80))
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }

    fileprivate func createButton(image: UIImage, selector: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: selector, for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFill
        return button
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        setupLayout()
        setupBottomControls()
        setupVisualBluEffectView()
    }

    fileprivate func setupVisualBluEffectView() {
        let blurEffct = UIBlurEffect(style: .regular)
        let visualEffctView = UIVisualEffectView(effect: blurEffct)
        view.addSubview(visualEffctView)
        visualEffctView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.topAnchor, trailing: view.trailingAnchor)
    }

    fileprivate func setupLayout() {
        view.addSubview(scrollView)
        scrollView.fillSuperview()
        let swipingView = swipingPhotosController.view!
        scrollView.addSubview(swipingView)
        // frame
        // why frame instead of autolayout
        scrollView.addSubview(infoLabel)
        infoLabel.anchor(top: swipingView.bottomAnchor,
                         leading: scrollView.leadingAnchor,
                         bottom: nil, trailing: scrollView.trailingAnchor,
                         padding: .init(top: 16, left: 16, bottom: 0, right: 16))
        scrollView.addSubview(dismissButton)
        dismissButton.anchor(top: swipingView.bottomAnchor, leading: nil, bottom: nil, trailing:
                                view.trailingAnchor, padding: .init(top: -25, left: 0, bottom: 0, right: 24),
                             size: .init(width: 50, height: 50))
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let changeY = -scrollView.contentOffset.y
        var width = view.frame.width + changeY * 2
        width = max(view.frame.width, width)
        let imageView = swipingPhotosController.view!
        imageView.frame = CGRect(x: min(0, -changeY), y: min(0, -changeY), width: width, height: width + extraSwipingHeight)

    }

    fileprivate let extraSwipingHeight: CGFloat = 80
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let swipingView = swipingPhotosController.view!
        swipingView.frame = .init(x: 0, y: 0, width: view.frame.width, height: view.frame.width + extraSwipingHeight)
    }

    @objc fileprivate func handleTapDismiss() {
        self.dismiss(animated: true)
    }

}
