//
//  PEPPlayerViewController.m
//  TestCoreText
//
//  Created by 李沛倬 on 2017/5/18.
//  Copyright © 2017年 PEP. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import "PEPPlayerViewController.h"
#import "PEPPlayerRequestLoader.h"
#import "FormatTimeTool.h"
#import "PEPPlayer.h"


@interface PEPPlayerViewController ()<AVPlayerViewControllerDelegate>
{
    CGFloat _resetBrightness;   // 初始亮度值：销毁controller时恢复初始亮度
}

@property (nonatomic, strong) AVPlayerLayer *playerLayer;

@property (nonatomic, strong) UISlider *volumeSlider;

@property (nonatomic, strong) UILabel *skipTimeLabel;

/** 滑动起点 */
@property (nonatomic, assign) CGPoint swipeOrigin;
/** 滑动起点音量值 */
@property (nonatomic, assign) CGFloat sliderValue;
/** 记录调节亮度 */
@property (nonatomic, assign) CGFloat brightness;
/** 记录媒体流当前时间 */
@property (nonatomic, assign) CMTime currentTime;
/** 是否跳转 */
@property (nonatomic, assign) BOOL isSkip;

@property (nonatomic, weak) NSTimer *timer;

@end

@implementation PEPPlayerViewController


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    _resetBrightness = [UIScreen mainScreen].brightness;
    self.view.backgroundColor = [UIColor blackColor];
    
    [self addGesture];
    [self initPlayer];
    [self initVolumeSlider];
    [self initTimeLabel];
    
    [self initToolBar];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:true animated:true];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.player pause];
    [UIScreen mainScreen].brightness = _resetBrightness;
    [self.navigationController setNavigationBarHidden:false animated:true];
}


- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.playerLayer.frame = self.view.bounds;
}

- (BOOL)shouldAutorotate {
    
    return true;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if (self.parentViewController) {
        return self.parentViewController.supportedInterfaceOrientations;
    }
    
    return UIInterfaceOrientationMaskAll;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    
    return [UIApplication sharedApplication].statusBarOrientation;
}

- (void)dealloc {
    PZLog(@"%@ Dead!", self);
    
    @try {
        [self.player.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    } @catch (NSException *exception) {
        PZLog(@"%@", exception);
    } @finally {
//        [self.player pause];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        
//        _playerLayer = nil;
//        _player = nil;
    }
    
}


#pragma mark - UI
- (void)initToolBar {
    [self initNaviBar];
    [self initBottomBar];
    
    [self showOrHideToolBar:true];
}

- (void)initNaviBar {
    PEPPlayerViewControllerNaviBar *naviBar = [[PEPPlayerViewControllerNaviBar alloc] initWithContainStatuBar:true];
    naviBar.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
//    PZLog(@"%@", [UIImage imageNamed:@"cancel" inBundle:kAssetBundle compatibleWithTraitCollection:nil]);
    [naviBar.rightItem setImage:[UIImage imageNamed:@"cancel" inBundle:kFrameworkBundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [naviBar.rightItem setImage:[UIImage imageNamed:@"cancel_s" inBundle:kFrameworkBundle compatibleWithTraitCollection:nil] forState:UIControlStateHighlighted];

    [self.view addSubview:naviBar];
    self.naviBar = naviBar;
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenH = [UIScreen mainScreen].bounds.size.height;
    BOOL ratio =  screenH/screenW >= 2.16;
    CGFloat naviBarHeight = 44 + (ratio?44:20);
    [naviBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(naviBar.superview);
        make.height.equalTo(@(naviBarHeight));
    }];
    
    
    naviBar.titleLabel.text = [self getFileNameWithURL:self.URL];
    
    PZWeakSelf;
//    naviBar.leftItemDidClick = ^(PEPPlayerViewControllerNaviBar *naviBar) {
//        if (weakSelf.navigationController) {
//            [weakSelf.navigationController popViewControllerAnimated:true];
//        } else {
//            [weakSelf dismissViewControllerAnimated:true completion:nil];
//        }
//        
//        NSNumber *orientation = [NSNumber numberWithInteger:UIInterfaceOrientationPortrait];
//        [[UIDevice currentDevice] setValue:orientation forKey:@"orientation"];
//
//    };

    naviBar.rightItemDidClick = ^(PEPPlayerViewControllerNaviBar *naviBar) {
        if (weakSelf.navigationController) {
            [weakSelf.navigationController popViewControllerAnimated:true];
        } else {
            [weakSelf dismissViewControllerAnimated:true completion:nil];
        }
    };
    
}

- (void)initBottomBar {
    
    PEPPlayerViewControllerBottomBar *bottomBar = [[PEPPlayerViewControllerBottomBar alloc] init];
    bottomBar.backgroundColor = self.naviBar.backgroundColor;
    bottomBar.playButton.selected = self.player.rate;
    [bottomBar.playButton setImage:[UIImage imageNamed:@"play" inBundle:kFrameworkBundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [bottomBar.playButton setImage:[UIImage imageNamed:@"Pause" inBundle:kFrameworkBundle compatibleWithTraitCollection:nil] forState:UIControlStateSelected];

    [self.view addSubview:bottomBar];
    self.bottomBar = bottomBar;
    
    [bottomBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(bottomBar.superview);
        make.height.equalTo(@49);
        if (UIDevice.currentDevice.systemVersion.floatValue >= 11.0) {
            make.bottom.equalTo(bottomBar.superview.mas_safeAreaLayoutGuideBottom);
        } else {
            make.bottom.equalTo(bottomBar.superview);
        }
    }];
    
    
    PZWeakSelf;
    bottomBar.playButtonClick = ^(PEPPlayerViewControllerBottomBar *bottomBar) {
        if (bottomBar.playButton.selected) {
            [weakSelf.player play];
        } else {
            [weakSelf.player pause];
        }
    };

    bottomBar.slideDidBeginDragging = ^(CGFloat currentProgress) {
        [weakSelf.player pause];
        weakSelf.bottomBar.playButton.selected = false;
    };
    
    bottomBar.slideDidEndDragging = ^(CGFloat currentProgress) {
        CGFloat timeScale = weakSelf.player.currentTime.timescale;
        CMTime seekTime = CMTimeMake(currentProgress * timeScale, timeScale);
        [weakSelf.player seekToTime:seekTime completionHandler:^(BOOL finished) {
            [weakSelf.player play];
            weakSelf.bottomBar.playButton.selected = true;
        }];
    };
    
    
}

- (void)initPlayer {
//    PEPAVPlayer *player = [[PEPAVPlayer alloc] initWithURL:self.URL];
    PEPAVPlayer *player = [PEPAVPlayer defaultPlayer];
    player.URL = self.URL;
    
    AVPlayerItem *playerItem = player.currentItem;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
    [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    playerLayer.frame = self.view.bounds;
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.view.layer addSublayer:playerLayer];
    
    if (self.isLandscape) {
        UIInterfaceOrientation orientation = UIInterfaceOrientationLandscapeRight;
        if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft ||
            [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight) {
            orientation = [UIApplication sharedApplication].statusBarOrientation;
        }
        [[UIDevice currentDevice] setValue:@(orientation) forKey:@"orientation"];
    }
    
    _player = player;
    self.playerLayer = playerLayer;
    [self.player play];

    // 监听播放进度
    PZWeakSelf;
    [player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        
        NSString *formatedTimeStr = [FormatTimeTool getFormatedTimeStringWithCurrentTime:time duration:playerItem.duration];
        weakSelf.bottomBar.timeLabel.text = formatedTimeStr;
        [weakSelf.bottomBar.activityIndicatorView stopAnimating];
        
        if (playerItem.duration.value > 0) {
            weakSelf.bottomBar.slider.maximumValue = CMTimeGetSeconds(playerItem.duration);
            weakSelf.bottomBar.slider.value = CMTimeGetSeconds(time);
        }
    }];
    
}

- (void)initVolumeSlider {
    
    MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(-1000, -1000, 0, 0)];
    volumeView.showsVolumeSlider = true;
    volumeView.showsRouteButton = true;
    [volumeView sizeToFit];

    for (UIView *subView in volumeView.subviews) {
        if ([subView isKindOfClass:[UISlider class]]) {
            self.volumeSlider = (UISlider *)subView;
            break;
        }
    }
}

- (void)addGesture {
    // 双击手势
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapAction:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTap];
    
    // 单击手势
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapAction:)];
    [self.view addGestureRecognizer:singleTap];
    
    // 双击事件触发是取消单击事件
    [singleTap requireGestureRecognizerToFail:doubleTap];
}

- (void)initTimeLabel {
    UILabel *timeLabel = [[UILabel alloc] init];
    timeLabel.textAlignment = NSTextAlignmentCenter;
    timeLabel.layer.cornerRadius = 5;
    timeLabel.layer.masksToBounds = true;
    timeLabel.alpha = 0;
    timeLabel.backgroundColor = [UIColor blackColor];
    timeLabel.textColor = [UIColor whiteColor];
    
    [self.view addSubview:timeLabel];
    self.skipTimeLabel = timeLabel;
    
    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_greaterThanOrEqualTo(110);
        make.height.mas_equalTo(45);
        make.centerX.equalTo(timeLabel.superview);
        make.centerY.equalTo(timeLabel.superview).multipliedBy(9/16.0);
    }];
}

#pragma mark - Setter & Getter

- (CGRect)lightRect {
    return CGRectMake(0, 0, self.view.bounds.size.width/3.0, self.view.bounds.size.height);
}

- (CGRect)volumeRect {
    return CGRectMake(self.view.bounds.size.width/3*2.0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
}


#pragma mark - Actions
- (void)playDidEnd:(NSNotification *)noti {
    
//    PZLog(@"%@", noti.object);
    self.bottomBar.playButton.selected = false;
    
}


- (void)showOrHideToolBar:(BOOL)isShow {
    NSTimeInterval duration = 0.3;
    
    if (isShow) {
        self.naviBar.hidden = false;
        self.bottomBar.hidden = false;
        
        [UIView animateWithDuration:duration animations:^{
            self.naviBar.transform = CGAffineTransformIdentity;
            self.bottomBar.transform = CGAffineTransformIdentity;
            
        } completion:^(BOOL finished) {
            if (self.timer) { [self.timer invalidate]; }
            PZWeakSelf;
            self.timer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:weakSelf selector:@selector(hideToolBar) userInfo:nil repeats:false];
        }];
        
    } else {
        [UIView animateWithDuration:duration animations:^{
            self.naviBar.transform = CGAffineTransformMakeTranslation(0, -self.naviBar.bounds.size.height);
            self.bottomBar.transform = CGAffineTransformMakeTranslation(0, self.bottomBar.bounds.size.height);
            
        } completion:^(BOOL finished) {
            self.naviBar.hidden = true;
            self.bottomBar.hidden = true;
        }];
    }
    
}

- (void)hideToolBar {
    [self showOrHideToolBar:false];
}

- (void)singleTapAction:(UITapGestureRecognizer *)tap {
    
    [self showOrHideToolBar:self.naviBar.hidden];
}

- (void)doubleTapAction:(UITapGestureRecognizer *)tap {
    
    self.player.rate == 0 ? [self.player play] : [self.player pause];
    self.bottomBar.playButton.selected = self.player.rate;
}

- (void)showTimeLabel:(BOOL)isShow {
    [UIView animateWithDuration:0.2 animations:^{
        self.skipTimeLabel.alpha = isShow ? 0.6 : 0;
    }];
}

- (void)setTimeLabelWithCurrentTime:(CMTime)currentTime duration:(CMTime)duration {
    
    self.skipTimeLabel.text = [FormatTimeTool getFormatedTimeStringWithCurrentTime:currentTime duration:duration];

}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        AVPlayerItem *playerItem = object;
        NSArray *array = playerItem.loadedTimeRanges;
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];//本次缓冲时间范围
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval totalBuffer = startSeconds + durationSeconds;//缓冲总长度
        self.bottomBar.bufferProgress = totalBuffer;
    }
}


#pragma mark - Private Methods 

- (NSString *)getFileNameWithURL:(NSURL *)URL {
    
    NSString *mediaName = @"";
    NSArray<NSString *> *fileNameComponents = [URL.lastPathComponent componentsSeparatedByString:@"."];
    if (fileNameComponents.count > 0) {
        mediaName = fileNameComponents.firstObject;
    }
    
    return mediaName;
}


#pragma mark - Touches Action

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    if (touches.count > 1) { return; }
    
    CGPoint touchPoint = [touches.anyObject locationInView:self.view];
    
    self.swipeOrigin = touchPoint;
    self.sliderValue = self.volumeSlider.value;
    self.brightness = [UIScreen mainScreen].brightness;;
    self.currentTime = self.player.currentTime;
    
    [self.view bringSubviewToFront:self.skipTimeLabel];
    
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    if (touches.count > 1) { return; }
    
    CGPoint touchPoint = [touches.anyObject locationInView:self.view];
    
    CGFloat value_x = self.swipeOrigin.x - touchPoint.x;
    CGFloat value_y = self.swipeOrigin.y - touchPoint.y;
    
    if (fabs(value_x) > fabs(value_y) && fabs(value_x) >= self.view.bounds.size.width/10) {                                    // 左右滑动 - 调整进度
        if (!self.player) { return; }
        CGFloat second = -value_x * 180 / self.view.bounds.size.width;
        
        CMTime time = CMTimeMake(self.currentTime.value + (NSInteger)second/2 * self.currentTime.timescale, self.currentTime.timescale);
        
        [self setTimeLabelWithCurrentTime:time duration:self.player.currentItem.duration];
        [self showTimeLabel:true];
        
        self.isSkip = true;
    } else if (fabs(value_y) > fabs(value_x) && fabs(value_y) >= self.view.bounds.size.height/10) {                                                                // 上下滑动
        value_y /= self.view.bounds.size.height;
        
        if (CGRectContainsPoint(self.lightRect, touchPoint)) {              // 调节亮度
            CGFloat light = value_y + self.brightness;
            light = MIN(1, MAX(0, light));
            PZLog(@"亮度：%.2f%%", light * 100.0);
            [[UIScreen mainScreen] setBrightness:light];
            
        } else if (CGRectContainsPoint(self.volumeRect, touchPoint)) {      // 调节音量
            
            CGFloat volume = value_y + self.sliderValue;
            volume = MIN(1, MAX(0, volume));
            PZLog(@"音量：%.2f%%", volume * 100.0);
            self.volumeSlider.value = volume;
        }
    
        self.isSkip = false;
    }
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    if (touches.count > 1) { return; }
    
    CGPoint touchPoint = [touches.anyObject locationInView:self.view];
    
    self.sliderValue = self.volumeSlider.value;
    
    if (self.isSkip) {
        CGFloat second = (touchPoint.x - self.swipeOrigin.x) * 180 / self.view.bounds.size.width;
        CMTime time = CMTimeMake(self.currentTime.value + second/2 * self.currentTime.timescale, self.currentTime.timescale);
        
        [self.player seekToTime:time];
        self.isSkip = false;
    }
    
    self.currentTime = self.player.currentTime;
    [self performSelector:@selector(showTimeLabel:) withObject:false afterDelay:1];
}



@end





