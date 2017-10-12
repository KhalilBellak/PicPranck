//
//  PicPranckCoreDataServices.h
//  PicPranck
//
//  Created by El Khalil Bellakrid on 21/02/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class ViewController;
@class TabBarViewController;
@class PicPranckCollectionViewCell;
@class SavedImage;
@class NSManagedObject;

@interface PicPranckCoreDataServices : NSObject

+(int) initCount;

+(NSManagedObjectContext *)managedObjectContext:(bool)forceReset fromViewController:(UIViewController *)viewController;

+(void)uploadImages:(NSArray *)listOfImages withViewController: (UIViewController *)viewController;

+(TabBarViewController *)getTabBarVCFromVC:(UIViewController *)vc;


+(id)retrieveDataAtIndex:(NSInteger)index withType:(NSString *)type;
+(NSMutableArray *)retrieveImagesArrayFromDataAtIndex:(NSInteger)index;
+(NSArray *)retrieveAllSavedImagesWithType:(NSString *)type;

+(void)removeImages:(NSManagedObject *)objectToDelete;
+(void)removeAllImages:(UIViewController *)sender;

+(BOOL)areAllPicPrancksDeletedMode:(UIViewController *)sender;

+(NSInteger)getNumberOfSavedPicPrancks;
@end
