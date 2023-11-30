//
//  UIImage+PEPExtension.h
//  DrawerArch
//
//  Created by 李沛倬 on 2017/5/9.
//  Copyright © 2017年 pep. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (PEPExtension)

#pragma mark - Class Methods

/**
 根据颜色和尺寸绘制并返回对应的图片

 @param color 图片颜色
 @param size 图片尺寸: 对于单一颜色的图片，拉伸不会失真，故可不设置尺寸，方法内部将以(1, 1)为尺寸绘制。
 @return 绘制后的图片
 */
+ (UIImage *)rj_imageWithColor:(UIColor *)color size:(CGSize)size;
+ (UIImage *)rj_imageWithColor:(UIColor *)color;

/**
 全屏截图

 @return 全屏截图
 */
+ (UIImage *)rj_fullScreenshot;

/**
 截取指定视图

 @param view 截取视图
 @return return value description
 */
+ (UIImage *)rj_screenshotWithView:(UIView *)view;

/**
 截取指定视图的指定范围

 @param view 截取视图
 @param rect 截取范围
 @return return value description
 */
+ (UIImage *)rj_screenshotWithView:(UIView *)view rect:(CGRect)rect;

/**
 绘制并返回一张扇形图片
 圆心坐标：(width, height/2)，弧度范围：M_PI-angle/2 -> M_PI+angle/2
 即圆弧在左，圆心在右，水平放置于矩形框内的扇形
 
 @param angle 需要绘制扇形的弧度
 @param radius 半径
 @param color 背景色
 @return 扇形图片
 */
+ (UIImage *)arcImageWithAngle:(CGFloat)angle radius:(CGFloat)radius backgroundColor:(UIColor *)color;

#pragma mark - Instance Methods
/**
 缩放图片

 @param scale 缩放倍数
 @return 缩放后的新图片
 */
- (UIImage *)rj_zoomImageWithScale:(CGFloat)scale;


/**
 根据传入的尺寸重新绘制并返回新图片：只重绘不做拉伸和适应处理，如果传入尺寸的宽高比与原始图片不一致，可能导致图片比例失真

 @param newSize 重绘尺寸
 @return 重绘后的新图片
 */
- (UIImage *)rj_resizeImageWithNewSize:(CGSize)newSize;

/**
 裁剪图片

 @param rect 裁剪范围
 @return 裁剪后的图片
 */
- (UIImage *)rj_cropImageWithRect:(CGRect)rect;


@end





#pragma mark - UIColor+RandomColor

@interface UIColor (PEPRandomColor)

/**
 随机色

 @return return value description
 */
+ (UIColor *)rj_randomColor;


@end

















