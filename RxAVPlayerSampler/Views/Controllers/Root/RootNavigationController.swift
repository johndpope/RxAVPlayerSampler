//
//  ViewController.swift
//  RxAVPlayerSampler
//
//  Created by hryk224 on 2016/12/15.
//  Copyright © 2016年 hryk224. All rights reserved.
//


import UIKit.UIViewController
import RxSwift

final class RootNavigationController: UINavigationController, Storyboardable {
    fileprivate var interactiveTransition: UIPercentDrivenInteractiveTransition?
    fileprivate lazy var edgePanGestureRecognizer = UIScreenEdgePanGestureRecognizer()
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        delegate = self
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.addGestureRecognizer(edgePanGestureRecognizer)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        view.removeGestureRecognizer(edgePanGestureRecognizer)
    }
    private func configureUI() {
        view.backgroundColor = .white
        let videoVC = VideoListViewController.makeFromStoryboard()
        self.setViewControllers([videoVC], animated: false)
        
        edgePanGestureRecognizer.addTarget(self,
                                           action: #selector(RootNavigationController.handleGesture(_:)))
        edgePanGestureRecognizer.edges = .left
    }
}

// MARK: - UIGestureRecognizerDelegate
extension RootNavigationController: UIGestureRecognizerDelegate {
    fileprivate dynamic func handleGesture(_ gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        guard let gestureView = gestureRecognizer.view else { return }
        switch gestureRecognizer.state {
        case .began:
            interactiveTransition = UIPercentDrivenInteractiveTransition()
            interactiveTransition?.completionCurve = .easeOut
            popViewController(animated: true)
        case .changed:
            var percent: CGFloat = 0
            percent = gestureRecognizer.translation(in: gestureView).x / gestureView.bounds.width
            percent = min(1, max(0, fabs(percent)))
            interactiveTransition?.update(percent)
        case .ended, .cancelled:
            let velocity = gestureRecognizer.velocity(in: view).x
            if fabs(velocity) > 0 {
                interactiveTransition?.finish()
            } else {
                interactiveTransition?.cancel()
            }
            interactiveTransition = nil
        default:
            break
        }
    }
}

// MARK: - UINavigationControllerDelegate
extension RootNavigationController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactiveTransition
    }
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .pop where interactiveTransition != nil:
            return EdgeAnimatedTransition(operation: operation)
        default:
            return AnimatedTransition(operation: operation)
        }
    }
}
