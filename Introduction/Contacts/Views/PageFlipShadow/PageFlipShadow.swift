//
//  PageFlipShadow.swift
//  Introduction
//
//  Created by Peter Fong on 10/8/18.
//  Copyright © 2018 Peter Fong. All rights reserved.
//

import UIKit

class PageFlipShadowLayer: CALayer {
    private override init() {
        super.init()
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
        self.opacity = 0
    }
    
    convenience required init(size: CGSize) {
        self.init()
        self.createShadow(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    func createShadow(size: CGSize) {
        /// Center section of the shadow
        let centerShadowSection = CAShapeLayer()
        let shadowPath = UIBezierPath()
        shadowPath.move(to: CGPoint(x: size.width / 4, y: 0))
        shadowPath.addLine(to: CGPoint(x: size.width / 4 * 3, y: 0))
        shadowPath.move(to: CGPoint(x: size.width / 4, y: 0))
        shadowPath.addCurve(to: CGPoint(x: size.width / 4 * 3, y: 0), controlPoint1: CGPoint(x: size.width / 2, y: 1.5), controlPoint2: CGPoint(x: size.width / 2, y: 1.5))
        centerShadowSection.path = shadowPath.cgPath
        centerShadowSection.strokeColor = UIColor(displayP3Red: 245/255, green: 245/255, blue: 245/255, alpha: 1).cgColor
        centerShadowSection.fillColor = UIColor.clear.cgColor
        centerShadowSection.lineWidth = 1.0
        
        /// Left section gradient
        let leftGradient = CAGradientLayer()
        leftGradient.startPoint = CGPoint(x: 0, y: 0)
        leftGradient.endPoint = CGPoint(x: 1, y: 0)
        leftGradient.frame = CGRect(origin: CGPoint(x: size.width / 10, y: -0.5), size: CGSize(width: size.width / 4 - size.width / 10, height: 1))
        leftGradient.colors = [UIColor(displayP3Red: 250/255, green: 250/255, blue: 250/255, alpha: 1).cgColor, UIColor(displayP3Red: 245/255, green: 245/255, blue: 245/255, alpha: 1).cgColor]
        
        /// right section gradient
        let rightGradient = CAGradientLayer()
        rightGradient.startPoint = CGPoint(x: 0, y: 0)
        rightGradient.endPoint = CGPoint(x: 1, y: 0)
        rightGradient.frame = CGRect(origin: CGPoint(x: size.width / 4 * 3, y: -0.5), size: CGSize(width: size.width / 4 - size.width / 10, height: 1))
        rightGradient.colors = [UIColor(displayP3Red: 245/255, green: 245/255, blue: 245/255, alpha: 1).cgColor, UIColor(displayP3Red: 250/255, green: 250/255, blue: 250/255, alpha: 1).cgColor,]
        
        self.shadowColor = UIColor.black.cgColor
        self.shadowOffset = CGSize(width: 0, height: 1)
        self.shadowRadius = 1
        self.shadowOpacity = 0.05
        self.backgroundColor = UIColor.clear.cgColor
        self.insertSublayer(centerShadowSection, at: 0)
        self.insertSublayer(leftGradient, at: 0)
        self.insertSublayer(rightGradient, at: 0)
        self.opacity = 0
    }
    
    func fadeIn() {
        self.opacity = 1.0
        let fadeAnimation = CABasicAnimation(keyPath: "opacity")
        fadeAnimation.fromValue = 0
        fadeAnimation.toValue = 1
        fadeAnimation.duration = 0.2
        self.add(fadeAnimation, forKey: "fadeIn")
    }
    
    func fadeOut() {
        self.opacity = 0.0
        let fadeAnimation = CABasicAnimation(keyPath: "opacity")
        fadeAnimation.fromValue = 1
        fadeAnimation.toValue = 0
        fadeAnimation.duration = 0.1
        self.add(fadeAnimation, forKey: "fadeOut")
        
    }
}
