//
//  PicPranckCustomViewsServices.h
//  PicPranck
//
//  Created by El Khalil Bellakrid on 23/02/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@class CollectionViewController;
@class PicPranckButton;
@interface PicPranckCustomViewsServices : NSObject

@property UIViewController *modalViewController;

+(void)createPreviewInCollectionViewController:(CollectionViewController *)vc WithIndex:(NSInteger) index;
+(void)createPreviewInCollectionVC:(CollectionViewController *)vc WithIndex:(NSInteger) index;

+(PicPranckButton *)addButtonInView:(UIView *)iView withFrame:(CGRect)iFrame text:(NSString *)text andSelector:(SEL)action;
+(PicPranckButton *)addButtonInView:(UIView *)iView withFrame:(CGRect)iFrame andImageName:(NSString *)imageName;

+(void)setViewDesign:(UIView *)view;
+(void)setLogInButtonsDesign:(UIButton *)button withText:(NSString *)string;
+(NSAttributedString *)getAttributedStringWithString:(NSString *)string withFontSize:(CGFloat)size;

@end
