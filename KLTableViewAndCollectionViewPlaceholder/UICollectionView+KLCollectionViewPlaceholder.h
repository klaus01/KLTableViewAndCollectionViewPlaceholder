//
//  UICollectionView+KLCollectionViewPlaceholder.h
//  KLTableViewAndCollectionViewPlaceholder
//
//  Created by 柯磊 on 2017/2/24.
//  Copyright © 2017年 https://github.com/klaus01 All rights reserved.
//

#import <UIKit/UIKit.h>

typedef UIView * _Nullable (^KLCollectionViewPlaceholderViewBlock)(UICollectionView * _Nonnull collectionView);
typedef void (^KLCollectionViewBackToNormalBlock)(UICollectionView * _Nonnull collectionView);

@interface UICollectionView (KLCollectionViewPlaceholder)

/**
 Call the placeholderViewBlock when the data is empty.
 
 placeholderViewBlock = nil is disabled, otherwise the null data display placeholder function is enabled.

 @param placeholderViewBlock Called when a placeholder needs to be displayed, returns a view.
 */
- (void)kl_placeholderViewBlock:(KLCollectionViewPlaceholderViewBlock _Nullable)placeholderViewBlock;

/**
 Called placeholderViewBlock when the data is empty, and backToNormalBlock when the data is not empty.
 
 placeholderViewBlock = nil is disabled, otherwise the null data display placeholder function is enabled.

 @param placeholderViewBlock Called when a placeholder needs to be displayed, returns a view.
 @param backToNormalBlock Called when there is data
 */
- (void)kl_placeholderViewBlock:(KLCollectionViewPlaceholderViewBlock _Nullable)placeholderViewBlock
              backToNormalBlock:(KLCollectionViewBackToNormalBlock _Nullable)backToNormalBlock;

@end
