//
//  Video+Notification.swift
//  RxAVPlayerSampler
//
//  Created by yoshida hiroyuki on 2016/12/19.
//  Copyright © 2016年 hryk224. All rights reserved.
//

import AVFoundation

struct Video {
    enum VolumeState: Float {
        case on = 1, off = 0
        var isOn: Bool {
            return self == .on
        }
        var isOff: Bool {
            return self == .off
        }
        var changing: VolumeState {
            switch self {
            case .on:
                return .off
            case .off:
                return .on
            }
        }
        var value: Float {
            return rawValue
        }
    }
    enum PlayState {
        case play, pause
        var changing: PlayState {
            switch self {
            case .play:
                return .pause
            case .pause:
                return .play
            }
        }
        var value: Bool {
            switch self {
            case .play:
                return true
            case .pause:
                return false
            }
        }
    }
}
