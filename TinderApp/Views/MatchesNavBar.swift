//
//  MatchesNavBar.swift
//  TinderApp
//
//  Created by Aleksey Kosov on 26.12.2022.
//
import LBTATools
import UIKit

class MatchesNavBar: UIView {

    let backButton = UIButton(image: #imageLiteral(resourceName: "app_icon"), tintColor: .gray)

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .white

        let iconImageView = UIImageView(image: #imageLiteral(resourceName: "top_right_messages").withRenderingMode(.alwaysTemplate), contentMode: .scaleAspectFit)
        iconImageView.tintColor = #colorLiteral(red: 0.8328611255, green: 0.4240204096, blue: 0.4448758364, alpha: 1)
        let messagesLabel = UILabel(text: "Messages", font: .boldSystemFont(ofSize: 20), textColor: #colorLiteral(red: 0.8328611255, green: 0.4240204096, blue: 0.4448758364, alpha: 1), textAlignment: .center)
        let feedLabel = UILabel(text: "Feed", font: .boldSystemFont(ofSize: 20), textColor: .gray, textAlignment: .center)
        setupShadow(opacity: 0.2, radius: 8, offset: .init(width: 0, height: 10),
                           color: .init(white: 0, alpha: 0.3))
        stack(iconImageView.withHeight(44),
                     hstack(messagesLabel, feedLabel, distribution: .fillEqually)).padTop(10)

        addSubview(backButton)
        backButton.anchor(top: safeAreaLayoutGuide.topAnchor, leading: leadingAnchor, bottom: nil, trailing: nil,
                          padding: .init(top: 12, left: 12, bottom: 0, right: 0), size: .init(width: 34, height: 34))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
