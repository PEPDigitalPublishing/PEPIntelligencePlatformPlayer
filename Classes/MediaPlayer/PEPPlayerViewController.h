//
//  PEPPlayerViewController.h
//  TestCoreText
//
//  Created by 李沛倬 on 2017/5/18.
//  Copyright © 2017年 PEP. All rights reserved.
//

#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

#import "PEPAVPlayer.h"
#import "PEPPlayerToolBar.h"

#pragma mark - PEPPlayerViewController

@interface PEPPlayerViewController : UIViewController

@property (nonatomic, strong, readonly) PEPAVPlayer *player;

@property (nonatomic, strong) NSURL *URL;

@property (nonatomic, strong) PEPPlayerViewControllerNaviBar *naviBar;

@property (nonatomic, strong) PEPPlayerViewControllerBottomBar *bottomBar;


/** 是否横屏显示：默认为NO */
@property (nonatomic, assign) BOOL isLandscape;


/**
 通过传入的URL得到文件名

 @param URL URL description
 @return 文件名，若无法获取到正确的文件名则返回空字符串
 */
- (NSString *)getFileNameWithURL:(NSURL *)URL;

@end


































