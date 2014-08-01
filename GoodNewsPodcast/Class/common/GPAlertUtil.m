//
//  GPAlertUtil.m
//  GoodNewsPodcast
//
//  Created by 김주영 on 2014. 7. 14..
//  Copyright (c) 2014년 GoodNews. All rights reserved.
//

#import "GPAlertUtil.h"

@implementation GPAlertUtil

+ (void)alertWithException:(NSException *)exception
{
	NSString *message = [NSString stringWithFormat:@"exception error%@ %@",
						 [exception name],
						 [exception reason]];
	[GPAlertUtil alertWithMessage:message];
}

+ (void)alertWithError:(NSError *)error
{
	NSString *message = [NSString stringWithFormat:@"ERROR %@ %@",
						 [error localizedDescription],
						 [error localizedFailureReason]];
	[GPAlertUtil alertWithMessage:message];
}

+ (void)alertWithMessage:(NSString *)message
{
	[GPAlertUtil alertWithMessage:message delegate:nil];
}

+ (void)alertWithMessage:(NSString *)message delegate:(id)aDelegate
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"알림", @"알림")
													message:message
												   delegate:aDelegate
										  cancelButtonTitle:NSLocalizedString(@"확인", @"확인")
										  otherButtonTitles:nil ];
	[alert show];
}

+ (void)alertWithMessage:(NSString *)message tag:(int)tag delegate:(id)aDelegate
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"알림", @"알림")
													message:message
												   delegate:aDelegate
										  cancelButtonTitle:NSLocalizedString(@"확인", @"확인")
										  otherButtonTitles:nil ];
    [alert setTag:tag];
	[alert show];
}

+ (void)alertWithMessage:(NSString *)message delegate:(id)aDelegate tag:(int)tag
{
	UIAlertView *alert = nil;
    
    if (tag == 0) {
        alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"다운로드", @"다운로드")
                                           message:message
                                          delegate:aDelegate
                                 cancelButtonTitle:nil
                                 otherButtonTitles:NSLocalizedString(@"확인", @"확인"),NSLocalizedString(@"취소", @"취소"),nil ];
        [alert setTag:1001];
    } else if (tag == 1) {
        alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"알림", @"알림")
                                           message:message
                                          delegate:aDelegate
                                 cancelButtonTitle:nil
                                 otherButtonTitles:NSLocalizedString(@"설정화면", @"설정화면"),NSLocalizedString(@"닫기", @"닫기"),nil ];
        [alert setTag:1002];
    } else if (tag == 2) {
        alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"최신버전 정보", @"최신버전 정보")
                                           message:message
                                          delegate:aDelegate
                                 cancelButtonTitle:nil
                                 otherButtonTitles:NSLocalizedString(@"업데이트", @"업데이트"),NSLocalizedString(@"나중에", @"나중에"),nil ];
        [alert setTag:1003];
    } else if (tag == 3) {
        alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"다운로드 항목 삭제", @"다운로드 항목 삭제")
                                           message:message
                                          delegate:aDelegate
                                 cancelButtonTitle:nil
                                 otherButtonTitles:NSLocalizedString(@"삭제", @"삭제"),NSLocalizedString(@"취소", @"취소"),nil ];
        [alert setTag:1004];
    } else if (tag == 4) {
        alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"다운로드 항목 삭제", @"다운로드 항목 삭제")
                                           message:message
                                          delegate:aDelegate
                                 cancelButtonTitle:nil
                                 otherButtonTitles:NSLocalizedString(@"삭제", @"삭제"),NSLocalizedString(@"취소", @"취소"),nil ];
        [alert setTag:1005];
    }
	[alert show];
}

+ (void)alertWithMessage:(id)aDelegate
                 MESSAGE:(NSString *)message
                   TITLE:(NSString *)title
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(title, title)
													message:message
												   delegate:aDelegate
										  cancelButtonTitle:NSLocalizedString(@"확인", @"확인")
										  otherButtonTitles:nil ];
    alert.tag = 8000;
	[alert show];
}
@end
