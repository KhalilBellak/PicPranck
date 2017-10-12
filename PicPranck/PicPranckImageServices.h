//
//  PicPranckImageServices.h
//  PicPranck
//
//  Created by El Khalil Bellakrid on 21/02/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class ViewController;
@class PicPranckTextView;
@class PicPranckImage;

@interface PicPranckImageServices : NSObject

//Dictionary with sizes to adapt prank to each App used to send PPs
+ (NSMutableDictionary *)dicOfSizes;

//Generate image to send from "Create" tab
+(UIImage *)generateImageToSend:(ViewController *)viewController;
+(UIImage *)generateBlackImageWithSize:(CGSize)size;

//Triggered when send button touched
+(void)sendPicture:(ViewController *)viewController;

//Setters of images in areas or image views
+(void)setImage:(UIImage *)iImage forPicPranckTextView:(PicPranckTextView *)pPTextView inViewController: (ViewController *)viewController;
+(void)setImage:(UIImage *)iImage forImageView:(UIImageView *)iImageView;
+(void)setImageAreasWithImages:(NSMutableArray *)listOfImages inViewController: (ViewController *)viewController;

+(PicPranckImage*)drawImageInBounds:(CGRect)bounds inPicPranckImage:(PicPranckImage *)ppImage;
+(UIImage *)croppedImage:(UIImage *)image withRect:(CGRect)rect;
+(CGImageRef)CGImageWithCorrectOrientationFromImage:(UIImage *)image;

+(UIImage *)getImageForBackgroundColoringWithSize:(CGSize)targetSize withDarkMode:(BOOL)darkMode;
+(UIColor *)getGlobalTintWithLighterFactor:(NSInteger)factor;
@end
