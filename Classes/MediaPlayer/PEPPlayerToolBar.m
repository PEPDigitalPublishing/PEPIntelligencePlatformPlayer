//
//  PEPPlayerToolBar.m
//  Player
//
//  Created by 李沛倬 on 2017/6/5.
//  Copyright © 2017年 pep. All rights reserved.
//

#import "PEPPlayerToolBar.h"
#import "PEPPlayer.h"


static CGFloat const PADDING = 10.0;

#pragma mark - PEPPlayerToolBar

@implementation PEPPlayerToolBar

- (instancetype)init {
    if (self = [super init]) {
        [self initSubviews];
    }
    
    return self;
}


- (void)initSubviews {
    
    PEPPlayerViewControllerNaviBar *naviBar = [[PEPPlayerViewControllerNaviBar alloc] init];
    
    PEPPlayerViewControllerBottomBar *bottomBar = [[PEPPlayerViewControllerBottomBar alloc] init];
    
    [self addSubview:naviBar];
    [self addSubview:bottomBar];
    
    _naviBar = naviBar;
    _bottomBar = bottomBar;
    
    
    [naviBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(naviBar.superview);
        make.height.equalTo(naviBar.superview).multipliedBy(0.45);
    }];
    
    [bottomBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.left.equalTo(bottomBar.superview);
        make.top.equalTo(naviBar.mas_bottom);
    }];
    
}

@end



#pragma mark - PEPPlayerViewControllerNaviBar

@interface PEPPlayerViewControllerNaviBar ()

@property (nonatomic, assign) BOOL containStatuBar;

@end

@implementation PEPPlayerViewControllerNaviBar

- (instancetype)init {
    if (self = [super init]) {
        [self initSubviews];
    }
    
    return self;
}

- (instancetype)initWithContainStatuBar:(BOOL)isContain {
    if (self = [super init]) {
        self.containStatuBar = isContain;
        [self initSubviews];
    }
    
    return self;
}


- (void)initSubviews {
    
    // Back Item
    UIButton *leftItem = [[UIButton alloc] init];
    [leftItem addTarget:self action:@selector(leftItemAction:) forControlEvents:UIControlEventTouchUpInside];
    
    // Right Item
    UIButton *rightItem = [[UIButton alloc] init];
    [rightItem addTarget:self action:@selector(rightItemAction:) forControlEvents:UIControlEventTouchUpInside];
    
    // Title Label
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.adjustsFontSizeToFitWidth = true;
    titleLabel.minimumScaleFactor = 0.5;
    
    // Add Subviews
    [self addSubview:leftItem];
    [self addSubview:rightItem];
    [self addSubview:titleLabel];
    
    _leftItem = leftItem;
    _rightItem = rightItem;
    _titleLabel = titleLabel;
    
    
    // Masonry
    CGFloat statuBarOffset = self.containStatuBar ? 20.0 : 0;
    
    [leftItem mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(leftItem.superview).offset(PADDING);
        make.top.equalTo(leftItem.superview).offset(statuBarOffset);
        make.height.equalTo(leftItem.superview).offset(-statuBarOffset);
        make.width.equalTo(leftItem.mas_height);
    }];
    
    [rightItem mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(rightItem.superview).offset(statuBarOffset);
        make.right.equalTo(rightItem.superview).offset(-PADDING);
        make.width.height.equalTo(leftItem);
    }];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(leftItem);
        make.left.equalTo(leftItem.mas_right);
        make.right.equalTo(rightItem.mas_left);
    }];
    
    
    // Test
//    [leftItem setTitle:@"Back" forState:UIControlStateNormal];
//    [rightItem setBackgroundColor:[UIColor flatSkyBlueColor]];
    
}

- (void)leftItemAction:(UIButton *)sender {
    if (self.leftItemDidClick) {
        self.leftItemDidClick(self);
    }
}


- (void)rightItemAction:(UIButton *)sender {
    if (self.rightItemDidClick) {
        self.rightItemDidClick(self);
    }
}


@end




#pragma mark - PEPPlayerViewControllerBottomBar

@interface PEPPlayerViewControllerBottomBar ()

@property (nonatomic, strong) UIView *progressView;

@end

@implementation PEPPlayerViewControllerBottomBar

- (instancetype)init {
    if (self = [super init]) {
        [self initSubviews];
    }
    
    return self;
}

- (void)dealloc {
    [self.slider removeObserver:self forKeyPath:@"tracking"];
}


- (void)initSubviews {
    
    // Play Button
    UIButton *playButton = [[UIButton alloc] init];
    [playButton addTarget:self action:@selector(playButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    playButton.titleLabel.font = [UIFont systemFontOfSize:16];
    playButton.titleLabel.adjustsFontSizeToFitWidth = true;
    playButton.titleLabel.minimumScaleFactor = 0.5;
    
    // Time Label
    UILabel *timeLabel = [[UILabel alloc] init];
    timeLabel.textAlignment = NSTextAlignmentCenter;
    timeLabel.textColor = [UIColor whiteColor];
    timeLabel.adjustsFontSizeToFitWidth = true;
    timeLabel.minimumScaleFactor = 0.8;
    if (@available(iOS 8.2, *)) {
        timeLabel.font = [UIFont systemFontOfSize:13.0 weight:UIFontWeightLight];
    } else {
        timeLabel.font = [UIFont systemFontOfSize:13.0];
    }
    
    // Progress View
    UISlider *slider = [[UISlider alloc] init];
    UIColor *thumbColor = [UIColor colorWithRed:1/255.0 green:183/255.0 blue:124/255.0 alpha:1];
    [slider setThumbTintColor:thumbColor];
    UIImage *minimumImage = [UIImage rj_imageWithColor:thumbColor size:CGSizeMake(20, 5)];
    [slider setMinimumTrackImage:minimumImage forState:UIControlStateNormal];
    UIImage *maximunImage = [UIImage rj_imageWithColor:[UIColor whiteColor] size:CGSizeMake(20, 5)];
    [slider setMaximumTrackImage:maximunImage forState:UIControlStateNormal];
    [slider addObserver:self forKeyPath:@"tracking" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
//    UIView *progressView = [[UIView alloc] init];
//    progressView.backgroundColor = [UIColor colorWithRed:167/255.0 green:168/255.0 blue:169/255.0 alpha:1];
//    progressView.tag = 111;
//    progressView.layer.cornerRadius = 2.5;
//    progressView.layer.masksToBounds = true;
    
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityIndicatorView.hidesWhenStopped = true;
    [activityIndicatorView startAnimating];
    
    // Add Subviews
    [self addSubview:playButton];
    [self addSubview:timeLabel];
    [self addSubview:slider];
    [self addSubview:activityIndicatorView];
    
    _playButton = playButton;
    _timeLabel = timeLabel;
    _slider = slider;
    _activityIndicatorView = activityIndicatorView;
//    self.progressView = progressView;
    
    // Masonry
    [playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(playButton.superview);
        make.left.equalTo(playButton.superview).offset(PADDING);
        make.width.equalTo(playButton.mas_height);
    }];
    
    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(timeLabel.superview);
        make.left.equalTo(playButton.mas_right).offset(PADDING);
        make.right.equalTo(slider.mas_left).offset(-PADDING);
//        make.width.lessThanOrEqualTo(timeLabel.superview).multipliedBy(0.2);
    }];
    
    [slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(slider.superview);
        make.left.equalTo(timeLabel.mas_right).offset(PADDING);
        make.right.equalTo(slider.superview).offset(-PADDING);
        make.width.greaterThanOrEqualTo(slider.superview).multipliedBy(0.5);
    }];
    
    [activityIndicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(timeLabel);
    }];
    
    
    // Test Color & Placeholder
//    playButton.backgroundColor = [UIColor flatOrangeColor];
//    timeLabel.backgroundColor = [UIColor flatGrayColor];
    
//    [playButton setTitle:@"Play" forState:UIControlStateNormal];
//    [playButton setTitle:@"Pause" forState:UIControlStateSelected];
//    timeLabel.text = @"00:00/00:00";
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.progressView.frame = CGRectMake(0, (self.slider.bounds.size.height-5)/2, 0, 5);
}


- (void)playButtonAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    
    if (self.playButtonClick) {
        self.playButtonClick(self);
    }
    
}


- (void)setBufferProgress:(CGFloat)bufferProgress {
    if (bufferProgress > self.slider.maximumValue || bufferProgress < 0) { return; }
    _bufferProgress = bufferProgress;
    
//    self.progressLayer.frame = CGRectMake(0, (self.slider.size.height-5)/2, self.slider.size.width * bufferProgress / self.slider.maximumValue, 5);
    
    if (![self.slider viewWithTag:111]) {
        [self.slider insertSubview:self.progressView atIndex:1];
        UIView *progressView = self.progressView;
        [progressView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(progressView.superview);
            make.height.equalTo(@5);
            make.centerY.equalTo(progressView.superview).offset(1);
            make.width.equalTo(@0);
        }];
    }
    
    CGFloat width =  bufferProgress / self.slider.maximumValue * self.slider.bounds.size.width;
    [self.progressView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(width));
    }];
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    
    if ([keyPath isEqualToString:@"tracking"]) {
        BOOL oldTracking = [change[@"old"] boolValue];
        BOOL newTracking = [change[@"new"] boolValue];
        
        if (oldTracking == true && newTracking == false) {          // 拖拽已停止
            if (self.slideDidEndDragging) {
                self.slideDidEndDragging(self.slider.value);
            }
        } else if (oldTracking == false && newTracking == true) {   // 开始拖拽
            if (self.slideDidBeginDragging) {
                self.slideDidBeginDragging(self.slider.value);
            }
            
        }
    }
    
}


@end
