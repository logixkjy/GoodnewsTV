//
//  GPDownloadController.h
//  GoodNewsPodcast
//
//  Created by 김주영 on 2014. 7. 18..
//  Copyright (c) 2014년 GoodNews. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPDownload.h"
#define GetGPDownloadController [GPDownloadController shared]

@interface NSMutableArray (Queue)

- (id)dequeue;
- (void)enqueue:(id)object;

@end

@interface GPDownloadController : NSObject < GPDownloadDelegate, UIAlertViewDelegate, NSURLConnectionDelegate > {
    NSThread                * communiCatorThread;
    NSMutableArray          * _sendQueue;
//    NSMutableArray          * _sendQueueForFileType;
    BOOL                    _is_downloading;
    GPDownload              *download;
    
    NSInteger sel_btn;
    NSString *str_type;
    
    NSURLConnection *theConnection;
    NSMutableDictionary *dic_fileinfo;
    
    BOOL isFileDownload;
}

+ (GPDownloadController*)shared;
+ (void)terminate;

- (BOOL)beginCommunicator;
- (void)communiCator;
- (void)requestAndrespones;
- (void)endCommunicator;
- (void)downlodResource:(NSDictionary*)downFileInfo :(DOWN_FILE_TYPE)fileType;
- (void)downloadPause;
- (void)downloadCanlcel;
- (void)downloadRestart;
- (void)downloadFileCheck:(NSDictionary*)fileInfo FileType:(NSInteger)fileType isDown:(BOOL)isDown;

@end
