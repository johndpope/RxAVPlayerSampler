//
//  VideoListViewController.swift
//  RxAVPlayerSampler
//
//  Created by hryk224 on 2016/12/16.
//  Copyright © 2016年 hryk224. All rights reserved.
//

import UIKit.UIViewController
import RxSwift

final class VideoListViewController: UIViewController, Storyboardable {
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.backgroundColor = .clear
        }
    }
    @IBOutlet weak var layout: UICollectionViewFlowLayout! {
        didSet {
            layout.minimumLineSpacing = 10
            layout.minimumInteritemSpacing = 10
            layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            layout.itemSize = cellSize
        }
    }
    private let dataSource = VideoListCollectionViewDataSource()
    private let disposeBag = DisposeBag()
    var selectedIndexPath: IndexPath? {
        return dataSource.selectedIndexPath
    }
    private var cellSize: CGSize {
        let screenSize = UIScreen.main.bounds.size
//        let width = (screenSize.width - 30) / 2
        let width = (screenSize.width - 20)
        return CGSize(width: width, height: width)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        observe()
    }
    private func configureUI() {
        view.backgroundColor = .white
        dataSource.register(collectionView: collectionView)
    }
    private func observe() {
        
        NotificationCenter.default.rx.notification(.UIApplicationDidBecomeActive)
            .map { _ in Void() }
            .subscribe(onNext: {
                self.dataSource.collectionView(self.collectionView, willChangePlay: .play)
            })
            .addDisposableTo(disposeBag)
        
        NotificationCenter.default.rx.notification(.UIApplicationDidEnterBackground)
            .map { _ in Void() }
            .subscribe(onNext: {
                self.dataSource.collectionView(self.collectionView, willChangePlay: .pause)
            })
            .addDisposableTo(disposeBag)
        
//        rx.sentMessage(#selector(self.viewWillAppear(_:))).shareReplay(1)
//            .skip(1)
//            .subscribe(onNext: { _ in
//                self.dataSource.collectionView(self.collectionView, willChangePlay: .play)
//            })
//            .addDisposableTo(disposeBag)
//
//        rx.sentMessage(#selector(self.viewWillDisappear(_:))).shareReplay(1)
//            .subscribe(onNext: { _ in
//                self.dataSource.collectionView(self.collectionView, willChangePlay: .pause)
//            })
//            .addDisposableTo(disposeBag)
        
    }

}
