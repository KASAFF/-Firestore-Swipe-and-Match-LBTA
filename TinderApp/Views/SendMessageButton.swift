//
//  SendMessageButton.swift
//  TinderApp
//
//  Created by Aleksey Kosov on 26.12.2022.
//

import UIKit

class SendMessageButton: UIButton {

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        let gradientLayer = CAGradientLayer()
        let leftColor = #colorLiteral(red: 0.9780111909, green: 0.1424481571, blue: 0.4468462467, alpha: 1)
        let rightColor = #colorLiteral(red: 0.9863607287, green: 0.4016316533, blue: 0.3039668798, alpha: 1)
        gradientLayer.colors = [leftColor.cgColor, rightColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)


        self.layer.insertSublayer(gradientLayer, at: 0)

        layer.cornerRadius = rect.height / 2
        clipsToBounds = true


        gradientLayer.frame = rect

    }

}
