//
//  PicPranckViewController.h
//  PicPranck
//
//  Created by El Khalil Bellakrid on 14/02/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//
//  
#import <UIKit/UIKit.h>

//View Controller used mainly as modal view for preview in collections view

//Delegation (allows view controller delegate to dismiss modal VC)
@protocol PicPranckModalViewDelegate < NSObject >
-(void)dismissModalViewController;
@end

@interface PicPranckViewController : UIViewController

//Atributes
@property (weak, nonatomic) id<PicPranckModalViewDelegate> delegate;

-(id)initModalView;

@end


