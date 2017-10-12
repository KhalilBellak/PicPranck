//
//  AppDelegate.h
//  foo
//
//  Created by El Khalil Bellakrid on 15/02/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

//Attributes
@property (strong, nonatomic) UIWindow *window;
////Core data attributes
@property (readonly, strong) NSPersistentContainer *persistentContainer;
@property (readonly, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

-(void)initializeManagedObjectContext;
-(void)initializePersistentStoreCoordinator;
-(void)resetPersistencyObjects;

@end

