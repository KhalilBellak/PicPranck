//
//  AvailablePicPranckCollectionViewController.m
//  PicPranck
//
//  Created by El Khalil Bellakrid on 19/03/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//
//View controllers
#import "AvailablePicPranckCollectionViewController.h"
//PicPrancks objects
#import "PicPranckCollectionViewCell.h"
//Services
#import "PicPranckCustomViewsServices.h"
//Extensions
#import "UIViewController+Alerts.h"
//Pods
@import Firebase;
@import FirebaseStorage;
@import FirebaseDatabase;
@import FirebaseStorageUI;

#pragma mark -
@implementation AvailablePicPranckCollectionViewController

static NSString * const reuseIdentifier = @"CellFromAvailablePP";

#pragma mark Synthetize

@synthesize storage = _storage;
@synthesize dicoNSURLOfAvailablePickPranks = _dicoNSURLOfAvailablePickPranks;
@synthesize listOfKeys = _listOfKeys;
@synthesize availablePPRef = _availablePPRef;

#pragma mark CollectionViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //Attributes
    self.nbOfItems = 0;
    _dicoNSURLOfAvailablePickPranks = [[NSMutableDictionary alloc] init];
    _listOfKeys = [[NSMutableArray alloc] init];
    //Firebase Storage
    _storage = [FIRStorage storageWithURL:@"gs://picpranck.appspot.com"];
    FIRStorageReference *storageRef = [_storage reference];
    _availablePPRef = [storageRef child:@"availablePicPrancks"];
 
    //Firebase Database
    self.firebaseRef = [[FIRDatabase database] reference];
    FIRDatabaseReference *availablePP=[self.firebaseRef child:@"availablePicPrancks"];
    self.dataSource = [self.collectionView bindToQuery:availablePP//self.firebaseRef
                                          populateCell:^UICollectionViewCell *(UICollectionView *collectionView,
                                                                               NSIndexPath *indexPath,
                                                                               FIRDataSnapshot *object) {
                                              return [self populateCell:collectionView atIndexPath:indexPath withFIRObject:object];
                                          }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark <UICollectionViewDataSource>

-(void)updateCells:(FIRDataSnapshot *)snapshot {
    [self.collectionView reloadData];
}

-(UICollectionViewCell *)populateCell:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath withFIRObject:(FIRDataSnapshot *)object {
    
    PicPranckCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier
                                                                                  forIndexPath:indexPath];
    //Activate activity indicator
    [cell.activityIndic startAnimating];
    
    //nameOfPicture (Ex: nutScape)
    NSString *pictureName = object.value;
    
    NSString *extension = @"png";
    
    //Root of path to preview (Ex: nutScape/image_1)
    NSString *pathToPreview = [NSString stringWithFormat:@"%@/",pictureName];
    
    //Array that will hold URLs where image are loaded
    NSMutableArray *arrayOfURLs = [[NSMutableArray alloc] init];
    
    //Dispatch async picture load
    //QOS_CLASS_USER_INITIATED
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^ {
        
        //Image to place while waiting for image_Index to be loaded
        UIImage *placeholderImage = [UIImage imageNamed:@"simple_fuck_no_back.png"];
        
        //3 pictures to retrieve
                       for(int i = 1;i <= 3;i++) {
                           
                           //Get a path to picture of type nameOfPicture/nameOfPicture_i.extension (Ex: nutScape/nutScape_1.png)
                           NSString *currRelativeImagePath = [NSString stringWithFormat: @"%@%@%@%@%@",pictureName,@"_",[@(i) stringValue],@".",extension];
                           NSString *currImagePath = [NSString stringWithFormat:@"%@%@", pathToPreview,currRelativeImagePath];
                           
                           FIRStorageReference *element = [self.availablePPRef child:currImagePath];
                           
                           // Create local filesystem URL
                           NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                           NSString *documentsDirectory = [paths objectAtIndex:0];
                           NSString *local = [NSString stringWithFormat:@"%@/%@",documentsDirectory,currRelativeImagePath];
                           NSURL *localURL = [NSURL fileURLWithPath:local];
                           
                           //Check if image already loaded
                           NSNumber *isAFile;
                           NSError *err;
                           [localURL getResourceValue:&isAFile
                                               forKey:NSURLFileResourceTypeKey error:&err];

                           // Download to the local filesystem
                           if(0 >= isAFile) {
                               [element writeToFile:localURL completion:^(NSURL *URL, NSError *error)
                                                                       {
                                                                           if(error)
                                                                           {
                                                                               [self showMessagePrompt:error.description];
                                                                               return;
                                                                           }
                                                                       }];
                           }
                           
                           [arrayOfURLs addObject:localURL];
                           
                           //Set cell's thumbnail
                           if(2 == i) {
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   [cell.imageViewInCell sd_setImageWithStorageReference:element placeholderImage:placeholderImage];
                                   //Deactivate activity indicator
                                   [cell.activityIndic stopAnimating];
                               });
                               
                           }
                       }
        
        //Once 3 pictures loaded we insert arrayOfUrls to dictionary with pictureName (PicPranck_0) as key
                       if(3 == [arrayOfURLs count]) {
                           [_dicoNSURLOfAvailablePickPranks setValue:arrayOfURLs forKey:pictureName];
                           if(indexPath.row <= [_listOfKeys count])
                               [_listOfKeys insertObject:pictureName atIndex:indexPath.row];
                           else
                               [_listOfKeys addObject:pictureName];
                       }
                       
                   });
    
    //Delegation for showing preview
    cell.imageViewInCell.delegate = self;
    
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSString *)getCellIdentifier {
    return reuseIdentifier;
}

@end
