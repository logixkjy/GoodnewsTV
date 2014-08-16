//
//  GPContentsViewController.m
//  GoodNewsPodcast
//
//  Created by 김주영 on 2014. 7. 15..
//  Copyright (c) 2014년 GoodNews. All rights reserved.
//

#import "GPContentsViewController.h"
#import "GPSettingViewController.h"
#import "GPAlertUtil.h"
#import "JSON.h"
#import "GPGNContentCell.h"
#import "GPAudioPlayerViewController.h"
#import "GPDataCenter.h"

@interface GPContentsViewController ()

@end

@implementation GPContentsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)]];
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];
    
    //백그라운드에서 재생
    AVAudioSession*session =[AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [session setActive:YES error:nil];
    
    self.arr_contents_list = [[NSMutableArray alloc] initWithCapacity:10];
    [self setDatas];
    [self performSelector:@selector(connectionNetwork) withObject:nil afterDelay:0.0];
//    [self performSelectorOnMainThread:@selector(connectionNetwork) withObject:nil waitUntilDone:NO];
//    [self connectionNetwork];
    
    moreViewCnt = 20; // 더보기 카운트
    _arr_moreView = [[NSMutableArray alloc] initWithCapacity:20];
    selBtnType = 99;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moveSettingView)
                                                 name:_CMD_MOVE_SETTING_VIEW
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fileDownloadFinished:)
                                                 name:_CMD_FILE_DOWN_FINISHED
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fileDownloadStart:)
                                                 name:_CMD_FILE_DOWN_START
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fileDownloadAdd)
                                                 name:_CMD_FILE_DOWN_ADD
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fileStreaming:)
                                                 name:_CMD_FILE_STREAMING
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(filePlaying:)
                                                 name:_CMD_FILE_PLAYING
                                               object:nil];
    
    self.btn_nowplay.hidden = !GetGPDataCenter.isAudioPlaying;
    [self.btn_nowplay addTarget:self action:@selector(moveAudioPlayView) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:_CMD_MOVE_SETTING_VIEW object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:_CMD_FILE_DOWN_FINISHED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:_CMD_FILE_DOWN_START object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:_CMD_FILE_DOWN_ADD object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:_CMD_FILE_STREAMING object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:_CMD_FILE_PLAYING object:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)remoteControlReceivedWithEvent:(UIEvent *)event{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoteControlEventReceived" object:event];
}

-(void)remoteControlEventNotification:(NSNotification *)note
{
    AppDelegate *mainDelegate = MAIN_APP_DELEGATE();
    UIEvent *event = note.object;
    if ( event.type == UIEventTypeRemoteControl ) {
        switch (event.subtype) {
            case UIEventSubtypeRemoteControlPlay:
                [mainDelegate.audioPlayer play];
                break;
            case UIEventSubtypeRemoteControlPause:
                [mainDelegate.audioPlayer pause];
                break;
            case UIEventSubtypeRemoteControlStop:
                [mainDelegate.audioPlayer stop];
                break;
            case UIEventSubtypeRemoteControlBeginSeekingBackward:
            case UIEventSubtypeRemoteControlBeginSeekingForward:
            case UIEventSubtypeRemoteControlEndSeekingBackward:
            case UIEventSubtypeRemoteControlEndSeekingForward:
            case UIEventSubtypeRemoteControlPreviousTrack:
            case UIEventSubtypeRemoteControlNextTrack:
                
                break;
                
            default:
                break;
        }
    }
}

- (void)moveSettingView
{
    GPSettingViewController *settingViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingView"];
    [self.navigationController pushViewController:settingViewController animated:YES];
}

- (void)fileDownloadAdd
{
//    [_arr_moreView removeAllObjects];
    [self setDownloadData];
    if ([self.arr_contents_list count] > 20) {
        _arr_moreView = [[self.arr_contents_list subarrayWithRange:NSMakeRange(0, moreViewCnt)] mutableCopy];
    } else {
        _arr_moreView = [self.arr_contents_list mutableCopy];
    }
    
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

- (void)fileDownloadStart:(NSNotification*)notification
{
//    [_arr_moreView removeAllObjects];
    [self setDownloadData];
    if ([self.arr_contents_list count] > 20) {
        _arr_moreView = [[self.arr_contents_list subarrayWithRange:NSMakeRange(0, moreViewCnt)] mutableCopy];
    } else {
        _arr_moreView = [self.arr_contents_list mutableCopy];
    }
    
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

- (void)fileDownloadFinished:(NSNotification*)notification
{
//    [_arr_moreView removeAllObjects];
    [self setDownloadData];
    if ([self.arr_contents_list count] > 20) {
        _arr_moreView = [[self.arr_contents_list subarrayWithRange:NSMakeRange(0, moreViewCnt)] mutableCopy];
    } else {
        _arr_moreView = [self.arr_contents_list mutableCopy];
    }
    
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}
#pragma mark -
#pragma mark Gesture recognizer

- (void)panGestureRecognized:(UIPanGestureRecognizer *)sender
{
    // Dismiss keyboard (optional)
    //
    [self.view endEditing:YES];
    [self.frostedViewController.view endEditing:YES];
    
    // Present the view controller
    //
    [self.frostedViewController panGestureRecognized:sender];
}

- (void)moveAudioPlayView
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *str_file_path = @"";
    if ([[GetGPDataCenter.dic_playInfo objectForKey:@"ctFileType"] integerValue] == FILE_TYPE_AUDIO) {
        str_file_path = [NSString stringWithFormat:@"%@/Contents/%@/%@_%@.mp3",
                         [documentPath objectAtIndex:0],
                         [GetGPDataCenter.dic_playInfo objectForKey:@"prCode"],
                         [GetGPDataCenter.dic_playInfo objectForKey:@"ctName"],
                         [GetGPDataCenter.dic_playInfo objectForKey:@"ctSpeaker"]];
        
        if ([fileManager fileExistsAtPath:str_file_path]) {
            [GPAlertUtil alertWithMessage:@"다운로드된 콘텐츠를 재생합니다."];
        } else {
            [GPAlertUtil alertWithMessage:@"인터넷을 통해 스트리밍되어 재생됩니다."];
        }
        
        GPAudioPlayerViewController *audioPlayer = [self.storyboard instantiateViewControllerWithIdentifier:@"AudioPlayer"];
        audioPlayer.dic_contents_data = [NSMutableDictionary dictionaryWithDictionary:GetGPDataCenter.dic_playInfo];
        [self.navigationController pushViewController:audioPlayer animated:YES];
    }else{
        if ([[GetGPDataCenter.dic_playInfo objectForKey:@"ctFileType"] integerValue] == FILE_TYPE_VIDEO_NORMAL) {
            str_file_path = [NSString stringWithFormat:@"%@/Contents/%@/%@_%@_N.mp4",
                             [documentPath objectAtIndex:0],
                             [GetGPDataCenter.dic_playInfo objectForKey:@"prCode"],
                             [GetGPDataCenter.dic_playInfo objectForKey:@"ctName"],
                             [GetGPDataCenter.dic_playInfo objectForKey:@"ctSpeaker"]];
            
            if ([fileManager fileExistsAtPath:str_file_path]) {
                [GPAlertUtil alertWithMessage:@"다운로드된 콘텐츠를 재생합니다."];
                url_path = [NSURL fileURLWithPath:str_file_path];
            } else {
                [GPAlertUtil alertWithMessage:@"인터넷을 통해 스트리밍되어 재생됩니다."];
                str_file_path = [GetGPDataCenter.dic_playInfo objectForKey:@"ctVideoNormal"];
                url_path = [NSURL URLWithString:str_file_path];
            }
        } else if ([[GetGPDataCenter.dic_playInfo objectForKey:@"ctFileType"] integerValue] == FILE_TYPE_VIDEO_LOW) {
            str_file_path = [NSString stringWithFormat:@"%@/Contents/%@/%@_%@_L.mp4",
                             [documentPath objectAtIndex:0],
                             [GetGPDataCenter.dic_playInfo objectForKey:@"prCode"],
                             [GetGPDataCenter.dic_playInfo objectForKey:@"ctName"],
                             [GetGPDataCenter.dic_playInfo objectForKey:@"ctSpeaker"]];
            
            if ([fileManager fileExistsAtPath:str_file_path]) {
                [GPAlertUtil alertWithMessage:@"다운로드된 콘텐츠를 재생합니다."];
                url_path = [NSURL fileURLWithPath:str_file_path];
            } else {
                [GPAlertUtil alertWithMessage:@"인터넷을 통해 스트리밍되어 재생됩니다."];
                str_file_path = [GetGPDataCenter.dic_playInfo objectForKey:@"ctVideoLow"];
                url_path = [NSURL URLWithString:str_file_path];
            }
        } else if ([[GetGPDataCenter.dic_playInfo objectForKey:@"ctFileType"] integerValue] == FILE_TYPE_VIDEO_STREAM ) {
            str_file_path = [GetGPDataCenter.dic_playInfo objectForKey:@"chIos"];
            url_path = [NSURL URLWithString:str_file_path];
        }

        AppDelegate *mainDelegate = MAIN_APP_DELEGATE();
        [mainDelegate.audioPlayer stop];
        mainDelegate.audioPlayer = [[MPMoviePlayerController alloc] initWithContentURL:url_path];
        mainDelegate.audioPlayer.controlStyle = MPMovieControlStyleFullscreen;
        mainDelegate.audioPlayer.scalingMode = MPMovieScalingModeAspectFit;
        mainDelegate.audioPlayer.view.frame = self.view.bounds;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(MPMoviePlayerDidExitFullscreenNotification)
                                                     name:MPMoviePlayerDidExitFullscreenNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(moviePlayBackDidFinish:)
                                                     name:MPMoviePlayerPlaybackDidFinishNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(MPMoviePlayerLoadStateDidChangeNotification)
                                                     name:MPMoviePlayerLoadStateDidChangeNotification
                                                   object:nil];
        
        [self.view addSubview:mainDelegate.audioPlayer.view];
        
        mainDelegate.audioPlayer.fullscreen = YES;
        
        [mainDelegate.audioPlayer prepareToPlay];
        
        [mainDelegate.audioPlayer.view setFrame:self.view.frame];
        
        [self.view addSubview:mainDelegate.audioPlayer.view];
        
    }
}

- (void)MPMoviePlayerLoadStateDidChangeNotification
{
    AppDelegate *mainDelegate = MAIN_APP_DELEGATE();
    if (mainDelegate.audioPlayer.playbackState == MPMoviePlaybackStatePlaying) {
        if ([[GetGPDataCenter.dic_playInfo objectForKey:@"ctFileType"] integerValue] == FILE_TYPE_VIDEO_LOW ||
            [[GetGPDataCenter.dic_playInfo objectForKey:@"ctFileType"] integerValue] == FILE_TYPE_VIDEO_NORMAL)
        {
            NSLog(@"%lf",GetGPDataCenter.playbackTime);
            [mainDelegate.audioPlayer pause];
            [mainDelegate.audioPlayer setCurrentPlaybackTime:GetGPDataCenter.playbackTime];
            [mainDelegate.audioPlayer play];
        }
    }
}

- (void)MPMoviePlayerDidExitFullscreenNotification
{
    
    AppDelegate *mainDelegate = MAIN_APP_DELEGATE();
    
    if ([[GetGPDataCenter.dic_playInfo objectForKey:@"ctFileType"] integerValue] == FILE_TYPE_VIDEO_LOW ||
        [[GetGPDataCenter.dic_playInfo objectForKey:@"ctFileType"] integerValue] == FILE_TYPE_VIDEO_NORMAL)
    {
        NSLog(@"%lf",mainDelegate.audioPlayer.currentPlaybackTime);
        GetGPDataCenter.playbackTime = mainDelegate.audioPlayer.currentPlaybackTime;
    }
    [mainDelegate.audioPlayer stop];
    [mainDelegate.audioPlayer.view removeFromSuperview];
}

- (void) moviePlayBackDidFinish:(NSNotification*)notification
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerDidExitFullscreenNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerLoadStateDidChangeNotification
                                                  object:nil];
    
    //[self.navigationController popViewControllerAnimated:YES];
}

- (void)setDatas
{
    [self.img_thumb setImageWithURL:[NSURL URLWithString:[self.dic_contents_data objectForKey:@"prThumbS"]] placeholderImage:[UIImage imageNamed:@"thumbnail_none.png"]];
    [self.lbl_Title setText:[self.dic_contents_data objectForKey:@"prTitle"]];
    [self.lbl_subTitle setText:[self.dic_contents_data objectForKey:@"prContent"]];
    
    CGSize maxSize = CGSizeMake(188, 10000);
    CGSize viewSize;
    
    if (IS_iOS_7) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        paragraphStyle.alignment = NSTextAlignmentLeft;
        NSDictionary *attributes = @{NSFontAttributeName:self.lbl_subTitle.font, NSParagraphStyleAttributeName: paragraphStyle};
        viewSize = [[self.dic_contents_data objectForKey:@"prContent"] boundingRectWithSize:maxSize options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                                                                 attributes:attributes  context:nil].size;
    }else{
        viewSize = [[self.dic_contents_data objectForKey:@"prContent"] sizeWithFont:self.lbl_subTitle.font constrainedToSize:maxSize lineBreakMode:NSLineBreakByCharWrapping];
    }

    [self.lbl_subTitle setFrame:CGRectMake(119, 40, viewSize.width, viewSize.height)];
    
    int img_line_y = viewSize.height < 46 ? 92 : viewSize.height + 50;
    [self.img_line setFrame:CGRectMake(10, img_line_y, 300, 1)];
    
    CGSize size = MAIN_SIZE();
    
    [self.tableView setFrame:CGRectMake(0, img_line_y+1, 320, size.height - img_line_y - 65)];
    
//    [self.tv_contents setText:[self.dic_contents_data objectForKey:@"prContent"]];
}

- (void)connectionNetwork {
    NSError                 *error  = nil;
    NSLog(@"url = [%@]",[NSString stringWithFormat:@"%@/%@.json",DEFAULT_URL,[self.dic_contents_data objectForKey:@"prCode"]]);
    NSMutableURLRequest *request = [NSMutableURLRequest
                                    requestWithURL:[[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@/%@.json",DEFAULT_URL,[self.dic_contents_data objectForKey:@"prCode"]]]
                                    cachePolicy:NSURLRequestReloadIgnoringCacheData
                                    timeoutInterval:60.0f];
    
    NSData *dataBuffer = [NSURLConnection sendSynchronousRequest:request returningResponse: nil error: &error];
    
    if (error) {
        [GPAlertUtil alertWithMessage:netError];
    }else {
        NSString *strJSON = [[NSString alloc] initWithData:dataBuffer encoding:NSUTF8StringEncoding];
        NSLog(@"recv : [%@]",strJSON);
        //                [KCCommonUtil fLog:@"RECV:[%@]", strJSON];
        
        self.arr_contents_list = [[NSJSONSerialization
                                   JSONObjectWithData:dataBuffer
                                   options:0 error:&error] mutableCopy];
        
        
        [self setDownloadData];
        if ([self.arr_contents_list count] > 20) {
            _arr_moreView = [[self.arr_contents_list subarrayWithRange:NSMakeRange(0, moreViewCnt)] mutableCopy];
        } else {
            _arr_moreView = [self.arr_contents_list mutableCopy];
        }
        
    }
    [self.tableView reloadData];
}

- (void)setDownloadData
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *str_videoN = @"";
    NSString *str_videoL = @"";
    NSString *str_audio = @"";
    
    for (int i = 0 ; i < [self.arr_contents_list count]; i++) {
        NSMutableDictionary *dic = [[self.arr_contents_list objectAtIndex:i] mutableCopy];
        if ([[dic objectForKey:@"ctName"] isEqualToString:[GetGPDataCenter.dic_fileInfo objectForKey:@"ctName"]]) {
            switch ([GetGPDataCenter.str_fileType integerValue]) {
                case FILE_TYPE_VIDEO_NORMAL:
                    [dic setValue:@"downloading" forKeyPath:@"ctVideoNormalStat"];
                    break;
                case FILE_TYPE_VIDEO_LOW:
                    [dic setValue:@"downloading" forKeyPath:@"ctVideoLowStat"];
                    break;
                case FILE_TYPE_AUDIO:
                    [dic setValue:@"downloading" forKeyPath:@"ctAudioDownStat"];
                    break;
            }
        } else {
            [dic setValue:@"normal" forKeyPath:@"ctVideoNormalStat"];
            [dic setValue:@"normal" forKeyPath:@"ctVideoLowStat"];
            [dic setValue:@"normal" forKeyPath:@"ctAudioDownStat"];
        }
        // 다운로드 대기중 파일 체크
        for (int i = 0; i < [GetGPDataCenter.sendQueue count]; i++) {
            NSDictionary *dic2 = [GetGPDataCenter.sendQueue objectAtIndex:i];
            NSString *type = [GetGPDataCenter.sendQueueForFileType objectAtIndex:i];
            if ([[dic objectForKey:@"ctName"] isEqualToString:[dic2 objectForKey:@"ctName"]]) {
                switch ([type integerValue]) {
                    case FILE_TYPE_VIDEO_NORMAL:
                        [dic setValue:@"wait" forKeyPath:@"ctVideoNormalStat"];
                        break;
                    case FILE_TYPE_VIDEO_LOW:
                        [dic setValue:@"wait" forKeyPath:@"ctVideoLowStat"];
                        break;
                    case FILE_TYPE_AUDIO:
                        [dic setValue:@"wait" forKeyPath:@"ctAudioDownStat"];
                        break;
                    default:
                        break;
                }
            }
        }
        
        str_videoN = [NSString stringWithFormat:@"%@_%@_N.mp4",[dic objectForKey:@"ctName"],[dic objectForKey:@"ctSpeaker"]];
        str_videoL = [NSString stringWithFormat:@"%@_%@_L.mp4",[dic objectForKey:@"ctName"],[dic objectForKey:@"ctSpeaker"]];
        str_audio = [NSString stringWithFormat:@"%@_%@.mp3",[dic objectForKey:@"ctName"],[dic objectForKey:@"ctSpeaker"]];
        
        if ([fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@/Contents/%@/%@",[documentPath objectAtIndex:0],[self.dic_contents_data objectForKey:@"prCode"],str_videoN]]) {
            [dic setValue:@"downloaded" forKeyPath:@"ctVideoNormalStat"];
        }
        if ([fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@/Contents/%@/%@",[documentPath objectAtIndex:0],[self.dic_contents_data objectForKey:@"prCode"],str_videoL]]) {
            [dic setValue:@"downloaded" forKeyPath:@"ctVideoLowStat"];
        }
        if ([fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@/Contents/%@/%@",[documentPath objectAtIndex:0],[self.dic_contents_data objectForKey:@"prCode"],str_audio]]) {
            [dic setValue:@"downloaded" forKeyPath:@"ctAudioDownStat"];
        }
        
        [dic setObject:[self.dic_contents_data objectForKey:@"pcThumb"] == nil ? @"" : [self.dic_contents_data objectForKey:@"pcThumb"] forKey:@"prThumb"];
        [dic setObject:[self.dic_contents_data objectForKey:@"prCode"] == nil ? @"" : [self.dic_contents_data objectForKey:@"prCode"] forKey:@"prCode"];
        [dic setObject:[self.dic_contents_data objectForKey:@"prTitle"] == nil ? @"" :[self.dic_contents_data objectForKey:@"prTitle"] forKey:@"prTitle"];
        
        [self.arr_contents_list removeObjectAtIndex:i];
        [self.arr_contents_list insertObject:dic atIndex:i];
    }
    
}

- (IBAction)pressBtn:(UIButton*)sender
{
    if (sender.tag == 0) {
        _img_back_btn.highlighted = !_img_back_btn.highlighted;
    }else{
        _img_menu_btn.highlighted = !_img_menu_btn.highlighted;
    }
    
}

- (IBAction)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
    _img_back_btn.highlighted = !_img_back_btn.highlighted;
}


- (IBAction)showMenu
{
    // Dismiss keyboard (optional)
    //
    [self.view endEditing:YES];
    [self.frostedViewController.view endEditing:YES];
    
    // Present the view controller
    //
    [self.frostedViewController presentMenuViewController];
    _img_menu_btn.highlighted = !_img_menu_btn.highlighted;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1002) {
        if (buttonIndex == 0) {
            GPSettingViewController *settingViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingView"];
            [self.navigationController pushViewController:settingViewController animated:YES];
        }
    }
}

#pragma mark -
#pragma mark UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.arr_contents_list count] > 20) {
        if ([self.arr_contents_list count] == moreViewCnt) {
            return [_arr_moreView count]+1;
        }
        return [_arr_moreView count]+2;
    } else {
        return [_arr_moreView count];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.arr_contents_list count] > 20) {
        if ([self.arr_contents_list count] == moreViewCnt) {
            if (indexPath.row == [_arr_moreView count]+1) {
                return 46;
            } else {
                return 100;
            }
        }
        if (indexPath.row == [_arr_moreView count]) {
            return 46;
        } else if (indexPath.row == [_arr_moreView count]+1) {
            return 46;
        } else {
            return 100;
        }
    } else {
        return 100;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    static NSString *cellIdentifier = @"ContentCell";
    
    if ([self.arr_contents_list count] > 20) {
        if ([self.arr_contents_list count] == moreViewCnt) {
            if (indexPath.row == [_arr_moreView count]) {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TopCell"];
                
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TopCell"];
                }
                
                UIImageView *img_Top = [[UIImageView alloc] initWithFrame:CGRectMake((320-37.5)/2,
                                                                                     (46-13)/2,
                                                                                     37.5, 13)];
                [img_Top setImage:[UIImage imageNamed:@"icon_TOP.png"]];
                
                [cell addSubview:img_Top];
                
                return cell;
            } else {
                GPGNContentCell *cell = (GPGNContentCell*)[tableView dequeueReusableCellWithIdentifier:@"ContentCell"];
                
                if (cell == nil) {
                    cell = [[GPGNContentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ContentCell"];
                }
                
                NSMutableDictionary *dic_fileInfo = [NSMutableDictionary dictionaryWithDictionary:[_arr_moreView objectAtIndex:indexPath.row]];
                
                [cell setContentsData:dic_fileInfo :[self.dic_contents_data objectForKey:@"prCode"]];
                
                return cell;
            }
        }else{
            if (indexPath.row == [_arr_moreView count]) {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MoreCell"];
                
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MoreCell"];
                }
                
                UILabel *lbl_more = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 46)];
                lbl_more.textAlignment = NSTextAlignmentCenter;
                lbl_more.textColor = UIColorFromRGB(0xabaaaa);
                lbl_more.text = @"더보기";
                
                [cell addSubview:lbl_more];
                
                return cell;
            } else if (indexPath.row == [_arr_moreView count]+1) {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TopCell"];
                
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TopCell"];
                }
                
                UIImageView *img_Top = [[UIImageView alloc] initWithFrame:CGRectMake((320-37.5)/2,
                                                                                     (46-13)/2,
                                                                                     37.5, 13)];
                [img_Top setImage:[UIImage imageNamed:@"icon_TOP.png"]];
                
                [cell addSubview:img_Top];
                
                return cell;
            } else {
                GPGNContentCell *cell = (GPGNContentCell*)[tableView dequeueReusableCellWithIdentifier:@"ContentCell"];
                
                if (cell == nil) {
                    cell = [[GPGNContentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ContentCell"];
                }
                
                NSMutableDictionary *dic_fileInfo = [NSMutableDictionary dictionaryWithDictionary:[_arr_moreView objectAtIndex:indexPath.row]];
                
                [cell setContentsData:dic_fileInfo :[self.dic_contents_data objectForKey:@"prCode"]];
                
                return cell;
            }
        }
    } else {
        GPGNContentCell *cell = (GPGNContentCell*)[tableView dequeueReusableCellWithIdentifier:@"ContentCell"];
        
        if (cell == nil) {
            cell = [[GPGNContentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ContentCell"];
        }
        
        NSMutableDictionary *dic_fileInfo = [NSMutableDictionary dictionaryWithDictionary:[_arr_moreView objectAtIndex:indexPath.row]];
        
        [cell setContentsData:dic_fileInfo :[self.dic_contents_data objectForKey:@"prCode"]];
        
        return cell;
    }
    return nil;
}

- (void)setActionSheet:(NSMutableArray*)items
{
    UIActionSheet *actionSheet = nil;
    
    if ([items count] == 3) {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"닫기" destructiveButtonTitle:nil otherButtonTitles:@"Video 고속",@"Video 저속",@"Audio",nil];
    } else if ([items count] == 2) {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"닫기" destructiveButtonTitle:nil otherButtonTitles:[items objectAtIndex:0],[items objectAtIndex:1],nil];
    } else if ([items count] == 1) {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"닫기" destructiveButtonTitle:nil otherButtonTitles:[items objectAtIndex:0],nil];
    }
    
    
    UIView *keyView = [[[[UIApplication sharedApplication] keyWindow] subviews] objectAtIndex:0];
    [actionSheet showInView:keyView];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *arr_item = [[NSMutableArray alloc] initWithCapacity:1];
    if ([self.arr_contents_list count] > 20) {
        if ([self.arr_contents_list count] == moreViewCnt) {
            if (indexPath.row == [_arr_moreView count]) {
                NSIndexPath* ip = [NSIndexPath indexPathForRow: 0 inSection:0];
                [tableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionNone animated:YES];
            } else {
                self.dic_selected_data = [NSMutableDictionary dictionaryWithDictionary:[self.arr_contents_list objectAtIndex:indexPath.row]];
                
                if ([self.dic_selected_data objectForKey:@"ctVideoNormal"] != nil) {
                    [arr_item addObject:@"Video 고속"];
                }
                if ([self.dic_selected_data objectForKey:@"ctVideoLow"] != nil) {
                    [arr_item addObject:@"Video 저속"];
                }
                if ([self.dic_selected_data objectForKey:@"ctAudioStream"] != nil) {
                    [arr_item addObject:@"Audio"];
                }
                
                [self setActionSheet:arr_item];
            }
        }
        if (indexPath.row == [_arr_moreView count]) {
            [self addMoreView];
        } else if (indexPath.row == [_arr_moreView count]+1) {
            NSIndexPath* ip = [NSIndexPath indexPathForRow: 0 inSection:0];
            [tableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionNone animated:YES];
        } else {
            self.dic_selected_data = [NSMutableDictionary dictionaryWithDictionary:[self.arr_contents_list objectAtIndex:indexPath.row]];
            
            if ([self.dic_selected_data objectForKey:@"ctVideoNormal"] != nil) {
                [arr_item addObject:@"Video 고속"];
            }
            if ([self.dic_selected_data objectForKey:@"ctVideoLow"] != nil) {
                [arr_item addObject:@"Video 저속"];
            }
            if ([self.dic_selected_data objectForKey:@"ctAudioStream"] != nil) {
                [arr_item addObject:@"Audio"];
            }
            
            [self setActionSheet:arr_item];
        }
    } else {
        self.dic_selected_data = [NSMutableDictionary dictionaryWithDictionary:[self.arr_contents_list objectAtIndex:indexPath.row]];
        
        if ([self.dic_selected_data objectForKey:@"ctVideoNormal"] != nil) {
            [arr_item addObject:@"Video 고속"];
        }
        if ([self.dic_selected_data objectForKey:@"ctVideoLow"] != nil) {
            [arr_item addObject:@"Video 저속"];
        }
        if ([self.dic_selected_data objectForKey:@"ctAudioStream"] != nil) {
            [arr_item addObject:@"Audio"];
        }
        
        [self setActionSheet:arr_item];
    }
}

- (void)addMoreView{
    moreViewCnt += 20;
    
    if (moreViewCnt > [self.arr_contents_list count]) {
        moreViewCnt = [self.arr_contents_list count];
    }
    [_arr_moreView removeAllObjects];
    [self setDownloadData];
    _arr_moreView = [[self.arr_contents_list subarrayWithRange:NSMakeRange(0, moreViewCnt)] mutableCopy];
    
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSMutableArray *arr_item = [[NSMutableArray alloc] initWithCapacity:1];
    if ([self.dic_selected_data objectForKey:@"ctVideoNormal"] != nil) {
        [arr_item addObject:[NSDictionary dictionaryWithObjectsAndKeys:[self.dic_selected_data objectForKey:@"ctVideoNormal"],@"streamURL",@"0",@"fileType", nil]];
    }
    if ([self.dic_selected_data objectForKey:@"ctVideoLow"] != nil) {
        [arr_item addObject:[NSDictionary dictionaryWithObjectsAndKeys:[self.dic_selected_data objectForKey:@"ctVideoLow"],@"streamURL",@"1",@"fileType", nil]];
    }
    if ([self.dic_selected_data objectForKey:@"ctAudioStream"] != nil) {
        [arr_item addObject:[NSDictionary dictionaryWithObjectsAndKeys:[self.dic_selected_data objectForKey:@"ctAudioStream"],@"streamURL",@"2",@"fileType", nil]];
    }
    
    if ([arr_item count] - 1 < buttonIndex) {
        return;
    }
    NSDictionary *dic = [arr_item objectAtIndex:buttonIndex];
    
    if ([[dic objectForKey:@"fileType"] integerValue] == FILE_TYPE_VIDEO_NORMAL) {
        [self playMovie:FILE_TYPE_VIDEO_NORMAL];
    } else if ([[dic objectForKey:@"fileType"] integerValue] == FILE_TYPE_VIDEO_LOW) {
        [self playMovie:FILE_TYPE_VIDEO_LOW];
    } else if ([[dic objectForKey:@"fileType"] integerValue] == FILE_TYPE_AUDIO) {
        [self playAudio:FILE_TYPE_AUDIO];
    }
}

- (void)playAudio:(int)buttonIndex
{
    BOOL isUse3G = [GPCommonUtil readBoolFromDefault:@"USE_3G"];
    selBtnType = buttonIndex;
    if (_downCont == nil) {
        AppDelegate *mainDelegate = MAIN_APP_DELEGATE();
        _downCont = mainDelegate.downloadController;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *str_file_path = @"";
    
    str_file_path = [NSString stringWithFormat:@"%@/Contents/%@/%@_%@.mp3",
                     [documentPath objectAtIndex:0],
                     [self.dic_contents_data objectForKey:@"prCode"],
                     [self.dic_selected_data objectForKey:@"ctEventDate"],
                     [self.dic_selected_data objectForKey:@"ctSpeaker"]];
    
    if ([fileManager fileExistsAtPath:str_file_path]) {
        url_path = [NSURL fileURLWithPath:str_file_path];
    } else {
        str_file_path = [self.dic_selected_data objectForKey:@"ctAudioStream"];
        url_path = [NSURL URLWithString:[self.dic_selected_data objectForKey:@"ctAudioStream"]];
    }
    
    NSRange range = [[url_path absoluteString] rangeOfString: @"file://"];
    if (range.location == NSNotFound) {
        if (GetGPDataCenter.gpNetowrkStatus == NETWORK_3G_LTE && !isUse3G) {
            [GPAlertUtil alertWithMessage:netStatus_3G_view delegate:self tag:1];
            return;
        }else{
            [GPAlertUtil alertWithMessage:@"인터넷을 통해 스트리밍되어 재생됩니다."];
            [_downCont downloadFileCheck:self.dic_selected_data FileType:selBtnType isDown:NO];
            return;
        }
    }
    [GPAlertUtil alertWithMessage:@"다운로드된 콘텐츠를 재생합니다."];
    GPAudioPlayerViewController *audioPlayer = [self.storyboard instantiateViewControllerWithIdentifier:@"AudioPlayer"];
    [self.dic_selected_data setObject:[self.dic_contents_data objectForKey:@"prThumbS"] forKey:@"prThumb"];
    audioPlayer.dic_contents_data = [NSMutableDictionary dictionaryWithDictionary:self.dic_selected_data];
    audioPlayer.prCode = [self.dic_contents_data objectForKey:@"prCode"];
    [self.navigationController pushViewController:audioPlayer animated:YES];
}

- (void)playMovie:(int)buttonIndex
{
    BOOL isUse3G = [GPCommonUtil readBoolFromDefault:@"USE_3G"];
    selBtnType = buttonIndex;
    if (_downCont == nil) {
        AppDelegate *mainDelegate = MAIN_APP_DELEGATE();
        _downCont = mainDelegate.downloadController;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *str_file_path = @"";
    if (buttonIndex == 0) {
        str_file_path = [NSString stringWithFormat:@"%@/Contents/%@/%@_%@_N.mp4",
                         [documentPath objectAtIndex:0],
                         [self.dic_contents_data objectForKey:@"prCode"],
                         [self.dic_selected_data objectForKey:@"ctName"],
                         [self.dic_selected_data objectForKey:@"ctSpeaker"]];
        
        [self.dic_selected_data setObject:@"0" forKey:@"ctFileType"];
        if ([fileManager fileExistsAtPath:str_file_path]) {
            url_path = [NSURL fileURLWithPath:str_file_path];
        } else {
            str_file_path = [self.dic_selected_data objectForKey:@"ctVideoNormal"];
            url_path = [NSURL URLWithString:[self.dic_selected_data objectForKey:@"ctVideoNormal"]];
        }
    } else if (buttonIndex == 1) {
        str_file_path = [NSString stringWithFormat:@"%@/Contents/%@/%@_%@_L.mp4",
                         [documentPath objectAtIndex:0],
                         [self.dic_contents_data objectForKey:@"prCode"],
                         [self.dic_selected_data objectForKey:@"ctName"],
                         [self.dic_selected_data objectForKey:@"ctSpeaker"]];
        
        [self.dic_selected_data setObject:@"1" forKey:@"ctFileType"];
        if ([fileManager fileExistsAtPath:str_file_path]) {
            url_path = [NSURL fileURLWithPath:str_file_path];
        } else {
            str_file_path = [self.dic_selected_data objectForKey:@"ctVideoLow"];
            url_path = [NSURL URLWithString:[self.dic_selected_data objectForKey:@"ctVideoLow"]];
        }
    }
    
    NSRange range = [[url_path absoluteString] rangeOfString: @"file://"];
    if (range.location == NSNotFound) {
        if (GetGPDataCenter.gpNetowrkStatus == NETWORK_3G_LTE && !isUse3G) {
            [GPAlertUtil alertWithMessage:netStatus_3G_view delegate:self tag:1];
            return;
        }else{
            [GPAlertUtil alertWithMessage:@"인터넷을 통해 스트리밍되어 재생됩니다."];
            [_downCont downloadFileCheck:self.dic_selected_data FileType:selBtnType isDown:NO];
            return;
        }
    }
    [GPAlertUtil alertWithMessage:@"다운로드된 콘텐츠를 재생합니다."];
    AppDelegate *mainDelegate = MAIN_APP_DELEGATE();
    [mainDelegate.audioPlayer stop];
    mainDelegate.audioPlayer = [[MPMoviePlayerController alloc] initWithContentURL:url_path];
    mainDelegate.audioPlayer.controlStyle = MPMovieControlStyleFullscreen;
    mainDelegate.audioPlayer.scalingMode = MPMovieScalingModeAspectFit;
    mainDelegate.audioPlayer.view.frame = self.view.bounds;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(MPMoviePlayerDidExitFullscreenNotification)
                                                 name:MPMoviePlayerDidExitFullscreenNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(MPMoviePlayerLoadStateDidChangeNotification)
                                                 name:MPMoviePlayerLoadStateDidChangeNotification
                                               object:nil];
    
    [self.view addSubview:mainDelegate.audioPlayer.view];
    
    mainDelegate.audioPlayer.fullscreen = YES;
    
    [mainDelegate.audioPlayer prepareToPlay];
    
    [mainDelegate.audioPlayer.view setFrame:self.view.frame];
    
    [self.view addSubview:mainDelegate.audioPlayer.view];
    
    if (![[GetGPDataCenter.dic_playInfo objectForKey:@"ctName"] isEqualToString:[self.dic_selected_data objectForKey:@"ctName"]] ||
        ![[GetGPDataCenter.dic_playInfo objectForKey:@"ctFileType"] isEqualToString:[self.dic_selected_data objectForKey:@"ctFileType"]]) {
        GetGPDataCenter.playbackTime = 0.0f;
    }
    
    GetGPDataCenter.dic_playInfo = self.dic_selected_data;
    GetGPDataCenter.isAudioPlaying = YES;
}

- (void)filePlayMovie:(int)buttonIndex selData:(NSDictionary*)dic_data
{
    NSArray *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *str_file_path = @"";
    
    if (buttonIndex == 0) {
        str_file_path = [NSString stringWithFormat:@"%@/Contents/%@/%@_%@_N.mp4",
                         [documentPath objectAtIndex:0],
                         [dic_data objectForKey:@"prCode"],
                         [dic_data objectForKey:@"ctName"],
                         [dic_data objectForKey:@"ctSpeaker"]];
        
        url_path = [NSURL fileURLWithPath:str_file_path];
    } else if (buttonIndex == 1) {
        str_file_path = [NSString stringWithFormat:@"%@/Contents/%@/%@_%@_L.mp4",
                         [documentPath objectAtIndex:0],
                         [dic_data objectForKey:@"prCode"],
                         [dic_data objectForKey:@"ctName"],
                         [dic_data objectForKey:@"ctSpeaker"]];
        
        url_path = [NSURL fileURLWithPath:str_file_path];
    }
    
    AppDelegate *mainDelegate = MAIN_APP_DELEGATE();
    [mainDelegate.audioPlayer stop];
    mainDelegate.audioPlayer = [[MPMoviePlayerController alloc] initWithContentURL:url_path];
    mainDelegate.audioPlayer.controlStyle = MPMovieControlStyleFullscreen;
    mainDelegate.audioPlayer.scalingMode = MPMovieScalingModeAspectFit;
    mainDelegate.audioPlayer.view.frame = self.view.bounds;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(MPMoviePlayerDidExitFullscreenNotification)
                                                 name:MPMoviePlayerDidExitFullscreenNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(MPMoviePlayerLoadStateDidChangeNotification)
                                                 name:MPMoviePlayerLoadStateDidChangeNotification
                                               object:nil];
    
    [self.view addSubview:mainDelegate.audioPlayer.view];
    
    mainDelegate.audioPlayer.fullscreen = YES;
    
    [mainDelegate.audioPlayer prepareToPlay];
    
    [mainDelegate.audioPlayer.view setFrame:self.view.frame];
    
    [self.view addSubview:mainDelegate.audioPlayer.view];
    
    
    if (![[GetGPDataCenter.dic_playInfo objectForKey:@"ctName"] isEqualToString:[dic_data objectForKey:@"ctName"]] ||
        ![[GetGPDataCenter.dic_playInfo objectForKey:@"ctFileType"] isEqualToString:[dic_data objectForKey:@"ctFileType"]]) {
        GetGPDataCenter.playbackTime = 0.0f;
    }
    
    GetGPDataCenter.dic_playInfo = [NSMutableDictionary dictionaryWithDictionary:dic_data];
    GetGPDataCenter.isAudioPlaying = YES;
}

- (void)filePlayAudio:(NSDictionary*)dic_data
{
    NSArray *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *str_file_path = @"";
    
    str_file_path = [NSString stringWithFormat:@"%@/Contents/%@/%@_%@.mp3",
                     [documentPath objectAtIndex:0],
                     [dic_data objectForKey:@"prCode"],
                     [dic_data objectForKey:@"ctEventDate"],
                     [dic_data objectForKey:@"ctSpeaker"]];
    
    url_path = [NSURL fileURLWithPath:str_file_path];
    
    GPAudioPlayerViewController *audioPlayer = [self.storyboard instantiateViewControllerWithIdentifier:@"AudioPlayer"];
    [self.dic_selected_data setObject:[self.dic_contents_data objectForKey:@"prThumbS"] forKey:@"prThumb"];
    audioPlayer.dic_contents_data = [NSMutableDictionary dictionaryWithDictionary:self.dic_selected_data];
    audioPlayer.prCode = [self.dic_contents_data objectForKey:@"prCode"];
    [self.navigationController pushViewController:audioPlayer animated:YES];
}

- (void)filePlaying:(NSNotification*)noti
{
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:noti.userInfo];
    switch ([[userInfo objectForKey:@"ctFileType"] integerValue]) {
        case 0:
        {
            [self filePlayMovie:FILE_TYPE_VIDEO_NORMAL selData:userInfo];
        }
            break;
        case 1:
        {
            [self filePlayMovie:FILE_TYPE_VIDEO_LOW selData:userInfo];
        }
            break;
        case 2:
        {
            [self filePlayAudio:userInfo];
        }
            break;
        default:
            break;
    }
}

- (void)fileStreaming:(NSNotification*)noti
{
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:noti.userInfo];
    switch ([[userInfo objectForKey:@"ctFileType"] integerValue]) {
        case 0:
        case 1:
        {
            if ([[userInfo objectForKey:@"ctFileType"] integerValue] == 0) {
                url_path = [NSURL URLWithString:[userInfo objectForKey:@"ctVideoNormal"]];
            } else if ([[userInfo objectForKey:@"ctFileType"] integerValue] == 1) {
                url_path = [NSURL URLWithString:[userInfo objectForKey:@"ctVideoLow"]];
            }
            
            AppDelegate *mainDelegate = MAIN_APP_DELEGATE();
            [mainDelegate.audioPlayer stop];
            mainDelegate.audioPlayer = [[MPMoviePlayerController alloc] initWithContentURL:url_path];
            mainDelegate.audioPlayer.controlStyle = MPMovieControlStyleFullscreen;
            mainDelegate.audioPlayer.scalingMode = MPMovieScalingModeAspectFit;
            mainDelegate.audioPlayer.view.frame = self.view.bounds;
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(MPMoviePlayerDidExitFullscreenNotification)
                                                         name:MPMoviePlayerDidExitFullscreenNotification
                                                       object:nil];
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(moviePlayBackDidFinish:)
                                                         name:MPMoviePlayerPlaybackDidFinishNotification
                                                       object:nil];
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(MPMoviePlayerLoadStateDidChangeNotification)
                                                         name:MPMoviePlayerLoadStateDidChangeNotification
                                                       object:nil];
            
            [self.view addSubview:mainDelegate.audioPlayer.view];
            
            mainDelegate.audioPlayer.fullscreen = YES;
            
            [mainDelegate.audioPlayer prepareToPlay];
            
            [mainDelegate.audioPlayer.view setFrame:self.view.frame];
            
            [self.view addSubview:mainDelegate.audioPlayer.view];
            
            if (![[GetGPDataCenter.dic_playInfo objectForKey:@"ctName"] isEqualToString:[self.dic_selected_data objectForKey:@"ctName"]] ||
                ![[GetGPDataCenter.dic_playInfo objectForKey:@"ctFileType"] isEqualToString:[self.dic_selected_data objectForKey:@"ctFileType"]]) {
                GetGPDataCenter.playbackTime = 0.0f;
            }
            
            GetGPDataCenter.dic_playInfo = self.dic_selected_data;
            GetGPDataCenter.isAudioPlaying = YES;
            
        }
            break;
        case 2:
        {
            GPAudioPlayerViewController *audioPlayer = [self.storyboard instantiateViewControllerWithIdentifier:@"AudioPlayer"];
            [userInfo setObject:[self.dic_contents_data objectForKey:@"prThumbS"] forKey:@"prThumb"];
            audioPlayer.dic_contents_data = [NSMutableDictionary dictionaryWithDictionary:userInfo];
            audioPlayer.prCode = [self.dic_contents_data objectForKey:@"prCode"];
            [self.navigationController pushViewController:audioPlayer animated:YES];
        }
            break;
        default:
            break;
    }
}

- (BOOL)shouldAutorotate
{
    return NO;
}

@end
