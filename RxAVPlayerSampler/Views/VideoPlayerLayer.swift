//
//  VideoPlayerLayer.swift
//  RxAVPlayerSampler
//
//  Created by yoshida hiroyuki on 2016/12/16.
//  Copyright © 2016年 hryk224. All rights reserved.
//

import UIKit
import AVFoundation
import RxSwift
import RxCocoa

class VideoPlayerLayer: AVPlayerLayer {
    fileprivate var disposeBag: DisposeBag?
    fileprivate var playerdisposeBag: DisposeBag?
    var videoPlayer: VideoPlayer? {
        didSet {
            guard let videoPlayer = videoPlayer else { return }
            observePlayerPlayable(videoPlayer)
        }
    }
    override init(layer: Any) {
        super.init(layer: layer)
    }
    override init() {
        super.init()
        configure()
        observe()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func configure() {
        isDoubleSided = false
        drawsAsynchronously = true
        videoGravity = AVLayerVideoGravityResizeAspect
    }
    func stop() {
        self.disposeBag = nil
        self.playerdisposeBag = nil
        player?.pause()
        player = nil
        videoPlayer?.stop()
        videoPlayer = nil
    }
    func observe() {
        let disposeBag = DisposeBag()
        self.disposeBag = disposeBag
        rx.readyForDisplay
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .userInteractive))
            .subscribe(onNext: { [weak self] readyForDisplay in
                guard readyForDisplay else { return }
//                Logger.info("Ready for display")
                self?.hidden(false, animated: true)
            })
            .addDisposableTo(disposeBag)
    }
    func observePlayerPlayable(_ videoPlayer: VideoPlayer) {
        let disposeBag = DisposeBag()
        playerdisposeBag = disposeBag
        
        // 再生準備
        videoPlayer.rx.playable.asObservable()
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .userInteractive))
            .filter { $0 == true }
            .subscribe(onNext: { [weak self] _ in
                self?.player = videoPlayer.player
                videoPlayer.changePlay(true)
            })
            .addDisposableTo(disposeBag)
        
        // 再生停止
        videoPlayer.rx.isPlaying.asObservable()
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .default))
            .subscribe(onNext: { isPlaying in
                if isPlaying {
                    self.player?.play()
                } else {
                    self.player?.pause()
                }
            })
            .addDisposableTo(disposeBag)
        
        // トラッキング
        videoPlayer.rx.periodicTimeObserver.asObservable()
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .map { floor($0.seconds) }
            .filter { $0 == Double(3) }
            .subscribe(onNext: { timer in
//                Logger.info(" [Tracking] timer: \(timer) 秒再生")
            })
            .addDisposableTo(disposeBag)

        // リピート
        videoPlayer.rx.didPlayToEnd.asObservable()
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .userInteractive))
            .subscribe(onNext: { [weak self] in
                self?.player?.pause()
                self?.player?.seek(to: kCMTimeZero)
                self?.player?.play()
            })
            .addDisposableTo(disposeBag)
    }
    
    func hidden(_ hidden: Bool, animated: Bool = false) {
        if animated {
            if hidden == false {
                self.isHidden = false
            }
            CATransaction.begin()
            CATransaction.setCompletionBlock({
                self.isHidden = hidden
                self.opacity = hidden ? 0 : 1
            })
            let animation = CABasicAnimation(keyPath: "opacity")
            animation.duration = 0.15
            animation.fromValue = hidden ? 1 : 0
            animation.toValue = hidden ? 0 : 1
            animation.fillMode = kCAFillModeForwards
            add(animation, forKey: "opacity")
            CATransaction.commit()
        } else {
            self.isHidden = hidden
        }
    }
    
}
