//
//  PicPranckImageView.m
//  PicPranck
//
//  Created by El Khalil Bellakrid on 16/02/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
//View Controllers
#import "ViewController.h"
//PicPranck Objects
#import "PicPranckImageView.h"

@implementation PicPranckImageView

#pragma mark Gesture Recognizers

-(void)removeDeleteButton: (UITapGestureRecognizer *)sender {
    if ( sender.state == UIGestureRecognizerStateEnded )
        [sender.view removeFromSuperview];
}

#pragma mark Buttons on Cover View

-(void)addButtonInView:(UIView *)iView withFrame:(CGRect)iFrame text:(NSString *)text andSelector:(SEL)action {
    UIButton *button = [[UIButton alloc] initWithFrame:iFrame];
    [button setTitle:text forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor clearColor]];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [iView addSubview:button];
}


@end
