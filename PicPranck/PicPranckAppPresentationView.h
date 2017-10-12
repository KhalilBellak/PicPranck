//
//  PicPranckAppPresentationView.h
//  PicPranck
//
//  Created by El Khalil Bellakrid on 24/06/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewController;

@interface PicPranckAppPresentationView : UIView

@property NSMutableDictionary *dicoOfModes;

+(NSMutableDictionary *)dicoOfModes;
-(void)customizeViewWithMode:(NSString *)mode;

@property (strong, nonatomic) UIImageView *imageView;

@property (strong, nonatomic)  UIPageControl *pageControl;

@property (strong,nonatomic) UIButton *closeButton;

@property (strong,nonatomic) UIImageView *howToImageView;

@property CGRect frameForTutorial;


@property (strong, nonatomic) UIVisualEffect *blurEffect;

@end
