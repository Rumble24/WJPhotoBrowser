//
//  WJPhotoBrowser.h
//  cbox
//
//  Created by 王景伟 on 2018/12/19.
//  Copyright © 2018 tjianli. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WJPhotoBrowserModel : NSObject
@property (nonatomic, strong) UIImageView *thumbView; ///< thumb image, used for animation position calculation
@property (nonatomic, assign) CGSize largeImageSize;
@property (nonatomic, strong) NSURL *largeImageURL;
@property (nonatomic, assign) BOOL isAnimated;
@end


@interface WJPhotoBrowser : UIView

- (instancetype)initWithGroupModel:(NSArray<WJPhotoBrowserModel *> *)groupModel;

- (void)presentFromImageView:(UIView *)fromView
                 toContainer:(UIView *)container
                    animated:(BOOL)animated
                  completion:(void (^)(void))completion;

- (void)dismissAnimated:(BOOL)animated completion:(void (^)(void))completion;
- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
