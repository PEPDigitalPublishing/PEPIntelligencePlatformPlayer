//
//  UIView+IBSupport.h
//  Player
//
//  Created by 李沛倬 on 2017/6/12.
//  Copyright © 2017年 pep. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (IBSupport)

/** 可以在xib里面直接设置圆角 */
@property (nonatomic, assign) IBInspectable CGFloat cornerRadius;

/** 可以在xib里面直接设置边线宽度 */
@property (nonatomic, assign) IBInspectable CGFloat borderWidth;

/** 可以在xib里面直接设置边线颜色 */
@property (nonatomic, assign) IBInspectable UIColor *borderColor;

@end





