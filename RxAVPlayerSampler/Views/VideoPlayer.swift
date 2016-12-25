//
//  VideoPlayer.swift
//  RxAVPlayerSampler
//
//  Created by yoshida hiroyuki on 2016/12/20.
//  Copyright © 2016年 hryk224. All rights reserved.
//

import AVFoundation
import RxSwift

final class VideoPlayer: ReactiveCompatible {
    enum ErrorStatus {
        case success
        case notFound
        case unavailable
        case unknown
        // http://villy21.livejournal.com/12782.html
        init(event: AVPlayerItemErrorLogEvent) {
            switch event.errorStatusCode {
            case -12938:    self = .notFound
            case -12661:    self = .unavailable
            default:        self = .unknown
            }
        }
    }
    private static let minimumBitRate: Double = 100 * 1024
    private let minimumBitRate: Double = VideoPlayer.minimumBitRate
    let videoPlayerScheduler = ConcurrentDispatchQueueScheduler(qos: .default)
    let playerItem: AVPlayerItem
    fileprivate(set) var player: AVPlayer?
    var asset: AVAsset {
        return playerItem.asset
    }
    var url: URL? {
        return (asset as? AVURLAsset)?.url
    }
    fileprivate(set) var disposeBag = DisposeBag()
    
    //
    fileprivate let rxPlayable = Variable<Bool>(false)
    fileprivate let rxIsPlaying = Variable<Bool>(false)
    fileprivate let rxVolume = Variable<Float>(0)
    fileprivate let rxPeriodicTimeObserver = Variable<CMTime>(kCMTimeZero)
    fileprivate let rxDidPlayToEnd = Variable<Void>()
    
    private var volume: Float {
        get { return rxVolume.value }
        set { rxVolume.value = newValue }
    }
    
    var volumeState: Video.VolumeState {
        return volume > 0 ? .on : .off
    }
    
    private var isPlaying: Bool {
        get { return rxIsPlaying.value }
        set { rxIsPlaying.value = newValue }
    }
    
    var playState: Video.PlayState {
        return isPlaying ? .play : .pause
    }
    
    init(url: URL, time: CMTime, volume: Float) {
        let asset = AVURLAsset(url: url)
        playerItem = AVPlayerItem(asset: asset)
        playerItem.seek(to: time)
        playerItem.preferredPeakBitRate = minimumBitRate
        rxVolume.value = volume
        start()
    }
    
    func stop() {
        disposeBag = DisposeBag()
    }

    func changeVolume(_ volume: Float) {
        self.volume = volume
    }
    
    func changePlay(_ play: Bool) {
        self.isPlaying = play
    }
    
}

private extension VideoPlayer {
    
    func start() {
        asset.rx.playable
            .filter { $0 == true }
            .map { _ in Void() }
            .take(1)
            .observeOn(MainScheduler.instance)
            .do(onNext: { [weak self] in
                guard let weakSelf = self else { return }
                weakSelf.player = AVPlayer(playerItem: weakSelf.playerItem)
                weakSelf.player?.volume = weakSelf.rxVolume.value
            })
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .userInteractive))
            .subscribe(onNext: { [weak self] in
                self?.observePlayable()
                self?.observeAssetValues()
            })
            .addDisposableTo(disposeBag)
        
        playerItem.rx.didPlayToEnd
            .map { $0.object as? AVPlayerItem }
            .filter { $0 == self.playerItem }
            .map { _ in Void()}
            .bindTo(rxDidPlayToEnd)
            .addDisposableTo(disposeBag)
    }
    
    func observePlayable() {
        
        // Player 再生秒数
        player?.rx.periodicTimeObserver(interval: CMTime(seconds: 1, preferredTimescale: CMTimeScale(1)))
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .bindTo(rxPeriodicTimeObserver)
            .addDisposableTo(disposeBag)
        
        // 音量変更
        Observable.combineLatest(rxPlayable.asObservable(), rxVolume.asObservable()) { $0 }
            .observeOn(videoPlayerScheduler)
            .filter { $0.0 == true }
            .skip(1)
            .subscribe(onNext: { [weak self] _, volume in
                self?.player?.volume = volume
            })
            .addDisposableTo(disposeBag)

    }

    func observeAssetValues() {
        
        asset.rx.playable
            .observeOn(videoPlayerScheduler)
            .bindTo(rxPlayable)
            .addDisposableTo(disposeBag)

    }
    
    func observeAVNotification() {
        Video.manager.rx.oldDeviceUnavailable.asObservable()
            .observeOn(videoPlayerScheduler)
            .subscribe(onNext: {
                let alert = UIAlertController(title: "oldDeviceUnavailable", message: nil, preferredStyle: .alert)
                UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
            })
            .addDisposableTo(disposeBag)
        
        Video.manager.rx.interruptionEnded.asObservable()
            .observeOn(videoPlayerScheduler)
            .map { $0 ?? AVAudioSessionInterruptionType.ended }
            .subscribe(onNext: { audioSessionInterruptionType in
                Logger.error("audioSessionInterruptionType: \(audioSessionInterruptionType)")
                let alert = UIAlertController(title: "audioSessionInterruptionType", message: String(audioSessionInterruptionType.rawValue), preferredStyle: .alert)
                UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
            })
            .addDisposableTo(disposeBag)

    }
    
}

extension Reactive where Base: VideoPlayer {
    var playable: Variable<Bool> {
        return base.rxPlayable
    }
    var isPlaying: Variable<Bool> {
        return base.rxIsPlaying
    }
    var periodicTimeObserver: Variable<CMTime> {
        return base.rxPeriodicTimeObserver
    }
    var didPlayToEnd: Variable<Void> {
        return base.rxDidPlayToEnd
    }
    var volume: Variable<Float> {
        return base.rxVolume
    }
}
