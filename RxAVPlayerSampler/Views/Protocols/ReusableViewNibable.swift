//
//  ReusableViewNibable.swift
//  RxAVPlayerSampler
//
//  Created by hryk224 on 2016/12/16.
//  Copyright © 2016年 hryk224. All rights reserved.
//

protocol ReusableViewNibable: Nibable {
    static var identifier: String { get }
}

extension ReusableViewNibable {
    static var identifier: String {
        return className
    }
}
