//
//  PhotoEditer.h
//  Player
//
//  Created by 李沛倬 on 2017/6/7.
//  Copyright © 2017年 pep. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoEditerToolBar;

#pragma mark - PhotoEditer

typedef void(^PhotoEditerAction)(id object);

@interface PhotoEditer : UIWindow

@property (nonatomic, strong, readonly) UIImageView *imageView;

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, copy) PhotoEditerAction cancelButtonDidClick;

@property (nonatomic, copy) PhotoEditerAction sureButtonDidClick;


- (instancetype)initWithImage:(UIImage *)image;

- (instancetype)initWithImagePath:(NSString *)imagePath;

+ (instancetype)editWithImage:(UIImage *)image;

+ (instancetype)editWithImagePath:(NSString *)imagePath;


- (void)show;

- (void)hide;

- (void)reset;

@end




#pragma mark - PhotoEditerToolBar

@interface PhotoEditerToolBar : UIView

@property (nonatomic, strong, readonly) UIButton *cancelButton;

@property (nonatomic, strong, readonly) UIButton *sureButton;

@end
































