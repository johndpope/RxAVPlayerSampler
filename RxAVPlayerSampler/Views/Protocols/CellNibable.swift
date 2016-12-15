//
//  CellNibable.swift
//  RxAVPlayerSampler
//
//  Created by hryk224 on 2016/12/16.
//  Copyright © 2016年 hryk224. All rights reserved.
//

protocol CellNibable: Nibable {
    static var identifier: String { get }
}

extension CellNibable {
    static var identifier: String {
        return className
    }
}
