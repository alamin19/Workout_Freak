//
//  CircleView.swift
//  Workout Freak
//
//  Created by Al Amin on 28.03.18.
//  Copyright © 2018 Amin. All rights reserved.
//

import UIKit

class CircleView: UIImageView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = self.frame.width / 2
        clipsToBounds = true
    }
    
}
