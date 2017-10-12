//
//  PicPranckPreview.m
//  PicPranck
//
//  Created by El Khalil Bellakrid on 01/06/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import "PicPranckPreview.h"
#import "PicPranckEncryptionServices.h"
#import "AvailablePicPranckCollectionViewController.h"
#import "PicPranckCollectionViewCell.h"
#import "PicPranckCustomViewsServices.h"
#import "PicPranckButton.h"
#import "PicPranckViewController.h"
#import "CollectionViewController.h"
#include "Constants.h"

#pragma mark -
@implementation PicPranckPreview

#pragma mark Initialization

-(id)initWithFrame:(CGRect)frame fromViewController:(CollectionViewController *)vc withIndex:(NSInteger)index andNumberOfElements:(NSInteger)nbOfElements {
    
    //Attributes
    _arrayOfAreasImageViews = [[NSMutableArray alloc] init];
    _previewIndex = index;
    _nbOfElements = nbOfElements;
    _collectionViewController = vc;
    
    self=[self initWithFrame:frame];

    //Get image to put in image views
    NSArray *arrayOfImages = [self getImagesFromCollectionViewAtIndex:index];
    [self insertImages:arrayOfImages];
    
    return self;
}

-(id)initWithFrame:(CGRect)frame {
    
    self=[super initWithFrame:frame];
    
    //Background
    self.backgroundColor = [UIColor clearColor] ;
    
    //Add Swipe Gestures
    UISwipeGestureRecognizer *gestRecoLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedLeft:)];
    [gestRecoLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    UISwipeGestureRecognizer *gestRecoRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedRight:)];
    [gestRecoRight setDirection:UISwipeGestureRecognizerDirectionRight];
    
    [self addGestureRecognizer:gestRecoLeft];
    [self addGestureRecognizer:gestRecoRight];
    
    //Preview frame
    CGRect previewFrame = [self getPreviewFrame];
    
    //Add buttons Use and Close
    
    ////Use button
    CGRect useFrame = CGRectMake(previewFrame.origin.x - (0.5*BUTTON_WIDTH), previewFrame.origin.y + previewFrame.size.height + Y_OFFSET_PREVIEW_TO_BUTTON, BUTTON_WIDTH, BUTTON_HEIGHT);
    if(!_useButton) {
        _useButton = [PicPranckCustomViewsServices addButtonInView:self withFrame:useFrame andImageName:@"useButton" ];
        [_useButton addTarget:self action:@selector(useImage:) forControlEvents:UIControlEventTouchUpInside];
    }
    _useButton.tag = _previewIndex;
    
    ////Close button
    CGRect closeFrame = CGRectMake(previewFrame.origin.x + previewFrame.size.width - (0.5*BUTTON_WIDTH), previewFrame.origin.y + previewFrame.size.height + Y_OFFSET_PREVIEW_TO_BUTTON, BUTTON_WIDTH, BUTTON_HEIGHT);
    if(!_closeButton) {
        _closeButton = [PicPranckCustomViewsServices addButtonInView:self withFrame:closeFrame andImageName:@"closeButton" ];
        [_closeButton addTarget:self action:@selector(closePreview:) forControlEvents:UIControlEventTouchUpInside];
    }
    _closeButton.tag = _previewIndex;

    
    //Set buttons' Delegate
    if(_collectionViewController) {
        _closeButton.delegate = _collectionViewController;
        _useButton.delegate = _collectionViewController;
    }
    
    //Add buttons next and previous
    CGFloat buttonSize = BUTTON_WIDTH;
    
    ////Previous Button
    CGRect previousFrame = CGRectMake(0,previewFrame.origin.y + (previewFrame.size.height/2) - (0.5*buttonSize), buttonSize, buttonSize);
    if(!_previousButton) {
        _previousButton = [PicPranckCustomViewsServices addButtonInView:self withFrame:previousFrame andImageName:@"previousButton" ];
        [_previousButton addTarget:self action:@selector(swipedRight:) forControlEvents:UIControlEventTouchUpInside];
    }
    if(0 == _previewIndex)
       [_previousButton setHidden:YES];
    
    ////Next Button
    CGRect nextFrame = CGRectMake(frame.size.width - buttonSize,previewFrame.origin.y + (previewFrame.size.height/2) - (0.5*buttonSize), buttonSize, buttonSize);
    if(!_nextButton) {
        _nextButton = [PicPranckCustomViewsServices addButtonInView:self withFrame:nextFrame andImageName:@"nextButton" ];
        [_nextButton addTarget:self action:@selector(swipedLeft:) forControlEvents:UIControlEventTouchUpInside];
    }
    if(_nbOfElements-1 == _previewIndex)
        [_nextButton setHidden:YES];
    
    return self;
}

-(void)setModalViewController:(PicPranckViewController *)modalVC {
    if(modalVC) {
    _useButton.modalVC = modalVC;
    _closeButton.modalVC = modalVC;
    }
}

#pragma mark Images manipulations

-(NSArray *)getImagesFromCollectionViewAtIndex:(NSInteger)index {
   
    NSMutableArray *arrayOfImages = [[NSMutableArray alloc] init];
    
    //Get cell of "index"
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_previewIndex inSection:0];
    PicPranckCollectionViewCell *ppCell = (PicPranckCollectionViewCell *)[_collectionViewController.collectionView cellForItemAtIndexPath:indexPath];
    
    //Retrieve URL where images are loaded
    if(ppCell) {
        NSString *key = ppCell.pictureName;
        if([_collectionViewController isKindOfClass:[AvailablePicPranckCollectionViewController class]]) {
            if(index < [[_collectionViewController listOfKeys] count])
                key = [[_collectionViewController listOfKeys] objectAtIndex:index];
        }
        
        NSArray *arrayOfNSURL = [[_collectionViewController dicoNSURLOfAvailablePickPranks] objectForKey:key];
        if(arrayOfNSURL) {
            
            for(NSURL *url in arrayOfNSURL) {
                
                NSData *data = [NSData dataWithContentsOfURL:url];
                UIImage *image = [[UIImage alloc] initWithData:data];
                
                //If image not loaded yet, place logo instead
                if(!image)
                    image = [UIImage imageNamed:@"logoNoBack"];
                
                [arrayOfImages addObject:image];
                
            }
        }
    }
    
    return arrayOfImages;
}

-(CGRect)getPreviewFrame {
    
    //Get frame
    CGRect frame = [UIScreen mainScreen].bounds;
  
    CGFloat widthOfPreview = frame.size.width/WIDTH_PREVIEW_RATIO;
    CGFloat heightOfPreview = frame.size.height/HEIGHT_PREVIEW_RATIO;
    
    CGRect previewFrame = CGRectMake((frame.size.width - widthOfPreview)/2, ((frame.size.height - heightOfPreview) - BUTTON_HEIGHT)/2, widthOfPreview, heightOfPreview);
    
    return previewFrame;
}

-(void)insertImages:(NSArray *)images {
    
    //Get frame
    CGRect previewFrame = [self getPreviewFrame];
    
    //Init container view if needed
    if(!_imageViewForPreview) {
        
        _imageViewForPreview = [[UIView alloc] initWithFrame:previewFrame];
        [self addSubview:_imageViewForPreview];
        [self bringSubviewToFront:_imageViewForPreview];
    }
    
    //Populate container view
    if(_imageViewForPreview) {
        
        CGFloat totalHeight = 0.0;
        CGFloat heightChildImageView = previewFrame.size.height/3;
        
        for(id imgOfArea in images) {
            
            if(![imgOfArea isKindOfClass:[UIImage class]])
                continue;
            
            UIImage *image = (UIImage *)imgOfArea;
            NSInteger indexOfImg = [images indexOfObject:imgOfArea];
            
            //Set frame of child UIImageVIew
            CGRect childFrame=CGRectMake(0, totalHeight, previewFrame.size.width, heightChildImageView);
            totalHeight += heightChildImageView;
            
            //Init image views for areas if not
            UIImageView *childImageView = nil;
            if(3!=[_arrayOfAreasImageViews count]) {
                
                childImageView = [[UIImageView alloc] init];
                [_arrayOfAreasImageViews addObject:childImageView];
                childImageView.tag = indexOfImg;
                [childImageView setFrame:childFrame];
                [childImageView setBackgroundColor:[UIColor blackColor]];
                [childImageView setContentMode:UIViewContentModeScaleAspectFit];
                [_imageViewForPreview addSubview:childImageView];
                
            }
            else
                childImageView = [_arrayOfAreasImageViews objectAtIndex:indexOfImg];
            
            //Animate transition
            [UIView transitionWithView:childImageView
                              duration:0.5f
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                childImageView.image = image;
                            } completion:nil];
        }
    }
}
#pragma mark Actions

-(void)swipedLeft:(id)sender {
    
    //Swipe left
    if(_previewIndex < _nbOfElements-1) {
        
        _previewIndex++;
        
        //Get Image to display from collection view
        NSArray *arrayOfImages=[self getImagesFromCollectionViewAtIndex:_previewIndex];
        
        //Insert
        [self insertImages:arrayOfImages];
        
        //Hide next button if needed
        if(_nbOfElements-1 == _previewIndex)
            [_nextButton setHidden:YES];
        [_previousButton setHidden:NO];
        
    }
}

-(void)swipedRight:(id)sender {
    
    if(_previewIndex > 0) {
        
        _previewIndex--;
        
        //Get Image to display from collection view
        NSArray *arrayOfImages = [self getImagesFromCollectionViewAtIndex:_previewIndex];
        
        //Insert
        [self insertImages:arrayOfImages];
        
        //Hide previous button if needed
        if(0 == _previewIndex)
            [_previousButton setHidden:YES];
        [_nextButton setHidden:NO];
    }

}

-(void)closePreview:(id)sender {
    
    if([sender isKindOfClass:[PicPranckButton class]]) {
        PicPranckButton *button = (PicPranckButton *)sender;
        [button.superview removeFromSuperview];
        [button.delegate dismissViewController];
    }
    
}

-(void)useImage:(id)sender {
    
    //Get Tab Bar Controller
    if([sender isKindOfClass:[PicPranckButton class]]) {
        PicPranckButton *button = (PicPranckButton *)sender;
        [button.delegate useImage:button];
    }
}


@end
