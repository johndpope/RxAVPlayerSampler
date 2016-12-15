//
//  EdgeAnimatedTransition.swift
//  RxAVPlayerSampler
//
//  Created by yoshida hiroyuki on 2016/12/22.
//  Copyright © 2016年 hryk224. All rights reserved.
//

import UIKit

final class EdgeAnimatedTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    required init(operation: UINavigationControllerOperation) {
        navigationControllerOperation = operation
        super.init()
    }
    
    private let navigationControllerOperation: UINavigationControllerOperation
    private let screenSize = UIScreen.main.bounds.size

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        switch navigationControllerOperation {
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
        let animations = {
            fromView.transform = CGAffineTransform(translationX: self.screenSize.width, y: 0)
        }
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: animations) {
            guard $0 else { return }
            let cancelled = transitionContext.transitionWasCancelled
            if cancelled {
                toVC.view.removeFromSuperview()
            } else {
                fromView.removeFromSuperview()
                videoPlayerView.frame = cell.bounds
                cell.insertVideoPlayerView(videoPlayerView)
            }
            videoPlayerView.isHidden = false
            transitionContext.completeTransition(!cancelled)
        }
    }
}
