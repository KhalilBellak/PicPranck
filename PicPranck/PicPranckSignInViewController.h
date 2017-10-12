//
//  PicPranckSignInViewController.h
//  PicPranck
//
//  Created by El Khalil Bellakrid on 16/03/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PicPranckSignInViewController : UIViewController

//Components of view where we select type of log: Email or Facebook

@property (strong, nonatomic) IBOutlet UIButton *facebookButton;
- (IBAction)logInWithFacebook:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *emailButton;
- (IBAction)logInWithEmail:(id)sender;


//Componenets of view where:

@property (strong, nonatomic) IBOutlet UIView *containerEmailLogInView;

@property (strong, nonatomic) IBOutlet UIButton *backButton;

- (IBAction)cancelView:(id)sender;

@property (strong, nonatomic) IBOutlet UITextField *emailTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;

////we sign in with email

@property (strong, nonatomic) IBOutlet UIButton *signUpButton;
- (IBAction)signUpWithEmail:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *logInButton;
- (IBAction)didTapEmailLogin:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *forgotPassButton;
- (IBAction)didRequestPasswordReset:(id)sender;

////we sign up with email
@property (strong, nonatomic) IBOutlet UIView *emailSignUpView;
@property (strong, nonatomic) IBOutlet UIButton *submitButton;
- (IBAction)submit:(id)sender;


@end
