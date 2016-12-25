//
//  Video+Notification.swift
//  RxAVPlayerSampler
//
//  Created by yoshida hiroyuki on 2016/12/19.
//  Copyright © 2016年 hryk224. All rights reserved.
//

import AVFoundation
import RxSwift
import RxCocoa

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
    static let manager: Manager = Manager()
}

// MARK: - Manager
extension Video {
    final class Manager: ReactiveCompatible {
        fileprivate let rxOldDeviceUnavailable = Variable<Void>()
        fileprivate let rxInterruptionEnded = Variable<AVAudioSessionInterruptionType?>(nil)
        fileprivate var audioSessionChangedDisposeBag = DisposeBag()
    }
}

extension Video.Manager {
    private var notificationCenter: NotificationCenter {
        return .default
    }
    private var audioSession: AVAudioSession {
        return .sharedInstance()
    }
    func startObserve() {
        notificationCenter.rx.notification(.AVAudioSessionRouteChange)
            .map { notification -> AVAudioSessionRouteChangeReason? in
                guard let reasonNumber = notification.userInfo?[AVAudioSessionRouteChangeReasonKey] as? NSNumber else {
                    return nil
                }
                return AVAudioSessionRouteChangeReason(rawValue: reasonNumber.uintValue)
            }
            .filter { $0 == .oldDeviceUnavailable }
            .map { _ in Void() }
            .bindTo(rxOldDeviceUnavailable)
            .addDisposableTo(audioSessionChangedDisposeBag)
        
        notificationCenter.rx.notification(.AVAudioSessionInterruption)
            .map { notification -> AVAudioSessionInterruptionType? in
                guard let interruptionTypeNumber = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? NSNumber else {
                    return nil
                }
                return AVAudioSessionInterruptionType(rawValue: interruptionTypeNumber.uintValue)
            }
            .bindTo(rxInterruptionEnded)
            .addDisposableTo(audioSessionChangedDisposeBag)
        
        do {
            try audioSession.setActive(true)
        } catch let error {
            Logger.error("\(error)")
        }
    }
    func stopObserve() {
        do {
            try audioSession.setActive(false)
        } catch let error {
            Logger.error("\(error)")
        }
        audioSessionChangedDisposeBag = DisposeBag()
    }
    func setCategorySoloAmbient() {
        do {
            try audioSession.setCategory(AVAudioSessionCategorySoloAmbient)
        } catch  {
            Logger.error("can not set category to AVAudioSession")
        }
    }
}

extension Reactive where Base: Video.Manager {
    var oldDeviceUnavailable: Variable<Void> {
        return base.rxOldDeviceUnavailable
    }
    var interruptionEnded: Variable<AVAudioSessionInterruptionType?> {
        return base.rxInterruptionEnded
    }
}
