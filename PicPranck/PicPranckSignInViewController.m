//
//  PicPranckSignInViewController.m
//  PicPranck
//
//  Created by El Khalil Bellakrid on 16/03/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

//View controllers
#import "PicPranckSignInViewController.h"
#import "PicPranckEmailSignInViewController.h"
//Services
#import "PicPranckImageServices.h"
#import "PicPranckCustomViewsServices.h"
#import "PicPranckEncryptionServices.h"
//Extensions
#import "UIViewController+Alerts.h"
//Pods
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
@import Firebase;
@import FirebaseAuth;

typedef enum : NSUInteger {
    AuthEmail,
    AuthAnonymous,
    AuthFacebook,
} AuthProvider;

@interface PicPranckSignInViewController ()
@property BOOL hasSegued;
@end

#pragma mark -

@implementation PicPranckSignInViewController

#pragma mark UIViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //Init attributes
    _hasSegued = NO;
    _backButton.tag = 0;
    
    //BackGround
    UIImage *imgBackground=[PicPranckImageServices getImageForBackgroundColoringWithSize:CGSizeMake(self.view.frame.size.width/2,self.view.frame.size.height/2) withDarkMode:NO];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:imgBackground]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Layout and appearance

-(UIInterfaceOrientationMask)supportedInterfaceOrientations {
    //Prevent from rotating
    return UIInterfaceOrientationMaskPortrait;
}
-(void)switchToMode:(NSInteger)mode {
    
    [UIView transitionWithView:self.view
                      duration:0.5f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        
                        //Mode 0: with email and FB connect buttons
                        if(0 == mode) {
                            
                            //Show Email and FB Log in buttons
                            [_facebookButton setHidden:NO];
                            [_emailButton setHidden:NO];
                            [self.view bringSubviewToFront:_facebookButton];
                            [self.view bringSubviewToFront:_emailButton];
                            
                            //Hide Email log in and sign up buttons
                            [_containerEmailLogInView setHidden:YES];
                            [self.view sendSubviewToBack:_containerEmailLogInView];
                            
                        }
                        //Mode 1: with log in Email
                        else if(1 == mode) {
                            
                            [self customizeTextFields];
                            
                            //Show Email log in and sign up buttons
                            [_containerEmailLogInView setHidden:NO];
                            [_logInButton setHidden:NO];
                            [_signUpButton setHidden:NO];
                            [_forgotPassButton setHidden:NO];
                            [self.view bringSubviewToFront:_containerEmailLogInView];
                            
                            //Hide Email and FB Log in buttons
                            [_facebookButton setHidden:YES];
                            [_emailButton setHidden:YES];
                            [self.view sendSubviewToBack:_facebookButton];
                            [self.view sendSubviewToBack:_emailButton];
                            
                            //Hide Submit button
                            [_emailSignUpView setHidden:YES];
                            [_containerEmailLogInView sendSubviewToBack:_emailSignUpView];
                            
                        }
                        //Mode 2: with email sign up
                        else if(2 == mode) {
                            
                            //Show Submit button
                            [_emailSignUpView setHidden:NO];
                            [_containerEmailLogInView bringSubviewToFront:_emailSignUpView];
                            [_containerEmailLogInView bringSubviewToFront:_backButton];
                            [_containerEmailLogInView bringSubviewToFront:_passwordTextField];
                            [_containerEmailLogInView bringSubviewToFront:_emailTextField];
                            //Hide Email log in and sign up buttons
                            [_logInButton setHidden:YES];
                            [_signUpButton setHidden:YES];
                            [_forgotPassButton setHidden:YES];
                            
                        }
                    } completion:nil];
    
    //Update button tag
    _backButton.tag = mode;
}

- (IBAction)cancelView:(id)sender {
    [self switchToMode:_backButton.tag-1];
}

-(void)customizeTextFields {
    
    UIToolbar *customKeyboard = [self getCustomizedKeyboard];
    
    _emailTextField.placeholder = @"Email";
    _emailTextField.inputAccessoryView = customKeyboard;
    
    _passwordTextField.placeholder = @"Password";
    _passwordTextField.inputAccessoryView = customKeyboard;
}

-(UIToolbar *)getCustomizedKeyboard {
    
    UIToolbar* keyboardToolbar = [[UIToolbar alloc] init];
    [keyboardToolbar sizeToFit];
    
    UIBarButtonItem *flexBarButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                      target:nil action:nil];
    
    UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                      target:self action:@selector(doneButtonPressed)];
    
    keyboardToolbar.items = @[flexBarButton, doneBarButton];
    return keyboardToolbar;
}

-(void)doneButtonPressed {
    if(_emailTextField.isEditing)
        [_emailTextField endEditing:YES];
    else if(_passwordTextField.isEditing)
        [_passwordTextField endEditing:YES];
}


#pragma Firebase Authentification

- (void)firebaseLoginWithCredential:(FIRAuthCredential *)credential {
    
    [self showSpinner:^{
        if ([FIRAuth auth].currentUser) {
            // [START link_credential]
            [[FIRAuth auth]
             .currentUser linkWithCredential:credential
             completion:^(FIRUser *_Nullable user, NSError *_Nullable error) {
                 [self hideSpinner:^{
                     if (error) {
                         [self showMessagePrompt:error.localizedDescription];
                         return;
                     }
                     //[PicPranckEncryptionServices getOrCreateSaltyKey:user];
                     [self performSegueWithIdentifier:@"signInSucceeded" sender:self];
                 }];
             }];
            // [END link_credential]
        }
        else {
            [[FIRAuth auth] signInWithCredential:credential
                                      completion:^(FIRUser *user, NSError *error) {
                                          [self hideSpinner:^{
                                              if (error) {
                                                  [self showMessagePrompt:error.localizedDescription];
                                                  return;
                                              }
                                              //[PicPranckEncryptionServices getOrCreateSaltyKey:user];
                                              [self performSegueWithIdentifier:@"signInSucceeded" sender:self];
                                          }];
                                      }];
        }
    }];
}

- (void)showAuthPicker: (NSArray<NSNumber *>*) providers {
    
    for (NSNumber *provider in providers) {
        
        switch (provider.unsignedIntegerValue) {
                
            case AuthEmail: {
                [self performSegueWithIdentifier:@"email" sender:nil];
            }
                break;

            case AuthFacebook: {
                
                FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
                [loginManager
                 logInWithReadPermissions:@[ @"public_profile", @"email" ]
                 fromViewController:self
                 handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                     if (error) {
                         [self showMessagePrompt:error.localizedDescription];
                     } else if (result.isCancelled) {
                         NSLog(@"FBLogin cancelled");
                     } else {
                         FIRAuthCredential *credential = [FIRFacebookAuthProvider
                                                          credentialWithAccessToken:[FBSDKAccessToken currentAccessToken]
                                                          .tokenString];
                         [self firebaseLoginWithCredential:credential];
                     }
                 }];
                
            }
                break;
                
            case AuthAnonymous: {
                [self showSpinner:^{
                    [[FIRAuth auth]
                     signInAnonymouslyWithCompletion:^(FIRUser *_Nullable user, NSError *_Nullable error) {
                         // [START_EXCLUDE]
                         [self hideSpinner:^{
                             if (error) {
                                 [self showMessagePrompt:error.localizedDescription];
                                 return;
                             }
                         }];
                     }];
                }];
            }
                break;
        }
    }
}

#pragma mark Handling Email Sign In/Up

- (IBAction)logInWithEmail:(id)sender {
    [self switchToMode:_backButton.tag+1];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}

- (IBAction)didTapEmailLogin:(id)sender {
    [self showSpinner:^{
        // [START headless_email_auth]
        [[FIRAuth auth] signInWithEmail:_emailTextField.text
                               password:_passwordTextField.text
                             completion:^(FIRUser *user, NSError *error) {
                                 // [START_EXCLUDE]
                                 [self hideSpinner:^{
                                     if (error) {
                                         [self showMessagePrompt:error.localizedDescription];
                                         return;
                                     }
                                     [self performSegueWithIdentifier:@"signInSucceeded" sender:self];
                                 }];
                                 // [END_EXCLUDE]
                             }];
    }];
}

/** @fn requestPasswordReset
 @brief Requests a "password reset" email be sent.
 */
- (IBAction)didRequestPasswordReset:(id)sender {
    [self
     showTextInputPromptWithMessage:@"Email:"
     completionBlock:^(BOOL userPressedOK, NSString *_Nullable userInput) {
         if (!userPressedOK || !userInput.length) {
             return;
         }
         
         [self showSpinner:^{
             // [START password_reset]
             [[FIRAuth auth]
              sendPasswordResetWithEmail:userInput
              completion:^(NSError *_Nullable error) {
                  // [START_EXCLUDE]
                  [self hideSpinner:^{
                      if (error) {
                          [self
                           showMessagePrompt:error
                           .localizedDescription];
                          return;
                      }
                      
                      [self showMessagePrompt:@"Sent"];
                  }];
                  // [END_EXCLUDE]
              }];
             // [END password_reset]
         }];
     }];
}

- (IBAction)signUpWithEmail:(id)sender {
    [self switchToMode:_backButton.tag+1];
}

- (IBAction)submit:(id)sender {
    [self showSpinner:^{
        // [START create_user]
        [[FIRAuth auth]
         createUserWithEmail:_emailTextField.text
         password:_passwordTextField.text
         completion:^(FIRUser *_Nullable user,
                      NSError *_Nullable error) {
             // [START_EXCLUDE]
             [self hideSpinner:^{
                 if (error) {
                     [self
                      showMessagePrompt:
                      error
                      .localizedDescription];
                     return;
                 }
                 NSLog(@"%@ created", user.email);
                 
                 //Create user's infos on Firebase 
                 //[PicPranckEncryptionServices getOrCreateSaltyKey:[FIRAuth auth].currentUser];
                 
                 [self performSegueWithIdentifier:@"signInSucceeded" sender:self];
             }];
             // [END_EXCLUDE]
         }];
    }];
}

#pragma mark Handling Facebook Sign In/Up

- (IBAction)logInWithFacebook:(id)sender {
    NSMutableArray *providers = [@[@(AuthFacebook)] mutableCopy];
    
    //    for (id<FIRUserInfo> userInfo in [FIRAuth auth].currentUser.providerData)
    //    {
    //        if ([userInfo.providerID isEqualToString:FIRFacebookAuthProviderID])
    //        {
    //            [providers removeObject:@(AuthFacebook)];
    //            //TODO: WARNING TO REMOVE AFTER FINISHING TESTS
    //            FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
    //            [loginManager logOut];
    //            NSError *signOutError;
    //            BOOL status = [[FIRAuth auth] signOut:&signOutError];
    //            if (!status) {
    //                NSLog(@"Error signing out: %@", signOutError);
    //            }
    //            [providers addObject:@(AuthFacebook)];
    //        }
    //    }
    [self showAuthPicker:providers];
}


@end
