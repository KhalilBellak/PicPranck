//
//  CollectionViewController.m
//  PicPranck
//
//  Created by El Khalil Bellakrid on 19/03/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//
#import "AppDelegate.h"
//View Controllers
#import "CollectionViewController.h"
#import "ViewController.h"
//Services
#import "PicPranckCoreDataServices.h"
#import "PicPranckCustomViewsServices.h"
#import "PicPranckImageServices.h"
#import "PicPranckCustomViewsServices.h"
//PicPranck Objects
#import "PicPranckImage.h"
#import "PicPranckCollectionViewCell.h"
#import "PicPranckCollectionViewFlowLayout.h"
#import "PicPranckPreview.h"
//Core Data
#import "ImageOfArea+CoreDataClass.h"

//TODO: initialize fetchedResultsController in view init and use all mechanisms of update

static int collectionViewMode = 0;

@interface CollectionViewController ()
@property(strong, nonatomic) FIRAuthStateDidChangeListenerHandle handle;
@end

#pragma mark -

@implementation CollectionViewController

#pragma mark UICollectionViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //Attributes
    _selectedIndices = [[NSMutableArray alloc] init];
    
    //Collection View "settings"
    [self.collectionView setAllowsMultipleSelection:YES];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    //Background
    UIImage *imgBackground = [PicPranckImageServices getImageForBackgroundColoringWithSize:CGSizeMake(self.view.frame.size.width/2,self.view.frame.size.height/2) withDarkMode:NO];
    [self.collectionView setBackgroundColor:[UIColor colorWithPatternImage:imgBackground]];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    [self.collectionView registerClass:[PicPranckCollectionViewCell class] forCellWithReuseIdentifier:[self getCellIdentifier]];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"collectionViewHeader"];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Actions

- (IBAction)goToCustomTab:(id)sender {
     [self.tabBarController setSelectedIndex:0];
}

- (IBAction)selectElements:(id)sender {
    
    NSInteger nbOfElements = [self.collectionView numberOfItemsInSection:0];
    if([sender isKindOfClass:[UIBarButtonItem class]] && 0<nbOfElements) {
        
        UINavigationItem *navigVC = self.navigationItem;
        UITabBarController *tabBarVC = self.tabBarController;
        
        UIBarButtonItem *button = (UIBarButtonItem *)sender;
        if(0 == button.tag) {
            
            //Replace Select by Delete (in red)
            [button setImage:[UIImage imageNamed:@"cancelButton"] ];
            
            //Replace custom button icon with trash button
            if(!_trashButton) {
                _trashButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"trashButtonNavigationBarGrayed"] style:UIBarButtonItemStylePlain target:self action:@selector(deleteSelectedElements:)];
                UIEdgeInsets titleInsets = UIEdgeInsetsMake(0.0, -20.0, 0.0, 0.0);
                [_trashButton setImageInsets:titleInsets];
            }
            
            //Title
            UIImageView *titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"selectedElements"]];
            [navigVC setTitleView:titleView];
            
            //Trash Button
            _trashButton.customView.frame = navigVC.leftBarButtonItem.customView.bounds;
            [navigVC setLeftBarButtonItem:_trashButton];
            [_trashButton setEnabled:NO];
            
            //Hide tab bar
            [tabBarVC.tabBar setHidden:YES];
            button.tag = 1;
            
        }
        else if(1 == button.tag)
            [self backToInitialStateFromBarButtonItem:button];
    }
}

#pragma mark Design

-(void)backToInitialStateFromBarButtonItem:(UIBarButtonItem *)barButton {
    
    UINavigationItem *navigVC = self.navigationItem;
    UITabBarController *tabBarVC = self.tabBarController;
    
    //Put back select button
    [barButton setImage:[UIImage imageNamed:@"selectButton"] ];
    [barButton setTintColor:self.collectionView.tintColor];
    
    //Remove title
    [navigVC setTitleView:nil];
    
    //Put back custom button
    [navigVC setLeftBarButtonItem:_buttonCustomView];
    
    //Show tab bar
    [tabBarVC.tabBar setHidden:NO];
    
    //Deselect all items
    for(id row in _selectedIndices) {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[row integerValue] inSection:0];
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
        
        if([cell isKindOfClass:[PicPranckCollectionViewCell class]]) {
            PicPranckCollectionViewCell *ppCell = (PicPranckCollectionViewCell *)cell;
            if(ppCell.imageViewInCell)
                [ppCell.imageViewInCell.layer setBorderWidth:0];
        }
    }
    
    //Reset selected indices (of cells)
    [_selectedIndices removeAllObjects];
    
    //Disable trashButton
    if(_trashButton) {
        [_trashButton setEnabled:NO];
        [_trashButton setImage:[UIImage imageNamed:@"trashButtonNavigationBarGrayed"]];
    }
    barButton.tag = 0;
}

-(void)deleteSelectedElements:(id)sender {
    //To be implemented by subclass
}

#pragma mark <UICollectionViewDataSource>

-(id)getPreviewImageForCellAtIndexPath:(NSIndexPath *)indexPath {
    //To be implemented by subclasses
    return nil;
}

-(NSString *)getCellIdentifier {
    //To be implemented by subclasses
    return nil;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    PicPranckCollectionViewCell *cell = (PicPranckCollectionViewCell *) [collectionView dequeueReusableCellWithReuseIdentifier:[self getCellIdentifier] forIndexPath:indexPath];
    
    //Delegation
    cell.imageViewInCell.delegate = self;
    
    //Get image for preview
    [cell.activityIndic startAnimating];
    
    id idImage = [self getPreviewImageForCellAtIndexPath:indexPath];
    UIImage *image = [UIImage imageWithData:idImage];

    [cell.imageViewInCell setContentMode:UIViewContentModeScaleAspectFit];
    [PicPranckImageServices setImage:image forImageView:cell.imageViewInCell];
    [cell.activityIndic stopAnimating];
    
    return cell;
}

#pragma mark <UICollectionViewDelegateFlowLayout>

- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 20;
}

- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 20;
}

- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if([collectionViewLayout isKindOfClass:[PicPranckCollectionViewFlowLayout class]]) {
        PicPranckCollectionViewFlowLayout *ppCollecViewLayout = (PicPranckCollectionViewFlowLayout *)collectionViewLayout;
        return ppCollecViewLayout.itemSize;
    }
    return CGSizeMake(120, 120);
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(self.collectionView.frame.size.width, [PicPranckCollectionViewFlowLayout getHeaderHeight]);
}

#pragma mark <PicPranckImageViewDelegate>

-(void)cellTaped:(PicPranckImageView *)sender {
    
    NSInteger index = 0;
    
    //Retrieve cell
    UIView *cell = [[sender superview] superview];
    PicPranckCollectionViewCell *ppCell = nil;
    if([cell isKindOfClass:[PicPranckCollectionViewCell class]]) {
        ppCell = (PicPranckCollectionViewCell *)cell;
        index = [[self.collectionView indexPathForCell:ppCell] row];
    }
    if(!ppCell)
        return;
    
    //If we are not in "selection" mode, tap leads to show preview
    if(0 == _selectButton.tag)
        [PicPranckCustomViewsServices createPreviewInCollectionViewController:self WithIndex:index];
    //Otherwise
    else if(1 == _selectButton.tag) {
        
        //Enable trash button if disabled
        CGFloat borderWidth = 0;
        if(_trashButton && ![_trashButton isEnabled]) {
            [_trashButton setEnabled:YES];
            [_trashButton setImage:[UIImage imageNamed:@"trashButtonNavigationBar"]];
        }
        
        
        //Check if element is already selected, then deselected
        if([self elementIsAlreadySelectedAtIndex:index]) {
            [_selectedIndices removeObject:@(index)];
            if(0 == [_selectedIndices count]) {
               [_trashButton setEnabled:NO];
                [_trashButton setImage:[UIImage imageNamed:@"trashButtonNavigationBarGrayed"]];
            }
        }
        //Otherwise select it
        else {
            [_selectedIndices addObject:@(index)];
            borderWidth = 4;
        }
        
        //Highlight Cell
        if(ppCell) {
            [ppCell.imageViewInCell.layer setBorderColor:[[UIColor whiteColor] CGColor]];
            [ppCell.imageViewInCell.layer setBorderWidth:borderWidth];
        }
    }
}

#pragma mark <PicPranckButtonDelegate>

-(void)useImage:(PicPranckButton *)sender {
    
    //REtrieve ViewController which is "Create" tab's view controller
    UITabBarController *tabBarController = self.tabBarController;
    NSArray *vcArray = [tabBarController viewControllers];
    
    for(UIViewController *currVc in vcArray) {
        
        if([currVc isKindOfClass:[ViewController class]]) {
            
            NSInteger iIndex = [vcArray indexOfObject:currVc];
            ViewController *vc = (ViewController *)currVc;
            
            //Retrieve images from the preview (Modal View Controller) and put it in areas in ViewController
            NSMutableArray *arrayOfImages = [[NSMutableArray alloc] init];
            NSArray *subViewsOfView = [sender.modalVC.view subviews];
            
            //Retrieve all images in arrayOfImages
            for(UIView *coverSubView in subViewsOfView) {
                
                if(![coverSubView isKindOfClass:[PicPranckPreview class]])
                    continue;
                
                NSArray *subViewsOfCoverView = [coverSubView subviews];
                for(UIView *subView in subViewsOfCoverView) {
                    
                    if(![subView isKindOfClass:[UIButton class]]) {
                        
                        NSArray *subViewsOfContainerView = [subView subviews];
                        
                        for(UIView *subViewOfCovecView in subViewsOfContainerView) {
                            
                            if([subViewOfCovecView isKindOfClass:[UIImageView class]]) {
                                UIImageView *imgSubView = (UIImageView *)subViewOfCovecView;
                                [arrayOfImages insertObject:imgSubView.image atIndex:imgSubView.tag];
                            }
                        }
                    }
                }
            }
            
            //Set images in areas
            [PicPranckImageServices setImageAreasWithImages:arrayOfImages inViewController:vc];
            
            //Remove Preview
            [sender removeFromSuperview];
            [sender.superview removeFromSuperview];
            
            //Disiss modal VC
            [sender.modalVC dismissViewControllerAnimated:YES completion:^{
                //Dismiss collection view VC
                //Animated transition to Main VC
                [UIView transitionFromView:sender.modalVC.view
                                    toView:vc.view
                                  duration:0.4
                                   options:UIViewAnimationOptionTransitionFlipFromTop
                                completion:^(BOOL finished) {
                                    if (finished) {
                                        [sender.modalVC.view removeFromSuperview];
                                        tabBarController.selectedIndex = iIndex;
                                    }
                                }];
                
            }];
            
            
            
            
        }
    }
}

-(void)dismissModalViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)dismissViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(BOOL)elementIsAlreadySelectedAtIndex:(NSInteger)index {
    
    bool result=NO;
    for(id currId in _selectedIndices) {
        NSInteger iId=[currId integerValue];
        if(iId==index)
            result=YES;
    }
    return result;
}

+(NSInteger)getModeOfCollectionView
{
    return collectionViewMode ;
}
@end
