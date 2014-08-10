//
//  GPDownloadController.m
//  GoodNewsPodcast
//
//  Created by 김주영 on 2014. 7. 18..
//  Copyright (c) 2014년 GoodNews. All rights reserved.
//

#import "GPDownloadController.h"
#import "GPDataCenter.h"
#import "GPSQLiteController.h"

@implementation NSMutableArray (Queue)

- (id)dequeue
{
	id headObject = [self objectAtIndex:0];
	if( headObject != nil )
	{
		[self removeObjectAtIndex:0];
	}
	return headObject;
}

- (void)enqueue:(id)object
{
	[self addObject:object];
}
@end

static GPDownloadController* g_GPDownloadControllerInstance = nil;
@implementation GPDownloadController

+ (GPDownloadController*)shared
{
	if( g_GPDownloadControllerInstance == nil )
	{
		@synchronized(self)
        {
            if(g_GPDownloadControllerInstance == nil)
            {
                g_GPDownloadControllerInstance = [[self alloc] init];
            }
        }
	}
	
	return g_GPDownloadControllerInstance;
}

+ (void)terminate
{
	if( g_GPDownloadControllerInstance == nil ) return;
}

- (id) init {
    self = [super init];
    if (self != nil) {
//		_sendQueue	 = [[NSMutableArray alloc] init];
//		_sendQueueForFileType	 = [[NSMutableArray alloc] init];
        GetGPDataCenter.isDownloading = NO;
        download = [[GPDownload alloc] init];
    }
    return self;
}

- (BOOL)beginCommunicator{
    if (communiCatorThread == nil) {
        communiCatorThread    = [[NSThread alloc] initWithTarget:self selector:@selector(communiCator) object:nil];
    }
    [communiCatorThread start];
    return YES;
}

- (void)communiCator{
    while (([[NSThread currentThread] isCancelled] == NO)) {
        // 보낼 전문을 큐에서 읽어온다.
        if (GetGPDataCenter.sendQueue.count > 0 && !GetGPDataCenter.isDownloading) {
            [self requestAndrespones];
        }
        [NSThread sleepForTimeInterval:0.3];
        if( [communiCatorThread isCancelled] ) break;
    }
    [self endCommunicator];
}

- (void)requestAndrespones
{
    NSDictionary *dic_fileInfo = [GetGPDataCenter.sendQueue dequeue];
    GetGPDataCenter.dic_fileInfo = [NSMutableDictionary dictionaryWithDictionary:dic_fileInfo];
    
    NSString *str_fileType = [GetGPDataCenter.sendQueueForFileType dequeue];
    GetGPDataCenter.str_fileType = str_fileType;
    
    [GPCommonUtil writeObjectToDefault:GetGPDataCenter.sendQueue KEY:@"SEND_QUEUE"];
    [GPCommonUtil writeObjectToDefault:GetGPDataCenter.sendQueueForFileType KEY:@"SEND_QUEUE_FILE_TYPE"];
    
    [GPCommonUtil writeObjectToDefault:GetGPDataCenter.dic_fileInfo KEY:@"DOWN_FILE_INFO"];
    [GPCommonUtil writeObjectToDefault:GetGPDataCenter.str_fileType KEY:@"DOWN_FILE_TYPE"];
    
    GetGPDataCenter.isDownloading = YES;
    
    [download downloadFileInfo:dic_fileInfo fileType:str_fileType delegate:self];
}

- (void)endCommunicator
{
   	if( communiCatorThread != nil )
	{
		[communiCatorThread cancel];
        communiCatorThread = nil;
    }
}

- (void)downlodResource:(NSDictionary*)downFileInfo :(DOWN_FILE_TYPE)fileType
{
    [GetGPDataCenter.sendQueue enqueue:downFileInfo];
    [GetGPDataCenter.sendQueueForFileType enqueue:[NSString stringWithFormat:@"%ld",(long)fileType]];
    
    [GPCommonUtil writeObjectToDefault:GetGPDataCenter.sendQueue KEY:@"SEND_QUEUE"];
    [GPCommonUtil writeObjectToDefault:GetGPDataCenter.sendQueueForFileType KEY:@"SEND_QUEUE_FILE_TYPE"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:_CMD_FILE_DOWN_ADD object:self userInfo:nil];
    
    if (![communiCatorThread isExecuting]) {
        [self beginCommunicator];
    }
}

- (void)didFileDownloadFinishWith:(NSDictionary *)fileinfo :(NSString *)fileType
{
    
    GetGPDataCenter.isDownloading = NO;
    NSString *file_name = @"";
    switch ([fileType integerValue]) {
        case FILE_TYPE_VIDEO_NORMAL:
            file_name = [NSString stringWithFormat:@"%@_%@_N.mp4",[fileinfo objectForKey:@"ctName"],[fileinfo objectForKey:@"ctSpeaker"]];
            break;
        case FILE_TYPE_VIDEO_LOW:
            file_name = [NSString stringWithFormat:@"%@_%@_L.mp4",[fileinfo objectForKey:@"ctName"],[fileinfo objectForKey:@"ctSpeaker"]];
            break;
        case FILE_TYPE_AUDIO:
            file_name = [NSString stringWithFormat:@"%@_%@.mp3",[fileinfo objectForKey:@"ctName"],[fileinfo objectForKey:@"ctSpeaker"]];
            break;
        default:
            break;
    }
    
    NSString *fullPath = [NSTemporaryDirectory() stringByAppendingPathComponent:file_name];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *str_filePath = [NSString stringWithFormat:@"%@/Contents/%@/%@",[paths objectAtIndex:0],[fileinfo objectForKey:@"prCode"],file_name];
    if (![self copyFileWithTempPath:fullPath CopyDirectoryPath:str_filePath]) {
        NSLog(@"ERROR!!!");
    }
    
    NSMutableDictionary *downFIleInfo = [NSMutableDictionary dictionaryWithDictionary:fileinfo];
    [downFIleInfo setValue:fileType forKey:@"ctFileType"];
    [downFIleInfo setValue:file_name forKey:@"ctFileName"];
    [GetGPSQLiteController addDownBox:downFIleInfo];
    
    NSMutableDictionary *user_info = [NSMutableDictionary dictionaryWithDictionary:fileinfo];
    [user_info setValue:fileType forKey:@"FILE_TYPE"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:_CMD_FILE_DOWN_FINISHED object:self userInfo:user_info];
}

- (void)didFileDownloadFailWithError:(NSError *)error suggestedFileInfo:(NSDictionary *)fileinfo :(NSString *)fileType
{
    GetGPDataCenter.isDownloading = NO;
    
    if (GetGPDataCenter.sendQueue.count == 0) {
        GetGPDataCenter.dic_fileInfo = nil;
        GetGPDataCenter.str_fileType = @"";
        [GPCommonUtil writeObjectToDefault:GetGPDataCenter.dic_fileInfo KEY:@"DOWN_FILE_INFO"];
        [GPCommonUtil writeObjectToDefault:GetGPDataCenter.str_fileType KEY:@"DOWN_FILE_TYPE"];
    }
    
    NSMutableDictionary *user_info = [NSMutableDictionary dictionaryWithDictionary:fileinfo];
    [user_info setValue:fileType forKey:@"FILE_TYPE"];
    [[NSNotificationCenter defaultCenter] postNotificationName:_CMD_FILE_DOWN_ERROR object:self userInfo:user_info];
}

- (BOOL)copyFileWithTempPath:(NSString*)tempPath CopyDirectoryPath:(NSString*)directoryPath
{
    if (GetGPDataCenter.sendQueue.count == 0) {
        GetGPDataCenter.dic_fileInfo = nil;
        GetGPDataCenter.str_fileType = @"";
        GetGPDataCenter.isExistingDownload = NO;
        [GPCommonUtil writeObjectToDefault:GetGPDataCenter.dic_fileInfo KEY:@"DOWN_FILE_INFO"];
        [GPCommonUtil writeObjectToDefault:GetGPDataCenter.str_fileType KEY:@"DOWN_FILE_TYPE"];
    }
    
    NSLog(@"TempPath=[%@], directoryPath=[%@]", tempPath, directoryPath);
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    [fileManager createDirectoryAtPath:[[paths objectAtIndex:0] stringByAppendingPathComponent:@"Contents"] withIntermediateDirectories:NO attributes:nil error:&error];
    
    [fileManager createDirectoryAtPath:[[directoryPath componentsSeparatedByString:[directoryPath lastPathComponent]] objectAtIndex:0] withIntermediateDirectories:NO attributes:nil error:&error];

    [fileManager copyItemAtPath:tempPath toPath:directoryPath error:nil];
    
    return [fileManager removeItemAtPath:tempPath error:nil];
}

- (void)downloadPause
{
    GetGPDataCenter.isDownloadPaused = YES;
    NSLog(@"download Pause!!!");
    [download downloadPause];
}

- (void)downloadCanlcel
{
    [download downloadCanlcel];
    GetGPDataCenter.isDownloading = NO;
    
    if (GetGPDataCenter.sendQueue.count == 0) {
        GetGPDataCenter.dic_fileInfo = nil;
        GetGPDataCenter.str_fileType = @"";
        [GPCommonUtil writeObjectToDefault:GetGPDataCenter.dic_fileInfo KEY:@"DOWN_FILE_INFO"];
        [GPCommonUtil writeObjectToDefault:GetGPDataCenter.str_fileType KEY:@"DOWN_FILE_TYPE"];
    }
}

- (void)downloadRestart
{
    GetGPDataCenter.isDownloadPaused = NO;
    [download downloadRestart];
}

- (void)downloadFileCheck:(NSDictionary*)fileInfo FileType:(NSInteger)fileType isDown:(BOOL)isDown
{
    isFileDownload = isDown;
    dic_fileinfo = [NSMutableDictionary dictionaryWithDictionary:fileInfo];
    NSString *file_url = @"";
    switch (fileType) {
        case FILE_TYPE_VIDEO_NORMAL:
            str_type = @"Video";
            sel_btn = FILE_TYPE_VIDEO_NORMAL;
            file_url = [dic_fileinfo objectForKey:@"ctVideoNormal"] == nil ? [dic_fileinfo objectForKey:@"ctFileUrl"] : [dic_fileinfo objectForKey:@"ctVideoNormal"];
            break;
        case FILE_TYPE_VIDEO_LOW:
            str_type = @"Video";
            sel_btn = FILE_TYPE_VIDEO_LOW;
            file_url = [dic_fileinfo objectForKey:@"ctVideoLow"];
            break;
        case FILE_TYPE_AUDIO:
            str_type = @"Audio";
            sel_btn = FILE_TYPE_AUDIO;
            if (isFileDownload) {
                file_url = [dic_fileinfo objectForKey:@"ctAudioDown"] == nil ? [dic_fileinfo objectForKey:@"ctFileUrl"] : [dic_fileinfo objectForKey:@"ctAudioDown"] ;
            }else{
                file_url = [dic_fileinfo objectForKey:@"ctAudioStream"] == nil ? [dic_fileinfo objectForKey:@"ctFileUrl"] : [dic_fileinfo objectForKey:@"ctAudioStream"] ;
            }
            break;
        default:
            break;
    }
    
    NSURL *reqURL =  [NSURL URLWithString:file_url];
    
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:reqURL];
    
    theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"[DO::didReceiveData] %d operation", (int)self);
	long long expectedBytes;
	NSHTTPURLResponse *r = (NSHTTPURLResponse*) response;
	NSDictionary *headers = [r allHeaderFields];
    NSInteger responseStatusCode = [r statusCode];
    if ((responseStatusCode < 200) || (responseStatusCode > 299))
    {
        [connection cancel];
        if (!isFileDownload) {
            [GPAlertUtil alertWithMessage:@"재생하실 파일이 \n등록되어 있지않습니다."];
        } else {
            [GPAlertUtil alertWithMessage:@"다운로드하실 파일이 \n등록되어 있지않습니다."];
        }
        return;
    }
    
    
    if ([[headers objectForKey:@"Content-Type"] isEqualToString:@"text/html"]) {
        if (!isFileDownload) {
            [GPAlertUtil alertWithMessage:@"재생하실 파일이 등록 되어 있지 않습니다."];
        } else {
            [GPAlertUtil alertWithMessage:@"다운로드하실 파일이 등록 되어 있지 않습니다."];
        }
        return;
    }
    
    NSLog(@"[DO::didReceiveResponse] response headers: %@", headers);
	if (headers){
		if ([headers objectForKey: @"Content-Range"]) {
			NSString *contentRange = [headers objectForKey: @"Content-Range"];
			NSLog(@"Content-Range: %@", contentRange);
			NSRange range = [contentRange rangeOfString: @"/"];
			NSString *totalBytesCount = [contentRange substringFromIndex: range.location + 1];
			expectedBytes = [totalBytesCount floatValue];
		} else if ([headers objectForKey: @"Content-Length"]) {
			NSLog(@"Content-Length: %@", [headers objectForKey: @"Content-Length"]);
			expectedBytes = [[headers objectForKey: @"Content-Length"] floatValue];
		} else expectedBytes = -1;
	}
    
    NSNumber *number = [NSNumber numberWithLongLong:expectedBytes];
    NSLog(@"Digital Value : %@", [number measuredByteStringWithSymbol:YES]);
    
    [connection cancel];
    if (isFileDownload) {
        [GPAlertUtil alertWithMessage:[NSString stringWithFormat:@"Type:%@\n다운받을 용량:%@\n다운로드 하시겠습니까?",str_type,[number measuredByteStringWithSymbol:YES]] delegate:self tag:0];
    } else {
        [dic_fileinfo setObject:[NSString stringWithFormat:@"%ld",(long)sel_btn] forKey:@"ctFileType"];
        [[NSNotificationCenter defaultCenter] postNotificationName:_CMD_FILE_STREAMING object:self userInfo:dic_fileinfo];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1001) {
        if (buttonIndex == 0) {
            [self downlodResource:dic_fileinfo :sel_btn];
        }
    }
}
@end
