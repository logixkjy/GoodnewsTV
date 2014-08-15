//
//  GPLiveCastViewController.m
//  GoodNewsPodcast
//
//  Created by 김주영 on 2014. 7. 29..
//  Copyright (c) 2014년 GoodNews. All rights reserved.
//

#import "GPLiveCastViewController.h"
#import "GPAudioPlayerViewController.h"
#import "GPSettingViewController.h"
#import "GPMoviePlayerViewController.h"
#import "SBJsonParser.h"
@import QuartzCore;

@interface GPLiveCastViewController ()

@end

@implementation GPLiveCastViewController

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
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];
    
    //백그라운드에서 재생
    AVAudioSession*session =[AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [session setActive:YES error:nil];
    
    // Do any additional setup after loading the view.
    [self.view addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)]];
    
    self.arr_views    = [[NSMutableArray alloc] initWithCapacity:2];
    self.arr_bg_img   = [[NSMutableArray alloc] initWithCapacity:2];
    self.arr_btns   = [[NSMutableArray alloc] initWithCapacity:2];
    self.arr_labels   = [[NSMutableArray alloc] initWithCapacity:2];
    
    [self.arr_views addObject:self.view_major_TV];
    [self.arr_views addObject:self.view_major_Audio];
    
    [self.arr_bg_img addObject:self.img_major_TV_bg];
    [self.arr_bg_img addObject:self.img_major_Audio_bg];
    
    [self.arr_labels addObject:self.lbl_major_TV];
    [self.arr_labels addObject:self.lbl_major_Audio];
    
    [self.arr_btns addObject:self.btn_major_TV];
    [self.arr_btns addObject:self.btn_major_Audio];
    
    count = 5;
    isFirst = NO;
    
    str_selCh = @"";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moveSettingView)
                                                 name:_CMD_MOVE_SETTING_VIEW
                                               object:nil];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    self.btn_nowplay.hidden = !GetGPDataCenter.isAudioPlaying;
    [self.btn_nowplay addTarget:self action:@selector(moveAudioPlayView) forControlEvents:UIControlEventTouchUpInside];
    [self connectionNetwork:@"appMsg"];
}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [timer invalidate];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:_CMD_MOVE_SETTING_VIEW object:nil];
}

- (void)connectionNetwork:(NSString*)type {
    NSError                 *error  = nil;
    NSMutableURLRequest *request = [NSMutableURLRequest
                                    requestWithURL:[[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@/%@.json",DEFAULT_URL,type]]
                                    cachePolicy:NSURLRequestReloadIgnoringCacheData
                                    timeoutInterval:60.0f];
    
    NSData *dataBuffer = [NSURLConnection sendSynchronousRequest:request returningResponse: nil error: &error];
    
    if (error) {
        [GPAlertUtil alertWithMessage:netError];
    }else {
        NSString *strJSON = [[NSString alloc] initWithData:dataBuffer encoding:NSUTF8StringEncoding];
        NSLog(@"recv : [%@]",strJSON);
        //                [KCCommonUtil fLog:@"RECV:[%@]", strJSON];
        
        NSArray *_arr_json = [[NSMutableArray alloc] init];
        NSDictionary *_dic_json = [[NSMutableDictionary alloc] init];
        SBJsonParser *sbParser = [[SBJsonParser alloc] init];
        if ([[sbParser objectWithString:strJSON] isKindOfClass:[NSMutableArray class]]) {
            _arr_json = (NSMutableArray*)[sbParser objectWithString:strJSON];
        } else if ([[sbParser objectWithString:strJSON] isKindOfClass:[NSMutableDictionary class]]) {
            _dic_json = (NSMutableDictionary*)[sbParser objectWithString:strJSON];
        }
        if ([type isEqualToString:@"appMsg"]) {
            self.dic_MsgIfo = [NSMutableDictionary dictionaryWithDictionary:_dic_json];
            [self connectionNetwork:@"channel"];
        } else {
            self.arr_channelList    = [[NSMutableArray alloc] initWithCapacity:2];
            for (int j = 0; j < [_arr_json count]; j++) {
                if ([[[_arr_json objectAtIndex:j] objectForKey:@"chIsLive"] isEqualToString:@"YES"]) {
                    [self.arr_channelList addObject:[_arr_json objectAtIndex:j]];
                }
            }
            
            [self setMenu:self.arr_channelList];
        }
    }
}

- (void)changeMsg
{
    if (count == 0) {
        [timer invalidate];
        self.lbl_msg.hidden = YES;
        [self moveLiveStreamingView:[[self.dic_MsgIfo objectForKey:@"chNO"] intValue]-1];
    } else {
        self.lbl_msg.text = [NSString stringWithFormat:@"%d%@",count,[self.dic_MsgIfo objectForKey:@"appMsg"]];
        count--;
    }
}

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

- (void)setMenu:(NSMutableArray*)menuData
{
    NSDictionary *dic_ch = [self.arr_channelList objectAtIndex:0];
    self.btn_major_TV.enabled = [[dic_ch objectForKey:@"chIsLive"] isEqualToString:@"YES"];
    dic_ch = [self.arr_channelList objectAtIndex:1];
    self.btn_major_Audio.enabled = [[dic_ch objectForKey:@"chIsLive"] isEqualToString:@"YES"];
    
    
    if (isFirst) {
        NSMutableIndexSet *itemToRemove = [[NSMutableIndexSet alloc] init];;
        for (int k = 2; k < [self.arr_channelList count]; k++) {
            UIView *view = [self.arr_views objectAtIndex:k];
            [itemToRemove addIndex:k];
            [view removeFromSuperview];
        }
        [self.arr_views removeObjectsAtIndexes:itemToRemove];
        [self.arr_bg_img removeObjectsAtIndexes:itemToRemove];
        [self.arr_labels removeObjectsAtIndexes:itemToRemove];
        [self.arr_btns removeObjectsAtIndexes:itemToRemove];
    }
    
    for (int i = 2; i < [self.arr_channelList count]; i++) {
        dic_ch = [self.arr_channelList objectAtIndex:i];
        UIView *btn_view = [[UIView alloc] initWithFrame:CGRectMake((i%2 == 0 ? 10 : 135 ), (i < 4 ? 247 : 314), 115, 57)];
        [btn_view setBackgroundColor:[UIColor clearColor]];
        
        UIImageView *btn_bg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 115, 57)];
        [btn_bg setBackgroundColor:[UIColor blackColor]];
        [btn_bg setAlpha:0.4f];
        [btn_view addSubview:btn_bg];
        
        UILabel *btn_title = [[UILabel alloc] initWithFrame:CGRectMake(5, 17, 105, 17)];
        btn_title.textAlignment = NSTextAlignmentCenter;
        btn_title.textColor = [UIColor whiteColor];
        btn_title.font = [UIFont systemFontOfSize:15];
        btn_title.text = [[menuData objectAtIndex:i] objectForKey:@"chName"];
        [btn_view addSubview:btn_title];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(0, 0, 115, 57)];
        [button setTag:i];
        [button addTarget:self action:@selector(buttonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        button.enabled = [[dic_ch objectForKey:@"chIsLive"] isEqualToString:@"YES"];
        [btn_view addSubview:button];
        
        
        [self.menu_view addSubview:btn_view];
        
        [self.arr_views addObject:btn_view];
        [self.arr_bg_img addObject:btn_bg];
        [self.arr_labels addObject:btn_title];
        [self.arr_btns addObject:button];
    }
    if (!isFirst) {
        for (int i = 0; i < [self.arr_views count]; i++) {
            UIView *view = [self.arr_views objectAtIndex:i];
            UIImageView *img = [self.arr_bg_img objectAtIndex:i];
            
            if ([[self.dic_MsgIfo objectForKey:@"chNO"] intValue]-1 == i) {
                view.layer.borderWidth = 2.0f;
                view.layer.borderColor=[UIColorFromRGB(0xf74300) CGColor];
                img.alpha = 0.5f;
                
                [self.img_major_TV_check setFrame:CGRectMake(view.frame.origin.x + view.frame.size.width - 20, view.frame.origin.y - 5, 25, 25)];
                self.img_major_TV_check.hidden = NO;
                [self.menu_view bringSubviewToFront:self.img_major_TV_check];
            } else {
                view.layer.borderWidth = 0.0f;
                view.layer.borderColor=[UIColorFromRGB(0xf74300) CGColor];
                img.alpha = 0.4f;
            }
        }
        isFirst = YES;
    } else {
        for (int i = 0; i < [self.arr_views count]; i++) {
            NSMutableDictionary *dic_ch = [self.arr_channelList objectAtIndex:i];
            UIView *view = [self.arr_views objectAtIndex:i];
            UIImageView *img = [self.arr_bg_img objectAtIndex:i];
            if ([str_selCh isEqualToString:[dic_ch objectForKey:@"chIos"]]) {
                view.layer.borderWidth = 2.0f;
                view.layer.borderColor=[UIColorFromRGB(0xf74300) CGColor];
                img.alpha = 0.5f;
                
                [self.img_major_TV_check setFrame:CGRectMake(view.frame.origin.x + view.frame.size.width - 20, view.frame.origin.y - 5, 25, 25)];
                self.img_major_TV_check.hidden = NO;
                [self.menu_view bringSubviewToFront:self.img_major_TV_check];
            } else {
                view.layer.borderWidth = 0.0f;
                view.layer.borderColor=[UIColorFromRGB(0xf74300) CGColor];
                img.alpha = 0.4f;
            }
        }
    }
    
    if ([[self.dic_MsgIfo objectForKey:@"chIsLive"] isEqualToString:@"YES"]) {
        if (timer == nil) {
            timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(changeMsg) userInfo:nil repeats:YES];
        }
    } else {
        self.lbl_msg.text = [self.dic_MsgIfo objectForKey:@"appMsg"];
    }
}

- (IBAction)buttonTouchUpInside:(id)sender
{
    [timer invalidate];
    self.lbl_msg.hidden = YES;
    UIButton *btn = (UIButton*)sender;
    for (int i = 0; i < [self.arr_views count]; i++) {
        UIView *view = [self.arr_views objectAtIndex:i];
        UIImageView *img = [self.arr_bg_img objectAtIndex:i];
        
        if (btn.tag == i) {
            view.layer.borderWidth = 2.0f;
            view.layer.borderColor=[UIColorFromRGB(0xf74300) CGColor];
            img.alpha = 0.5f;
            
            [self.img_major_TV_check setFrame:CGRectMake(view.frame.origin.x + view.frame.size.width - 20, view.frame.origin.y - 5, 25, 25)];
            self.img_major_TV_check.hidden = NO;
            [self.menu_view bringSubviewToFront:self.img_major_TV_check];
        } else {
            view.layer.borderWidth = 0.0f;
            view.layer.borderColor=[UIColorFromRGB(0xf74300) CGColor];
            img.alpha = 0.4f;
        }
    }
    [self moveLiveStreamingView:btn.tag];
}

- (void)moveLiveStreamingView:(int)idx
{
    NSMutableDictionary *dic_ch = [self.arr_channelList objectAtIndex:idx];
    str_selCh = [dic_ch objectForKey:@"chIos"];
    if ([[dic_ch objectForKey:@"chType"] isEqualToString:@"VIDEO"]) {
        [dic_ch setObject:[NSString stringWithFormat:@"%d",FILE_TYPE_VIDEO_STREAM] forKey:@"ctFileType"];
        GetGPDataCenter.dic_playInfo = [NSMutableDictionary dictionaryWithDictionary:dic_ch];
        GetGPDataCenter.isAudioPlaying = YES;
        AppDelegate *mainDelegate = MAIN_APP_DELEGATE();
        [mainDelegate.audioPlayer stop];
        mainDelegate.audioPlayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:[dic_ch objectForKey:@"chIos"]]];
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
    } else {
        [dic_ch setObject:[dic_ch objectForKey:@"chName"] forKey:@"ctName"];
        [dic_ch setObject:@"" forKey:@"ctPhrase"];
        [dic_ch setObject:@"" forKey:@"ctSpeaker"];
        [dic_ch setObject:@"" forKey:@"ctEventDate"];
        [dic_ch setObject:[dic_ch objectForKey:@"chIos"] forKey:@"ctAudioStream"];
        [dic_ch setObject:[NSString stringWithFormat:@"%d",FILE_TYPE_AUDIO_STREAM] forKey:@"ctFileType"];
        GPAudioPlayerViewController *audioPlayer = [self.storyboard instantiateViewControllerWithIdentifier:@"AudioPlayer"];
        audioPlayer.dic_contents_data = [NSMutableDictionary dictionaryWithDictionary:dic_ch];
        [self.navigationController pushViewController:audioPlayer animated:YES];
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

- (IBAction)pressBtn
{
    _img_btn.highlighted = !_img_btn.highlighted;
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
    _img_btn.highlighted = !_img_btn.highlighted;
}

- (void)moveAudioPlayView
{
    if ([[GetGPDataCenter.dic_playInfo objectForKey:@"ctFileType"] integerValue] == FILE_TYPE_AUDIO) {
        GPAudioPlayerViewController *audioPlayer = [self.storyboard instantiateViewControllerWithIdentifier:@"AudioPlayer"];
        audioPlayer.dic_contents_data = [NSMutableDictionary dictionaryWithDictionary:GetGPDataCenter.dic_playInfo];
        [self.navigationController pushViewController:audioPlayer animated:YES];
    }else{
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        NSString *str_file_path = @"";
        NSURL *url_path = nil;
        if ([[GetGPDataCenter.dic_playInfo objectForKey:@"ctFileType"] integerValue] == FILE_TYPE_VIDEO_NORMAL) {
            str_file_path = [NSString stringWithFormat:@"%@/Contents/%@/%@_%@_N.mp4",
                             [documentPath objectAtIndex:0],
                             [GetGPDataCenter.dic_playInfo objectForKey:@"prCode"],
                             [GetGPDataCenter.dic_playInfo objectForKey:@"ctName"],
                             [GetGPDataCenter.dic_playInfo objectForKey:@"ctSpeaker"]];
            
            if ([fileManager fileExistsAtPath:str_file_path]) {
                url_path = [NSURL fileURLWithPath:str_file_path];
            } else {
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
                url_path = [NSURL fileURLWithPath:str_file_path];
            } else {
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
        
        [self.view addSubview:mainDelegate.audioPlayer.view];
        
        mainDelegate.audioPlayer.fullscreen = YES;
        
        [mainDelegate.audioPlayer prepareToPlay];
        
        [mainDelegate.audioPlayer.view setFrame:self.view.frame];
        
        [self.view addSubview:mainDelegate.audioPlayer.view];
        
    }
}

- (void)moveSettingView
{
    GPSettingViewController *settingViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingView"];
    [self.navigationController pushViewController:settingViewController animated:YES];
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



@end
