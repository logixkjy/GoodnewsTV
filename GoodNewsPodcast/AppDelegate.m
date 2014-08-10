//
//  AppDelegate.m
//  GoodNewsPodcast
//
//  Created by 김주영 on 2014. 7. 14..
//  Copyright (c) 2014년 GoodNews. All rights reserved.
//

#import "AppDelegate.h"
#import "GPDataCenter.h"
#import "GPCommonUtil.h"
#import "GPNavigationController.h"
#import "GPDownloadController.h"
#import "GPSQLiteController.h"
#import "ActivityIndicatorCommonViewController.h"

#define degreesToRadian(x) (M_PI * (x) / 180.0)
@implementation AppDelegate
@synthesize downloadController = _downloadController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    if (IS_iOS_7) {
        [application setStatusBarStyle:UIStatusBarStyleLightContent];
    }
    [GetGPDataCenter setGpNetowrkStatus:[GPCommonUtil CheckNetworkEnable]];
    _downloadController = [GPDownloadController shared];
    
    [GetGPSQLiteController initDB];
    
    [iVersion sharedInstance].applicationBundleID = @"com.goodnews.goodnewstv";
    [iVersion sharedInstance].delegate = self;
    
    NSMutableDictionary *dic_downInfo = [GPCommonUtil readObjectFromDefault:@"DOWN_FILE_INFO"];
    NSString *str_downInfo = [GPCommonUtil readObjectFromDefault:@"DOWN_FILE_TYPE"];
    
    if (dic_downInfo != nil || [str_downInfo length] != 0) {
        GetGPDataCenter.isExistingDownload = YES;
        [GetGPDataCenter.sendQueue addObject:dic_downInfo];
        [GetGPDataCenter.sendQueueForFileType addObject:str_downInfo];
    }
    
    NSArray *_sendQueue = [GPCommonUtil readObjectFromDefault:@"SEND_QUEUE"];
    NSArray *_sendQueue_ft = [GPCommonUtil readObjectFromDefault:@"SEND_QUEUE_FILE_TYPE"];
    if ([_sendQueue count] != 0) {
        GetGPDataCenter.isExistingDownload = YES;
        for (int j = 0; j < [_sendQueue count]; j++) {
            [GetGPDataCenter.sendQueue addObject:[_sendQueue objectAtIndex:j]];
            [GetGPDataCenter.sendQueueForFileType addObject:[_sendQueue_ft objectAtIndex:j]];
        }
    }
    
    // documentDirectory, libraryDirectory에 저장한 파일들이 iCloud에 백업되지 않도록 설정
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSURL *pathURL = [NSURL fileURLWithPath:[paths objectAtIndex:0]];
    [self addSkipBackupAttributeToItemAtURL:pathURL];
    
    paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    pathURL = [NSURL fileURLWithPath:[paths objectAtIndex:0]];
    [self addSkipBackupAttributeToItemAtURL:pathURL];
    return YES;
}

- (BOOL)iVersionShouldDisplayNewVersion:(NSString *)version details:(NSString *)versionDetails{
    NSLog(@"%@",version);
    GetGPDataCenter.str_AppStore = version;
    NSLog(@"%@",versionDetails);
    return YES;
}

// documentDirectory, libraryDirectory에 저장한 파일들이 iCloud에 백업되지 않도록 설정
- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    if (&NSURLIsExcludedFromBackupKey == nil) { // iOS <= 5.0.1
        const char* filePath = [[URL path] fileSystemRepresentation];
        
        const char* attrName = "com.apple.MobileBackup";
        u_int8_t attrValue = 1;
        
        int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
        return result == 0;
    } else { // iOS >= 5.1
        return [URL setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:nil];
    }
}

#pragma mark -
#pragma mark Animation View part

- (void)startAnimatedLodingView
{
    if (processingController == nil) {
        processingController = [[ActivityIndicatorCommonViewController alloc] initWithNibName:nil bundle:nil];
        [self.window addSubview:processingController.view];
    }
    [self.window bringSubviewToFront:processingController.view];
    NSLog(@"startAnimatedLodingView");
}

- (void)stopAnimatedLodingView
{
    if (processingController) {
        [processingController removeFromSuperViewFadeout];
        processingController = nil;
    }
    NSLog(@"stopAnimatedLodingView");
}
					
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    if (!GetGPDataCenter.isDownloadPaused) {
        [_downloadController downloadPause];
    }
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    if (GetGPDataCenter.isDownloadPaused) {
        if ([GetGPDataCenter.str_fileType length] != 0 ||
            GetGPDataCenter.dic_fileInfo != nil) {
            [_downloadController downloadRestart];
        }
    }
    
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [GPAlertUtil alertWithMessage:@"applicationWillTerminate"];
    [_downloadController downloadPause];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
