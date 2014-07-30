//
//  GPCommonUtil.h
//  GoodNewsPodcast
//
//  Created by 김주영 on 2014. 7. 14..
//  Copyright (c) 2014년 GoodNews. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GPCommonUtil : NSObject

+ (NSInteger)CheckNetworkEnable;
+ (NSString *)md5StringForString:(NSString *)string;
+ (NSString *)cacheFolder;

+ (void) writeIntToDefault:(int) nValue KEY:(NSString *)strKey;
+ (int) readIntFromDefault:(NSString *)strKey;
+ (void) writeObjectToDefault:(id)idValue KEY:(NSString *)strKey;
+ (id) readObjectFromDefault:(NSString *)strKey;
+ (void) writeBoolToDefault:(BOOL)bValue KEY:(NSString *)strKey;
+ (BOOL) readBoolFromDefault:(NSString *)strKey;
+ (void) writeFloatToDefault:(float) fValue KEY:(NSString *)strKey;
+ (float) readFloatFromDefault:(NSString *)strKey;

@end
