//
//  Reactive+AVPlayerItem.swift
//  RxAVPlayerSampler
//
//  Created by yoshida hiroyuki on 2016/12/16.
//  Copyright © 2016年 hryk224. All rights reserved.
//

import AVFoundation
import RxSwift
import RxCocoa

extension Reactive where Base: AVPlayerItem {
    var status: Observable<AVPlayerItemStatus> {
        return observe(AVPlayerItemStatus.self, #keyPath(AVPlayerItem.status))
            .map { $0 ?? .unknown }
    }
    var duration: Observable<CMTime> {
        return observe(CMTime.self, #keyPath(AVPlayerItem.duration))
            .map { $0 ?? kCMTimeZero }
    }
    var error: Observable<Error?> {
        return observe(Error.self, #keyPath(AVPlayerItem.error))
    }
    var playbackLikelyToKeepUp: Observable<Bool> {
        return observe(Bool.self, #keyPath(AVPlayerItem.isPlaybackLikelyToKeepUp))
            .map { $0 ?? false }
    }
    var playbackBufferFull: Observable<Bool> {
        return observe(Bool.self, #keyPath(AVPlayerItem.isPlaybackBufferFull))
            .map { $0 ?? false }
    }
    var playbackBufferEmpty: Observable<Bool> {
        return observe(Bool.self, #keyPath(AVPlayerItem.isPlaybackBufferEmpty))
            .map { $0 ?? false }
    }
    var didPlayToEnd: Observable<Notification> {
        return NotificationCenter.default.rx.notification(.AVPlayerItemDidPlayToEndTime, object: base)
    }
    var loadedTimeRanges: Observable<[CMTimeRange]> {
        return observe([NSValue].self, #keyPath(AVPlayerItem.loadedTimeRanges))
            .map { $0 ?? [] }
            .map { values in values.map { $0.timeRangeValue } }
    }
}
