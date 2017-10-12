//
//  PicPranckTextView.m
//  PicPranck
//
//  Created by El Khalil Bellakrid on 28/01/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
//PicPranck Objects
#import "PicPranckTextView.h"
//Services
#import "PicPranckImageServices.h"
#import "PicPranckCustomViewsServices.h"

#pragma mark -

@implementation PicPranckTextView

#pragma mark Initialization

-(void)initWithDelegate:(id<UITextViewDelegate> ) textViewDelegate ImageView:(UIImageView *)iImageView AndText:(NSString *)text {
    
    //Text View
    self.editable = YES;
    self.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    self.delegate = textViewDelegate;
    self.edited=NO; //know if text view has been edited by user
    [self setFont:[UIFont fontWithName:@"Impact" size:22.0f]];
    [self setTextColor:[UIColor whiteColor]];
    if([text length] == 0) text = @" ";
    if([text length] > 0) {
        NSAttributedString *attributedText = [PicPranckCustomViewsServices getAttributedStringWithString:text withFontSize:22.0f];
        [self setAttributedText:attributedText];
        self.edited=YES;
    }
    
    
    //Image view
    self.imageView = iImageView;
    self.imageView.clipsToBounds = YES;
    
    //Gestures
    self.tapsAcquired = 0;
    if(!self.gestureView)
        self.gestureView = [[UIView alloc] init];
    iImageView.userInteractionEnabled = YES;
    self.gestureView.userInteractionEnabled = YES;
    
    //Layout & appearence of Text View
    [self setTextAlignment:NSTextAlignmentCenter];
    [self setBackgroundColor:[UIColor clearColor]];
    self.layer.masksToBounds = YES;
    self.clipsToBounds = YES;
    CGRect newFrame = CGRectMake(0,0,iImageView.frame.size.width,iImageView.frame.size.height);
    self.frame = newFrame;
    
    //Layout gesture view
    [self.gestureView setBackgroundColor:[UIColor clearColor]];
    self.gestureView.frame = newFrame;
    
    //Layout image view
    iImageView.clipsToBounds = YES;
    iImageView.autoresizesSubviews = YES;
    
    //Make UITextView as a subview of UIImageView (for print and auto-resize issues)
    [iImageView addSubview:self];
    [iImageView addSubview:self.gestureView];
    [iImageView bringSubviewToFront:self.gestureView];
    
}

#pragma mark Copy Methods

+(void)copyTextView:(PicPranckTextView *)textViewToCopy inOtherTextView:(PicPranckTextView *)targetTextView withImageView:(UIImageView *)iImageView {
    
    if(textViewToCopy && targetTextView)
        [targetTextView initWithDelegate:textViewToCopy.delegate ImageView:iImageView AndText:textViewToCopy.text];
    
}

#pragma mark Gesture Recognizer

-(void)addGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    if([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        [super addGestureRecognizer:gestureRecognizer];
    }
}

@end
