//
//  PicPranckPreview.h
//  PicPranck
//
//  Created by El Khalil Bellakrid on 01/06/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CollectionViewController;
@class PicPranckButton;
@class PicPranckViewController;

@interface PicPranckPreview : UIView

//Attributes
@property (weak,nonatomic) CollectionViewController *collectionViewController;

////Index of element in collection view
@property NSInteger previewIndex;

////Number of element in collection view
@property NSInteger nbOfElements;

////Buttons on preview (close, use, prev and next)
@property (strong, nonatomic) PicPranckButton *closeButton;
@property (strong, nonatomic) PicPranckButton *useButton;
@property (strong, nonatomic) UIButton *previousButton;
@property (strong, nonatomic) UIButton *nextButton;

////Container view of image views
@property (strong, nonatomic) UIView *imageViewForPreview;

////Array of image views
@property (strong, nonatomic) NSMutableArray *arrayOfAreasImageViews;


-(id)initWithFrame:(CGRect)frame fromViewController:(CollectionViewController *)vc withIndex:(NSInteger)index andNumberOfElements:(NSInteger)nbOfElements;

-(void)setModalViewController:(PicPranckViewController *)modalVC;

@end
