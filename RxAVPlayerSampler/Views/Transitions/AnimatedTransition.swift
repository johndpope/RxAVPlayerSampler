//
//  AnimatedTransition.swift
//  RxAVPlayerSampler
//
//  Created by yoshida hiroyuki on 2016/12/21.
//  Copyright © 2016年 hryk224. All rights reserved.
//

import UIKit

final class AnimatedTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let navigationControllerOperation: UINavigationControllerOperation
    
    required init(operation: UINavigationControllerOperation) {
        navigationControllerOperation = operation
        super.init()
    }
    
    private var screenSize: CGSize {
        return UIScreen.main.bounds.size
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        switch navigationControllerOperation {
        case .push:
            pushAnimation(using: transitionContext)
        case .pop:
            popAnimation(using: transitionContext)
        default:
            cancel(using: transitionContext)
        }
    }
    
    func cancel(using transitionContext: UIViewControllerContextTransitioning) {
        let cancelled = transitionContext.transitionWasCancelled
        transitionContext.completeTransition(!cancelled)
    }
    
    private func pushAnimation(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from) as? VideoListViewController,
            let toView = transitionContext.view(forKey: .to),
            let selectedIndexPath = fromVC.selectedIndexPath,
            let cell = fromVC.collectionView.cellForItem(at: selectedIndexPath) as? VideoListCollectionViewCell,
            let videoPlayerView = cell.videoPlayerView else {
                cancel(using: transitionContext)
                return
        }
        let containerView = transitionContext.containerView
        containerView.backgroundColor = .clear
        containerView.addSubview(fromVC.view)
        videoPlayerView.frame = videoPlayerView.convert(videoPlayerView.frame, to: fromVC.view)
        toView.addSubview(videoPlayerView)
        toView.backgroundColor = .clear
        containerView.addSubview(toView)
        let animations = {
            videoPlayerView.frame.size = CGSize(width: self.screenSize.width, height: self.screenSize.width)
            videoPlayerView.center = toView.center
            toView.backgroundColor = .black
        }
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: animations) {
            guard $0 else { return }
            let cancelled = transitionContext.transitionWasCancelled
            if cancelled {
                toView.removeFromSuperview()
            } else {
                fromVC.view.removeFromSuperview()
                videoPlayerView.videoPlayer?.changeVolume(1)
            }
            transitionContext.completeTransition(!cancelled)
        }
    }
    
    private func popAnimation(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.view(forKey: .from),
            let videoPlayerView = fromView.subviews.flatMap({ $0 as? VideoPlayerView }).first,
            let toVC = transitionContext.viewController(forKey: .to) as? VideoListViewController,
            let selectedIndexPath = toVC.selectedIndexPath,
            let cell = toVC.collectionView.cellForItem(at: selectedIndexPath) as? VideoListCollectionViewCell else {
                cancel(using: transitionContext)
                return
        }
        let containerView = transitionContext.containerView
        containerView.backgroundColor = .clear
        containerView.addSubview(toVC.view)
        containerView.addSubview(fromView)
        containerView.addSubview(videoPlayerView)
        let animations = {
            videoPlayerView.frame.origin = cell.convert(cell.bounds.origin, to: toVC.view)
            videoPlayerView.frame.size = cell.bounds.size
        }
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: animations) {
            guard $0 else { return }
            let cancelled = transitionContext.transitionWasCancelled
            if cancelled {
                toVC.view.removeFromSuperview()
            } else {
                fromView.removeFromSuperview()
                videoPlayerView.removeFromSuperview()
                videoPlayerView.frame = cell.bounds
                cell.insertVideoPlayerView(videoPlayerView)
            }
            transitionContext.completeTransition(!cancelled)
        }
    }
    
}
