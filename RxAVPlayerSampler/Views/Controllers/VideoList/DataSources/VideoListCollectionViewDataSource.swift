//
//  VideoListCollectionViewDataSource.swift
//  RxAVPlayerSampler
//
//  Created by hryk224 on 2016/12/16.
//  Copyright © 2016年 hryk224. All rights reserved.
//

import Foundation.NSObject
import UIKit.UICollectionView
import RxSwift
import RxCocoa
import NSObject_Rx

final class VideoListCollectionViewDataSource: NSObject {
    
    fileprivate typealias VideoCell = VideoListCollectionViewCell
    
    weak var collectionView: UICollectionView?
    func register(collectionView: UICollectionView) {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(cell: VideoCell.self)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        self.collectionView = collectionView
    }
    
    func collectionView(_ collectionView: UICollectionView, willChangePlay state: Video.PlayState) {
        collectionView.visibleCells.flatMap { $0 as? VideoCell }.filter { $0.playState == state.changing }.forEach { $0.changePlay(state.value) }
    }
    
    var selectedIndexPath: IndexPath?
    
}

// MARK: - UICollectionViewDataSource
extension VideoListCollectionViewDataSource: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 300
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(type: VideoCell.self, for: indexPath)
        cell.configureVideo()
        cell.volumeButton.rx.tap
            .subscribe(onNext: { [unowned cell] in
                guard let volumeState = cell.volumeState else { return }
                switch volumeState {
                case .off:
                    collectionView.visibleCells.map { $0 as? VideoCell }.filter { cell != $0 }.filter { $0?.volumeState == .on }.forEach { $0?.changeVolume(Video.VolumeState.off.value) }
                case .on:
                    break
                }
                cell.changeVolume(volumeState.isOn ? 0 : 1)
            })
            .addDisposableTo(cell.disposeBag)
        return cell
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
extension VideoListCollectionViewDataSource: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        collectionView.visibleCells.map { $0 as? VideoCell }.filter { cell != $0 }.filter { $0?.volumeState == .on }.forEach { $0?.changeVolume(Video.VolumeState.off.value) }
        self.selectedIndexPath = indexPath
        let next = NextViewController.makeFromStoryboard()
        (UIApplication.shared.keyWindow?.rootViewController as? UINavigationController)?.pushViewController(next, animated: true)
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let collectionView = scrollView as? UICollectionView else { return }
        collectionView.visibleCells.flatMap { $0 as? VideoCell }.filter { $0.volumeState == .on }.filter {
            var bounds = collectionView.bounds
            bounds.origin.y -= $0.frame.height
            bounds.size.height += ($0.frame.height * 2)
            return !bounds.contains($0.frame)
            }
            .forEach { $0.changeVolume(Video.VolumeState.off.value) }
    }
}
