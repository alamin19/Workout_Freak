//
//  CustomButton.swift
//  Workout Freak
//
//  Created by Al Amin on 28.03.18.
//  Copyright © 2018 Amin. All rights reserved.
//

import UIKit

class CustomButton: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // dropshadow
        layer.shadowColor = UIColor(red: SHADOW_GRAY, green: SHADOW_GRAY, blue: SHADOW_GRAY, alpha: 0.6).cgColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 5.0
        layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        
        // rounded edges
        layer.cornerRadius = 2.0
        
    }

}
