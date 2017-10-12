//
//  TabBarViewController.m
//  PicPranck
//
//  Created by El Khalil Bellakrid on 16/02/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//
//View Controllers
#import "TabBarViewController.h"
//PicPranck Objects
#import "PicPranckViewControllerAnimatedTransitioning.h"
//Services
#import "PicPranckImageServices.h"

#pragma mark -
@implementation TabBarViewController

#pragma mark UITabBarController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.delegate = self;
    
    //Init attributes
    _allPicPrancksRemovedMode = NO;
    
    //Customize tab's appearance
    [self customizeTab];
    
}
-(void)customizeTab {
    
    self.tabBar.barTintColor = [UIColor whiteColor];
    self.tabBar.tintColor = [UIColor blackColor];
    
    NSArray *listOfItems = self.tabBar.items;
    for(UITabBarItem *item in listOfItems) {
        
        NSString * iconName;
        NSString * iconNameLighter;
        
        switch ([listOfItems indexOfObject:item]) {
            case 0:
                iconName = @"homeButton";
                iconNameLighter = @"homeButtonGrayed";
                break;
            case 1:
                iconName = @"archiveButton";
                iconNameLighter = @"archiveButtonGrayed";
                break;
            case 2:
                iconName = @"ideaButton";
                iconNameLighter = @"ideaButtonGrayed";
                break;
            default:
                iconName = @"menuButton";
                iconNameLighter = @"menuButtonGrayed";
                break;
        }
        
        //Tab bar item selected
        UIImage *tabBarIcon = [[UIImage imageNamed:iconName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        item.selectedImage = tabBarIcon;
        
        ////Tab bar item unselected
        UIImage *tabBarIconLighter = [[UIImage imageNamed:iconNameLighter] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        item.image = tabBarIconLighter;
    }
    
    //Set text of Tab Bar Items
    UIColor *grayColor = [UIColor colorWithRed:210.0f/255.0f green:210.0f/255.0f blue:210.0f/255.0f alpha:1.0f];
    
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"Impact" size:10.0f],
                                                        NSForegroundColorAttributeName : [UIColor blackColor]
                                                        } forState:UIControlStateSelected];
    
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"Impact" size:10.0f],
                                                        NSForegroundColorAttributeName : grayColor
                                                        } forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIInterfaceOrientationMask)tabBarControllerSupportedInterfaceOrientations:(UITabBarController *)tabBarController {
    //Prevent from rotating
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark <UITabBarControllerDelegate>

- (id<UIViewControllerAnimatedTransitioning>)tabBarController:(UITabBarController *)tabBarController animationControllerForTransitionFromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    
    PicPranckViewControllerAnimatedTransitioning *vcAnimTrans = [[PicPranckViewControllerAnimatedTransitioning alloc]  initWithtabBarController:self andIndex:tabBarController.selectedIndex];
    
    return vcAnimTrans;
}

@end
