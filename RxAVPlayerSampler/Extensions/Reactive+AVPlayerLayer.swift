//
//  Reactive+AVPlayerLayer.swift
//  RxAVPlayerSampler
//
//  Created by yoshida hiroyuki on 2016/12/16.
//  Copyright © 2016年 hryk224. All rights reserved.
//

import AVFoundation
import RxSwift
import RxCocoa

extension Reactive where Base: AVPlayerLayer {
    var readyForDisplay: Observable<Bool> {
        return observe(Bool.self, #keyPath(AVPlayerLayer.readyForDisplay))
            .map { $0 ?? false }
    }    
}
