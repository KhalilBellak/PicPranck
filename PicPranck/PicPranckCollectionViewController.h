//
//  PicPranckCollectionViewController.h
//  PicPranck
//
//  Created by El Khalil Bellakrid on 23/02/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "CollectionViewController.h"

#import "PicPranckImageView.h"
#import "PicPranckButton.h"

@import Firebase;

@interface PicPranckCollectionViewController : CollectionViewController <NSFetchedResultsControllerDelegate>

//Attributes

////Controller will notify delegate of changes
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

////Block to execute when changes occurs from controller side
@property NSBlockOperation *blockOperation;
@property BOOL shouldReloadCollectionView;

@end
