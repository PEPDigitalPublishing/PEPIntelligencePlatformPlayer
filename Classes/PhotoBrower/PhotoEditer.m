//
//  PhotoEditer.m
//  Player
//
//  Created by 李沛倬 on 2017/6/7.
//  Copyright © 2017年 pep. All rights reserved.
//

#import "PhotoEditer.h"
#import "PEPPlayer.h"


@interface PhotoEditer ()
{
    CGPoint _originPoint;
    
    BOOL _allowFollow;
    
    CGRect _cutViewFrame;
    
}

@property (nonatomic, strong) UIView *coverView;

@property (nonatomic, strong) UIImageView *cutView;

@property (nonatomic, strong) UILabel *infoLabel;

@property (nonatomic, strong) PhotoEditerToolBar *toolBar;

@end

@implementation PhotoEditer

#pragma mark - init
- (instancetype)initWithImage:(UIImage *)image {
    if (self = [super init]) {
        
        self.windowLevel = UIWindowLevelAlert;
        self.layer.shadowRadius = 5;
        self.layer.shadowOpacity = 1;
        self.layer.shadowColor = [UIColor grayColor].CGColor;
        
        [self initImageViewWithImage:image];
        [self initSubviews];
    }
    
    return self;
}


- (instancetype)initWithImagePath:(NSString *)imagePath {
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    if (self = [self initWithImage:image]) {
        
    }
    
    return self;
}

+ (instancetype)editWithImage:(UIImage *)image {
    return [[PhotoEditer alloc] initWithImage:image];
}

+ (instancetype)editWithImagePath:(NSString *)imagePath {
    return [[PhotoEditer alloc] initWithImagePath:imagePath];
}


#pragma mark - init Subviews

- (void)initImageViewWithImage:(UIImage *)image {
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.backgroundColor = [UIColor whiteColor];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [self addSubview:imageView];
    _imageView = imageView;
    self.image = image;
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(imageView.superview);
    }];
}

- (void)initSubviews {
    UIView *coverView = [[UIView alloc] init];
    coverView.backgroundColor = [UIColor blackColor];
    coverView.alpha = 0.6;
    coverView.hidden = true;
    
    UIImageView *cutView = [[UIImageView alloc] init];
    cutView.backgroundColor = [UIColor whiteColor];
    cutView.layer.borderColor = [UIColor cyanColor].CGColor;
    cutView.layer.borderWidth = 1.5;
    cutView.contentMode = UIViewContentModeScaleAspectFit;
    
    UILabel *infoLabel = [[UILabel alloc] init];
    infoLabel.layer.cornerRadius = 5;
    infoLabel.layer.masksToBounds = true;
    infoLabel.backgroundColor = [UIColor blackColor];
    infoLabel.alpha = 0.7;
    infoLabel.textAlignment = NSTextAlignmentCenter;
    infoLabel.textColor = [UIColor whiteColor];
    infoLabel.font = [UIFont systemFontOfSize:14.0];
    infoLabel.adjustsFontSizeToFitWidth = true;
    infoLabel.minimumScaleFactor = 0.5;
    infoLabel.hidden = true;
    
    PhotoEditerToolBar *toolBar = [[PhotoEditerToolBar alloc] init];
    toolBar.hidden = true;
    [toolBar.cancelButton addTarget:self action:@selector(toolBarAction:) forControlEvents:UIControlEventTouchUpInside];
    [toolBar.sureButton addTarget:self action:@selector(toolBarAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:coverView];
    [self addSubview:cutView];
    [self addSubview:infoLabel];
    [self addSubview:toolBar];
    self.coverView = coverView;
    self.cutView = cutView;
    self.infoLabel = infoLabel;
    self.toolBar = toolBar;
    
    [coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(coverView.superview);
    }];
    
    [cutView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(@0);
        make.size.mas_equalTo(CGSizeZero);
    }];
    
    [infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.cutView);
        make.bottom.equalTo(self.cutView.mas_top).offset(-10);
        make.height.equalTo(@30);
        make.width.greaterThanOrEqualTo(@60);
    }];
    
    [toolBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.greaterThanOrEqualTo(cutView).priorityHigh();
        make.right.equalTo(cutView).priorityLow();
        make.height.equalTo(@35);
        make.width.greaterThanOrEqualTo(@70);
        make.top.equalTo(cutView.mas_bottom).offset(10);
    }];
    
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    
}



#pragma mark - Setter & Getter
- (void)setImage:(UIImage *)image {
    if (_image != image) {
        _image = image;
        
        self.imageView.image = image;
        
        [self show];
    }
    
}


#pragma mark - Action

- (void)toolBarAction:(UIButton *)sender {
    
    if (self.toolBar.cancelButton == sender) {      // 取消
        if (self.cancelButtonDidClick) {
            self.cancelButtonDidClick(nil);
        }
        
    } else {                                        // 确定
        if (self.sureButtonDidClick) {
            self.sureButtonDidClick(self.cutView.image);
        }
        
//        PZLog(@"%@", self.cutView.image);
        
    }
    
    
    [self reset];
    
}


#pragma mark - Private Methods

- (void)setAllowFollow:(NSNumber *)allow {

    _allowFollow = [allow boolValue];
}


#pragma mark - Touch Action

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    _originPoint = [touches.anyObject locationInView:self];
    self.coverView.hidden = false;
    _cutViewFrame = self.cutView.frame;

}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    
    CGPoint movePoint = [touches.anyObject locationInView:self];
    
    CGRect cutRect = CGRectZero;
    if (_allowFollow) {     // cutView跟随手指移动
        // FIXME: 性能较差、存在bug
        cutRect = CGRectWith(CGPointMake(_cutViewFrame.origin.x + (movePoint.x - _originPoint.x),
                                         _cutViewFrame.origin.y + (movePoint.y - _originPoint.y)),
                             self.cutView.bounds.size);
    } else {
        cutRect = CGRectMakePoint(_originPoint, movePoint);
    }
    
    UIImage *cutImage = [UIImage rj_screenshotWithView:self.imageView rect:cutRect];
    
    self.cutView.image = cutImage;
    self.toolBar.hidden = false;
    self.infoLabel.hidden = false;
    self.infoLabel.text = [NSString stringWithFormat:@" %.0f * %.0f  ", cutRect.size.width, cutRect.size.height];
    
    [self.cutView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(cutRect.origin.x);
        make.top.mas_equalTo(cutRect.origin.y);
        make.size.mas_equalTo(cutRect.size);
    }];
    self.cutView.layer.cornerRadius = cutRect.size.width / 2.0;

}


- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
//    [self performSelector:@selector(setAllowFollow:) withObject:@(true) afterDelay:2];
    
}


#pragma mark - Public Methods

- (void)show {
    [self showOrHideWithAnimation:true];
}


- (void)hide {
    [self showOrHideWithAnimation:false];
}

- (void)reset {
    self.coverView.hidden = true;
    self.infoLabel.hidden = true;
    self.toolBar.hidden = true;
    self.cutView.image = nil;
    
    [self.cutView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(@0);
        make.size.mas_equalTo(CGSizeZero);
    }];
    
}



#pragma mark - Private Methods

- (void)showOrHideWithAnimation:(BOOL)isShow {
    
    if (isShow && self.hidden) {
        self.hidden = false;
        self.frame = [UIScreen mainScreen].bounds;
        
        [UIView animateWithDuration:0.3 animations:^{
            
            self.transform = CGAffineTransformMakeScale(0.9, 0.9);
            
        } completion:^(BOOL finished) {
            
        }];
    } else if (!isShow && !self.hidden) {
        
        [UIView animateWithDuration:0.3 animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
            self.alpha = 1;
            self.hidden = true;
            self.transform = CGAffineTransformIdentity;
        }];
        
    }

    
}




@end






#pragma mark - PhotoEditerToolBar

@implementation PhotoEditerToolBar

- (instancetype)init {
    if (self = [super init]) {
        [self initSubviews];
    }
    return self;
}



- (void)initSubviews {
    
    UIButton *cancelButton = [[UIButton alloc] init];
    cancelButton.backgroundColor = [UIColor redColor];
    [cancelButton setTitle:@"✖️" forState:UIControlStateNormal];
    
    UIButton *sureButton = [[UIButton alloc] init];
    sureButton.backgroundColor = [UIColor greenColor];
    [sureButton setTitle:@"✔️" forState:UIControlStateNormal];
    
    [self addSubview:cancelButton];
    [self addSubview:sureButton];
    _cancelButton = cancelButton;
    _sureButton = sureButton;
    
    
    [sureButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(sureButton.superview.mas_height);
        make.top.right.equalTo(sureButton.superview);
    }];
    
    [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.top.equalTo(sureButton);
        make.right.equalTo(sureButton.mas_left);
    }];
    
}


@end



























