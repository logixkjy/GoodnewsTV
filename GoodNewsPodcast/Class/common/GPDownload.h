//
//  GPDownload.h
//  GoodNewsPodcast
//
//  Created by 김주영 on 2014. 7. 18..
//  Copyright (c) 2014년 GoodNews. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "AFDownloadRequestOperation.h"
@protocol GPDownloadDelegate;

@interface GPDownload : NSObject {
    NSDictionary        *dic_fileinfo;
    AFDownloadRequestOperation *operation;
    
    DOWNLOAD_STATUS down_stat;
}

@property (nonatomic, assign) __block id<GPDownloadDelegate> delegate;

- (void)downloadFileInfo:(NSDictionary*)fileInfo
                fileType:(NSString*)fileType
                delegate:(id<GPDownloadDelegate>)theDelegate;

- (void)downloadPause;
- (void)downloadCanlcel;
- (void)downloadRestart;

@end

@protocol GPDownloadDelegate<NSObject>

@optional
- (void)didFileDownloadFinishWith:(NSDictionary *)fileinfo :(NSString *)fileType;
- (void)didFileDownloadFailWithError:(NSError *)error suggestedFileInfo:(NSDictionary *)fileinfo :(NSString *)fileType;

@end