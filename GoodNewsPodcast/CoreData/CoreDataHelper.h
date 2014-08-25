//
//  CoreDataHelper.h
//  GoodNewsPodcast
//
//  Created by 김주영 on 2014. 8. 20..
//  Copyright (c) 2014년 GoodNews. All rights reserved.
//

@import Foundation;
@import CoreData;

@interface CoreDataHelper : NSObject
@property (nonatomic) NSString *entityName;
@property (nonatomic) NSString *defaultSortAttribute;

@property (nonatomic) NSManagedObjectContext *context;
@property (nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, readonly) BOOL hasStore;
@property (nonatomic, readonly) NSInteger numberOfSections;
@property (nonatomic, readonly) NSInteger numberOfEntities;

- (void)setupCoreData;

- (void)fetchData;
- (BOOL)fetchItemsMatching:(NSString *)searchString forAttribute:(NSString *)attribute sortingBy:(NSString *)sortAttribute;

- (BOOL)save;
- (NSManagedObject *)newObject;
- (BOOL)clearData;
- (BOOL)deleteObject:(NSManagedObject *)object;

- (NSInteger)numberOfItemsInSection:(NSInteger)section;
@end
