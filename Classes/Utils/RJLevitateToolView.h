//
//  RJLevitateToolView.h
//  DrawerArch
//
//  Created by 李沛倬 on 2017/5/8.
//  Copyright © 2017年 pep. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, RJLevitateToolViewShowType) {
    RJLevitateToolViewZoom      = 0,            // 缩放
    RJLevitateToolViewRotation  = 1,            // 旋转
};

@class RJLevitateToolView;

#pragma mark - RJLevitateToolItemModel
@interface RJLevitateToolItemModel : NSObject

/// 标题
@property (nonatomic, copy) NSString *title;
/// 图标
@property (nonatomic, strong) UIImage *icon;
/// 如果点击该item存在下一级工具栏，则需传入此数组，否则传nil
@property (nonatomic, strong) NSArray<RJLevitateToolItemModel *> *subItems;

- (instancetype)initWithTitle:(NSString *)title icon:(UIImage *)icon subItems:(NSArray<RJLevitateToolItemModel *> *)subItems;

@end


#pragma mark - RJIndexPath
@interface RJIndexPath : NSObject<NSCoding>

@property (nonatomic, assign, readonly) NSInteger firstLevel;
@property (nonatomic, assign, readonly) NSInteger secondLevel;

- (instancetype)initWithFirstLevel:(NSInteger)firstLevel SecondLevel:(NSInteger)secondLevel;

+ (instancetype)indexPathWithFirstLevel:(NSInteger)firstLevel SecondLevel:(NSInteger)secondLevel;

@end



#pragma mark - RJLevitateToolViewDataSource
@protocol RJLevitateToolViewDataSource <NSObject>

@required

- (NSInteger)numberOfFirstLevelInlevitateToolView:(RJLevitateToolView *)levitateToolView;

- (RJLevitateToolItemModel *)levitateToolView:(RJLevitateToolView *)levitateToolView itemForRowAtIndexPath:(RJIndexPath *)indexPath;

@optional
//- (NSInteger)levitateToolView:(RJLevitateToolView *)levitateToolView numberOfFirstLevel:(NSInteger)firstLevel;


@end




#pragma mark - RJLevitateToolViewDelegate
@protocol RJLevitateToolViewDelegate <NSObject, UITableViewDelegate>

@optional

- (void)levitateToolView:(RJLevitateToolView *)levitateToolView didSelectItem:(UIButton *)itemButton atIndexPath:(RJIndexPath *)indexPath;

@end




#pragma mark - RJLevitateToolView
@interface RJLevitateToolView : UIView

@property (nonatomic, weak) id<RJLevitateToolViewDataSource>    dataSource;
@property (nonatomic, weak) id<RJLevitateToolViewDelegate>      delegate;

@property (nonatomic, assign) RJLevitateToolViewShowType showType;


- (void)reloadData;

@end















