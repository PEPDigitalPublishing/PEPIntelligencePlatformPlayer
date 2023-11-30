//
//  PEPMaskView.m
//  PEPPlayer
//
//  Created by 李沛倬 on 2017/7/26.
//  Copyright © 2017年 RavenKite. All rights reserved.
//

#import "PEPMaskView.h"

@interface PEPMaskView ()

@property (nonatomic, weak) CAShapeLayer *fillLayer;

@property (nonatomic, strong) UIBezierPath *overlayPath;

@property (nonatomic, strong) NSMutableArray *transparentPaths;

@end

@implementation PEPMaskView


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.userInteractionEnabled = false;
        [self setUp];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self refreshMask];
}

#pragma mark - Public Methods

- (void)reset {
    [self.transparentPaths removeAllObjects];
    
    [self refreshMask];
}

- (void)addTransparentPath:(UIBezierPath *)transparentPath {
    [self.overlayPath appendPath:transparentPath];
    
    [self.transparentPaths addObject:transparentPath];
    
    self.fillLayer.path = self.overlayPath.CGPath;
}

- (void)addTransparentRect:(CGRect)rect {
    UIBezierPath *transparentPath = [UIBezierPath bezierPathWithRect:rect];
    
    [self addTransparentPath:transparentPath];
}

- (void)addTransparentRoundedRect:(CGRect)rect cornerRadius:(CGFloat)cornerRadius {
    UIBezierPath *transparentPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:cornerRadius];
    
    [self addTransparentPath:transparentPath];
}

- (void)addTransparentRoundedRect:(CGRect)rect
                byRoundingCorners:(UIRectCorner)corners
                      cornerRadii:(CGSize)cornerRadii {
    UIBezierPath *transparentPath = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:corners cornerRadii:cornerRadii];
    
    [self addTransparentPath:transparentPath];
}

- (void)addTransparentOvalRect:(CGRect)rect {
    UIBezierPath *transparentPath = [UIBezierPath bezierPathWithOvalInRect:rect];
    
    [self addTransparentPath:transparentPath];
}

#pragma mark - Private Methods

- (void)setUp {
    self.backgroundColor = [UIColor clearColor];
    self.maskColor = [UIColor blackColor];
    
    self.fillLayer.path = self.overlayPath.CGPath;
    self.fillLayer.fillRule = kCAFillRuleEvenOdd;
    self.fillLayer.fillColor = self.maskColor.CGColor;
}

- (UIBezierPath *)generateOverlayPath {
    UIBezierPath *overlayPath = [UIBezierPath bezierPathWithRect:self.bounds];
    [overlayPath setUsesEvenOddFillRule:YES];
    
    return overlayPath;
}

- (void)refreshMask {
    
    UIBezierPath *path = [self generateOverlayPath];
    for (UIBezierPath *transparentPath in self.transparentPaths) {
        [path appendPath:transparentPath];
    }
    
    self.overlayPath = path;
    
    self.fillLayer.frame = self.bounds;
    self.fillLayer.path = self.overlayPath.CGPath;
    self.fillLayer.fillColor = self.maskColor.CGColor;
}

#pragma mark - Setter and Getter Methods

- (UIBezierPath *)overlayPath {
    if (!_overlayPath) {
        _overlayPath = [self generateOverlayPath];
    }
    
    return _overlayPath;
}

- (CAShapeLayer *)fillLayer {
    if (!_fillLayer) {
        CAShapeLayer *fillLayer = [CAShapeLayer layer];
        fillLayer.frame = self.bounds;
        [self.layer addSublayer:fillLayer];
        
        _fillLayer = fillLayer;
    }
    
    return _fillLayer;
}

- (NSMutableArray *)transparentPaths {
    if (!_transparentPaths) {
        _transparentPaths = [NSMutableArray array];
    }
    
    return _transparentPaths;
}

- (void)setMaskColor:(UIColor *)maskColor {
    _maskColor = maskColor;
    
    [self refreshMask];
}



@end





//@implementation UIView (HitThrough)
//
//const static NSString *HitThroughViewBlockKey   = @"HitThroughViewBlockKey";
//const static NSString *PointInsideBlockKey      = @"PointInsideBlockKey";
//
//+ (void)load {
//    method_exchangeImplementations(class_getInstanceMethod(self, @selector(hitTest:withEvent:)),
//                                   class_getInstanceMethod(self, @selector(st_hitTest:withEvent:)));
//    method_exchangeImplementations(class_getInstanceMethod(self, @selector(pointInside:withEvent:)),
//                                   class_getInstanceMethod(self, @selector(st_pointInside:withEvent:)));
//}
//
//- (UIView *)st_hitTest:(CGPoint)point withEvent:(UIEvent *)event {
//    NSMutableString *spaces = [NSMutableString stringWithCapacity:20];
//    UIView *superView = self.superview;
//    while (superView) {
//        [spaces appendString:@"----"];
//        superView = superView.superview;
//    }
////    NSLog(@"%@%@:[hitTest:withEvent:]", spaces, NSStringFromClass(self.class));
//    UIView *deliveredView = nil;
//    // 如果有hitTestBlock的实现，则调用block
//    if (self.hitThroughBlock) {
//        BOOL returnSuper = NO;
//        deliveredView = self.hitThroughBlock(point, event, &returnSuper);
//        if (returnSuper) {
//            deliveredView = [self st_hitTest:point withEvent:event];
//        }
//    } else {
//        deliveredView = [self st_hitTest:point withEvent:event];
//    }
////    NSLog(@"%@%@:[hitTest:withEvent:] Result:%@", spaces, NSStringFromClass(self.class), NSStringFromClass(deliveredView.class));
//    return deliveredView;
//}
//
//- (BOOL)st_pointInside:(CGPoint)point withEvent:(UIEvent *)event {
//    NSMutableString *spaces = [NSMutableString stringWithCapacity:20];
//    UIView *superView = self.superview;
//    while (superView) {
//        [spaces appendString:@"----"];
//        superView = superView.superview;
//    }
////    NSLog(@"%@%@:[pointInside:withEvent:]", spaces, NSStringFromClass(self.class));
//    BOOL pointInside = NO;
//    if (self.pointInsideBlock) {
//        BOOL returnSuper = NO;
//        pointInside =  self.pointInsideBlock(point, event, &returnSuper);
//        if (returnSuper) {
//            pointInside = [self st_pointInside:point withEvent:event];
//        }
//    } else {
//        pointInside = [self st_pointInside:point withEvent:event];
//    }
//    return pointInside;
//}
//
//- (void)setHitThroughBlock:(HitThroughViewBlock)hitThroughBlock {
//    objc_setAssociatedObject(self, (__bridge const void *)(HitThroughViewBlockKey), hitThroughBlock, OBJC_ASSOCIATION_COPY);
//}
//
//- (HitThroughViewBlock)hitThroughBlock {
//    return objc_getAssociatedObject(self, (__bridge const void *)(HitThroughViewBlockKey));
//}
//
//
//- (void)setPointInsideBlock:(PointInsideBlock)pointInsideBlock {
//    objc_setAssociatedObject(self, (__bridge const void *)(PointInsideBlockKey), pointInsideBlock, OBJC_ASSOCIATION_COPY);
//}
//
//- (PointInsideBlock)pointInsideBlock {
//    return objc_getAssociatedObject(self, (__bridge const void *)(PointInsideBlockKey));
//}
//
//
//@end

































