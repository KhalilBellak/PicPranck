//
//  PicPranckAppPresentationView.m
//  PicPranck
//
//  Created by El Khalil Bellakrid on 24/06/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import "PicPranckAppPresentationView.h"
#import "ViewController.h"
#import "PicPranckTextView.h"
#include "Constants.h"

@implementation PicPranckAppPresentationView

@synthesize frameForTutorial = _frameForTutorial;

+(NSMutableDictionary *)dicoOfModes {
    
    static NSMutableDictionary *dico = nil;
    
    //Create Dictionary
    if(!dico) {
        dico=[[NSMutableDictionary alloc] init];
        [dico setValue:@"tapOnceToTakePicture" forKey:@"0"];
        [dico setValue:@"tapTwiceToEdit" forKey:@"1"];
    }
    
    return dico;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
    // Drawing code
    [self setBackgroundColor:[UIColor clearColor]];
    
    CGRect pageControlFrame = CGRectMake(self.center.x - (0.5*BUTTON_WIDTH), self.frame.origin.y + self.frame.size.height - (1.5*BUTTON_HEIGHT),BUTTON_WIDTH, BUTTON_HEIGHT);
    
    if(!_pageControl) {
        
        _pageControl=[[UIPageControl alloc]  initWithFrame:pageControlFrame];
        
        [_pageControl setNumberOfPages:2];
        
        [_pageControl addTarget:self action:@selector(changeScreen:) forControlEvents:UIControlEventValueChanged];
        
        //Add Swipe Gestures
        UISwipeGestureRecognizer *gestRecoLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedLeft:)];
        [gestRecoLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
        UISwipeGestureRecognizer *gestRecoRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedRight:)];
        [gestRecoRight setDirection:UISwipeGestureRecognizerDirectionRight];
        
        [self addGestureRecognizer:gestRecoLeft];
        [self addGestureRecognizer:gestRecoRight];
        
        [self addSubview:_pageControl];
    }
    
    //Blur effect
    if(!_blurEffect) {
        
        _blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *visualEffectView;
        visualEffectView = [[UIVisualEffectView alloc] initWithEffect:_blurEffect];
        visualEffectView.frame = self.frame;
        [self insertSubview:visualEffectView atIndex:0];

    }
    
    if(!_closeButton) {
    
        CGRect buttonFrame = CGRectMake(rect.origin.x,rect.origin.y,(0.75*TITLE_WIDTH), (0.75*TITLE_HEIGHT));
        
        _closeButton = [[UIButton alloc] initWithFrame:buttonFrame];
        [_closeButton setImage:[UIImage imageNamed:@"gotIt"] forState:UIControlStateNormal];
        
        _closeButton.center = CGPointMake(_pageControl.center.x,_pageControl.center.y-TITLE_HEIGHT);
        [_closeButton addTarget:self action:@selector(closePresentation:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:_closeButton];
        [self bringSubviewToFront:_closeButton];
    }
    
    if(!_howToImageView) {
         CGRect howToFrame = CGRectMake(self.center.x - (0.5*TITLE_WIDTH), self.frame.origin.y + (0.5*TITLE_HEIGHT),TITLE_WIDTH, TITLE_HEIGHT);
        
        _howToImageView = [[UIImageView alloc] initWithFrame:howToFrame];
        [_howToImageView setImage:[UIImage imageNamed:@"customizeAreas"]];
        [self addSubview:_howToImageView];
        [self bringSubviewToFront:_howToImageView];
    }
    
}

-(void)closePresentation:(id)sender {
    [self removeFromSuperview];
}

-(void)swipedLeft:(id)sender {
    
    if(self.pageControl.currentPage < self.pageControl.numberOfPages-1) {
        self.pageControl.currentPage += 1;
        NSDictionary *dico = [PicPranckAppPresentationView dicoOfModes];
        [self customizeViewWithMode:[dico valueForKey:[@(self.pageControl.currentPage) stringValue]]];
    }
    
}

-(void)swipedRight:(id)sender {
    
    if(0 < self.pageControl.currentPage) {
        self.pageControl.currentPage -= 1;
        NSDictionary *dico = [PicPranckAppPresentationView dicoOfModes];
        [self customizeViewWithMode:[dico valueForKey:[@(self.pageControl.currentPage) stringValue]]];
    }
    
}

- (IBAction)changeScreen:(id)sender {
    
}


-(void)customizeViewWithMode:(NSString *)mode {
    
    if(!_imageView) {

        _imageView = [[UIImageView alloc] initWithFrame:_frameForTutorial];
        [self addSubview:_imageView];
        [self bringSubviewToFront:_imageView];
        
    }
    
    [UIView transitionWithView:_imageView duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations: ^{
        [_imageView setImage:[UIImage imageNamed:mode]];
    } completion:nil];
    
}

@end
