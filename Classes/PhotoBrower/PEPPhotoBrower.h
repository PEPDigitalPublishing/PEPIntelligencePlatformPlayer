//
//  PEPPhotoBrower.h
//  DrawerArch
//
//  Created by 李沛倬 on 2017/5/25.
//  Copyright © 2017年 pep. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PEPPhotoBrower, PEPPhotoBrowerItem;

typedef void(^PEPPhotoBrowerClose)(PEPPhotoBrowerItem *item);

#pragma mark - Protocol
@protocol PEPPhotoBrowerDataSource <NSObject>
@required

- (NSInteger)numberOfItemsInPhotoBrower:(PEPPhotoBrower *)photoBrower;

- (PEPPhotoBrowerItem *)photoBrower:(PEPPhotoBrower *)photoBrower itemForIndex:(NSInteger)index;

@end


#pragma mark - PEPPhotoBrower
@interface PEPPhotoBrower : UIView

@property (nonatomic, strong) NSArray<NSString *> *dataAry;

@property (nonatomic, weak) id<PEPPhotoBrowerDataSource> dataSource;

@property (nonatomic, strong) UIScrollView *contentView;

/**
 遮罩视图透明度：0.0 ~ 1.0; 默认0.6
 */
@property (nonatomic, assign) CGFloat coverAlpha;


- (PEPPhotoBrowerItem *)itemForIndex:(NSUInteger)index;

- (NSUInteger)indexForItem:(PEPPhotoBrowerItem *)item;

@end




#pragma mark - PEPPhotoBrowerItem

@interface PEPPhotoBrowerItem : UIScrollView<UIScrollViewDelegate>

@property (nonatomic, strong, readonly) UIImageView *imageView;

@property (nonatomic, copy) PEPPhotoBrowerClose closeBlock;

@end















