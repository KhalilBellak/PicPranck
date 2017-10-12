//
//  CollectionViewController.h
//  PicPranck
//
//  Created by El Khalil Bellakrid on 19/03/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "PicPranckImageView.h"
#import "PicPranckButton.h"
#import "PicPranckViewController.h"

@import Firebase;


@interface CollectionViewController : UICollectionViewController <UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,PicPranckImageViewDelegate,PicPranckButtonDelegate,PicPranckModalViewDelegate>

//Buttons

////Back button
@property (strong, nonatomic) IBOutlet UIBarButtonItem *buttonCustomView;
- (IBAction)goToCustomTab:(id)sender;

////Select button
@property (strong, nonatomic) IBOutlet UIBarButtonItem *selectButton;
- (IBAction)selectElements:(id)sender;

////Trash button
@property (strong, nonatomic) UIBarButtonItem *trashButton;

//Selected indices (for delete)
@property (strong,nonatomic) NSMutableArray *selectedIndices;

//Dictionary to keep URLs of loaded PicPrancks
@property (strong, nonatomic) NSMutableDictionary *dicoNSURLOfAvailablePickPranks;
@property (strong,nonatomic) NSMutableArray *listOfKeys;

-(id)getPreviewImageForCellAtIndexPath:(NSIndexPath *)indexPath;
-(NSString *)getCellIdentifier;
-(void)deleteSelectedElements:(id)sender;
-(void)backToInitialStateFromBarButtonItem:(UIBarButtonItem *)barButton;

+(NSInteger)getModeOfCollectionView;

@end


