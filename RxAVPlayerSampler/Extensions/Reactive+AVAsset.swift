//
//  Reactive+AVAsset.swift
//  RxAVPlayerSampler
//
//  Created by yoshida hiroyuki on 2016/12/16.
//  Copyright © 2016年 hryk224. All rights reserved.
//

import AVFoundation
import RxSwift
import RxCocoa

extension Reactive where Base: AVAsset {
    var duration: Observable<CMTime> {
        let keys: [String] = ["duration"]
        return Observable.create { observer in
            self.base.loadValuesAsynchronously(forKeys: keys) {
                observer.onNext(self.base.duration)
            }
            return Disposables.create()
        }
    }
    var playable: Observable<Bool> {
        let keys: [String] = ["playable"]
        return Observable.create { observer in
            self.base.loadValuesAsynchronously(forKeys: keys) {
                observer.onNext(self.base.isPlayable)
            }
            return Disposables.create()
        }
    }    
}
