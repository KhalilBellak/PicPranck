//
//  PicPranckTextView.h
//  PicPranck
//
//  Created by El Khalil Bellakrid on 28/01/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import <UIKit/UIKit.h>

//Subclass text view which will contain Image view and are the main areas to edit
@interface PicPranckTextView : UITextView

//Attributes
@property NSInteger tapsAcquired;
@property BOOL edited;
@property UIImageView *imageView;
@property UIView *gestureView;

-(void)initWithDelegate:(id<UITextViewDelegate> )textViewDelegate ImageView:(UIImageView *)iImageView AndText:(NSString *)text;

+(void)copyTextView:(PicPranckTextView *)textViewToCopy inOtherTextView:(PicPranckTextView *)targetTextView withImageView:(UIImageView *)iImageView;

@end
