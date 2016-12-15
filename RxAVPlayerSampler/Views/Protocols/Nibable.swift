//
//  Nibable.swift
//  RxAVPlayerSampler
//
//  Created by hryk224 on 2016/12/16.
//  Copyright © 2016年 hryk224. All rights reserved.
//

import Foundation.NSObject
import UIKit.UINib

protocol Nibable: NSObjectProtocol {
    associatedtype Instance
    static func makeFromNib(_ index: Int) -> Instance
    static var nib: UINib { get }
    static var nibName: String { get }
}

extension Nibable {
    static var nib: UINib {
        return UINib(nibName: nibName, bundle: Bundle(for: self))
    }
    static var nibName: String {
        return className
    }
    static func makeFromNib(_ index: Int = 0) -> Self {
        return nib.instantiate(withOwner: self, options: nil)[index] as! Self
    }
}
