//
//  PicPranckFirebaseCollectionViewController
//  PicPranck
//
//  Created by El Khalil Bellakrid on 02/05/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//
//View Controllers
#import "PicPranckFirebaseCollectionViewController.h"
//PicPranck Objects
#import "PicPranckCollectionViewCell.h"
//Services
#import "PicPranckCustomViewsServices.h"
#import "PicPranckEncryptionServices.h"
//Extensions
#import "UIViewController+Alerts.h"
//Pods
@import Firebase;
@import FirebaseStorage;
@import FirebaseDatabase;
@import FirebaseStorageUI;

#pragma mark-
@implementation PicPranckFirebaseCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

#pragma mark Synthetize
@synthesize storage = _storage;
@synthesize dicoNSURLOfAvailablePickPranks = _dicoNSURLOfAvailablePickPranks;
@synthesize availablePPRef = _availablePPRef;

#pragma mark CollectionViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //Attributes
    self.nbOfItems=0;
    _dicoNSURLOfAvailablePickPranks = [[NSMutableDictionary alloc] init];
    
    //Firebase Storage
    _storage = [FIRStorage storageWithURL:@"gs://picpranck.appspot.com"];
    FIRStorageReference *storageRef = [_storage reference];
    
    //User's id
    NSString *userID = [FIRAuth auth].currentUser.uid;
    
    //Path to storage
    NSString *pathToStorage = [NSString stringWithFormat:@"usersPicPrancks/%@",userID];
    _availablePPRef = [storageRef child:pathToStorage];
    
    //Firebase Database
    ////Path to Database
    NSString *pathToDB = [NSString stringWithFormat:@"usersPicPrancks/%@/PicPrancks",userID];
    self.firebaseRef = [[FIRDatabase database] reference];
    FIRDatabaseReference *availablePP=[self.firebaseRef child:pathToDB];
    self.dataSource = [self.collectionView bindToQuery:availablePP
                                          populateCell:^UICollectionViewCell *(UICollectionView *collectionView,
                                                                               NSIndexPath *indexPath,
                                                                               FIRDataSnapshot *object) {
                                              return [self populateCell:collectionView atIndexPath:indexPath withFIRObject:object];
                                          }];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [self.collectionView reloadData];
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    //nameOfPicture (Ex: PicPranck_0)
    cell.pictureName=object.value;
    
    NSString *extension = @"png";
    
    NSString *pathToPreview = object.value;
    NSMutableArray *arrayOfURLs = [[NSMutableArray alloc] init];
    
    //Create local directory to cache images
    NSString *documentsDirectory = [PicPranckEncryptionServices getOrCreateLocalUserStorage];
    //Ex: documentsDirectory/PicPranck_0
    NSString *pathToCacheDirectory = [NSString stringWithFormat:@"%@/%@", documentsDirectory,pathToPreview];
    //Ex: documentsDirectory/PicPranck_0/image_1.png
    NSString *pathToCachedImagePreview = [NSString stringWithFormat:@"%@/image_1.png", pathToCacheDirectory];
    
    //Create directory cache if not yet done
    if (![[NSFileManager defaultManager] fileExistsAtPath:pathToCacheDirectory isDirectory:nil]) {
        
        //If not, create it
        NSError * error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath: pathToCacheDirectory
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];
        
    }
    //Otherwise retrieve preview
    else if([[NSFileManager defaultManager] fileExistsAtPath:pathToCachedImagePreview isDirectory:nil]) {
        
        //And set it in cell
        NSArray *arrayOfNSURL = [_dicoNSURLOfAvailablePickPranks objectForKey:pathToPreview];
        
        if(arrayOfNSURL && 1<[arrayOfNSURL count]) {
            
            NSData *data = [NSData dataWithContentsOfURL:[arrayOfNSURL objectAtIndex:1]];
            UIImage *imagePreview = [[UIImage alloc] initWithData:data];
            [cell.imageViewInCell setImage:imagePreview];
            
            //Deactivate activity indicator
            if(imagePreview)
                [cell.activityIndic stopAnimating];
            
            cell.imageViewInCell.delegate=self;
            
            return cell;
        }
    }
    
    //Dispatch async picture load
    //QOS_CLASS_USER_INITIATED
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^ {
        
        //3 pictures to retrieve
                       for(int i = 1;i <= 3;i++){
                           
                           //Get a path to picture of type nameOfFolder/nameOfPicture_i.extension (Ex: PicPranck_0/image_1.png)
                           NSString *currRelativeImagePath = [NSString stringWithFormat: @"image_%d.%@",i-1,extension];
                           NSString *currImagePath = [NSString stringWithFormat:@"%@/%@", pathToPreview,currRelativeImagePath];
                           FIRStorageReference *element = [self.availablePPRef child:currImagePath];
                           
                           // Create local filesystem URL
                           //With document directory
                           NSString *local = [NSString stringWithFormat:@"%@/%@",pathToCacheDirectory,currRelativeImagePath];
                           NSURL *localURL = [NSURL fileURLWithPath:local];
                           
                           //Check if image already loaded
                           NSNumber *isAFile;
                           NSError *err;
                           NSData *cachedData = [NSData dataWithContentsOfURL:localURL];
                           [localURL getResourceValue:&isAFile
                                               forKey:NSURLFileResourceTypeKey error:&err];
                           
                           // Download to the local filesystem
                           if(0 >= isAFile && !cachedData)
                           {
                               [element dataWithMaxSize:1 * 1024 * 1024 completion:^(NSData *data, NSError *error){
                                   if (!error) {
                                       
                                       //Decrypt data loaded from Firebase
                                       NSData *decryptedData = [PicPranckEncryptionServices decryptImage:data];
                                       [decryptedData writeToURL:localURL  atomically:YES];
                                       
                                       //Set cell's thumbnail
                                       if(2 == i) {
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               if(decryptedData)
                                               {
                                                   [cell.imageViewInCell setImage:[UIImage imageWithData:decryptedData]];
                                                   [cell.activityIndic stopAnimating];
                                               }
                                           });
                                           
                                       }
                                   }
                               }];

                           }
                           else if(2 == i && cachedData) {
                               //Set thumbnail
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   [cell.imageViewInCell setImage:[UIImage imageWithData:cachedData]];
                                   //Deactivate activity indicator
                                   [cell.activityIndic stopAnimating];
                               });
                           }
                           
                           [arrayOfURLs addObject:localURL];
                       }
        
                       if(3 == [arrayOfURLs count]) {
                           [_dicoNSURLOfAvailablePickPranks setValue:arrayOfURLs forKey:pathToPreview];
                       }
                       
                   });
    
    cell.imageViewInCell.delegate=self;
    
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSString *)getCellIdentifier {
    return reuseIdentifier;
}

-(void)deleteSelectedElements:(id)sender {
    
    //Sort selected indices (ascending)
    NSSortDescriptor* sortOrder = [NSSortDescriptor sortDescriptorWithKey: @"self"
                                                                ascending: YES];
    [self.selectedIndices sortedArrayUsingDescriptors: [NSArray arrayWithObject: sortOrder]];
    
    //Array of PPs Name to delete (Ex: [PicPranck_3,PicPranck_10]
    NSMutableArray *folderNamesToDelete = [[NSMutableArray alloc] init];
    for(id row in self.selectedIndices)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[row integerValue] inSection:0];
        PicPranckCollectionViewCell *currCell = (PicPranckCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        [folderNamesToDelete addObject:currCell.pictureName];
    }
    
    //Remove
    [PicPranckEncryptionServices removePicPrancks:self withNames:folderNamesToDelete];
    
    //Remove deleted elements from selectedIndices list
    [self.selectedIndices removeAllObjects];
    
    //Remove "trash" and "cancel" buttons
    [self backToInitialStateFromBarButtonItem:self.selectButton];
}
@end
