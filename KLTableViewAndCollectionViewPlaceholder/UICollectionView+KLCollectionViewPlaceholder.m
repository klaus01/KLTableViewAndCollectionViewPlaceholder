//
//  UICollectionView+KLCollectionViewPlaceholder.m
//  KLTableViewAndCollectionViewPlaceholder
//
//  Created by 柯磊 on 2017/2/24.
//  Copyright © 2017年 https://github.com/klaus01 All rights reserved.
//

#import "UICollectionView+KLCollectionViewPlaceholder.h"
#import "KLUtility.h"
#import <objc/runtime.h>

@implementation UICollectionView (KLCollectionViewPlaceholder)

#pragma mark - public methods

- (void)kl_placeholderViewBlock:(KLCollectionViewPlaceholderViewBlock _Nullable)placeholderViewBlock {
    [self kl_placeholderViewBlock:placeholderViewBlock backToNormalBlock:nil];
}

- (void)kl_placeholderViewBlock:(KLCollectionViewPlaceholderViewBlock _Nullable)placeholderViewBlock
              backToNormalBlock:(KLCollectionViewBackToNormalBlock _Nullable)backToNormalBlock {
    self.kl_placeholderViewBlock = placeholderViewBlock;
    self.kl_backToNormalBlock = backToNormalBlock;
}

#pragma mark - property methods

- (KLCollectionViewPlaceholderViewBlock)kl_placeholderViewBlock {
    return objc_getAssociatedObject(self, @selector(kl_placeholderViewBlock));
}

- (void)setKl_placeholderViewBlock:(KLCollectionViewPlaceholderViewBlock)kl_placeholderViewBlock {
    objc_setAssociatedObject(self, @selector(kl_placeholderViewBlock), kl_placeholderViewBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    if (kl_placeholderViewBlock) {
        if (!self.kl_hasHooked) {
            [self kl_hookChangeDataMethods];
        }
    } else {
        if (self.kl_hasHooked) {
            [self kl_restoreChangeDataMethods];
        }
        [self.kl_placeholderView removeFromSuperview];
        self.kl_placeholderView = nil;
        self.kl_isBatchUpdates = NO;
    }
}

- (KLCollectionViewBackToNormalBlock)kl_backToNormalBlock {
    return objc_getAssociatedObject(self, @selector(kl_backToNormalBlock));
}

- (void)setKl_backToNormalBlock:(KLCollectionViewBackToNormalBlock)kl_backToNormalBlock {
    objc_setAssociatedObject(self, @selector(kl_backToNormalBlock), kl_backToNormalBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (UIView *)kl_placeholderView {
    return objc_getAssociatedObject(self, @selector(kl_placeholderView));
}

- (void)setKl_placeholderView:(UIView *)kl_placeholderView {
    objc_setAssociatedObject(self, @selector(kl_placeholderView), kl_placeholderView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)kl_isBatchUpdates {
    NSNumber *number = objc_getAssociatedObject(self, @selector(kl_isBatchUpdates));
    return number ? number.boolValue : NO;
}

- (void)setKl_isBatchUpdates:(BOOL)kl_isBatchUpdates {
    objc_setAssociatedObject(self, @selector(kl_isBatchUpdates), @(kl_isBatchUpdates), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - private methods

- (BOOL)kl_hasHooked {
    return [NSStringFromClass([self class]) hasPrefix:kNewClassPrefix];
}

- (void)kl_hookChangeDataMethods {
    Class baseClass = [self class];
    
    const char *newClassName = [kNewClassPrefix stringByAppendingString:NSStringFromClass(baseClass)].UTF8String;
    Class newClass = objc_getClass(newClassName);
    if (newClass == nil) {
        newClass = objc_allocateClassPair(baseClass, newClassName, 0);
        objc_registerClassPair(newClass);
        
        swizzleMethod(newClass, @selector(reloadData), @selector(kl_reloadData));
        swizzleMethod(newClass, @selector(insertSections:), @selector(kl_insertSections:));
        swizzleMethod(newClass, @selector(deleteSections:), @selector(kl_deleteSections:));
        swizzleMethod(newClass, @selector(reloadSections:), @selector(kl_reloadSections:));
        swizzleMethod(newClass, @selector(insertItemsAtIndexPaths:), @selector(kl_insertItemsAtIndexPaths:));
        swizzleMethod(newClass, @selector(deleteItemsAtIndexPaths:), @selector(kl_deleteItemsAtIndexPaths:));
    }
    object_setClass(self, newClass);
}

- (void)kl_restoreChangeDataMethods {
    object_setClass(self, [[self class] superclass]);
}

- (void)kl_checkEmpty {
    if (self.kl_isBatchUpdates) {
        return;
    }
    
    BOOL isEmpty = YES;
    
    id<UICollectionViewDataSource> dataSource = self.dataSource;
    NSInteger sections = 1;
    if ([dataSource respondsToSelector:@selector(numberOfSectionsInCollectionView:)]) {
        sections = [dataSource numberOfSectionsInCollectionView:self];
    }
    
    for (NSInteger i = 0; i < sections; i++) {
        NSInteger rows = [dataSource collectionView:self numberOfItemsInSection:i];
        if (rows) {
            isEmpty = NO;
            break;
        }
    }
    
    if (isEmpty) {
        UIView *placeholderView = self.kl_placeholderViewBlock ? self.kl_placeholderViewBlock(self) : nil;
        if (!placeholderView) {
            @throw [NSException exceptionWithName:NSGenericException
                                           reason:@"You must return the placeholder view in kl_placeholderViewBlock."
                                         userInfo:nil];
        }
        if (self.kl_placeholderView != placeholderView) {
            [self.kl_placeholderView removeFromSuperview];
            self.kl_placeholderView = placeholderView;
            
            placeholderView.translatesAutoresizingMaskIntoConstraints = NO;
            [self addSubview:placeholderView];
            NSDictionary *views = @{@"view": placeholderView, @"superview": self};
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view(==superview)]|" options:0 metrics:nil views:views]];
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view(==superview)]|" options:0 metrics:nil views:views]];
        }
    } else {
        if (self.kl_placeholderView) {
            [self.kl_placeholderView removeFromSuperview];
            self.kl_placeholderView = nil;
            self.kl_backToNormalBlock ? self.kl_backToNormalBlock(self) : nil;
        }
    }
}

#pragma mark - hook methods

- (void)kl_reloadData {
    [self kl_reloadData];
    [self kl_checkEmpty];
}

- (void)kl_insertSections:(NSIndexSet *)sections {
    [self kl_insertSections:sections];
    [self kl_checkEmpty];
}

- (void)kl_deleteSections:(NSIndexSet *)sections {
    [self kl_deleteSections:sections];
    [self kl_checkEmpty];
}

- (void)kl_reloadSections:(NSIndexSet *)sections {
    [self kl_reloadSections:sections];
    [self kl_checkEmpty];
}

- (void)kl_insertItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    [self kl_insertItemsAtIndexPaths:indexPaths];
    [self kl_checkEmpty];
}

- (void)kl_deleteItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    [self kl_deleteItemsAtIndexPaths:indexPaths];
    [self kl_checkEmpty];
}

- (void)kl_performBatchUpdates:(void (^)(void))updates completion:(void (^)(BOOL))completion {
    self.kl_isBatchUpdates = YES;
    __weak typeof(self) weakself = self;
    [self kl_performBatchUpdates:updates completion:^(BOOL finished) {
        if (completion) {
            completion(finished);
        }
        if (weakself) {
            weakself.kl_isBatchUpdates = NO;
            [weakself kl_checkEmpty];
        }
    }];
}

@end
