//
//  PEPPlayerToolBar.h
//  Player
//
//  Created by 李沛倬 on 2017/6/5.
//  Copyright © 2017年 pep. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PEPPlayerViewControllerNaviBar, PEPPlayerViewControllerBottomBar;

#pragma mark - PEPPlayerToolBar

@interface PEPPlayerToolBar : UIView

@property (nonatomic, strong, readonly) PEPPlayerViewControllerNaviBar *naviBar;

@property (nonatomic, strong, readonly) PEPPlayerViewControllerBottomBar *bottomBar;


@end



#pragma mark - PEPPlayerViewControllerNaviBar

typedef void(^NaviItemDidClick)(PEPPlayerViewControllerNaviBar *naviBar);

@interface PEPPlayerViewControllerNaviBar : UIView

@property (nonatomic, strong, readonly) UIButton *leftItem;

@property (nonatomic, strong, readonly) UIButton *rightItem;

@property (nonatomic, strong, readonly) UILabel *titleLabel;

@property (nonatomic, copy) NaviItemDidClick leftItemDidClick;

@property (nonatomic, copy) NaviItemDidClick rightItemDidClick;


/**
 构造方法

 @param isContain 是否包含状态栏：默认为NO；如果设置为YES，内部视图布局将自动偏移出状态栏范围（20.0）
 @return return value description
 */
- (instancetype)initWithContainStatuBar:(BOOL)isContain;

@end


#pragma mark - PEPPlayerViewControllerBottomBar

typedef void(^BottomBarPlayButtonClick)(PEPPlayerViewControllerBottomBar *bottomBar);
typedef void(^BottomBarSlideDragging)(CGFloat currentProgress);

@interface PEPPlayerViewControllerBottomBar : UIView

/**
 playButton.selected == NO  时，播放器应处于未播放状态，playButton显示播放按钮；
 playButton.selected == YES 时，播放器应处于播放状态，playButton显示暂停按钮；
 playButton.selected 默认为NO。
 */
@property (nonatomic, strong, readonly) UIButton *playButton;

@property (nonatomic, strong, readonly) UILabel *timeLabel;

@property (nonatomic, strong, readonly) UISlider *slider;

@property (nonatomic, strong, readonly) UIActivityIndicatorView *activityIndicatorView;

@property (nonatomic, copy) BottomBarPlayButtonClick playButtonClick;

/** slider进度条开始拖动时将回调该block */
@property (nonatomic, copy) BottomBarSlideDragging slideDidBeginDragging;

/** slider进度条停止拖动时将会回调该block */
@property (nonatomic, copy) BottomBarSlideDragging slideDidEndDragging;
/** 缓冲进度：0.0 ~ slider.maximumValue */
@property (nonatomic, assign) CGFloat bufferProgress;


@end



























