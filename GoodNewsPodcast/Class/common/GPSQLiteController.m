//
//  GPSQLiteController.m
//  GoodNewsPodcast
//
//  Created by 김주영 on 2014. 7. 23..
//  Copyright (c) 2014년 GoodNews. All rights reserved.
//

#import "GPSQLiteController.h"

@implementation GPSQLiteController
static GPSQLiteController* g_GPSQLiteControllerInstance = nil;

+ (GPSQLiteController*)shared{
    if ( g_GPSQLiteControllerInstance == nil) {
        @synchronized(self)
        {
            if (g_GPSQLiteControllerInstance == nil) {
                g_GPSQLiteControllerInstance = [[self alloc] init];
            }
        }
    }
    
    return g_GPSQLiteControllerInstance;
}

- (id) init
{
    self = [super init];
    if (self != nil) {
        self.database = nil;
        self.databasePath = @"";
    }
    return self;
}

- (void)initDB
{
    NSString *DirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *databasePath = [DirectoryPath stringByAppendingPathComponent:@"goodnewsCast.db"];
    
    self.databasePath = databasePath;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:databasePath]) {
        _database = [FMDatabase databaseWithPath:databasePath];
        [_database setLogsErrors:YES];
        [_database setTraceExecution:NO];
        NSLog(@"database created");
    } else {
        NSLog(@"Didnt need to create database");
    }
    
    [self createTable];
}

- (void)createTable
{
    // 다운로드 보관함
    NSString *sql = @"CREATE TABLE TBL_DOWN_BOX (\
    _id INTEGER PRIMARY KEY AUTOINCREMENT,\
    PR_CODE TEXT NOT NULL,\
    PR_TITLE TEXT NOT NULL,\
    PR_THUMB TEXT,\
    CT_NAME TEXT NOT NULL,\
    CT_SPEAKER TEXT NOT NULL,\
    CT_PHRASE TEXT NOT NULL,\
    CT_FILE_NAME TEXT NOT NULL,\
    CT_FILE_TYPE TEXT NOT NULL,\
    CT_EVENT_DATE TEXT NOT NULL)";
    
    // 마이캐스트
    NSString *sql2 = @"CREATE TABLE TBL_MY_CAST (\
    _id INTEGER PRIMARY KEY AUTOINCREMENT,\
    PR_CODE TEXT NOT NULL,\
    PR_TITLE TEXT NOT NULL,\
    PR_SUB_TITLE TEXT,\
    PR_THUMB TEXT,\
    PR_XML_ADDRESS TEXT NOT NULL,\
    PR_CAST_INDEX INTEGER NOT NULL)";
    
    _database = [FMDatabase databaseWithPath:self.databasePath];
    [_database open];
    
    if(![_database tableExists:@"TBL_DOWN_BOX"]){
        if (![_database executeUpdate:sql]) {
            NSLog(@"Error!!");
        }
    }
    if(![_database tableExists:@"TBL_MY_CAST"]){
        if (![_database executeUpdate:sql2]) {
            NSLog(@"Error!!");
        }
    }
    [_database close];
}

- (void)dropTable
{
    NSString *sql = @"DROP TABLE TBL_DOWN_BOX";
    _database = [FMDatabase databaseWithPath:self.databasePath];
    [_database open];
    if (![_database executeUpdate:sql]) {
        NSLog(@"Error!!");
    }
    [_database close];
    
    [self createTable];
}


#pragma mark --------------------------------------------
#pragma mark SQL Query - INSERT
- (void)addDownBox:(NSDictionary*)fileInfo
{
    NSString *sql = @"INSERT INTO TBL_DOWN_BOX (PR_CODE, PR_TITLE, PR_THUMB, CT_NAME,\
    CT_SPEAKER, CT_PHRASE, CT_FILE_NAME, CT_FILE_TYPE, CT_EVENT_DATE)\
    VALUES(?,?,?,?,?,?,?,?,?)";
    
    _database = [FMDatabase databaseWithPath:self.databasePath];
    [_database open];
    [_database executeUpdate:sql,
     [fileInfo objectForKey:@"prCode"],
     [fileInfo objectForKey:@"prTitle"],
     [fileInfo objectForKey:@"prThumb"],
     [fileInfo objectForKey:@"ctName"],
     [fileInfo objectForKey:@"ctSpeaker"],
     [fileInfo objectForKey:@"ctPhrase"],
     [fileInfo objectForKey:@"ctFileName"],
     [fileInfo objectForKey:@"ctFileType"],
     [fileInfo objectForKey:@"ctEventDate"]];
    [_database close];
}

- (BOOL)addMyCast:(NSDictionary*)castInfo
{
    NSString *sql = @"INSERT INTO TBL_MY_CAST (PR_CODE, PR_TITLE, PR_SUB_TITLE,\
    PR_THUMB, PR_XML_ADDRESS, PR_CAST_INDEX) VALUES(?,?,?,?,?,?)";
    
    _database = [FMDatabase databaseWithPath:self.databasePath];
    int index = [self getMyCastCount];
    [_database open];
    BOOL isSuc = [_database executeUpdate:sql,
     [NSString stringWithFormat:@"99%04d",index+1],
     [castInfo objectForKey:@"prTitle"],
     [castInfo objectForKey:@"prSubTitle"],
     [castInfo objectForKey:@"prThumb"],
     [castInfo objectForKey:@"prXmlAddress"],
     [NSNumber numberWithInt:index]];
    [_database close];
    
    return isSuc;
}

#pragma mark --------------------------------------------
#pragma mark SQL Query - UPDATE

- (void)updateMyCastWithNo:(int)idx CastIndex:(int)castIndex
{
    NSString *sql = @"UPDATE TBL_MY_CAST SET PR_CAST_INDEX = ? WHERE _id = ?";
    _database = [FMDatabase databaseWithPath:self.databasePath];
    [_database open];
    [_database executeUpdate:sql,
     [NSNumber numberWithInt:castIndex],
     [NSNumber numberWithInt:idx]];
    [_database close];
}

#pragma mark --------------------------------------------
#pragma mark SQL Query - DELETE
// 다운로드 보관함
- (void)deleteDownFileWithNo:(int)idx
{
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM TBL_DOWN_BOX WHERE _id = ?"];
    
    _database = [FMDatabase databaseWithPath:self.databasePath];
    [_database open];
    [_database executeUpdate:sql,[NSString stringWithFormat:@"%d",idx]];
    [_database close];
}

- (void)deleteMyCastWithNo:(int)idx
{
    NSString *sql =
    [NSString stringWithFormat:@"DELETE FROM TBL_MY_CAST WHERE _id = ?"];
    
    _database = [FMDatabase databaseWithPath:self.databasePath];
    [_database open];
    [_database executeUpdate:sql,[NSString stringWithFormat:@"%d",idx]];
    [_database close];
}

#pragma mark --------------------------------------------
#pragma mark SQL Query - SELECT
// 마이캐스트
- (int)getMyCastCount
{
    NSString *sql = @"SELECT COUNT(PR_CODE) FROM TBL_MY_CAST";
    _database = [FMDatabase databaseWithPath:self.databasePath];
    [_database open];
    FMResultSet *results = [_database executeQuery:sql];
    int cnt = 0;
    
    while ([results next]) {
        cnt = [results intForColumnIndex:0];
    }
    
    [_database close];
    return cnt;
}

- (int)getSameMyCastAddress:(NSString*)xmladdress
{
    NSString *sql = @"SELECT COUNT(PR_CODE) FROM TBL_MY_CAST WHERE PR_XML_ADDRESS = ?";
    FMResultSet *results = [_database executeQuery:sql,xmladdress];
    [_database open];
    int cnt = 0;
    
    while ([results next]) {
        cnt = [results intForColumnIndex:0];
    }
    
    [_database close];
    return cnt;
}

- (NSMutableArray*)GetRecordsMyCast
{
    NSString *sql  = @"SELECT _id, PR_CODE, PR_TITLE, PR_SUB_TITLE, PR_THUMB,\
    PR_XML_ADDRESS, PR_CAST_INDEX FROM TBL_MY_CAST ORDER BY PR_CAST_INDEX ASC";
    
    NSLog(@"sql ==> [%@}",sql);
    _database = [FMDatabase databaseWithPath:self.databasePath];
    [_database open];
    
    FMResultSet *results = [_database executeQuery:sql];
    NSMutableArray *msgResult = [NSMutableArray array];
    
    while ([results next]) {
        NSDictionary *dic =
        [NSDictionary dictionaryWithObjectsAndKeys:
         [NSNumber numberWithInt:[results intForColumnIndex:0]],    @"_ID",
         [results stringForColumnIndex:1],                          @"prCode",
         [results stringForColumnIndex:2],                          @"prTitle",
         [results stringForColumnIndex:3],                          @"prSubTitle",
         [results stringForColumnIndex:4] == nil ? @"" : [results stringForColumnIndex:4], @"prThumb",
         [results stringForColumnIndex:5],                          @"prXmlAddress",
         [NSNumber numberWithInt:[results intForColumnIndex:6]],    @"prCastIndex",
         nil];
        
        [msgResult addObject:dic];
    }
    
    [_database close];
    
    return msgResult;
}

- (NSMutableArray*)GetRecordsDownList
{
    NSString *sql  = @"SELECT _id, PR_CODE, PR_TITLE, PR_THUMB, CT_NAME, CT_SPEAKER,\
    CT_PHRASE, CT_FILE_NAME, CT_FILE_TYPE, CT_EVENT_DATE\
    FROM TBL_DOWN_BOX ORDER BY PR_CODE ASC, CT_EVENT_DATE DESC";
    
    NSLog(@"sql ==> [%@}",sql);
    _database = [FMDatabase databaseWithPath:self.databasePath];
    [_database open];
    
    FMResultSet *results = [_database executeQuery:sql];
    NSMutableArray *msgResult = [NSMutableArray array];
    
    while ([results next]) {
        NSDictionary *dic =
        [NSDictionary dictionaryWithObjectsAndKeys:
         [NSNumber numberWithInt:[results intForColumnIndex:0]],    @"_ID",
         [results stringForColumnIndex:1],                          @"prCode",
         [results stringForColumnIndex:2],                          @"prTitle",
         [results stringForColumnIndex:3],                          @"prThumb",
         [results stringForColumnIndex:4],                          @"ctName",
         [results stringForColumnIndex:5],                          @"ctSpeaker",
         [results stringForColumnIndex:6],                          @"ctPhrase",
         [results stringForColumnIndex:7],                          @"ctFileName",
         [results stringForColumnIndex:8],                          @"ctFileType",
         [results stringForColumnIndex:9],                          @"ctEventDate",
         nil];
        
        [msgResult addObject:dic];
    }
    
    [_database close];
    
    return msgResult;
}

- (NSMutableArray*)GetRecordsDownListSection
{
    NSString *sql  = @"SELECT PR_CODE, COUNT(PR_CODE), PR_TITLE FROM TBL_DOWN_BOX\
    GROUP BY PR_CODE ORDER BY PR_CODE ASC";
    
    NSLog(@"sql ==> [%@}",sql);
    _database = [FMDatabase databaseWithPath:self.databasePath];
    [_database open];
    
    FMResultSet *results = [_database executeQuery:sql];
    NSMutableArray *msgResult = [NSMutableArray array];
    
    while ([results next]) {
        NSDictionary *dic =
        [NSDictionary dictionaryWithObjectsAndKeys:
         [results stringForColumnIndex:0],                          @"prCode",
         [NSNumber numberWithInt:[results intForColumnIndex:1]],    @"prCount",
         [results stringForColumnIndex:2],                          @"prTitle",
         nil];
        
        [msgResult addObject:dic];
    }
    
    [_database close];
    
    return msgResult;
}

@end
