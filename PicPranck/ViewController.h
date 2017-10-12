//
//  ViewController.h
//  PicPranck
//
//  Created by El Khalil Bellakrid on 22/01/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PicPranckTextView.h"
#import "PicPranckImage.h"

@interface ViewController : UIViewController <UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITextViewDelegate,UIDocumentInteractionControllerDelegate>
{
    //Design
    UIColor *globalTint;
    
    //Areas
    
    ////Text Views
    IBOutlet UIView *viewToMoveForKeyBoardAppearance;
    PicPranckTextView *tapedTextView;
    NSMutableArray *listOfGestureViews;
    PicPranckTextView *textView1;
    PicPranckTextView *textView2;
    PicPranckTextView *textView3;
    
    ////Image Views
    IBOutlet UIStackView *areasStackView;
    IBOutlet UIImageView *imageViewArea1;
    IBOutlet UIImageView *imageViewArea2;
    IBOutlet UIImageView *imageViewArea3;
    IBOutlet UIImageView *frameComplete;
    
    //Buttons
    IBOutlet UIStackView *buttonsStackView;
    IBOutlet UIButton *buttonSend;
    IBOutlet UIButton *saveButton;
    IBOutlet UIButton *resetButton;
    
    
    UIImagePickerController *picker;
}

//Attributes

@property NSMutableArray *listOfTextViews;
@property UIImage *ppImage;
@property NSString *activityType;
@property UIActivityViewController * activityViewController;
@property UIDocumentInteractionController *documentInteractionController;

//Actions
- (IBAction)reset:(id)sender;
- (IBAction)performSave:(id)sender;
- (IBAction)buttonSendClicked:(id)sender;

-(void)generateImageToSendWithActivityType:(NSString *)iActivityType;

-(UIImage *)getImageOfAreaOfIndex:(NSInteger)index;

-(void)presentApp;
@end

