//
//  PicPranckCollectionViewController.m
//  PicPranck
//
//  Created by El Khalil Bellakrid on 23/02/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import "AppDelegate.h"
//View Controllers
#import "PicPranckCollectionViewController.h"
#import "ViewController.h"
//PicPranck Objects
#import "PicPranckImage.h"
#import "PicPranckCollectionViewCell.h"
#import "PicPranckCollectionViewFlowLayout.h"
//Services
#import "PicPranckCoreDataServices.h"
#import "PicPranckImageServices.h"
#import "PicPranckCustomViewsServices.h"
//Core Data
#import "ImageOfArea+CoreDataClass.h"
#import "ImageOfAreaDetails+CoreDataClass.h"
#import "SavedImage+CoreDataClass.h"
#import "Bridge+CoreDataClass.h"
//Extensions
#import "UIViewController+Alerts.h"

@interface PicPranckCollectionViewController ()
//Handle for collection view update when Database Realtime content changes
@property(strong, nonatomic) FIRAuthStateDidChangeListenerHandle handle;
@end

#pragma mark -
@implementation PicPranckCollectionViewController

#pragma mark Synthetize

@synthesize shouldReloadCollectionView = _shouldReloadCollectionView;
@synthesize fetchedResultsController = _fetchedResultsController;

static NSString * const reuseIdentifier = @"Cell";

#pragma mark CollectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Attributes
    _shouldReloadCollectionView = YES;
    
    //First fetch when view loaded
    [self performFetch];
}

-(void)viewWillAppear:(BOOL)animated {
    
    //Refresh collection view in case all PPs are deletes
    if([PicPranckCoreDataServices areAllPicPrancksDeletedMode:self]) {
        _fetchedResultsController = nil;
        [self fetchedResultsController];
        [self performFetch];
        [self.collectionView reloadData];
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    //For memory issues
    NSManagedObjectContext *managedObjCtx = [PicPranckCoreDataServices managedObjectContext:NO fromViewController:self];
    [managedObjCtx reset];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    //Only one section
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    id  sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

-(NSString *)getCellIdentifier {
    return reuseIdentifier;
}

-(id)getPreviewImageForCellAtIndexPath:(NSIndexPath *)indexPath {
    SavedImage *savedImg = [_fetchedResultsController objectAtIndexPath:indexPath];
    //Sort the set
    if(savedImg)
        return savedImg.imageOfAreaDetails.thumbnail;
    return nil;
}

#pragma mark <NSFetchedResultsControllerDelegate>

-(void)performFetch {
    
    NSError *error;
    if (![self.fetchedResultsController performFetch:&error]) {
        if(error)
            [self showMessagePrompt:error.description];
    }
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController)
        return _fetchedResultsController;

    //Otherwise initialize
    return [self initializeFRC];
    
}

-(NSFetchedResultsController *)initializeFRC {
    
    //Get MOC
    NSManagedObjectContext *managedObjCtx=[PicPranckCoreDataServices managedObjectContext:[PicPranckCoreDataServices areAllPicPrancksDeletedMode:self] fromViewController:self];
    
    //Fetch request with right entity to fetch
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"SavedImage" inManagedObjectContext:managedObjCtx];
    [fetchRequest setEntity:entity];
    
    //Sort by date of creation
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"dateOfCreation" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    //Performance purpose
    [fetchRequest setFetchBatchSize:20];
    
    //Controller which will notify delegate (here self) of Core Data changes
    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:managedObjCtx sectionNameKeyPath:nil
                                                   cacheName:nil];
    _fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

-(void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    self.shouldReloadCollectionView = NO;
    self.blockOperation = [[NSBlockOperation alloc] init];
}

-(void)deleteSelectedElements:(id)sender {
    
    NSMutableArray *arrayOfIdxPaths = [[NSMutableArray alloc] init];
    
    //Sort selected indices (ascendung)
    NSSortDescriptor* sortOrder = [NSSortDescriptor sortDescriptorWithKey: @"self"
                                                               ascending: YES];
    [self.selectedIndices sortedArrayUsingDescriptors: [NSArray arrayWithObject: sortOrder]];
    
    //Get MOC to delete selected objects
     NSManagedObjectContext *managedObjCtx = [PicPranckCoreDataServices managedObjectContext:[PicPranckCoreDataServices areAllPicPrancksDeletedMode:self] fromViewController:self];
    
    for(id row in self.selectedIndices) {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[row integerValue] inSection:0];
        [arrayOfIdxPaths addObject:indexPath];
        
        //Delete saved image + bridge
        Bridge *bridge = [PicPranckCoreDataServices retrieveDataAtIndex:indexPath.row withType:@"Bridge"];
        SavedImage *savedImage = [PicPranckCoreDataServices retrieveDataAtIndex:indexPath.row withType:@"SavedImage"];
        
        [managedObjCtx deleteObject:bridge];
        [managedObjCtx deleteObject:savedImage];
    }
    
    //Remove all selected elements (since deleted)
    [self.selectedIndices removeAllObjects];
    
    //Unhighlight elements and remove "trash" and "cancel" buttons from top bar
    [self backToInitialStateFromBarButtonItem:self.selectButton];
    
    //Save changes
    NSError *err;
    [managedObjCtx save:&err];
    if(err)
        [self showMessagePrompt:err.description];
    
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    __weak UICollectionView *collectionView = self.collectionView;
    switch (type) {
            //Insertion of new elements
        case NSFetchedResultsChangeInsert: {
            if ([self.collectionView numberOfSections] > 0) {
                if ([self.collectionView numberOfItemsInSection:indexPath.section] == 0)
                    self.shouldReloadCollectionView = YES;
                else {
                    [self.blockOperation addExecutionBlock:^{
                        [collectionView insertItemsAtIndexPaths:@[newIndexPath]];
                    }];
                }
            }
            else
                self.shouldReloadCollectionView = YES;
            break;
        }
           //Delete of elements
        case NSFetchedResultsChangeDelete: {
            if ([self.collectionView numberOfItemsInSection:indexPath.section] == 1)
                self.shouldReloadCollectionView = YES;
            else {
                [self.blockOperation addExecutionBlock:^{
                    [collectionView deleteItemsAtIndexPaths:@[indexPath]];
                }];
            }
            break;
        }
            //Update of existing data
        case NSFetchedResultsChangeUpdate: {
            [self.blockOperation addExecutionBlock:^{
                [collectionView reloadItemsAtIndexPaths:@[indexPath]];
            }];
            break;
        }
            //Move of elements
        case NSFetchedResultsChangeMove: {
            [self.blockOperation addExecutionBlock:^{
                [collectionView moveItemAtIndexPath:indexPath toIndexPath:newIndexPath];
            }];
            break;
        }
            
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    if (self.shouldReloadCollectionView)
        [self.collectionView reloadData];
    else {
        [self.collectionView performBatchUpdates:^{
            [self.blockOperation start];
        } completion:nil];
    }
    
}

@end
