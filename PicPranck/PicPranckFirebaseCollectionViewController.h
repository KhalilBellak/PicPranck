//
//  PicPranckFirebaseCollectionViewController.h
//  PicPranck
//
//  Created by El Khalil Bellakrid on 19/03/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import "CollectionViewController.h"

@import Firebase;
@import FirebaseStorage;
@import FirebaseDatabase;
@import FirebaseDatabaseUI;

@interface PicPranckFirebaseCollectionViewController : CollectionViewController

//Attributes

////Storage
@property FIRStorage *storage;
@property FIRStorageReference *availablePPRef;

////Database realtime
@property (strong, nonatomic) FIRDatabaseReference *firebaseRef;
@property (strong, nonatomic) FUICollectionViewDataSource *dataSource;

@property NSInteger nbOfItems;

@end
