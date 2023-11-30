//
//  PEPPhotoBrower.m
//  DrawerArch
//
//  Created by 李沛倬 on 2017/5/25.
//  Copyright © 2017年 pep. All rights reserved.
//

#import "PEPPhotoBrower.h"
#import "PEPPlayer.h"


@interface PEPPhotoBrower ()<UIScrollViewDelegate>

@property (nonatomic, strong) UILabel *pageLabel;

@property (nonatomic, strong) NSMutableArray<PEPPhotoBrowerItem *> *items;

@property (nonatomic, assign) NSInteger pageIndex;

@end

@implementation PEPPhotoBrower

#pragma mark - Life Cycle
- (instancetype)init {
    if (self = [super init]) {
        self.coverAlpha = 0.6;
        [self initSubviews];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.coverAlpha = 0.6;
        [self initSubviews];
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Public Method 

- (PEPPhotoBrowerItem *)itemForIndex:(NSUInteger)index {
    if (index > self.items.count) {
        return nil;
    }
    
    return self.items[index];
}

- (NSUInteger)indexForItem:(PEPPhotoBrowerItem *)item {
    return [self.items indexOfObject:item];
}


#pragma mark - UI
- (void)initSubviews {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenDidChangeOrientation:) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
    
    [self initContentView];
    [self initItemViews];
    [self initPageLabel];
}


- (void)initContentView {
    UIView *coverView = [[UIView alloc] init];
    coverView.backgroundColor = [UIColor blackColor];
    coverView.alpha = MAX(0, MIN(1, self.coverAlpha));
    
    UIScrollView *contentView = [[UIScrollView alloc] initWithFrame:self.bounds];
    contentView.delegate = self;
    contentView.pagingEnabled = true;
    contentView.showsVerticalScrollIndicator = false;
    contentView.showsHorizontalScrollIndicator = false;
    contentView.maximumZoomScale = 2;
    contentView.minimumZoomScale = 0.5;
    
    [self addSubview:coverView];
    [self addSubview:contentView];
    
    [coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(coverView.superview);
    }];
    
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(contentView.superview).multipliedBy(1.0);
    }];
    
    self.contentView = contentView;
}

- (void)initItemViews {
    if (!self.dataSource) { return; }
    NSInteger itemCount = [self.dataSource numberOfItemsInPhotoBrower:self];
    
    self.items = [NSMutableArray array];
    
    for (NSInteger i = 0; i < itemCount; i++) {
        PEPPhotoBrowerItem *itemView = [self.dataSource photoBrower:self itemForIndex:i];
        itemView.backgroundColor = self.contentView.backgroundColor;
        itemView.delegate = self;

        [self.contentView addSubview:itemView];
        [self.items addObject:itemView];
    }
    
}

- (void)initPageLabel {
    UILabel *pageLabel = [[UILabel alloc] init];
    pageLabel.textAlignment = NSTextAlignmentCenter;
    pageLabel.textColor = [UIColor whiteColor];
    pageLabel.font = [UIFont systemFontOfSize:14.0];
    pageLabel.backgroundColor = [UIColor colorWithRed:82/255.0 green:82/255.0 blue:82/255.0 alpha:1];
    pageLabel.alpha = 0.8;
    pageLabel.layer.cornerRadius = 12.5;
    pageLabel.layer.masksToBounds = true;
    
    [self addSubview:pageLabel];
    self.pageLabel = pageLabel;
    
    [pageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(pageLabel.superview).offset(-15.0);
        make.bottom.equalTo(pageLabel.superview).offset(-17.0);
        make.height.equalTo(@25.0);
        make.width.greaterThanOrEqualTo(@60);
        make.width.lessThanOrEqualTo(@120).priorityHigh();
    }];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.contentView.contentSize = CGSizeMake(self.bounds.size.width*self.items.count, self.bounds.size.height);
    
    for (NSInteger i = 0; i < self.items.count; i++) {
        PEPPhotoBrowerItem *itemView = self.items[i];
        
        [itemView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.centerY.equalTo(itemView.superview);
//            make.top.equalTo(itemView.superview);
            make.left.mas_equalTo(i * itemView.superview.bounds.size.width);
        }];
    }
    
    [self.items[self.pageIndex] setZoomScale:1 animated:true];
    [self.contentView setContentOffset:CGPointMake(self.pageIndex*self.bounds.size.width, 0) animated:true];
}



#pragma mark - Setter & Getter 
- (void)setDataSource:(id<PEPPhotoBrowerDataSource>)dataSource {
    _dataSource = dataSource;
    [self initItemViews];
    [self setPage];
}


- (void)screenDidChangeOrientation:(NSNotification *)noti {
    
    [self setNeedsLayout];
}

- (void)setPage {
    if (self.items.count <= 1) {
        self.pageLabel.hidden = true;
        return;
    }
    
    self.pageLabel.hidden = false;
    NSInteger pageNum = MIN(self.pageIndex + 1, self.items.count);
    
    switch (@(self.items.count).stringValue.length) {
        case 2:
        {
            self.pageLabel.text = [NSString stringWithFormat:@" %02ld/%02ld   ", pageNum, self.items.count];
            break;

        }
        case 3:
        {
            self.pageLabel.text = [NSString stringWithFormat:@" %03ld/%03ld   ", pageNum, self.items.count];
            break;
            
        }
        default:
        {
            self.pageLabel.text = [NSString stringWithFormat:@" %ld/%ld   ", pageNum, self.items.count];
            break;
        }
    }
    
}


#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    
    if ([scrollView isKindOfClass:[PEPPhotoBrowerItem class]]) {
        return [(PEPPhotoBrowerItem *)scrollView imageView];
    }
    
    return nil;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    
    if ([scrollView isKindOfClass:[PEPPhotoBrowerItem class]]) {
        CGFloat top = 0, left = 0;
        
        if (scrollView.contentSize.width < scrollView.bounds.size.width) {
            left = (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5f;
        }
        if (scrollView.contentSize.height < scrollView.bounds.size.height) {
            top = (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5f;
        }
        scrollView.contentInset = UIEdgeInsetsMake(top, left, top, left);
        
        
    }
    
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view atScale:(CGFloat)scale {

    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    if (scrollView == self.contentView) {
        NSInteger page = scrollView.contentOffset.x / scrollView.bounds.size.width;
        
        if (self.pageIndex != page) {
            [self.items[self.pageIndex] setZoomScale:1];
            self.pageIndex = page;
            
            [self setPage];
        }
    }
    
}


@end




#pragma mark - PEPPhotoBrowerItem

@implementation PEPPhotoBrowerItem

#pragma mark - init
- (instancetype)init {
    if (self = [super init]) {
        [self initSubviews];
    }
    
    return self;
}

- (void)initSubviews {
    
    [self configSelf];
    [self initImageView];
}


- (void)configSelf {
    self.showsVerticalScrollIndicator = false;
    self.showsHorizontalScrollIndicator = false;
    self.maximumZoomScale = 2;
    self.minimumZoomScale = 1;
    
    // 单击手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapAction:)];
    [self addGestureRecognizer:tap];
    
    // 双击手势
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapAction:)];
    doubleTap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTap];
    
    // 双击手势触发时取消单击手势事件
    [tap requireGestureRecognizerToFail:doubleTap];

}

- (void)initImageView {
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.backgroundColor = self.backgroundColor;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [self addSubview:imageView];
    _imageView = imageView;
    
    [imageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(imageView.superview);
        make.size.equalTo(imageView.superview);
    }];
}


- (void)layoutSubviews {
    [super layoutSubviews];

}


#pragma mark - Actions
- (void)singleTapAction:(UITapGestureRecognizer *)tap {
    
    if (self.closeBlock) {
        self.closeBlock(self);
    }
    
}

- (void)doubleTapAction:(UITapGestureRecognizer *)tap {
    if (![tap.view isKindOfClass:[UIScrollView class]]) { return; }
    
    UIScrollView *scrollView = (UIScrollView *)tap.view;
    if (scrollView.zoomScale > 1) {
        [scrollView setZoomScale:1 animated:true];
    } else {
        [scrollView setZoomScale:2 animated:true];
    }
    
}



@end


























