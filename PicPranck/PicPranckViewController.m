//
//  PicPranckViewController.m
//  PicPranck
//
//  Created by El Khalil Bellakrid on 14/02/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//
#import "AppDelegate.h"
//View Controllers
#import "PicPranckViewController.h"
//Services
#import "PicPranckCoreDataServices.h"
#import "PicPranckImageServices.h"
//PicPranck objects
#import "PicPranckCollectionViewCell.h"
#import "PicPranckImageView.h"


#pragma mark -
@implementation PicPranckViewController

#pragma mark PicPranckViewController

-(id)initModalView {
    
    self = [self init];
    
    if(self) {
        
        //Modal mode
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        
        //Background clear
        [self.view setBackgroundColor:[UIColor clearColor]];
        
        //Blur effect
        UIVisualEffect *blurEffect;
        blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *visualEffectView;
        visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        visualEffectView.frame=self.view.frame;
        [self.view insertSubview:visualEffectView atIndex:0];
        
        //Add tap gesture (to also dismiss VC)
        UITapGestureRecognizer *tapReco = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(taped:)];
        [self.view addGestureRecognizer:tapReco];
        
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSManagedObjectContext *managedObjCtx = [PicPranckCoreDataServices managedObjectContext:NO fromViewController:nil];
    [managedObjCtx reset];
}

#pragma mark - Actions

-(void)taped:(id)sender {
    [self.delegate dismissModalViewController];
}


@end
