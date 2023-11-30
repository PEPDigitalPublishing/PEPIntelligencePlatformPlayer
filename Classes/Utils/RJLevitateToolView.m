//
//  RJLevitateToolView.m
//  DrawerArch
//
//  Created by 李沛倬 on 2017/5/8.
//  Copyright © 2017年 pep. All rights reserved.
//

#import "RJLevitateToolView.h"
#import "UIImage+PEPExtension.h"
#import "PEPPlayer.h"

static NSInteger const BASETAG = 100;
static NSInteger const SUBCONTAINERBAERTAG = 888;

@interface RJLevitateToolView ()

@property (nonatomic, strong) UIButton *iconButton;
@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, assign) CGFloat itemRadius;

@property (nonatomic, assign) NSInteger itemCount;

@property (nonatomic, strong) UIImage *itemBackgroundImage;

@property (nonatomic, strong) NSMutableArray<RJLevitateToolItemModel *> *models;

@property (nonatomic, strong) UIView *subContainer;

@end

@implementation RJLevitateToolView

#pragma mark - Life Cycle
- (instancetype)initWithFrame:(CGRect)frame {
    CGRect newframe = frame;
    if (frame.size.width != frame.size.height) {
        CGFloat length = MAX(frame.size.width, frame.size.height);
        newframe = CGRectMake(frame.origin.x, frame.origin.y, length, length);
    }
    
    if (self = [super initWithFrame:newframe]) {
        self.itemRadius = self.bounds.size.width / 2.0;
        self.models = [NSMutableArray array];
        
        self.layer.cornerRadius = self.itemRadius;
        self.layer.masksToBounds = true;
        
        [self initSubviews];
        
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    
}

#pragma mark - Public Methods
- (void)reloadData {
    // TODO: 刷新UI
    
    
}


#pragma mark - UI
- (void)initSubviews {
    [self initContentView];
    [self initIconButton];
}

- (void)initIconButton {
    CGFloat length = self.bounds.size.width / 3.2;
    
    UIButton *iconButton = [UIButton buttonWithType:UIButtonTypeCustom];
    iconButton.contentMode = UIViewContentModeScaleAspectFit;
    [iconButton addTarget:self action:@selector(iconButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    iconButton.frame = CGRectMake(0, 0, length, length);
    iconButton.center = self.center;
    
    iconButton.layer.cornerRadius = length / 2.0;
    iconButton.layer.masksToBounds = true;
    
    [self addSubview:iconButton];
    
    // TODO: 设置Icon
    [iconButton setBackgroundImage:[UIImage imageNamed:@"icon"] forState:UIControlStateNormal];
    
    self.iconButton = iconButton;
}

- (void)initContentView {
    UIView *contentView = [[UIView alloc] initWithFrame:self.frame];
    contentView.backgroundColor = self.backgroundColor;
    
    [self addSubview:contentView];
    self.contentView = contentView;
}

- (void)initItemViews {
    if (!self.dataSource) { return; }
    self.itemCount = [self.dataSource numberOfFirstLevelInlevitateToolView:self];
//    [self handleItemCount];
    
    for (NSInteger i = 0; i < self.itemCount; i++) {
//        NSInteger itemCount = [self.itemCounts[i] integerValue];
        CGFloat angle = 2*M_PI/self.itemCount;
        self.itemBackgroundImage = [UIImage arcImageWithAngle:2*M_PI/self.itemCount radius:self.contentView.bounds.size.width/2-30 backgroundColor:[UIColor grayColor]];
    
//        for (NSInteger j = 0; j < itemCount; j++) {
        RJIndexPath *indexPath = [RJIndexPath indexPathWithFirstLevel:i SecondLevel:0];
        RJLevitateToolItemModel *model = [self.dataSource levitateToolView:self itemForRowAtIndexPath:indexPath];
        [self.models addObject:model];
        
        UIButton *itemView = [self getItemViewWith:indexPath angle:angle model:model];
        [self.contentView addSubview:itemView];
//        }
    }
    
    
    self.contentView.alpha = 0;
    self.contentView.transform = CGAffineTransformMakeScale(0.2, 0.2);

}

- (UIButton *)getItemViewWith:(RJIndexPath *)indexPath angle:(CGFloat)angle model:(RJLevitateToolItemModel *)model {
    UIImage *bgImage = self.itemBackgroundImage;
    CGFloat rotationAngle = angle * indexPath.firstLevel;
    
    UIButton *itemButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [itemButton setBackgroundImage:bgImage forState:UIControlStateNormal];
    itemButton.contentMode = UIViewContentModeScaleAspectFit;
    itemButton.frame = CGRectMake(0, 0, bgImage.size.width, bgImage.size.height);
    
    itemButton.layer.anchorPoint = CGPointMake(1.0, 0.5);
    itemButton.layer.position = CGPointMake(self.contentView.bounds.size.width/2.0 - self.contentView.frame.origin.x,
                                         self.contentView.bounds.size.height/2.0 - self.contentView.frame.origin.y);
    itemButton.tag = indexPath.firstLevel * BASETAG + indexPath.secondLevel;
    
    [itemButton addTarget:self action:@selector(itemDidSelected:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *itemIcon = [self getItemIconWith:indexPath angle:angle model:model];
    
    itemIcon.layer.position = CGPointMake(itemButton.bounds.size.width/2*0.65, itemButton.bounds.size.height/2);
    itemButton.transform = CGAffineTransformMakeRotation(rotationAngle);
    itemIcon.transform = CGAffineTransformMakeRotation(-rotationAngle);
    
    [itemButton addSubview:itemIcon];
    
    if (model.subItems.count > 0) {
        [self addSubitemsWith:indexPath angle:rotationAngle model:model];
    }
    
    return itemButton;
}

- (UIImageView *)getItemIconWith:(RJIndexPath *)indexPath angle:(CGFloat)angle model:(RJLevitateToolItemModel *)model {
    if (!self.dataSource) { return nil; }
    
    UIImage *image = [self.dataSource levitateToolView:self itemForRowAtIndexPath:indexPath].icon;
    
    UIImageView *iconView = [[UIImageView alloc] initWithImage:image];
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    iconView.frame = CGRectMake(0, 0, self.contentView.bounds.size.width/4, self.contentView.bounds.size.height/4);
    
    return iconView;
}


- (void)addSubitemsWith:(RJIndexPath *)indexPath angle:(CGFloat)superAngle model:(RJLevitateToolItemModel *)model {
    
    UIView *subContainer = [[UIView alloc] initWithFrame:self.contentView.bounds];
    subContainer.tag = SUBCONTAINERBAERTAG + indexPath.firstLevel;
    CGFloat angle = 2*M_PI/10;
    
    for (NSInteger i = 0; i < model.subItems.count; i++) {
        RJIndexPath *subIndexPath = [RJIndexPath indexPathWithFirstLevel:indexPath.firstLevel SecondLevel:i+1];
        UIButton *subItem = [self getSubItemViewWith:subIndexPath angle:angle model:model.subItems[i]];
        [subContainer addSubview:subItem];
    }
    
    subContainer.transform = CGAffineTransformMakeRotation(superAngle - angle*model.subItems.count/2);
    subContainer.alpha = 0;
    
    [self.contentView addSubview:subContainer];
    [self.contentView sendSubviewToBack:subContainer];
}

- (UIButton *)getSubItemViewWith:(RJIndexPath *)indexPath angle:(CGFloat)angle model:(RJLevitateToolItemModel *)model {
    UIImage *bgImage = [UIImage arcImageWithAngle:angle radius:self.contentView.bounds.size.width/2 backgroundColor:[UIColor grayColor]];
    CGFloat rotationAngle = angle*indexPath.secondLevel;
    
    UIButton *subItemButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [subItemButton setBackgroundImage:bgImage forState:UIControlStateNormal];
    subItemButton.contentMode = UIViewContentModeScaleAspectFit;
    subItemButton.frame = CGRectMake(0, 0, bgImage.size.width, bgImage.size.height);
    
    subItemButton.layer.anchorPoint = CGPointMake(1.0, 0.5);
    subItemButton.layer.position = CGPointMake(self.contentView.bounds.size.width/2.0 - self.contentView.frame.origin.x,
                                            self.contentView.bounds.size.height/2.0 - self.contentView.frame.origin.y);
    subItemButton.tag = indexPath.firstLevel * BASETAG + indexPath.secondLevel;
    
    [subItemButton addTarget:self action:@selector(subItemDidSelected:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *subItemIcon = [self getSubItemIconWith:indexPath angle:angle model:model];

    subItemIcon.layer.position = CGPointMake(subItemButton.bounds.size.width/2*0.65, subItemButton.bounds.size.height/2);
    subItemButton.transform = CGAffineTransformMakeRotation(rotationAngle);
    subItemIcon.transform = CGAffineTransformMakeRotation(-rotationAngle);
    
    [subItemButton addSubview:subItemIcon];
    
    return subItemButton;
}

- (UIImageView *)getSubItemIconWith:(RJIndexPath *)indexPath angle:(CGFloat)superAngle model:(RJLevitateToolItemModel *)model {
    UIImage *image = model.icon;
    
    UIImageView *iconView = [[UIImageView alloc] initWithImage:image];
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    iconView.frame = CGRectMake(0, 0, self.contentView.bounds.size.width/4, self.contentView.bounds.size.height/4);
    
    return nil;
}

#pragma mark - Action 
- (void)iconButtonAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self showSections:sender.selected];
    self.subContainer.alpha = 0;
}

- (BOOL)showSections:(BOOL)isShow {
    if (self.contentView.subviews.count == 0) {
        [self initItemViews];
    }
    
    [self zoomContentView:isShow];
    
    return true;
}

- (void)itemDidSelected:(UIButton *)sender {
    RJIndexPath *indexPath = [self getIndexPathWithTag:sender.tag];
    
    RJLevitateToolItemModel *model = [self.dataSource levitateToolView:self itemForRowAtIndexPath:indexPath];
    if (model.subItems.count > 0) {
        UIView *subContainer = [self.contentView viewWithTag:SUBCONTAINERBAERTAG + indexPath.firstLevel];
        if (self.subContainer.tag != subContainer.tag) { self.subContainer.alpha = 0; }
        
        [self.contentView sendSubviewToBack:subContainer];
        subContainer.alpha = !subContainer.alpha;
        self.subContainer = subContainer;
    } else {
        self.subContainer.alpha = 0;
        if ([self.delegate respondsToSelector:@selector(levitateToolView:didSelectItem:atIndexPath:)]) {
            [self.delegate levitateToolView:self didSelectItem:sender atIndexPath:indexPath];
        }
    }
}

- (void)subItemDidSelected:(UIButton *)sender {
    RJIndexPath *indexPath = [self getIndexPathWithTag:sender.tag];

    if ([self.delegate respondsToSelector:@selector(levitateToolView:didSelectItem:atIndexPath:)]) {
        [self.delegate levitateToolView:self didSelectItem:sender atIndexPath:indexPath];
    }
}


#pragma mark - Private Methods
- (void)zoomContentView:(BOOL)isShow {
    NSTimeInterval duration = 0.3;

    [UIView animateWithDuration:duration animations:^{
        self.contentView.alpha = isShow;
        self.contentView.transform = isShow ? CGAffineTransformIdentity : CGAffineTransformMakeScale(0.2, 0.2);
    }];
}

- (void)handleItemCount {
    if (self.dataSource) {
        self.itemCount = [self.dataSource numberOfFirstLevelInlevitateToolView:self];
    }

    
//    for (NSInteger i = 0; i < section; i++) {
//        NSInteger itemCount = [self.dataSource levitateToolView:self numberOfRowsInSection:i];
//        [self.itemCounts addObject:@(itemCount)];
//    }
}

- (RJIndexPath *)getIndexPathWithTag:(NSInteger)tag {
    return [RJIndexPath indexPathWithFirstLevel:tag / BASETAG SecondLevel:tag % BASETAG];
}



#pragma mark - Override Super



@end




#pragma mark - RJLevitateToolItemModel
@implementation RJLevitateToolItemModel

- (instancetype)initWithTitle:(NSString *)title icon:(UIImage *)icon subItems:(NSArray<RJLevitateToolItemModel *> *)subItems {
    if (self = [super init]) {
        self.title = title;
        self.icon = icon;
        self.subItems = subItems;
    }
    return self;
}

@end



#pragma mark - RJIndexPath
static NSString *const FIRSTLEVEL_KEY  = @"FIRSTLEVEL_KEY";
static NSString *const SECONDLEVEL_KEY = @"SECONDLEVEL_KEY";

@implementation RJIndexPath

- (instancetype)initWithFirstLevel:(NSInteger)firstLevel SecondLevel:(NSInteger)secondLevel {
    
    if (self = [super init]) {
        _firstLevel = firstLevel;
        _secondLevel = secondLevel;
    }
    
    return self;
}

+ (instancetype)indexPathWithFirstLevel:(NSInteger)firstLevel SecondLevel:(NSInteger)secondLevel {
    
    return [[RJIndexPath alloc] initWithFirstLevel:firstLevel SecondLevel:secondLevel];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    [aCoder encodeObject:@(self.firstLevel) forKey:FIRSTLEVEL_KEY];
    [aCoder encodeObject:@(self.secondLevel) forKey:SECONDLEVEL_KEY];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    if (self = [super init]) {
        _firstLevel = [(NSNumber *)[aDecoder decodeObjectForKey:FIRSTLEVEL_KEY] integerValue];
        _secondLevel = [(NSNumber *)[aDecoder decodeObjectForKey:SECONDLEVEL_KEY] integerValue];
    }
    
    return self;
}

@end















