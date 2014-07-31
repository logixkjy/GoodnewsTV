//
//  GPDownload.m
//  GoodNewsPodcast
//
//  Created by 김주영 on 2014. 7. 18..
//  Copyright (c) 2014년 GoodNews. All rights reserved.
//

#import "GPDownload.h"
#import "AFNetworking.h"

@implementation GPDownload
@synthesize delegate;

- (id) init {
    self = [super init];
    if (self != nil) {
        
        dic_fileinfo = [[NSDictionary alloc] init];
        operation = nil;
    }
    return self;
}

- (void)downloadFileInfo:(NSDictionary*)fileInfo
                fileType:(NSString *)fileType
                delegate:(id<GPDownloadDelegate>)theDelegate
{
    down_stat = DOWNLOAD_STATUS_READY;
    dic_fileinfo = [NSDictionary dictionaryWithDictionary:fileInfo];
    self.delegate = theDelegate;
    
    NSString *file_url = @"";
    NSString *file_name = @"";
    switch ([fileType integerValue]) {
        case FILE_TYPE_VIDEO_NORMAL:
            file_url = [fileInfo objectForKey:@"ctVideoNormal"] == nil ? [fileInfo objectForKey:@"ctFileUrl"] : [fileInfo objectForKey:@"ctVideoNormal"];
            file_name = [fileInfo objectForKey:@"ctFileName"] != nil ? [fileInfo objectForKey:@"ctFileName"] : [NSString stringWithFormat:@"%@_%@_N.mp4",[fileInfo objectForKey:@"ctName"],[fileInfo objectForKey:@"ctSpeaker"]];
            break;
        case FILE_TYPE_VIDEO_LOW:
            file_url = [fileInfo objectForKey:@"ctVideoLow"] == nil ? [fileInfo objectForKey:@"ctFileUrl"] : [fileInfo objectForKey:@"ctVideoLow"];
            file_name = [fileInfo objectForKey:@"ctFileName"] != nil ? [fileInfo objectForKey:@"ctFileName"] : [NSString stringWithFormat:@"%@_%@_L.mp4",[fileInfo objectForKey:@"ctName"],[fileInfo objectForKey:@"ctSpeaker"]];
            break;
        case FILE_TYPE_AUDIO:
            file_url = [fileInfo objectForKey:@"ctAudioDown"] == nil ? [fileInfo objectForKey:@"ctFileUrl"] : [fileInfo objectForKey:@"ctAudioDown"];
            file_name = [fileInfo objectForKey:@"ctFileName"] != nil ? [fileInfo objectForKey:@"ctFileName"] : [NSString stringWithFormat:@"%@_%@.mp3",[fileInfo objectForKey:@"ctName"],[fileInfo objectForKey:@"ctSpeaker"]];
            break;
        default:
            break;
    }
    
    NSMutableDictionary *user_info = [NSMutableDictionary dictionaryWithDictionary:dic_fileinfo];
    [user_info setValue:file_name forKey:@"ctFileName"];
    [user_info setValue:fileType forKey:@"ctFileType"];
    [[NSNotificationCenter defaultCenter] postNotificationName:_CMD_FILE_DOWN_START object:self userInfo:user_info];
    
    NSURL *url = [NSURL URLWithString:file_url];
    NSString *fullPath = [NSTemporaryDirectory() stringByAppendingPathComponent:file_name];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    operation = [[AFDownloadRequestOperation alloc] initWithRequest:request
                                                         targetPath:fullPath
                                                       shouldResume:YES];
    
    __block long long _totalByte;
    __block long long _downByte;
    [operation setProgressiveDownloadProgressBlock:^(AFDownloadRequestOperation *operation, NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile) {
        _totalByte = totalBytesExpected;
        _downByte = totalBytesRead;
        float percentComplete = ((totalBytesReadForFile/(float)totalBytesExpectedToReadForFile)*100);
        NSLog(@" %@ Data receiving... Percent complete: %.02f", file_name, percentComplete);
        
        [user_info setValue:[NSNumber numberWithFloat:percentComplete] forKey:@"PERCENT_COMP"];
        [[NSNotificationCenter defaultCenter] postNotificationName:_CMD_FILE_DOWNLOADING object:nil userInfo:user_info];
    } ];
        
    [operation setCompletionBlock:^{
        if (_totalByte <= _downByte) {
            
            if ([delegate respondsToSelector:@selector(didFileDownloadFinishWith::)]) {
                [delegate didFileDownloadFinishWith:dic_fileinfo :fileType];
            }
        } else {
            if (down_stat == DOWNLOAD_STATUS_CANCEL) {
                if ([delegate respondsToSelector:@selector(didFileDownloadFailWithError:suggestedFileInfo::)]) {
                    [delegate didFileDownloadFailWithError:[NSError errorWithDomain:@"GPDownload Error" code:1 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"User Cancle!!", NSLocalizedDescriptionKey, nil]] suggestedFileInfo:dic_fileinfo :fileType];
                }
            }
        }
        
        
    }];
    
    [operation start];
    
}

- (void)downloadPause{
    down_stat = DOWNLOAD_STATUS_PAUSE;
    [operation pause];
}

- (void)downloadCanlcel{
    down_stat = DOWNLOAD_STATUS_CANCEL;
    [operation cancel];
}

- (void)downloadRestart{
    down_stat = DOWNLOAD_STATUS_READY;
    [operation resume];
}

@end
