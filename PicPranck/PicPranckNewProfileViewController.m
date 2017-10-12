//
//  PicPranckNewProfileViewController.m
//  PicPranck
//
//  Created by El Khalil Bellakrid on 24/05/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//
//View Controllers
#import "PicPranckNewProfileViewController.h"
#import "TabBarViewController.h"
//Extensions
#import "UIViewController+Alerts.h"
#import "UIImageView+AFNetworking.h"
//Services
#import "PicPranckCustomViewsServices.h"
#import "PicPranckImageServices.h"
#import "PicPranckCoreDataServices.h"
#import "PicPranckEncryptionServices.h"
//Pods
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
@import Firebase;

#pragma mark -
@implementation PicPranckNewProfileViewController

#pragma mark UIViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //User's info: profile picture and Username
    [self setProfileNameAndPicture];
    
    //Background
    UIImage *imgBackground = [PicPranckImageServices getImageForBackgroundColoringWithSize:CGSizeMake(self.view.frame.size.width/2,self.view.frame.size.height/2) withDarkMode:NO];
    [self.backGroungView setBackgroundColor:[UIColor colorWithPatternImage:imgBackground]];
    
    UIImage *imgBackgroundDarker = [PicPranckImageServices getImageForBackgroundColoringWithSize:CGSizeMake(self.view.frame.size.width/2,self.view.frame.size.height/2) withDarkMode:YES];
    
    [self.scrollView setBackgroundColor:[UIColor colorWithPatternImage:imgBackgroundDarker]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)setProfileNameAndPicture
{
    [PicPranckCustomViewsServices setViewDesign:_profilePicture];
    
    _profilePicture.layer.cornerRadius = _profilePicture.frame.size.height/2;
    _profilePicture.clipsToBounds = YES;
    
    //Default values
    NSAttributedString *defaultUserName = [PicPranckCustomViewsServices getAttributedStringWithString:@"User Name" withFontSize:19.0];
    UIImage *defaultImage = [UIImage imageNamed:@"profilePicture"];
    
    //Hide views
    [_userName setAlpha:0];
    
    //Check if profile picture was not cached
    NSString *pathToCacheDirectory = [PicPranckEncryptionServices getOrCreateLocalUserStorage];
    NSString *local = [NSString stringWithFormat:@"%@/profilePicture.png",pathToCacheDirectory];
    NSString *localUserName = [NSString stringWithFormat:@"%@/userName.txt",pathToCacheDirectory];
    
    NSURL *localURL = [NSURL fileURLWithPath:local];
    NSURL *localURLName = [NSURL fileURLWithPath:localUserName];
    
    NSNumber *isAFile;
    NSError *err;
    NSData *cachedData = [NSData dataWithContentsOfURL:localURL];
    [localURL getResourceValue:&isAFile
                        forKey:NSURLFileResourceTypeKey error:&err];
    
    
    // If not cached, download it
    if(0>=isAFile && !cachedData) {
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
            //Set User's name and picture
            if ([FBSDKAccessToken currentAccessToken]) {
                [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{ @"fields" : @"id,name,picture.width(100).height(100)"}] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                    if (!error) {
                        //Set User's name
                        NSString *nameOfLoginUser = [result valueForKey:@"name"];
                        NSAttributedString *blockUserName;
                        if(0<[nameOfLoginUser length])
                            blockUserName = [PicPranckCustomViewsServices getAttributedStringWithString:nameOfLoginUser withFontSize:19.0];
                        else
                            blockUserName = defaultUserName;
                        
                        [[nameOfLoginUser dataUsingEncoding:NSUTF8StringEncoding] writeToURL:localURLName  atomically:YES];
                        //Set Profile's picture
                        NSString *imageStringOfLoginUser = [[[result valueForKey:@"picture"] valueForKey:@"data"] valueForKey:@"url"];
                        NSURL *url = [[NSURL alloc] initWithString:imageStringOfLoginUser];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            [_profilePicture setImageWithURL:url placeholderImage: defaultImage];
                            //Write to local url
                            [[NSData dataWithContentsOfURL:url] writeToURL:localURL  atomically:YES];
                            
                            [_userName setAttributedText:blockUserName];
                            [_userName setAlpha:1];
                        });
                        
                    }
                    else {
                        [_profilePicture setImage:defaultImage];
                        [_userName setAttributedText:defaultUserName];
                        [_userName setAlpha:1];
                    }
                }];
            }
            else{
                //TODO: handle user name when logging with email
                [_profilePicture setImage:defaultImage];
            }
        });
    }
    else if(localURL) {
        [_profilePicture setImageWithURL:localURL placeholderImage: [UIImage imageNamed:@"profilePicture"]];
        NSAttributedString *userName = nil;
        NSError *err = nil;
        NSStringEncoding *enc = nil;
        NSString *sUserName = [NSString stringWithContentsOfURL:localURLName usedEncoding:enc error:&err];
        if(0<[sUserName length])
            userName = [PicPranckCustomViewsServices getAttributedStringWithString:sUserName withFontSize:19.0];
        [_userName setAttributedText:userName];
        [_userName setAlpha:1];
    }

}

#pragma mark <MFMailComposeViewControllerDelegate>

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    // Check the result or perform other tasks.
    
    // Dismiss the mail compose view controller.
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Actions: Log Out, Flush and Share (with Email and FB)

- (IBAction)logOutAction:(id)sender {
    [self showMessagePrompt:@"Do you really want to Log out from PickPrank ?" withActionBlockOfType:@"Log out"];
}

-(void)logOut {
    
    //User's already logged in once
    //[PicPranckEncryptionServices setAsFirstLogIn:NO];
    
    FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
    [loginManager logOut];
    NSError *signOutError;
    BOOL status = [[FIRAuth auth] signOut:&signOutError];
    if (!status) {
        NSLog(@"Error signing out: %@", signOutError);
    }
    [self performSegueWithIdentifier:@"logOut" sender:self];
    
}

- (IBAction)flushPicPranksAction:(id)sender {
    [self showMessagePrompt:@"Do you really want to delete all PickPranks ?" withActionBlockOfType:@"Remove all"];
}

-(void)removeAll {
    
    [PicPranckCoreDataServices removeAllImages:self];
    TabBarViewController *tabBarVC = [PicPranckCoreDataServices getTabBarVCFromVC:self];
    //Let know other views that we've just wiped out all data (to re-initialize MOC)
    if(tabBarVC)
        tabBarVC.allPicPrancksRemovedMode=YES;
    
}

- (IBAction)shareWithFBAction:(id)sender {
    
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.contentURL = [NSURL URLWithString:@"http://pickprank-app.com/"];
    [FBSDKMessageDialog showWithContent:content delegate:nil];
    
}

- (IBAction)shareWithEmail:(id)sender {
    
    if([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailVC = [[MFMailComposeViewController alloc] init];
        [mailVC setMailComposeDelegate:self];
        
        // Configure the fields of the interface.
        [mailVC setSubject:[PicPranckNewProfileViewController getTitle]];
        [mailVC setMessageBody:[PicPranckNewProfileViewController getDescription] isHTML:YES];
        
        // Present the view controller modally.
        [self presentViewController:mailVC animated:YES completion:nil];
    }
    else
        [self showMessagePrompt:@"Mail services are not available !"];
    
}

+(NSString *)getTitle {
    return @"Let the troll inside you take over! ";
}

+(NSString *)getDescription {
    
    NSString *string1 = @"Hello !";
    NSString *string2 = @"Here is my application to create customizable PickPranks: ";
    NSString *string3 = @"http://pickprank-app.com/";
    NSString *desc = [NSString stringWithFormat:@"%@\r%@\r%@",string1,string2,string3];
    
    return desc;
}

@end
