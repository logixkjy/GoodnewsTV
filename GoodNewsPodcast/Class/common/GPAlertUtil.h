//
//  GPAlertUtil.h
//  GoodNewsPodcast
//
//  Created by 김주영 on 2014. 7. 14..
//  Copyright (c) 2014년 GoodNews. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GPAlertUtil : NSObject
+ (void)alertWithException:(NSException *)exception;
+ (void)alertWithError:(NSError *)error;
+ (void)alertWithMessage:(NSString *)message;
+ (void)alertWithMessage:(NSString *)message delegate:(id)aDelegate;
+ (void)alertWithMessage:(NSString *)message tag:(int)tag delegate:(id)aDelegate;
+ (void)alertWithMessage:(NSString *)message delegate:(id)aDelegate tag:(int)tag;
+ (void)alertWithMessage:(id)aDelegate
                 MESSAGE:(NSString *)message
                   TITLE:(NSString *)title;
@end
