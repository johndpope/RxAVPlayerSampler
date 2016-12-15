//
//  UIButton.swift
//  RxAVPlayerSampler
//
//  Created by yoshida hiroyuki on 2016/12/21.
//  Copyright © 2016年 hryk224. All rights reserved.
//

import UIKit.UIButton

extension UIButton {
    func setBackgroundColor(_ color: UIColor, for state: UIControlState) {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        UIGraphicsGetCurrentContext()?.setFillColor(color.cgColor)
        UIGraphicsGetCurrentContext()?.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        defer {
            UIGraphicsEndImageContext()
        }
        setBackgroundImage(UIGraphicsGetImageFromCurrentImageContext(), for: state)
    }
}
