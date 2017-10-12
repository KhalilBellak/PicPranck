//
//  PicPranckImageServices.m
//  PicPranck
//
//  Created by El Khalil Bellakrid on 21/02/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//
//View controllers
#import "ViewController.h"
//Services
#import "PicPranckImageServices.h"
//PicPranck objects
#import "PicPranckTextView.h"
#import "PicPranckActivityItemProvider.h"
#import "PicPranckImage.h"

#include "Constants.h"

#pragma mark -
@implementation PicPranckImageServices

+ (NSMutableDictionary *)dicOfSizes {
    
    static NSMutableDictionary *dict = nil;
    
    if (!dict) {
        //Dictionary for size for every application
        dict= [[NSMutableDictionary alloc] init];
        [dict setValue:[NSValue valueWithCGSize:CGSizeMake(1000, 1000)]
                       forKey:@"WhatsApp"];
        [dict setValue:[NSValue valueWithCGSize:CGSizeMake(300, 1000)]
                       forKey:@"Facebook"];
        [dict setValue:[NSValue valueWithCGSize:CGSizeMake(300, 400)]
                       forKey:@"iMessage"];
        [dict setValue:[NSValue valueWithCGSize:CGSizeMake(400, 400)]
                forKey:@"Preview"];
    }
    
    return dict;
}

#pragma mark Set Image methods

+(void)setImage:(UIImage *)iImage forPicPranckTextView:(PicPranckTextView *)pPTextView inViewController: (ViewController *)viewController {
    
    [PicPranckImageServices setImage:iImage forImageView:pPTextView.imageView];
    [pPTextView.imageView bringSubviewToFront:pPTextView];
    [pPTextView.imageView bringSubviewToFront:pPTextView.gestureView];
    if(!pPTextView.edited)
        [pPTextView setText:@""];
}

+(void)setImage:(UIImage *)iImage forImageView:(UIImageView *)iImageView {
    
    iImageView.backgroundColor = [UIColor blackColor];
    [iImageView setContentMode:UIViewContentModeScaleAspectFit];
    iImageView.clipsToBounds = YES;
    [iImageView setImage:iImage];
    
}

+(void)setImageAreasWithImages:(NSMutableArray *)listOfImages inViewController: (ViewController *)viewController {
    
    for(UIImage *currImage in listOfImages) {
        
        NSInteger iIndex = [listOfImages indexOfObject:currImage];
        PicPranckTextView *textViewToSet = [viewController.listOfTextViews objectAtIndex:iIndex];
        [textViewToSet setText:@""];
        [PicPranckImageServices setImage:currImage forPicPranckTextView:textViewToSet inViewController:viewController];
        
    }
    
}

#pragma mark Send Picture

+(void)sendPicture:(ViewController *)viewController {
    
    if(USE_ACTIVITY_VIEW_CONTROLLER) {
        
        //Put first image of areas in message so provider knows which type of object will be sent
        PicPranckActivityItemProvider *message = [[PicPranckActivityItemProvider alloc] initWithPlaceholderItem:[viewController getImageOfAreaOfIndex:0]];
        
        message.viewController = viewController;
        
        NSMutableArray *activityItems = [[NSMutableArray alloc] init];
        [activityItems addObject:message];
        
        //Set activity view controller
        viewController.activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
        viewController.activityViewController.excludedActivityTypes = @[UIActivityTypeMail,UIActivityTypePostToTwitter,UIActivityTypePostToWeibo,UIActivityTypePrint,                                                         UIActivityTypeCopyToPasteboard,UIActivityTypeAssignToContact,UIActivityTypePostToFacebook,                                                        UIActivityTypeSaveToCameraRoll,UIActivityTypeAddToReadingList,                                                         UIActivityTypePostToFlickr,UIActivityTypePostToVimeo,                                                         UIActivityTypePostToTencentWeibo,UIActivityTypeAirDrop,
                                                          @"com.apple.mobilenotes.SharingExtension"];
        
        //Present it
        [viewController presentViewController:viewController.activityViewController animated:YES completion:nil];
        
    }
    else {
        /////////////////////////////////
        //DEPRECATED/////////////////////
        /////////////////////////////////
        if ([[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString:@"whatsapp://app"]]) {
            
            NSString    * savePath  = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/whatsAppTmp.png"];

            [UIImageJPEGRepresentation([viewController getImageOfAreaOfIndex:0], 1.0) writeToFile:savePath atomically:YES];
            
            viewController.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:savePath]];
            
            viewController.documentInteractionController.UTI = @"net.whatsapp.image";
            viewController.documentInteractionController.delegate = viewController;
            
            [viewController.documentInteractionController presentOpenInMenuFromRect:CGRectMake(0, 0, 0, 0) inView:viewController.view animated: YES];
        }
        //////////////////////////////////
    }
}

#pragma mark Generate Picture for sharing

+(UIImage *)generateImageToSend:(ViewController *)viewController {
    
    //Create clones of UIImageViews and UITextViews with right "application" sizes that we'll snapshot and send
    CGSize sizesForApp = [[[PicPranckImageServices dicOfSizes] objectForKey:viewController.activityType] CGSizeValue];
    
    NSMutableArray *listOfTextViewsClones = [[NSMutableArray alloc] init];
    NSMutableArray *listOfImageViewsClones = [[NSMutableArray alloc] init];
    NSMutableArray *listOfSizes = [[NSMutableArray alloc] init];
    NSMutableArray *listOfImages = [[NSMutableArray alloc] init];
    
    //Clone UIImageViews
    NSInteger maxWidth = 0,maxHeight = 0,totalHeight = 0,totalWidth = 0;
    CGFloat x = 0.0,y = 0.0;
    UIImage *blackImage = nil;
    for(PicPranckTextView *currTextView in viewController.listOfTextViews) {
        
        UIImageView *currImageView = currTextView.imageView;
        UIImage *currImage = currImageView.image;
        UIView *stackView = [currTextView.imageView superview];
        
        if(0 == [viewController.listOfTextViews indexOfObject:currTextView]) {
            //Get origin of container view
            x = stackView.frame.origin.x;
            y = stackView.frame.origin.y;
        }
        
        CGSize size= CGSizeMake(currImageView.frame.size.width, currImageView.frame.size.height);
        [listOfSizes addObject:[NSValue valueWithCGSize:size]];

        //If image nil replace it by a black image
        if(!currImage) {
            
            if(!blackImage) {
                
                CGSize imageSize = CGSizeMake(300,300);
                blackImage = [PicPranckImageServices generateBlackImageWithSize:imageSize];
                currImage = blackImage;
            }
            
            [PicPranckImageServices setImage:blackImage forPicPranckTextView:currTextView inViewController:viewController];

        }
        
        if(0 == maxWidth || maxWidth < currImage.size.width)
            maxWidth = currImage.size.width;
        if(0 == maxHeight || maxHeight < currImage.size.height)
            maxHeight = currImage.size.height;
        
        //Clone UIImage View and Text View
        UIImageView *imageViewClone = [[UIImageView alloc] init];
        imageViewClone.frame = [stackView convertRect:currImageView.frame toView:viewController.view];
        [listOfImages addObject:currImage];
        
        PicPranckTextView *textViewClone = [[PicPranckTextView alloc] init];
        [PicPranckTextView copyTextView:currTextView inOtherTextView:textViewClone withImageView:imageViewClone];
        
        [textViewClone.layer setBorderWidth:0.0f];
        textViewClone.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        //Keep clones in array for later use
        [listOfTextViewsClones addObject:textViewClone];
        [listOfImageViewsClones addObject:imageViewClone];
        
    }
    
    //Creation of UIImageView which will contain all UIImageViews for later print
    UIImageView *imageViewContainer = [[UIImageView alloc] init];
    [imageViewContainer setBackgroundColor:[UIColor clearColor]];
    imageViewContainer.clipsToBounds = YES;
    
    //Put all views in imageViewContainer and reframe if necessary
    for(PicPranckTextView *currTextView in listOfTextViewsClones) {
        
        NSInteger indexOfCurrObject = [listOfTextViewsClones indexOfObject:currTextView];
        UIImageView *currImageView = currTextView.imageView;
        
        //Ratio of resize
        CGFloat ratio = 0.0;
        if(0 < currImageView.frame.size.width)
            ratio = sizesForApp.width/currImageView.frame.size.width;
        
        //CGRect oldFrameImageView=currImageView.frame;
        CGRect newFrameImageView = CGRectMake(0,totalHeight,sizesForApp.width,sizesForApp.height);
        
        //Keep old frame for preview
        if([viewController.activityType isEqualToString:@"Preview"]) {
            
            if(indexOfCurrObject < [listOfSizes count]) {
                
                CGSize oldSize = [[listOfSizes objectAtIndex:indexOfCurrObject] CGSizeValue];
                newFrameImageView = CGRectMake(0,totalHeight,oldSize.width,oldSize.height);
                totalWidth = oldSize.width;
            
            }
            
            ratio = 1;
        }
        
        currImageView.frame = newFrameImageView;
        
        //Set new font based on ratio of resize
        CGFloat oldFontSize = currTextView.font.pointSize;
        [currTextView setFont:[UIFont fontWithName:@"Impact" size:ratio*oldFontSize]];
        
        //Make background black and opaque
        [currImageView setBackgroundColor:[UIColor blackColor]];
        currImageView.alpha = 1;
        
        //Add to the container
        [imageViewContainer addSubview:currImageView];
        [imageViewContainer bringSubviewToFront:currImageView];
        
        //Keep old frame for preview
        if([viewController.activityType isEqualToString:@"Preview"])
            totalHeight += currImageView.frame.size.height;
        else
            totalHeight += sizesForApp.height;
        
    }
    
    //We need an additional black image at the bottom for Whatsapp
    if([viewController.activityType isEqualToString:@"WhatsApp"]) {
        
        CGSize imageSize = CGSizeMake(sizesForApp.width,sizesForApp.height);
        UIImage *blackImage = [PicPranckImageServices generateBlackImageWithSize:imageSize];
        UIImageView *blackImageView = [[UIImageView alloc] init];
        CGRect frame = CGRectMake(0,totalHeight,sizesForApp.width,sizesForApp.height);
        blackImageView.frame = frame;
        [blackImageView setImage:blackImage];
        [imageViewContainer addSubview:blackImageView];
        totalHeight += sizesForApp.height;
    }
    
    //Container width
    CGFloat containerWidth = 0.0;
    if([viewController.activityType isEqualToString:@"Preview"])
        containerWidth = totalWidth;
    else
        containerWidth = sizesForApp.width;
    
    CGSize size = CGSizeMake(containerWidth,totalHeight);
    CGRect newFrame = CGRectMake(x,y,size.width,size.height);
    imageViewContainer.frame = newFrame;
    
    //Now that all operations of image and text views resize are done, we can set images
    for(PicPranckTextView *currTextView in listOfTextViewsClones) {
        
        NSInteger indexOfCurrObject = [listOfTextViewsClones indexOfObject:currTextView];
        UIImage *currImg = [listOfImages objectAtIndex:indexOfCurrObject];
        [PicPranckImageServices setImage:currImg forImageView:currTextView.imageView];

    }
    

    //Generate final image to send
    
    CGFloat screenScale = [UIScreen mainScreen].scale;
    UIGraphicsBeginImageContextWithOptions(imageViewContainer.bounds.size, NO, screenScale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    [imageViewContainer.layer renderInContext:context];
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    viewController.ppImage = finalImage;
    
    return finalImage;
}

+(UIImage *)generateBlackImageWithSize:(CGSize)size {
    
    UIColor *fillColor = [UIColor blackColor];
    UIGraphicsBeginImageContextWithOptions(size, YES, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [fillColor setFill];
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
    UIImage *blackImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return blackImage;
}

#pragma mark Methods for Image manipulations

+(PicPranckImage*)drawImageInBounds:(CGRect)bounds inPicPranckImage:(PicPranckImage *)ppImage {
    
    CGFloat angle = 0.0;
    
    switch(ppImage.originalImageOrientation) {
        case UIImageOrientationRight:
            angle = 90*M_PI/180;
            break;
        case UIImageOrientationLeft:
            angle -= 90*M_PI/180;
            break;
        case UIImageOrientationDown:
            angle = M_PI;
            break;
        default:
            angle = 0;
            break;
    }
    
    //Get size of rotated image
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,bounds.size.width, bounds.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(angle);
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
    //Create the context
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //Move origin of context to center
    CGContextTranslateCTM(context, rotatedSize.width/2, rotatedSize.height/2);
    
    //Now easy to rotate
    CGContextRotateCTM (context,angle);
    
    //Move back the origin and draw image
    [ppImage drawInRect: CGRectMake(-bounds.size.width / 2, -bounds.size.height / 2, bounds.size.width, bounds.size.height)];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //Return the PicPranckImage
    PicPranckImage *ppResizedImage = [[PicPranckImage alloc] initWithImage:image ];
    
    return ppResizedImage;
}

+(UIImage *)croppedImage:(UIImage *)image withRect:(CGRect)rect {
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect drawRect = CGRectMake(-rect.origin.x, -rect.origin.y, image.size.width, image.size.height);
    CGContextClipToRect(context, CGRectMake(0, 0, rect.size.width, rect.size.height));
    [image drawInRect:drawRect];
    UIImage* subImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return subImage;
}

+(CGImageRef)CGImageWithCorrectOrientationFromImage:(UIImage *)image
{
    if (image.imageOrientation == UIImageOrientationDown) {
        //retaining because caller expects to own the reference
        CGImageRetain([image CGImage]);
        return [image CGImage];
    }
    
    UIGraphicsBeginImageContext(image.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (image.imageOrientation == UIImageOrientationRight) {
        CGContextRotateCTM (context, 90 * M_PI/180);
    } else if (image.imageOrientation == UIImageOrientationLeft) {
        CGContextRotateCTM (context, -90 * M_PI/180);
    } else if (image.imageOrientation == UIImageOrientationUp) {
        CGContextRotateCTM (context, 180 * M_PI/180);
    }
    
    [image drawAtPoint:CGPointMake(0, 0)];
    
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    UIGraphicsEndImageContext();
    
    return cgImage;
}

#pragma mark Generate image for background coloring

+(UIImage *)getImageForBackgroundColoringWithSize:(CGSize)targetSize withDarkMode:(BOOL)darkMode {
    
    NSString *imageName=@"backGroundImage";
    if(darkMode)
        imageName=@"backGroundImageDarker";
    
    PicPranckImage *ppBackGround=[[PicPranckImage alloc] initWithImage:[UIImage imageNamed:imageName]];
    return [ppBackGround imageByScalingProportionallyToSize:targetSize];
    
}

#pragma mark Colors

//182 192 247 Purple
//207 213 247 Blue
+(UIColor *)getGlobalTintWithLighterFactor:(NSInteger)factor {
    return [UIColor colorWithRed:(207.0f+factor)/255.0f
                           green:(213.0f+factor)/255.0f
                            blue:(247.0f+factor)/255.0f
                           alpha:1.0f];
}

@end

