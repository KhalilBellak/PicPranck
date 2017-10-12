//
//  PicPranckCustomViewsServices.m
//  PicPranck
//
//  Created by El Khalil Bellakrid on 23/02/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//
//View Controllers
#import "AvailablePicPranckCollectionViewController.h"
#import "PicPranckFirebaseCollectionViewController.h"
#import "ViewController.h"
#import "CollectionViewController.h"
#import "PicPranckViewController.h"
//Services
#import "PicPranckCustomViewsServices.h"
#import "PicPranckCoreDataServices.h"
#import "PicPranckImageServices.h"
//PicPranck Objects
#import "PicPranckViewControllerAnimatedTransitioning.h"
#import "PicPranckButton.h"
#import "PicPranckCollectionViewCell.h"
#import "PicPranckPreview.h"
//Core Data
#import "SavedImage+CoreDataClass.h"
#import "ImageOfArea+CoreDataClass.h"
#import "ImageOfAreaDetails+CoreDataClass.h"
#import "Bridge+CoreDataClass.h"
#import "PicPranckEncryptionServices.h"

#include "Constants.h"

@implementation PicPranckCustomViewsServices

#pragma mark Preview creation

+(void)createPreviewInCollectionViewController:(CollectionViewController *)vc WithIndex:(NSInteger) index {
    
    //KEEP:If we want to activate Core Data Mode
//    if([vc isKindOfClass:[AvailablePicPranckCollectionViewController class]]) {
//        Bridge *managedObject = [PicPranckCoreDataServices retrieveDataAtIndex:index withType:@"Bridge"];
//        if(!managedObject)
//            return;
//        //Sort the set
//        NSSortDescriptor *sortDsc = [[NSSortDescriptor alloc] initWithKey:@"position" ascending:YES];
//        NSArray *arrayDsc = [[NSArray alloc] initWithObjects:sortDsc, nil];
//        NSArray *sortedArray = [managedObject.imagesOfArea sortedArrayUsingDescriptors:arrayDsc];
//        for(ImageOfArea *imgOfArea in sortedArray)
//        {
//            UIImage *img = [UIImage imageWithData:imgOfArea.dataImage];
//            [arrayOfImages addObject:img];
//        }
//        
//    }

    if([vc isKindOfClass:[AvailablePicPranckCollectionViewController class]] ||
            [vc isKindOfClass:[PicPranckFirebaseCollectionViewController class]]) {
        [PicPranckCustomViewsServices createPreviewInCollectionVC:vc WithIndex:index] ;
        return;
    }

}

+(void)createPreviewInCollectionVC:(CollectionViewController *)vc WithIndex:(NSInteger) index {
    
    //Get frame
    CGRect frame = [UIScreen mainScreen].bounds;
    
    //View of screen's size and semi-transparent
    PicPranckPreview *coverView = nil;
    
    coverView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    
    NSInteger nbOfPPs = [PicPranckEncryptionServices getNumberOfUserPicPranks:NO];
    
    if([vc isKindOfClass:[AvailablePicPranckCollectionViewController class]])
        nbOfPPs = [PicPranckEncryptionServices getNumberOfAvailablePicPranks];
    
    coverView = [[PicPranckPreview alloc] initWithFrame:frame fromViewController:vc withIndex:index andNumberOfElements:nbOfPPs];
    
    //Modal VC to display view
    PicPranckViewController *modalViewController = [[PicPranckViewController alloc] initModalView];
    [coverView setModalViewController:modalViewController];
    modalViewController.delegate = vc;
    
    [modalViewController.view addSubview:coverView];
    
    //Handle animation of modal presentation
    [vc.tabBarController presentViewController:modalViewController animated:YES completion:nil];
    
}

#pragma mark Buttons on Cover View

+(PicPranckButton *)addButtonInView:(UIView *)iView withFrame:(CGRect)iFrame text:(NSString *)text andSelector:(SEL)action {
    
    PicPranckButton *button = [[PicPranckButton alloc] initWithFrame:iFrame];
    
    [PicPranckCustomViewsServices setLogInButtonsDesign:button withText:text];
    
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [iView addSubview:button];
    [iView bringSubviewToFront:button];
    return button;
}

+(PicPranckButton *)addButtonInView:(UIView *)iView withFrame:(CGRect)iFrame andImageName:(NSString *)imageName {
    
    PicPranckButton *button = [[PicPranckButton alloc] initWithFrame:iFrame];
    
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    
    [iView addSubview:button];
    [iView bringSubviewToFront:button];
    
    return button;
}

#pragma mark Design of buttons (border, background, attributed text....)

+(void)setViewDesign:(UIView *)view {
    
    view.layer.cornerRadius = view.frame.size.height/10;
    [view.layer setBorderWidth:2.0f];
    [view.layer setBorderColor:[[PicPranckImageServices getGlobalTintWithLighterFactor:-100] CGColor]];
    [view setBackgroundColor:[PicPranckImageServices getGlobalTintWithLighterFactor:-50]];
    
}

+(void)setLogInButtonsDesign:(UIButton *)button withText:(NSString *)string {
    
    if([string isEqualToString:@"Use"] || [string isEqualToString:@"Close"] ||
       [string isEqualToString:@"Next"] || [string isEqualToString:@"Previous"] ) {
        
        NSString *imageName = @"useButton";
        if([string isEqualToString:@"Close"])
            imageName = @"closeButton";
        else if([string isEqualToString:@"Next"])
            imageName = @"nextButton";
        else if([string isEqualToString:@"Previous"])
            imageName = @"previousButton";
        
        [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    }
    else {
        [button setBackgroundColor:[UIColor whiteColor]];
        CGFloat fontSize = 18.0f;
        if([string isEqualToString:@"Forgot Password ?"])
            fontSize = 15.0f;
        NSAttributedString *buttonTitle = [PicPranckCustomViewsServices getAttributedStringWithString:string withFontSize:fontSize];
        [button setAttributedTitle:buttonTitle forState:UIControlStateNormal];
    }
}

+(NSAttributedString *)getAttributedStringWithString:(NSString *)string withFontSize:(CGFloat)size {
    
    NSNumber *stroke = [[NSNumber alloc] init];
    stroke = [NSNumber numberWithFloat:-7.0];
    NSDictionary *typingAttributes = @{
                                       NSFontAttributeName: [UIFont fontWithName:@"Impact" size:size],
                                       NSForegroundColorAttributeName : [UIColor whiteColor],
                                       NSKernAttributeName : @(1.3f),
                                       NSStrokeColorAttributeName : [UIColor blackColor],
                                       NSStrokeWidthAttributeName :stroke
                                       };
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:string attributes:typingAttributes];
    
    return attributedText;
}

@end
