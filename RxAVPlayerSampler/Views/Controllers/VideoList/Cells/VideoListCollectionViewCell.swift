//
//  VideoListCollectionViewCell.swift
//  RxAVPlayerSampler
//
//  Created by hryk224 on 2016/12/16.
//  Copyright © 2016年 hryk224. All rights reserved.
//

import UIKit.UICollectionViewCell
import Kingfisher
import RxSwift
import NSObject_Rx

final class VideoListCollectionViewCell: UICollectionViewCell, CellNibable {
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var volumeButton: UIButton! {
        didSet {
            volumeButton.layer.cornerRadius = 15
            volumeButton.layer.masksToBounds = true
            volumeButton.setBackgroundColor(.red, for: .normal)
            volumeButton.setBackgroundColor(.blue, for: .selected)
            volumeButton.setBackgroundColor(.blue, for: [.selected, .highlighted])
        }
    }
    var videoPlayerView: VideoPlayerView? {
        didSet {
            observeVideoPlayer()
        }
    }
    var videoPlayer: VideoPlayer? {
        return videoPlayerView?.videoPlayer
    }
    var volumeState: Video.VolumeState? {
        return videoPlayer?.volumeState
    }
    var playState: Video.PlayState? {
        return videoPlayer?.playState
    }
    var disposeBag = DisposeBag()
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.image = nil
        removeVideoPlayerView()
    }
    func removeVideoPlayerView() {
        videoPlayerView?.stopVideoPlayer()
        videoPlayerView?.removeFromSuperview()
    }
    func configureVideo() {
        removeVideoPlayerView()
        disposeBag = DisposeBag()
        makeVideoPlayer()
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .userInteractive))
            .subscribe(onNext: { videoPlayerView in
                videoPlayerView.assetURL(URL(string: App.video.url)!)
                self.videoPlayerView = videoPlayerView
            })
            .addDisposableTo(disposeBag)
        let resource = ImageResource(downloadURL: URL(string: App.image.url)!)
        thumbnailImageView.kf.setImage(with: resource)
        setNeedsLayout()
        layoutIfNeeded()
    }
    func configureImage() {
        removeVideoPlayerView()
        disposeBag = DisposeBag()
        let resource = ImageResource(downloadURL: URL(string: App.image.url)!)
        thumbnailImageView.kf.setImage(with: resource)
        setNeedsLayout()
        layoutIfNeeded()
    }
    func changeVolume(_ volume: Float) {
        videoPlayer?.changeVolume(volume)
    }
    func changePlay(_ play: Bool) {
        videoPlayer?.changePlay(play)
    }
    func makeVideoPlayer() -> Observable<VideoPlayerView> {
        let videoPlayerView = VideoPlayerView(frame: bounds)
        insertVideoPlayerView(videoPlayerView)
        return .just(videoPlayerView)
    }
    func insertVideoPlayerView(_ videoPlayerView: VideoPlayerView) {
        contentView.insertSubview(videoPlayerView, aboveSubview: thumbnailImageView)
    }
    func observeVideoPlayer() {
        guard let videoPlayer = videoPlayer else { return }
        
        Observable.combineLatest(videoPlayer.rx.playable.asObservable(), videoPlayer.rx.volume.asObservable()) { $0 }
            .filter { $0.0 == true }
            .skip(1)
            .map { $0.1 > 0 ? Video.VolumeState.on : Video.VolumeState.off }
            .subscribe(onNext: { [weak self] volumeState in
                self?.volumeButton.isSelected = volumeState.isOn
            })
            .addDisposableTo(videoPlayer.disposeBag)
        
    }
}
