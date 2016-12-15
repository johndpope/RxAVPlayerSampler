//
//  Storyboardable.swift
//  RxAVPlayerSampler
//
//  Created by hryk224 on 2016/12/16.
//  Copyright © 2016年 hryk224. All rights reserved.
//

import Foundation.NSObject
import UIKit.UIStoryboard

protocol Storyboardable: NSObjectProtocol {
    associatedtype Instance
    static func makeFromStoryboard() -> Instance
    static var storyboard: UIStoryboard { get }
    static var storyboardName: String { get }
}

extension Storyboardable {
    static var storyboardName: String {
        return className
    }
    static var storyboard: UIStoryboard {
        return UIStoryboard(name: storyboardName, bundle: nil)
    }
    static func makeFromStoryboard() -> Self {
        return storyboard.instantiateInitialViewController() as! Self
    }
}
