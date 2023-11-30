//
//  PEPMaskView.h
//  PEPPlayer
//
//  Created by 李沛倬 on 2017/7/26.
//  Copyright © 2017年 RavenKite. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef UIView * (^HitThroughViewBlock)(CGPoint point, UIEvent *event, BOOL *returnSuper);
typedef BOOL (^PointInsideBlock)(CGPoint point, UIEvent *event, BOOL *returnSuper);


@interface PEPMaskView : UIView

@property (nonatomic, strong) UIColor *maskColor;

- (void)addTransparentRect:(CGRect)rect;

- (void)addTransparentRoundedRect:(CGRect)rect
                     cornerRadius:(CGFloat)cornerRadius;

- (void)addTransparentRoundedRect:(CGRect)rect
                byRoundingCorners:(UIRectCorner)corners
                      cornerRadii:(CGSize)cornerRadii;

- (void)addTransparentOvalRect:(CGRect)rect;

- (void)reset;


@end





//@interface UIView (HitThrough)
//
//@property(nonatomic, strong) HitThroughViewBlock hitThroughBlock;
//
//@property(nonatomic, strong) PointInsideBlock pointInsideBlock;
//
//@end
