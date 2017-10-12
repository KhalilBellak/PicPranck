//
//  PicPranckImageView.h
//  PicPranck
//
//  Created by El Khalil Bellakrid on 16/02/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "SavedImage+CoreDataClass.h"

@class PicPranckImageView;
@protocol PicPranckImageViewDelegate < NSObject >
-(void)cellTaped:(PicPranckImageView *)sender;
@end

@class PicPranckImageViewDelegate;

@interface PicPranckImageView : UIImageView

//Attributes
@property  NSInteger indexOfViewInCollectionView;
@property  UIView *layerView;
@property  SavedImage *managedObject;
@property (nonatomic, weak) id <PicPranckImageViewDelegate> delegate;
@property  UIView *coverView;
@property  UIImageView *imageViewForPreview;
@property  NSMutableArray *listOfImgs;

@end


