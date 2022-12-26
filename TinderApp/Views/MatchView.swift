//
//  MatchView.swift
//  TinderApp
//
//  Created by Aleksey Kosov on 26.12.2022.
//

import UIKit
import Firebase

class MatchView: UIView {

    var currentUser: User! {
        didSet {

        }
    }

    // you are almost always guaranteed to have this variable set up
    var cardUID: String! {
        didSet {
            // either fetch user inside here or pass in our current user if we have it

            // fetch the cardUID information
            let quary = Firestore.firestore().collection("users")
            quary.document(cardUID).getDocument { snapshot, err in
                if let err = err {
                    print("failed to fetch card user:", err)
                    return
                }
                guard let dictionary = snapshot?.data() else { return }
                let user = User(dictionary: dictionary)
                guard let url = URL(string: user.imageUrl1 ?? "") else { return }
                self.cardUserImageView.sd_setImage(with: url)
                guard let currentUserImageUrl = URL(string: self.currentUser.imageUrl1 ?? "") else { return }
                self.currentUserImageView.sd_setImage(with: currentUserImageUrl) { _, _, _, _ in
                    if let userName = user.name {
                        self.descriptionLabel.text = "You and \(userName) liked each other"
                    }
                    self.setupAnimations()
                }
            }
        }
    }


    fileprivate let itsAMatchImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "itsamatch"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    fileprivate lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "You and X liked each other"
        label.textAlignment = .center
        label.textColor = .white
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 20)
        return label
    }()

    fileprivate let currentUserImageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "kelly1"))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.white.cgColor
        return imageView
    }()

    fileprivate let cardUserImageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "jane1"))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.alpha = 0
        return imageView
    }()

    fileprivate let sendMessageButton: SendMessageButton = {
        let button = SendMessageButton(type: .system)
        button.setTitleColor(.white, for: .normal)
        button.setTitle("SEND MESSAGE", for: .normal)
        return button
    }()

    fileprivate let keepSwipingButton: KeepSwipingButton = {
        let button = KeepSwipingButton(type: .system)
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Keep Swiping", for: .normal)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupBlurView()
        setupLayout()
     //   setupAnimations()
    }

    fileprivate func setupAnimations() {
        views.forEach({$0.alpha = 1})
        // starting positions
        let angle = 30 * CGFloat.pi / 180


        currentUserImageView.transform = CGAffineTransform(rotationAngle: -angle).concatenating(CGAffineTransform(translationX: 200, y: 0))
        cardUserImageView.transform = CGAffineTransform(rotationAngle: angle).concatenating(CGAffineTransform(translationX: -200, y: 0))

        sendMessageButton.transform = CGAffineTransform(translationX: -500, y: 0)
        keepSwipingButton.transform = CGAffineTransform(translationX: 500, y: 0)

        // keyframe animations for segmented animation
        UIView.animateKeyframes(withDuration: 1.3, delay: 0, options: .calculationModeCubic) {
            // animation1 = translation back to original position

            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.45) {
                self.currentUserImageView.transform =  CGAffineTransform(rotationAngle: -angle)
                self.cardUserImageView.transform = CGAffineTransform(rotationAngle: angle)
            }
            // rotation2
            UIView.addKeyframe(withRelativeStartTime: 0.6, relativeDuration: 0.4) {
                self.currentUserImageView.transform = .identity
                self.cardUserImageView.transform = .identity
            }
        }

        UIView.animate(withDuration: 0.75, delay: 0.6 * 1.3, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: .curveEaseOut) {
            self.keepSwipingButton.transform = .identity
            self.sendMessageButton.transform = .identity
        }
    }


    lazy var views = [
        itsAMatchImageView,
        descriptionLabel,
        currentUserImageView,
        cardUserImageView,
        sendMessageButton,
        keepSwipingButton
    ]

    fileprivate func setupLayout() {
        views.forEach { view in
            addSubview(view)
            view.alpha = 0
        }
//        addSubview(itsAMatchImageView)
//        addSubview(descriptionLabel)
//        addSubview(currentUserImageView)
//        addSubview(cardUserImageView)
//        addSubview(sendMessageButton)
//        addSubview(keepSwipingButton)

        let imageWidth: CGFloat = 140

        itsAMatchImageView.anchor(top: nil, leading: nil, bottom: descriptionLabel.topAnchor, trailing: nil,
                                  padding: .init(top: 0, left: 0, bottom: 16, right: 0), size: .init(width: 300, height: 80))
        itsAMatchImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        descriptionLabel.anchor(top: nil, leading: self.leadingAnchor, bottom: currentUserImageView.topAnchor,
                                trailing: self.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 32, right: 0),
                                size: .init(width: 0, height: 50))

        currentUserImageView.anchor(top: nil, leading: nil, bottom: nil, trailing: centerXAnchor,
                                    padding: .init(top: 0, left: 0, bottom: 0, right: 16), size: .init(width: imageWidth, height: imageWidth))
        currentUserImageView.layer.cornerRadius = imageWidth / 2
        currentUserImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true

        cardUserImageView.anchor(top: nil, leading: centerXAnchor, bottom: nil, trailing: nil,
                                 padding: .init(top: 0, left: 16, bottom: 0, right: 0), size: .init(width: imageWidth, height: imageWidth))
        cardUserImageView.layer.cornerRadius = imageWidth / 2
        cardUserImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true

        sendMessageButton.anchor(top: currentUserImageView.bottomAnchor, leading: self.leadingAnchor, bottom: nil, trailing: self.trailingAnchor,
                                 padding: .init(top: 32, left: 48, bottom: 0, right: 48), size: .init(width: 0, height: 60))

        keepSwipingButton.anchor(top: sendMessageButton.bottomAnchor, leading: sendMessageButton.leadingAnchor, bottom: nil, trailing: sendMessageButton.trailingAnchor, padding:
                .init(top: 16, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: 60))
    }

    let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))


    fileprivate func setupBlurView() {
        visualEffectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapDismiss)))
        addSubview(visualEffectView)
        visualEffectView.fillSuperview()
        visualEffectView.alpha = 0

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut) {
            self.visualEffectView.alpha = 1
        } completion: { _ in

        }

    }

    @objc fileprivate func handleTapDismiss() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut) {
            self.alpha = 0
        } completion: { _ in
            self.removeFromSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
