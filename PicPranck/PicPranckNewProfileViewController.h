//
//  PicPranckNewProfileViewController.h
//  PicPranck
//
//  Created by El Khalil Bellakrid on 24/05/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface PicPranckNewProfileViewController : UIViewController<MFMailComposeViewControllerDelegate>

//View which holds profile picture and username
@property (strong, nonatomic) IBOutlet UIView *backGroungView;
@property (strong, nonatomic) IBOutlet UIImageView *profilePicture;
@property (strong, nonatomic) IBOutlet UILabel *userName;

//View which holds Log Out, Flush and Share buttons
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
- (IBAction)logOutAction:(id)sender;
- (IBAction)flushPicPranksAction:(id)sender;
- (IBAction)shareWithFBAction:(id)sender;
- (IBAction)shareWithEmail:(id)sender;
-(void)logOut;
-(void)removeAll;

//Title and Description of sharing email or message on FB
+(NSString *)getTitle;
+(NSString *)getDescription;

@end
