//
//  UICollectionViewCell.swift
//  RxAVPlayerSampler
//
//  Created by hryk224 on 2016/12/16.
//  Copyright © 2016年 hryk224. All rights reserved.
//

import UIKit.UICollectionView

extension UICollectionView {
    //register.
    func register<T: CellNibable>(cell: T.Type) {
        register(cell.nib, forCellWithReuseIdentifier: cell.identifier)
    }
    func register<T: ReusableViewNibable>(headerView: T.Type) {
        register(headerView.nib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerView.identifier)
    }
    func register<T: ReusableViewNibable>(footerView: T.Type) {
        register(footerView.nib, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: footerView.identifier)
    }
    
    //dequeue.
    func dequeueReusableCell<T: CellNibable>(type: T.Type, for indexPath: IndexPath) -> T {
        return dequeueReusableCell(withReuseIdentifier: type.identifier, for: indexPath) as! T
    }
    func dequeueReusableHeaderView<T: ReusableViewNibable>(type: T.Type, for indexPath: IndexPath) -> T {
        return dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: type.identifier, for: indexPath) as! T
    }
    func dequeueReusableFooterView<T: ReusableViewNibable>(type: T.Type, for indexPath: IndexPath) -> T {
        return dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: type.identifier, for: indexPath) as! T
    }
}
