//
//  GPCommonUtil.m
//  GoodNewsPodcast
//
//  Created by 김주영 on 2014. 7. 14..
//  Copyright (c) 2014년 GoodNews. All rights reserved.
//

#import "GPCommonUtil.h"
#import "KCReachability.h"
#import <CommonCrypto/CommonDigest.h>

@implementation GPCommonUtil

+ (NSInteger)CheckNetworkEnable {
    KCReachability *isConnect = [KCReachability reachabilityForInternetConnection];
    return [isConnect currentReachabilityStatus];
}

+ (NSString *)cacheFolder {
    NSFileManager *filemgr = [NSFileManager new];
    static NSString *cacheFolder;
    
    if (!cacheFolder) {
        NSString *cacheDir = NSTemporaryDirectory();
        cacheFolder = [cacheDir stringByAppendingPathComponent:kAFNetworkingIncompleteDownloadFolderName];
    }
    
    // ensure all cache directories are there
    NSError *error = nil;
    if(![filemgr createDirectoryAtPath:cacheFolder withIntermediateDirectories:YES attributes:nil error:&error]) {
        NSLog(@"Failed to create cache directory at %@", cacheFolder);
        cacheFolder = nil;
    }
    return cacheFolder;
}

// calculates the MD5 hash of a key
+ (NSString *)md5StringForString:(NSString *)string {
    const char *str = [string UTF8String];
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (uint32_t)strlen(str), r);
    return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
}

#pragma mark -------------------------------------------------------------------
#pragma mark < NSUserDefaults Methods >

+ (void) writeIntToDefault:(int) nValue KEY:(NSString *)strKey
{
	NSUserDefaults *defaults;
	defaults = NUD;
    
	[defaults setInteger:nValue forKey:strKey];
	[defaults synchronize];
}

+ (int) readIntFromDefault:(NSString *)strKey
{
	NSUserDefaults *defaults;
	defaults = NUD;
    
	return [defaults integerForKey:strKey];
}

+ (void) writeObjectToDefault:(id)idValue KEY:(NSString *)strKey
{
	NSUserDefaults *defaults;
	defaults = NUD;
	
	[defaults setObject:idValue forKey:strKey];
	[defaults synchronize];
}

+ (id) readObjectFromDefault:(NSString *)strKey
{
	NSUserDefaults *defaults;
	defaults = NUD;
    
	return [defaults objectForKey:strKey];
}

+ (void) writeBoolToDefault:(BOOL)bValue KEY:(NSString *)strKey
{
	NSUserDefaults *defaults;
	defaults = NUD;
	
	[defaults setBool:bValue forKey:strKey];
	[defaults synchronize];
}

+(BOOL) readBoolFromDefault:(NSString *)strKey
{
	NSUserDefaults *defaults;
	defaults = NUD;
    
	return [defaults boolForKey:strKey];
}

+ (void) writeFloatToDefault:(float) fValue KEY:(NSString *)strKey
{
	NSUserDefaults *defaults;
	defaults = NUD;
	
	[defaults setFloat:fValue forKey:strKey];
	[defaults synchronize];
}

+(float) readFloatFromDefault:(NSString *)strKey
{
	NSUserDefaults *defaults;
	defaults = NUD;
	
	return [defaults floatForKey:strKey];
}

@end
