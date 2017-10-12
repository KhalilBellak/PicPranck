//
//  ViewController.m
//  PicPranck
//
//  Created by El Khalil Bellakrid on 22/01/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//
#import <objc/runtime.h>
#import "AppDelegate.h"
//View Controllers
#import "ViewController.h"
#import "PicPranckViewController.h"
//PicPranck Objects
#import "PicPranckTextView.h"
#import "PicPranckActivityItemProvider.h"
#import "PicPranckAppPresentationView.h"
//Services
#import "PicPranckImageServices.h"
#import "PicPranckCoreDataServices.h"
#import "PicPranckCustomViewsServices.h"
#import "PicPranckEncryptionServices.h"
//Extensions
#import "UIViewController+Alerts.h"
#define MAXIMUM_DATA_SIZE 250000

#pragma mark -

@implementation ViewController

#pragma mark Synthetizing

@synthesize listOfTextViews=_listOfTextViews;
@synthesize  activityViewController=_activityViewController;
@synthesize activityType=_activityType;
@synthesize documentInteractionController=_documentInteractionController;

#pragma mark UIViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //Create or get user's infos
    [PicPranckEncryptionServices getOrCreateSaltyKey:[FIRAuth auth].currentUser fromViewController:self];
    
    //Attributes
    _activityType = @"";
    _listOfTextViews = [[NSMutableArray alloc] init];
    listOfGestureViews = [[NSMutableArray alloc] init];
    
    //View that will move when keyboard appears
    [viewToMoveForKeyBoardAppearance bringSubviewToFront:areasStackView];
    
    //Buttons' design: Delete, Save and Send
    [self setButtons];
    
    //Global tint
    [self.view setTintColor:[PicPranckImageServices getGlobalTintWithLighterFactor:0]];
    globalTint = [self.view tintColor];
    
    //Initialize image's areas
    [self initializeAreas:YES];
    
    //Add self as observer of Keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
    //Background
    UIImage *imgBackground = [PicPranckImageServices getImageForBackgroundColoringWithSize:CGSizeMake(self.view.frame.size.width/2,self.view.frame.size.height/2) withDarkMode:NO];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:imgBackground]];
    
}

- (void)viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
    
    NSArray *listOfImageViews = [[NSArray alloc] initWithObjects:imageViewArea1,imageViewArea2,imageViewArea3,nil];
    if([listOfImageViews count] != [_listOfTextViews count])
        return;
    
    //Update Text view and gesture views frames
    for(UIImageView *currImageView in listOfImageViews) {
        
        PicPranckTextView *currTextView = [_listOfTextViews objectAtIndex:[listOfImageViews indexOfObject:currImageView]];
        CGRect newFrame = CGRectMake(0,0,currImageView.frame.size.width,currImageView.frame.size.height);
        currTextView.frame = newFrame;
        currTextView.gestureView.frame = newFrame;
        
    }
    
}

-(void)viewWillDisappear:(BOOL)animated {
    //Remove observer
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

#pragma mark Design of buttons and areas

-(void)setButtons {
    [self setButton:@"Reset"];
    [self setButton:@"Save"];
    [self setButton:@"Send"];
    [self.view bringSubviewToFront:buttonsStackView];
}

-(void)setButton:(NSString *)nameOfButton {
    
    UIButton *button = resetButton;

    if([nameOfButton isEqualToString:@"Send"])
        button = buttonSend;
    else if([nameOfButton isEqualToString:@"Save"])
        button = saveButton;
    
    button.clipsToBounds = YES;
    [button setTitle:@"" forState:UIControlStateNormal];
    [buttonsStackView bringSubviewToFront:button];
    
}

-(void) initializeAreas:(BOOL)firstInitialization {
    
    NSArray *listOfImageViews = [[NSArray alloc] initWithObjects:imageViewArea1,imageViewArea2,imageViewArea3,nil];
    if(!firstInitialization && ([listOfImageViews count] != [_listOfTextViews count]))
        return;
    
    for(UIImageView *currImageView in listOfImageViews) {
        
        //Image content mode
        currImageView.clipsToBounds = YES;
        currImageView.contentMode = UIViewContentModeScaleAspectFit;
        
        //Initialization of PicPranckTextViews (text, layout ....)
        NSInteger iIndex = [listOfImageViews indexOfObject:currImageView];
        currImageView.tag = iIndex;

        NSString *text = @"";
        PicPranckTextView *currTextView = nil;
        
        //When hitting reset button should set images to nil and background to clear
        currImageView.image = nil;
        [currImageView setBackgroundColor:[UIColor clearColor]];
        
        //Create or get the text view
        if(firstInitialization)
            currTextView = [[PicPranckTextView alloc] init];
        else
            currTextView = [_listOfTextViews objectAtIndex:iIndex];
        
        [currTextView initWithDelegate:self ImageView:currImageView AndText:text];
        
        //If first initializiation, add Gesture Recognizers to gestureView
        if(firstInitialization) {
            
            currTextView.edited = NO;
            
            //Add gesture Recognizers
            
            ////Tap once to camera
            UITapGestureRecognizer *tapOnce = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnce:)];
            tapOnce.cancelsTouchesInView = NO;
            tapOnce.numberOfTouchesRequired = 1;
            [currTextView.gestureView addGestureRecognizer:tapOnce];
            
            ////Tap twice to edition
            UITapGestureRecognizer *tapTwice = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapTwice:)];
            tapTwice.cancelsTouchesInView = NO;
            tapTwice.numberOfTapsRequired = 2;
            [tapOnce requireGestureRecognizerToFail:tapTwice];
            [currTextView.gestureView addGestureRecognizer:tapTwice];
            
            [_listOfTextViews addObject:currTextView];
        }
        
        [listOfGestureViews addObject:currTextView.gestureView];
        [areasStackView bringSubviewToFront:currImageView];
    }
}

#pragma mark Camera and Galery Actions

-(void)imagePickerController:(UIImagePickerController *)iPicker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    NSString *key = @"UIImagePickerControllerOriginalImage";
    
    //Get image from UIImagePickerController
    UIImage *imageFromPicker = [info objectForKey:key];

    //Set it in the right image view
    [PicPranckImageServices setImage:imageFromPicker forPicPranckTextView:tapedTextView inViewController:self];
    [self dismissViewControllerAnimated:TRUE completion:NULL];
    
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:TRUE completion:NULL];
}

#pragma mark Action for Gesture Recognizers

-(void) handleTapOnce: (UITapGestureRecognizer *)sender {
    
    NSInteger iIndex = [listOfGestureViews indexOfObject:sender.view];
    tapedTextView = [_listOfTextViews objectAtIndex:iIndex];
    
    if(UIGestureRecognizerStateEnded == sender.state)
    {
        tapedTextView.tapsAcquired = 1;
        //Initialize picker
        if(!picker) {
            picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
            
            CGRect frame = picker.view.frame;
            int x = frame.size.width;
            
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(x-100, 10, 100, 30)];
            [button setTitle:@"Library" forState:UIControlStateNormal];
            [button setBackgroundColor:[UIColor clearColor]];
            [button addTarget:self action:@selector(gotoLibrary:) forControlEvents:UIControlEventTouchUpInside];
            [picker.view addSubview:button];
        }
        
        [self presentViewController:picker animated:YES completion:nil];
        
    }
}

-(void) handleTapTwice: (UITapGestureRecognizer *)sender {
    
    NSInteger iIndex = [listOfGestureViews indexOfObject:sender.view];
    tapedTextView = [_listOfTextViews objectAtIndex:iIndex];
    
    if(UIGestureRecognizerStateEnded == sender.state) {
        
        tapedTextView.tapsAcquired = 2;
        if(!tapedTextView.edited)
            [tapedTextView setText:@""];
        tapedTextView.edited = YES;
        
        //Add Done button to keyboard
        UIToolbar* keyboardToolbar = [[UIToolbar alloc] init];
        [keyboardToolbar sizeToFit];
        UIBarButtonItem *flexBarButton = [[UIBarButtonItem alloc]
                                          initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                          target:nil action:nil];
        UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc]
                                          initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                          target:self action:@selector(doneButtonPressed)];
        
        keyboardToolbar.items = @[flexBarButton, doneBarButton];
        tapedTextView.inputAccessoryView = keyboardToolbar;
        tapedTextView.editable = YES;
        [tapedTextView becomeFirstResponder];
    }
    
}

#pragma mark Text View Edition methods

-(void)doneButtonPressed {
    [tapedTextView endEditing:YES];
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView {
    [textView resignFirstResponder];
    return YES;
}

-(void)textViewDidEndEditing:(UITextView *)textView {
    textView.editable = NO;
    [textView endEditing:YES];
}

- (void)keyboardDidShow:(NSNotification *)notification{
    CGRect keyboardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    [self moveViewVertically:viewToMoveForKeyBoardAppearance withTapedTextView:tapedTextView andKeyBoardFrame:keyboardFrame];
}

-(void)keyboardDidHide:(NSNotification *)notification {
    [self moveViewVertically:viewToMoveForKeyBoardAppearance toPosition:0];
}

-(void)moveViewVertically:(UIView *)iView withTapedTextView:(PicPranckTextView *) iTapedTextView andKeyBoardFrame:(CGRect) keyBoardFrame {
    
    //Get coordinates in controller's view
    CGRect imgFrameInView = [areasStackView convertRect:iTapedTextView.imageView.frame toView:self.view];
    
    CGFloat yDown = imgFrameInView.origin.y+iTapedTextView.imageView.frame.size.height;
    
    CGFloat yKeyboard = keyBoardFrame.origin.y-keyBoardFrame.size.height;
    CGFloat dY = yDown-yKeyboard;

    if(0<dY)
        [self moveViewVertically:iView toPosition:iView.frame.origin.y-dY];
    
}

-(void)moveViewVertically:(UIView *)iView toPosition:(CGFloat)y {
    
    [UIView animateWithDuration:0.1
                          delay:0.0
                        options: UIViewAnimationOptionCurveLinear
                     animations:^
     {
         CGRect frame = iView.frame;
         frame.origin.y = y;
         iView.frame = frame;
     }
                     completion:nil];
}

#pragma mark Sharing methods

- (BOOL)isWhatsApplication:(NSString *)application {
    if ([application rangeOfString:@"whats"].location == NSNotFound)
        return NO;
    else
        return YES;
}

-(void)generateImageToSendWithActivityType:(NSString *)iActivityType {
    _activityType = iActivityType;
    [PicPranckImageServices generateImageToSend:self];
}

-(UIImage *)getImageOfAreaOfIndex:(NSInteger)index {
    
    UIImage *result = nil;
    if(2<index)
        return result;
    
    id textView = [_listOfTextViews objectAtIndex:index];
    if([textView isKindOfClass:[PicPranckTextView class]]) {
        PicPranckTextView *ppTextView = (PicPranckTextView *)textView;
        result = ppTextView.imageView.image;
    }
    
    return result;
}

#pragma mark Actions: Send, Save and Reset/Delete

- (IBAction)reset:(id)sender {
    [self initializeAreas:NO];
}

- (IBAction)buttonSendClicked:(id)sender {
    
    NSInteger countOfAreasToSet = 0;
    
    NSArray *listOfImageViews = [[NSArray alloc] initWithObjects:imageViewArea1,imageViewArea2,imageViewArea3,nil];
    
    for(UIImageView *img in listOfImageViews) {
        if(!img.image)
            countOfAreasToSet++;
    }
    if(0 == countOfAreasToSet)
        [PicPranckImageServices sendPicture:self];
    else {
        NSString *message = [NSString stringWithFormat:@"Please set %ld remaining areas to send your PickPrank",(long)countOfAreasToSet];
        [self showMessagePrompt:message];
    }
    
}

-(IBAction)gotoLibrary:(id)sender {
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    [imagePicker.view setFrame:CGRectMake(0, 80, 450, 350)];
    [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    imagePicker.allowsEditing = NO;
    [imagePicker setDelegate:self];
    
    [picker presentViewController:imagePicker animated:YES completion:nil];
}

- (IBAction)performSave:(id)sender {
    
    NSArray *listOfImagesTmp = [[NSArray alloc] initWithObjects:imageViewArea1.image,imageViewArea2.image,imageViewArea3.image, nil];
    
    //Images that were not set are replaced by black images
    CGSize imageSize = CGSizeMake(imageViewArea1.frame.size.width,imageViewArea1.frame.size.height);
    UIImage *blackImage = [PicPranckImageServices generateBlackImageWithSize:imageSize];
    NSMutableArray *listOfImages = [[NSMutableArray alloc] init];
    
    for(UIImage *image in listOfImagesTmp) {
        if(image)
           [listOfImages addObject:image];
        else
            [listOfImages addObject:blackImage];
        
    }
    
    [PicPranckCoreDataServices uploadImages:listOfImages withViewController:self];
}

#pragma mark App Presentation

-(void)presentApp {
    
    //If first log in, segue to PicPranckAppPresentationViewController
    PicPranckAppPresentationView *ppAppPresentation = [[PicPranckAppPresentationView alloc] initWithFrame:self.view.frame];
    ppAppPresentation.frameForTutorial = [viewToMoveForKeyBoardAppearance convertRect:frameComplete.frame toView:self.view];
    
    [ppAppPresentation setBackgroundColor:[UIColor clearColor]];
    
    NSDictionary *dico = [PicPranckAppPresentationView dicoOfModes];
    [ppAppPresentation customizeViewWithMode:[dico valueForKey:@"0"]];
    
    [self.view addSubview:ppAppPresentation];
    [self.view bringSubviewToFront:ppAppPresentation];
    
}

@end
