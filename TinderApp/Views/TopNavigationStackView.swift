//
//  TopNavigationStackView.swift
//  TinderApp
//
//  Created by Aleksey Kosov on 21.12.2022.
//

import UIKit

class TopNavigationStackView: UIStackView {

    let settingsButton = UIButton(type: .system)
    let messageButton = UIButton(type: .system)
    let fireImageView = UIImageView(image: #imageLiteral(resourceName: "app_icon"))

    override init(frame: CGRect) {
        super.init(frame: frame)
        heightAnchor.constraint(equalToConstant: 80).isActive = true

        fireImageView.contentMode = .scaleAspectFit
        settingsButton.setImage(UIImage(named: "top_left_profile")?.withRenderingMode(.alwaysOriginal), for: .normal)
        messageButton.setImage(UIImage(named: "top_right_messages")?.withRenderingMode(.alwaysOriginal), for: .normal)

        [settingsButton, UIView(), fireImageView, UIView(), messageButton].forEach { view in
            addArrangedSubview(view)
        }
        distribution = .equalCentering

        isLayoutMarginsRelativeArrangement = true
        layoutMargins = .init(top: 0, left: 16, bottom: 0, right: 16)

    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
