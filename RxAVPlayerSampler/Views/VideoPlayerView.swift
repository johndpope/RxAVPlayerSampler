//
//  VideoPlayerView.swift
//  RxAVPlayerSampler
//
//  Created by hryk224 on 2016/12/16.
//  Copyright © 2016年 hryk224. All rights reserved.
//

import UIKit.UIView
import AVFoundation
import RxSwift
import RxCocoa

class VideoPlayerView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    deinit {
        stopVideoPlayer()
        let layer = playerLayer
        let qos = DispatchQoS.QoSClass.background
        DispatchQueue.global(qos: qos).async {
            //            Logger.error("Remove video player")
            layer.videoPlayer = nil
            layer.player = nil
        }
    }
    override class var layerClass: AnyClass {
        return VideoPlayerLayer.self
    }
    var playerLayer: VideoPlayerLayer {
        return layer as! VideoPlayerLayer
    }
    var videoPlayer: VideoPlayer? {
        return playerLayer.videoPlayer
    }
    private var disposeBag = DisposeBag()
    func configure() {
        playerLayer.configure()
        playerLayer.observe()
    }
    func assetURL(_ URL: URL, time: CMTime = kCMTimeZero, volume: Float = 0) {
        playerLayer.videoPlayer = VideoPlayer(url: URL, time: time, volume: volume)
    }
    func stopVideoPlayer() {
        playerLayer.stop()
    }
}
