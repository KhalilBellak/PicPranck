//
//  UIViewController+Alerts.m
//  PicPranck
//
//  Created by El Khalil Bellakrid on 16/03/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import "UIViewController+Alerts.h"
#import <objc/runtime.h>
#import "PicPranckProfileViewController.h"
#import "PicPranckNewProfileViewController.h"

/*! @var kPleaseWaitAssociatedObjectKey
 @brief Key used to identify the "please wait" spinner associated object.
 */

static NSString *const kPleaseWaitAssociatedObjectKey =
@"_UIViewControllerAlertCategory_PleaseWaitScreenAssociatedObject";

/*! @var kOK
 @brief Text for an 'OK' button.
 */
static NSString *const kOK = @"OK";

/*! @var kCancel
 @brief Text for an 'Cancel' button.
 */
static NSString *const kCancel = @"Cancel";

/*! @class SimpleTextPromptDelegate
 @brief A @c UIAlertViewDelegate which allows @c UIAlertView to be used with blocks more easily.
 */
@interface SimpleTextPromptDelegate : NSObject<UIAlertViewDelegate>

/*! @fn init
 @brief Please use initWithCompletionHandler.
 */
- (nullable instancetype)init NS_UNAVAILABLE;

/*! @fn initWithCompletionHandler:
 @brief Designated initializer.
 @param completionHandler The block to call when the alert view is dismissed.
 */
- (nullable instancetype)initWithCompletionHandler:(AlertPromptCompletionBlock)completionHandler
NS_DESIGNATED_INITIALIZER;

@end

@implementation UIViewController (Alerts)

/*! @fn supportsAlertController
 @brief Determines if the current platform supports @c UIAlertController.
 @return YES if the current platform supports @c UIAlertController.
 */
- (BOOL)supportsAlertController {
    return NSClassFromString(@"UIAlertController") != nil;
}

- (void)showMessagePrompt:(NSString *)message {
    if ([self supportsAlertController]) {
        UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:nil
                                            message:message
                                     preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction =
        [UIAlertAction actionWithTitle:kOK style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else
    {
//        UIAlertController *alert = [[UIAlertController alloc] initWithTitle:nil
//                                                        message:message
//                                                       delegate:nil
//                                              cancelButtonTitle:nil
//                                              otherButtonTitles:kOK, nil];
        //[alert show];
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}
-(void)showMessagePrompt:(NSString *)message withActionBlockOfType:(NSString *)type
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleActionSheet];
    __weak __typeof(self) weakSelf = self;
    //(void (^)(UIPreviewAction *action, UIViewController *previewViewController))
    NSString *okText=@"Log out";
    if([type isEqualToString:@"Remove all"])
        okText=@"Remove all";
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction* ok = [UIAlertAction actionWithTitle:okText style:UIAlertActionStyleDestructive handler:
                         ^(UIAlertAction * action) {
                             
//                             if([weakSelf isKindOfClass:[PicPranckProfileViewController class]])
//                             {
//                                 PicPranckProfileViewController *ppProfileVC=(PicPranckProfileViewController *)weakSelf;
//                                 if([type isEqualToString:@"Log out"])
//                                     [ppProfileVC logOut];
//                                 else if([type isEqualToString:@"Remove all"])
//                                     [ppProfileVC removeAll];
//                             }
                             if([weakSelf isKindOfClass:[PicPranckNewProfileViewController class]])
                             {
                                 PicPranckNewProfileViewController *ppProfileVC=(PicPranckNewProfileViewController *)weakSelf;
                                 if([type isEqualToString:@"Log out"])
                                     [ppProfileVC logOut];
                                 else if([type isEqualToString:@"Remove all"])
                                     [ppProfileVC removeAll];
                             }
                             
                         }];
    [alertController addAction:cancel];
    [alertController addAction:ok];
    
    [self presentViewController:alertController animated:YES completion:nil];
}
- (void)showTextInputPromptWithMessage:(NSString *)message
                       completionBlock:(AlertPromptCompletionBlock)completion {
    if ([self supportsAlertController]) {
        UIAlertController *prompt =
        [UIAlertController alertControllerWithTitle:nil
                                            message:message
                                     preferredStyle:UIAlertControllerStyleAlert];
        __weak UIAlertController *weakPrompt = prompt;
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:kCancel
                                                               style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction *_Nonnull action) {
                                                                 completion(NO, nil);
                                                             }];
        UIAlertAction *okAction =
        [UIAlertAction actionWithTitle:kOK
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *_Nonnull action) {
                                   UIAlertController *strongPrompt = weakPrompt;
                                   completion(YES, strongPrompt.textFields[0].text);
                               }];
        [prompt addTextFieldWithConfigurationHandler:nil];
        [prompt addAction:cancelAction];
        [prompt addAction:okAction];
        [self presentViewController:prompt animated:YES completion:nil];
    } else {
//        SimpleTextPromptDelegate *prompt =
//        [[SimpleTextPromptDelegate alloc] initWithCompletionHandler:completion];
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
//                                                            message:message
//                                                           delegate:prompt
//                                                  cancelButtonTitle:@"Cancel"
//                                                  otherButtonTitles:@"Ok", nil];
//        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
//        [alertView show];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:cancel];
        [alertController addAction:ok];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)showSpinner:(nullable void (^)(void))completion {
    if ([self supportsAlertController]) {
        [self showModernSpinner:completion];
    } else {
        [self showIOS7Spinner:completion];
    }
}

- (void)showModernSpinner:(nullable void (^)(void))completion {
    UIAlertController *pleaseWaitAlert =
    objc_getAssociatedObject(self, (__bridge const void *)(kPleaseWaitAssociatedObjectKey));
    
    if (pleaseWaitAlert) {
        
        if (completion) {
            completion();
        }
        return;
    }
    pleaseWaitAlert = [UIAlertController alertControllerWithTitle:nil
                                                          message:@"Please Wait...\n\n\n\n"
                                                   preferredStyle:UIAlertControllerStyleAlert];
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]
                                        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.color = [UIColor blackColor];
    spinner.center = CGPointMake(pleaseWaitAlert.view.bounds.size.width / 2,
                                 pleaseWaitAlert.view.bounds.size.height / 2);
    spinner.autoresizingMask =
    UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin |
    UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [spinner startAnimating];
    [pleaseWaitAlert.view addSubview:spinner];
    
    objc_setAssociatedObject(self, (__bridge const void *)(kPleaseWaitAssociatedObjectKey),
                             pleaseWaitAlert, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self presentViewController:pleaseWaitAlert animated:YES completion:completion];
}

- (void)showIOS7Spinner:(nullable void (^)(void))completion {
    UIWindow *pleaseWaitWindow =
    objc_getAssociatedObject(self, (__bridge const void *)(kPleaseWaitAssociatedObjectKey));
    
    if (pleaseWaitWindow) {
        if (completion) {
            completion();
        }
        return;
    }
    
    pleaseWaitWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    pleaseWaitWindow.backgroundColor = [UIColor clearColor];
    pleaseWaitWindow.windowLevel = UIWindowLevelStatusBar - 1;
    
    UIView *pleaseWaitView = [[UIView alloc] initWithFrame:pleaseWaitWindow.bounds];
    pleaseWaitView.autoresizingMask =
    UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    pleaseWaitView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]
                                        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    spinner.center = pleaseWaitView.center;
    [pleaseWaitView addSubview:spinner];
    [spinner startAnimating];
    
    pleaseWaitView.layer.opacity = 0.0;
    [self.view addSubview:pleaseWaitView];
    
    [pleaseWaitWindow addSubview:pleaseWaitView];
    
    [pleaseWaitWindow makeKeyAndVisible];
    
    objc_setAssociatedObject(self, (__bridge const void *)(kPleaseWaitAssociatedObjectKey),
                             pleaseWaitWindow, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [UIView animateWithDuration:0.5f
                     animations:^{
                         pleaseWaitView.layer.opacity = 1.0f;
                     }
                     completion:^(BOOL finished) {
                         if (completion) {
                             completion();
                         }
                     }];
}

- (void)hideSpinner:(nullable void (^)(void))completion {
    if ([self supportsAlertController]) {
        [self hideModernSpinner:completion];
    } else {
        [self hideIOS7Spinner:completion];
    }
}

- (void)hideModernSpinner:(nullable void (^)(void))completion {
    UIAlertController *pleaseWaitAlert =
    objc_getAssociatedObject(self, (__bridge const void *)(kPleaseWaitAssociatedObjectKey));
    
    [pleaseWaitAlert dismissViewControllerAnimated:YES completion:completion];
    
    objc_setAssociatedObject(self, (__bridge const void *)(kPleaseWaitAssociatedObjectKey), nil,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)hideIOS7Spinner:(nullable void (^)(void))completion {
    UIWindow *pleaseWaitWindow =
    objc_getAssociatedObject(self, (__bridge const void *)(kPleaseWaitAssociatedObjectKey));
    
    UIView *pleaseWaitView;
    pleaseWaitView = pleaseWaitWindow.subviews.firstObject;
    
    [UIView animateWithDuration:0.5f
                     animations:^{
                         pleaseWaitView.layer.opacity = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         [pleaseWaitWindow resignKeyWindow];
                         objc_setAssociatedObject(self, (__bridge const void *)(kPleaseWaitAssociatedObjectKey), nil,
                                                  OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                         if (completion) {
                             completion();
                         }
                     }];
}

@end

@implementation SimpleTextPromptDelegate {
    AlertPromptCompletionBlock _completionHandler;
    SimpleTextPromptDelegate *_retainedSelf;
}

- (instancetype)initWithCompletionHandler:(AlertPromptCompletionBlock)completionHandler {
    self = [super init];
    if (self) {
        _completionHandler = completionHandler;
        _retainedSelf = self;
    }
    return self;
}

//- (void)alertView:(UIAlertController *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
//{
//    
//    if (buttonIndex == alertView.actions )
//        _completionHandler(YES, [alertView textFieldAtIndex:0].text);
//    else
//        _completionHandler(NO, nil);
//    
//    _completionHandler = nil;
//    _retainedSelf = nil;
//}

@end
