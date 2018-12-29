//
//  WJPhotoBrowser.m
//  cbox
//
//  Created by 王景伟 on 2018/12/19.
//  Copyright © 2018 tjianli. All rights reserved.
//  1.单击放大展示 到这个View 2.双击放大。 3.在单击消失。 4.可放大缩小

#import "WJPhotoBrowser.h"
#define kPadding 10

#define kBrowserW [UIScreen mainScreen].bounds.size.width
#define kBrowserH [UIScreen mainScreen].bounds.size.height

//测试用的随机颜色
#define CNCbox_RandomColor ([UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:1])

@implementation WJPhotoBrowserModel
@end


@interface BrowserCollectionCell : UICollectionViewCell<UIScrollViewDelegate>
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) WJPhotoBrowserModel *model;
@property (nonatomic, strong) CAShapeLayer *progressLayer;
@property (nonatomic, strong) UIScrollView *scrollView;
@end
@implementation BrowserCollectionCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    _scrollView = UIScrollView.new;
    _scrollView.bouncesZoom = YES;
    _scrollView.minimumZoomScale = 1;
    _scrollView.maximumZoomScale = 3;
    _scrollView.multipleTouchEnabled = YES;
    _scrollView.alwaysBounceVertical = NO;
    _scrollView.showsVerticalScrollIndicator = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.frame = [UIScreen mainScreen].bounds;
    _scrollView.delegate = self;
    [self.contentView addSubview:_scrollView];
    
    _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kBrowserW, 0)];
    _imageView.backgroundColor = CNCbox_RandomColor;
    [_scrollView addSubview:_imageView];
    
    _progressLayer = [CAShapeLayer layer];
    _progressLayer.frame = CGRectMake((kBrowserW - 40)/2.0f, (kBrowserH - 40)/2.0f, 40, 40);
    _progressLayer.cornerRadius = 20;
    _progressLayer.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.500].CGColor;
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(_progressLayer.bounds, 7, 7) cornerRadius:(40 / 2 - 7)];
    _progressLayer.path = path.CGPath;
    _progressLayer.fillColor = [UIColor clearColor].CGColor;
    _progressLayer.strokeColor = [UIColor whiteColor].CGColor;
    _progressLayer.lineWidth = 4;
    _progressLayer.lineCap = kCALineCapRound;
    _progressLayer.strokeStart = 0;
    _progressLayer.strokeEnd = 0;
    _progressLayer.hidden = YES;
    [self.layer addSublayer:_progressLayer];
    return self;
}


- (void)setModel:(WJPhotoBrowserModel *)model {
    _model = model;
    
    [self.scrollView setZoomScale:1.0 animated:NO];
    self.scrollView.maximumZoomScale = 1;
    
    _progressLayer.hidden = NO;
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _progressLayer.strokeEnd = 0;
    _progressLayer.hidden = YES;
    [CATransaction commit];
    
    if (model.isAnimated) {
        __weak typeof(self) weakSelf = self;
//        [_imageView setImageWithURL:model.largeImageURL placeholderImage:model.thumbView.image options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
//            CGFloat progress = receivedSize / (float)expectedSize;
//            progress = progress < 0.01 ? 0.01 : progress > 1 ? 1 : progress;
//            if (isnan(progress)) progress = 0;
//            weakSelf.progressLayer.hidden = NO;
//            weakSelf.progressLayer.strokeEnd = progress;
//        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
//            weakSelf.progressLayer.hidden = YES;
//            weakSelf.scrollView.maximumZoomScale = 3;
//            [weakSelf resizeSubviewSize];
//        }];
    } else {
        [_imageView setImage:model.thumbView.image];
    }
}

- (void)resizeSubviewSize {
    
    UIImage *image = _imageView.image;
//    if (image.size.height / image.size.width > self.height / kBrowserW) {
//        _imageView.height = floor(image.size.height / (image.size.width / kBrowserW));
//    } else {
//        CGFloat height = image.size.height / image.size.width * kBrowserW;
//        if (height < 1 || isnan(height)) height = self.height;
//        height = floor(height);
//        _imageView.height = height;
//        _imageView.centerY = self.height / 2;
//    }
//    if (_imageView.height > self.height && _imageView.height - self.height <= 1) {
//        _imageView.height = self.height;
//    }
//    self.scrollView.contentSize = CGSizeMake(kBrowserW, MAX(_imageView.height, self.height));
//    [self.scrollView scrollRectToVisible:self.bounds animated:NO];
//
//    if (_imageView.height <= self.height) {
//        self.scrollView.alwaysBounceVertical = NO;
//    } else {
//        self.scrollView.alwaysBounceVertical = YES;
//    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    UIView *subView = _imageView;
    
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    subView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                 scrollView.contentSize.height * 0.5 + offsetY);
}
@end








@interface WJPhotoBrowser ()<UIGestureRecognizerDelegate,UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, weak) UIView *fromView;
@property (nonatomic, weak) UIView *toContainerView;

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) NSArray *groupModel;
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UIImageView *topView;
@property (nonatomic, strong) UILabel *pageLabel; ///> 显示 9/9

@property (nonatomic, assign) NSInteger page; ///> 显示 9/9
@property (nonatomic, assign) BOOL isPresented;

@end
@implementation WJPhotoBrowser


- (instancetype)initWithGroupModel:(NSArray<WJPhotoBrowserModel *> *)groupModel {
    self = [super init];
    if (groupModel.count == 0) return nil;
    
    _groupModel = groupModel;
    _isPresented = NO;
    
    self.backgroundColor = [UIColor clearColor];
    self.frame = [UIScreen mainScreen].bounds;
    self.clipsToBounds = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
    
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    tap2.delegate = self;
    tap2.numberOfTapsRequired = 2;
    [tap requireGestureRecognizerToFail: tap2];
    [self addGestureRecognizer:tap2];
    
    UILongPressGestureRecognizer *press = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress)];
    press.delegate = self;
    [self addGestureRecognizer:press];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self addGestureRecognizer:pan];
    
    _bgView = UIView.new;
    _bgView.frame = [UIScreen mainScreen].bounds;
    _bgView.backgroundColor = [UIColor blackColor];
    _bgView.alpha = 0;
    [self addSubview:_bgView];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(kBrowserW + kPadding, kBrowserH);
    layout.minimumLineSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, kBrowserW + kPadding, kBrowserH) collectionViewLayout:layout];
    [_collectionView registerClass:[BrowserCollectionCell class] forCellWithReuseIdentifier:@"BrowserCollectionCell"];
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.pagingEnabled = YES;
    _collectionView.delaysContentTouches = NO;
    _collectionView.canCancelContentTouches = YES;
    _collectionView.scrollsToTop = NO;
    [self addSubview:_collectionView];
    
    _topView = UIImageView.new;
    _topView.frame = CGRectMake(0, 0, kBrowserW, 50);
    _topView.hidden = YES;
    _topView.backgroundColor = [UIColor blackColor];
    _topView.alpha = 0.5;
    [self addSubview:_topView];
    
    _pageLabel = UILabel.new;
    _pageLabel.frame = CGRectMake(20, 0, 100, 50);
    _pageLabel.textColor = [UIColor whiteColor];
    _pageLabel.hidden = groupModel.count > 1;
    _pageLabel.hidden = YES;
    [self addSubview:_pageLabel];
    
    return self;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _groupModel.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BrowserCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BrowserCollectionCell" forIndexPath:indexPath];
    cell.model = _groupModel[indexPath.row];
    return cell;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    _pageLabel.text = [NSString stringWithFormat:@"%tu/%tu",(self.currentPage + 1),self.groupModel.count];
}

- (void)presentFromImageView:(UIView *)fromView
                 toContainer:(UIView *)container
                    animated:(BOOL)animated
                  completion:(void (^)(void))completion {
    
    if (!container) return;
    _fromView = fromView;
    _toContainerView = container;
    [_toContainerView addSubview:self];

    ///> 0.获取点击的是第几个
    NSInteger page = -1;
    for (NSInteger i = 0; i < self.groupModel.count; i++) {
        if (fromView == ((WJPhotoBrowserModel *)self.groupModel[i]).thumbView) {
            page = i;
            break;
        }
    }
    if (page == -1) page = 0;
    
    ///> 1.滑动只需要的位置
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.collectionView setContentOffset:CGPointMake((kBrowserW + kPadding) * page, 0) animated:NO];
    });

    ///> 3. 将collectionView设置 frame
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.04 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        ///> 2.找到我们的cell
//        BrowserCollectionCell *cell = (BrowserCollectionCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:page inSection:0]];
////        CGRect fromFrame = [fromView convertRect:fromView.bounds toView:[AppDelegate sharedInstance].window];
//        cell.imageView.frame = fromFrame;
//        ///> 4.动画
//        float oneTime = animated ? 0.25 : 0;
//        [UIView animateWithDuration:oneTime animations:^{
//            self.bgView.alpha = 0.95;
//            cell.imageView.frame = CGRectMake(0, 0, kBrowserW, kBrowserH);
//        } completion:^(BOOL finished) {
//            for (WJPhotoBrowserModel *model in self.groupModel) {
//                model.isAnimated = YES;
//            }
//            [self.collectionView reloadData];
//            self.isPresented = YES;
//            self.topView.hidden = NO;
//            self.pageLabel.hidden = NO;
//            [self scrollViewDidEndDecelerating:self.collectionView];
//        }];
    });
}

- (void)dismissAnimated:(BOOL)animated completion:(void (^)(void))completion {
    _isPresented = NO;
    self.topView.hidden = YES;
    self.pageLabel.hidden = YES;
    BrowserCollectionCell *cell = (BrowserCollectionCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentPage inSection:0]];
    cell.hidden = YES;
    self.bgView.alpha = 0;
    UIImageView *toView = ((WJPhotoBrowserModel *)self.groupModel[self.currentPage]).thumbView;
    [toView.superview bringSubviewToFront:toView];
    CGRect originFrame = toView.frame;
    toView.frame = CGRectMake(0, 0, kBrowserW, kBrowserH);
    float oneTime = animated ? 0.25 : 0;
    [UIView animateWithDuration:oneTime animations:^{
        toView.frame = originFrame;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        if (completion) completion();
    }];
}

- (void)dismiss {
    [self dismissAnimated:YES completion:^{}];
}

- (NSInteger)currentPage {
//    NSInteger page = _collectionView.contentOffset.x / _collectionView.width;
//    if (page >= _groupModel.count) page = (NSInteger)_groupModel.count - 1;
//    if (page < 0) page = 0;
//    return page;
    return 0;
}

#pragma mark - 双击
- (void)doubleTap:(UITapGestureRecognizer *)g {
//    if (!_isPresented) return;
//    BrowserCollectionCell *cell = (BrowserCollectionCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentPage inSection:0]];
//    if (cell) {
//        if (cell.scrollView.zoomScale > 1) {
//            [cell.scrollView setZoomScale:1 animated:YES];
//        } else {
//            CGPoint touchPoint = [g locationInView:cell.scrollView];
//            CGFloat newZoomScale = cell.scrollView.maximumZoomScale;
//            CGFloat xsize = self.width / newZoomScale;
//            CGFloat ysize = self.height / newZoomScale;
//            [cell.scrollView zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
//        }
//    }
}

- (void)longPress {
//    if (!_isPresented) return;
//
//    YYPhotoGroupCell *tile = [self cellForPage:self.currentPage];
//    if (!tile.imageView.image) return;
//
//    // try to save original image data if the image contains multi-frame (such as GIF/APNG)
//    id imageItem = [tile.imageView.image imageDataRepresentation];
//    YYImageType type = YYImageDetectType((__bridge CFDataRef)(imageItem));
//    if (type != YYImageTypePNG &&
//        type != YYImageTypeJPEG &&
//        type != YYImageTypeGIF) {
//        imageItem = tile.imageView.image;
//    }
//
//    UIActivityViewController *activityViewController =
//    [[UIActivityViewController alloc] initWithActivityItems:@[imageItem] applicationActivities:nil];
//    if ([activityViewController respondsToSelector:@selector(popoverPresentationController)]) {
//        activityViewController.popoverPresentationController.sourceView = self;
//    }
//
//    UIViewController *toVC = self.toContainerView.viewController;
//    if (!toVC) toVC = self.viewController;
//    [toVC presentViewController:activityViewController animated:YES completion:nil];
}

// 拖动手势
- (void)pan:(UIPanGestureRecognizer *)g {
//    NSLog(@"      - (void)pan:(UIPanGestureRecognizer *)g      ");
//    switch (g.state) {
//        case UIGestureRecognizerStateBegan: {
//            if (_isPresented) {
//                _panGestureBeginPoint = [g locationInView:self];
//            } else {
//                _panGestureBeginPoint = CGPointZero;
//            }
//        } break;
//        case UIGestureRecognizerStateChanged: {
//            if (_panGestureBeginPoint.x == 0 && _panGestureBeginPoint.y == 0) return;
//            CGPoint p = [g locationInView:self];
//            CGFloat deltaY = p.y - _panGestureBeginPoint.y;
//            _scrollView.top = deltaY;
//
//            CGFloat alphaDelta = 160;
//            CGFloat alpha = (alphaDelta - fabs(deltaY) + 50) / alphaDelta;
//            alpha = YY_CLAMP(alpha, 0, 1);
//            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveLinear animations:^{
//                _blurBackground.alpha = alpha;
//                _pager.alpha = alpha;
//            } completion:nil];
//
//        } break;
//        case UIGestureRecognizerStateEnded: {
//            if (_panGestureBeginPoint.x == 0 && _panGestureBeginPoint.y == 0) return;
//            CGPoint v = [g velocityInView:self];
//            CGPoint p = [g locationInView:self];
//            CGFloat deltaY = p.y - _panGestureBeginPoint.y;
//
//            if (fabs(v.y) > 1000 || fabs(deltaY) > 120) {
//                [self cancelAllImageLoad];
//                _isPresented = NO;
//                [[UIApplication sharedApplication] setStatusBarHidden:_fromNavigationBarHidden withAnimation:UIStatusBarAnimationFade];
//
//                BOOL moveToTop = (v.y < - 50 || (v.y < 50 && deltaY < 0));
//                CGFloat vy = fabs(v.y);
//                if (vy < 1) vy = 1;
//                CGFloat duration = (moveToTop ? _scrollView.bottom : self.height - _scrollView.top) / vy;
//                duration *= 0.8;
//                duration = YY_CLAMP(duration, 0.05, 0.3);
//
//                [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState animations:^{
//                    _blurBackground.alpha = 0;
//                    _pager.alpha = 0;
//                    if (moveToTop) {
//                        _scrollView.bottom = 0;
//                    } else {
//                        _scrollView.top = self.height;
//                    }
//                } completion:^(BOOL finished) {
//                    [self removeFromSuperview];
//                }];
//
//                _background.image = _snapshotImage;
//                [_background.layer addFadeAnimationWithDuration:0.3 curve:UIViewAnimationCurveEaseInOut];
//
//            } else {
//                [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:v.y / 1000 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState animations:^{
//                    _scrollView.top = 0;
//                    _blurBackground.alpha = 1;
//                    _pager.alpha = 1;
//                } completion:^(BOOL finished) {
//
//                }];
//            }
//
//        } break;
//        case UIGestureRecognizerStateCancelled : {
//            _scrollView.top = 0;
//            _blurBackground.alpha = 1;
//        }
//        default:break;
//    }
}
@end
