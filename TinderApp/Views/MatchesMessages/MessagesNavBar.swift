//
//  MessagesNavBar.swift
//  TinderApp
//
//  Created by Aleksey Kosov on 27.12.2022.
//

import LBTATools

class MessagesNavBar: UIView {

    let userProfileImageView = CircularImageView(width: 44, image: #imageLiteral(resourceName: "jane1"))
    let nameLabel = UILabel(text: "ÜserName", font: .systemFont(ofSize: 16))

    let backButton = UIButton(image: #imageLiteral(resourceName: "back"), tintColor: #colorLiteral(red: 0.9471849799, green: 0.3858051896, blue: 0.373521179, alpha: 1))
    let flagButton = UIButton(image: #imageLiteral(resourceName: "flag"), tintColor: #colorLiteral(red: 0.9471849799, green: 0.3858051896, blue: 0.373521179, alpha: 1))

    fileprivate let match: Match

    init(match: Match) {
        self.match = match
        super.init(frame: .zero)
        nameLabel.text = match.name
        userProfileImageView.sd_setImage(with: URL(string: match.profileImageUrl))
        backgroundColor = .white

        setupShadow(opacity: 0.2, radius: 8, offset: .init(width: 0, height: 10),
                           color: .init(white: 0, alpha: 0.3))

//        userProfileImageView.constrainWidth(44)
//        userProfileImageView.constrainHeight(44)
//        userProfileImageView.clipsToBounds = true
//        userProfileImageView.layer.cornerRadius = 44 / 2

        let middle = hstack(
            stack(
                userProfileImageView,
                nameLabel,
                spacing: 8,
                alignment: .center),
            alignment: .center
        )


        hstack(backButton.withWidth(50),
               middle,
               flagButton).withMargins(.init(top: 0, left: 4, bottom: 0, right: 16))


    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
