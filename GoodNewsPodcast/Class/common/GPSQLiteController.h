//
//  GPSQLiteController.h
//  GoodNewsPodcast
//
//  Created by 김주영 on 2014. 7. 23..
//  Copyright (c) 2014년 GoodNews. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"

@interface GPSQLiteController : NSObject

@property (nonatomic, strong) FMDatabase *database;
@property (nonatomic, strong) NSString *databasePath;

+ (GPSQLiteController*)shared;
- (void)initDB;
- (void)createTable;
- (void)dropTable;
// insert
- (void)addDownBox:(NSDictionary*)fileInfo;
- (void)addMyCast:(NSDictionary*)castInfo;
// update
- (void)updateMyCastWithNo:(int)idx CastIndex:(int)castIndex;
// delete
- (void)deleteDownFileWithNo:(int)idx;
- (void)deleteMyCastWithNo:(int)idx;
// select
- (int)getMyCastCount;
- (NSMutableArray*)GetRecordsMyCast;
- (NSMutableArray*)GetRecordsDownList;
- (NSMutableArray*)GetRecordsDownListSection;

#define GetGPSQLiteController [GPSQLiteController shared]
@end
