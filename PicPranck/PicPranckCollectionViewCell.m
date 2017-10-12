//
//  PicPranckCollectionViewCell.m
//  PicPranck
//
//  Created by El Khalil Bellakrid on 23/02/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//
//View Controllers
#import "CollectionViewController.h"
//PicPranck Objects
#import "PicPranckCollectionViewCell.h"
#import "PicPranckImageView.h"
//Services
#import "PicPranckImageServices.h"
#include "Constants.h"

@implementation PicPranckCollectionViewCell

@synthesize pictureName = _pictureName;

- (PicPranckImageView *) imageViewInCell {
    
    if (!_imageViewInCell) {
        
        //Layout
        _imageViewInCell = [[PicPranckImageView alloc] initWithFrame:self.contentView.bounds];
        _imageViewInCell.layer.cornerRadius = CELL_CORNER_RADIUS;
        _imageViewInCell.clipsToBounds = YES;
        
        //Gesture Recognizers
        _imageViewInCell.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapOnce = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnce:)];
        tapOnce.numberOfTouchesRequired = 1;
        tapOnce.cancelsTouchesInView = 1;
        [_imageViewInCell addGestureRecognizer:tapOnce];
        
        //Add image view to cell
        [self.contentView addSubview:_imageViewInCell];
    }
    
    return _imageViewInCell;
}

-(UIActivityIndicatorView *)activityIndic {
    
    if(!_activityIndic) {
        
        //Layout
        _activityIndic=[[UIActivityIndicatorView alloc] initWithFrame:self.contentView.bounds];
        [_activityIndic setBackgroundColor:[PicPranckImageServices getGlobalTintWithLighterFactor:-50]];
        _activityIndic.alpha=0.75;
        [self.contentView addSubview:_activityIndic];
        
        //Start animating
        [_activityIndic startAnimating];
    }
    
    return _activityIndic;
}

-(void)handleTapOnce:(id)sender {
    
    if([sender isKindOfClass:[UITapGestureRecognizer class]]) {
        UITapGestureRecognizer *tapGest = (UITapGestureRecognizer *)sender;
        
        if(UIGestureRecognizerStateEnded == tapGest.state) {
            
            if([tapGest.view isKindOfClass:[PicPranckImageView class]]) {
                PicPranckImageView *imgView = (PicPranckImageView *)tapGest.view;
                [imgView.delegate cellTaped:imgView ];
            }
            
        }
    }
}

// Here we remove all the custom stuff that we added to our subclassed cell
-(void)prepareForReuse {
    [super prepareForReuse];
    [self.imageViewInCell removeFromSuperview];
    self.imageViewInCell = nil;
}
@end
