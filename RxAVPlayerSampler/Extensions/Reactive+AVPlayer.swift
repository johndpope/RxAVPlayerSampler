//
//  Reactive+AVPlayer.swift
//  RxAVPlayerSampler
//
//  Created by yoshida hiroyuki on 2016/12/16.
//  Copyright © 2016年 hryk224. All rights reserved.
//

import AVFoundation
import RxSwift
import RxCocoa

extension Reactive where Base: AVPlayer  {
    var rate: Observable<Float> {
        return observe(Float.self, #keyPath(AVPlayer.rate))
            .map { $0 ?? 0 }
    }
    var status: Observable<AVPlayerStatus> {
        return observe(AVPlayerStatus.self, #keyPath(AVPlayer.status))
            .map { $0 ?? .unknown }
    }
    var volume: Observable<Float> {
        return observe(Float.self, #keyPath(AVPlayer.volume)).map { $0 ?? 0 }
    }
    var error: Observable<Error?> {
        return observe(Error.self, #keyPath(AVPlayer.error))
    }
    func periodicTimeObserver(interval: CMTime) -> Observable<CMTime> {
        return Observable.create { observer in
            let timeObserver = self.base.addPeriodicTimeObserver(forInterval: interval, queue: nil) { time in
                observer.onNext(time)
            }
            return Disposables.create { self.base.removeTimeObserver(timeObserver) }
        }
    }
    func boundaryTimeObserver(times: [CMTime]) -> Observable<Void> {
        return Observable.create { observer in
            let timeValues = times.map() { NSValue(time: $0) }
            let timeObserver = self.base.addBoundaryTimeObserver(forTimes: timeValues, queue: nil) {
                observer.onNext()
            }
            return Disposables.create { self.base.removeTimeObserver(timeObserver) }
        }
    }
}
