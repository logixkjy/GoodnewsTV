//
//  GPAudioPlayerViewController.m
//  GoodNewsPodcast
//
//  Created by 김주영 on 2014. 7. 16..
//  Copyright (c) 2014년 GoodNews. All rights reserved.
//

#import "GPAudioPlayerViewController.h"
#import "GPSettingViewController.h"
@import AVFoundation;
@import AudioToolbox;

@interface GPAudioPlayerViewController ()

@end

@implementation GPAudioPlayerViewController

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
    isFileOpenFail = NO;
    //이걸 지우면 전화걸때... 꺼짐
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];
    
    //백그라운드에서 재생
    AVAudioSession*session =[AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [session setActive:YES error:nil];
    
    mainDelegate = MAIN_APP_DELEGATE();
    
    if (![[GetGPDataCenter.dic_playInfo objectForKey:@"ctName"] isEqualToString:[self.dic_contents_data objectForKey:@"ctName"]]) {
        [mainDelegate.audioPlayer stop];
        GetGPDataCenter.isAudioPlaying = NO;
    }
    
    if (!GetGPDataCenter.isAudioPlaying ||
        mainDelegate.audioPlayer.playbackState == MPMoviePlaybackStateStopped)
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        NSString *str_file_path = [NSString stringWithFormat:@"%@/Contents/%@",
                                   [documentPath objectAtIndex:0],self.prCode];
        if ([self.dic_contents_data objectForKey:@"ctFileName"] != nil) {
            str_file_path = [str_file_path stringByAppendingPathComponent:[self.dic_contents_data objectForKey:@"ctFileName"]];
        }else {
            str_file_path = [str_file_path stringByAppendingFormat:@"/%@_%@.mp3", [self.dic_contents_data objectForKey:@"ctEventDate"], [self.dic_contents_data objectForKey:@"ctSpeaker"]];
        }
        
        NSURL *url_path = nil;
        
        if ([fileManager fileExistsAtPath:str_file_path]) {
            url_path = [NSURL fileURLWithPath:str_file_path];
        } else {
            url_path = [NSURL URLWithString:[self.dic_contents_data objectForKey:@"ctAudioStream"] != nil ? [self.dic_contents_data objectForKey:@"ctAudioStream"] : [self.dic_contents_data objectForKey:@"ctFileUrl"]];
        }
        
        if (![[GetGPDataCenter.dic_playInfo objectForKey:@"ctName"] isEqualToString:[self.dic_contents_data objectForKey:@"ctName"]]||
            ![[GetGPDataCenter.dic_playInfo objectForKey:@"ctFileType"] isEqualToString:[self.dic_contents_data objectForKey:@"ctFileType"]]) {
            mainDelegate.audioPlayer =  [[MPMoviePlayerController alloc] initWithContentURL:url_path];
            mainDelegate.audioPlayer.shouldAutoplay = YES;
            [mainDelegate.audioPlayer prepareToPlay];
            
            
        } else {
            self.timeProgress.maximumValue = mainDelegate.audioPlayer.duration;
        }
        
        mainDelegate.audioPlayer.controlStyle = MPMovieControlStyleNone;
        
        mainDelegate.audioPlayer.view.hidden = YES;
        
        [self.dic_contents_data setObject:@"2" forKey:@"ctFileType"];
        GetGPDataCenter.dic_playInfo = [NSMutableDictionary dictionaryWithDictionary:self.dic_contents_data];
        
        if ([self.dic_contents_data objectForKey:@"chIos"] == nil) {
            self.timeProgress.enabled = YES;
            [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updatePlaybackProgressFromTimer:) userInfo:nil repeats:YES];
        } else {
            self.timeProgress.enabled = NO;
            self.lbl_playtime.text = @"--:--:--";
            self.lbl_lasttime.text = @"--:--:--";
        }
        //        mainDelegate.audioPlayer = audioPlayer;
    }else {
        self.btn_play.selected = mainDelegate.audioPlayer.playbackState == MPMoviePlaybackStatePaused ? NO : YES;
        
        self.timeProgress.maximumValue = mainDelegate.audioPlayer.duration;
        self.timeProgress.value = GetGPDataCenter.playbackTime;

        if ([self.dic_contents_data objectForKey:@"chIos"] == nil) {
//            [mainDelegate.audioPlayer setCurrentPlaybackTime:GetGPDataCenter.playbackTime];
            self.lbl_playtime.text = [NSString stringWithFormat:@"%@",[self convertIntToTime:(int)GetGPDataCenter.playbackTime]];
            
            self.lbl_lasttime.text = [NSString stringWithFormat:@"-%@",[self convertIntToTime:fabs((int)(GetGPDataCenter.playbackTime-mainDelegate.audioPlayer.duration))]];
            [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updatePlaybackProgressFromTimer:) userInfo:nil repeats:YES];
        } else {
            self.timeProgress.enabled = NO;
            self.lbl_playtime.text = @"--:--:--";
            self.lbl_lasttime.text = @"--:--:--";
        }
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:mainDelegate.audioPlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayerLoadStateChanged:)
                                                 name:MPMoviePlayerLoadStateDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:mainDelegate.audioPlayer];
    
    [[UISlider appearance] setThumbImage:[UIImage imageNamed:@"player_time_handle.png"] forState:UIControlStateNormal];
    
    if (!IS_4_INCH) {
        CGSize size = MAIN_SIZE();
        [self.playerView bringSubviewToFront:self.toolbarView];
        [self.img_thumb setFrame:CGRectMake(0, 0, 320, size.height - 64 - self.toolbarView.frame.size.height)];
        [self.img_thumb setImageWithURL:[NSURL URLWithString:[self.dic_contents_data objectForKey:@"prThumb"]]  placeholderImage:[UIImage imageNamed:@"thumbnail_none.png"]];
        [self.toolbarView setFrame:CGRectMake(0, size.height - 64 - self.toolbarView.frame.size.height, self.toolbarView.frame.size.width , self.toolbarView.frame.size.height)];
    } else {
        [self.img_thumb setImageWithURL:[NSURL URLWithString:[self.dic_contents_data objectForKey:@"prThumb"]]  placeholderImage:[UIImage imageNamed:@"thumbnail_none_square.png"]];
    }
    
    CGSize maxSize = CGSizeMake(239, 27);
    CGSize viewSize;
    
    if (IS_iOS_7) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        paragraphStyle.alignment = NSTextAlignmentLeft;
        NSDictionary *attributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:20], NSParagraphStyleAttributeName: paragraphStyle};
        viewSize = [[self.dic_contents_data objectForKey:@"ctName"] boundingRectWithSize:maxSize options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                                                                 attributes:attributes  context:nil].size;
    }else{
        viewSize = [[self.dic_contents_data objectForKey:@"ctName"] sizeWithFont:[UIFont boldSystemFontOfSize:20] constrainedToSize:maxSize lineBreakMode:NSLineBreakByCharWrapping];
    }
    
    [self.asl_naviTitle setFrame:CGRectMake((320 - viewSize.width)/2, 9, viewSize.width, viewSize.height)];
    self.asl_naviTitle.text = [self.dic_contents_data objectForKey:@"ctName"];
    self.asl_naviTitle.pauseInterval = 3.f;
    self.asl_naviTitle.font = [UIFont boldSystemFontOfSize:20];
    self.asl_naviTitle.textColor = [UIColor whiteColor];
    self.asl_naviTitle.shadowOffset = CGSizeMake(-1, -1);
    self.asl_naviTitle.shadowColor = [UIColor blackColor];
    self.asl_naviTitle.textAlignment = NSTextAlignmentCenter;
    [self.asl_naviTitle observeApplicationNotifications];
    
    if ([[self.dic_contents_data objectForKey:@"ctEventDate"] isEqualToString:@""]) {
        [self.lbl_title setText:@""];
        [self.lbl_subtitle setText:@""];
    } else {
        [self.lbl_title setText:[NSString stringWithFormat:@"%@ %@",[self.dic_contents_data objectForKey:@"ctEventDate"],[self.dic_contents_data objectForKey:@"ctPhrase"]]];
        [self.lbl_subtitle setText:[self.dic_contents_data objectForKey:@"ctName"]];
    }
    
    
    MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:self.volumeView.bounds];
    [self.volumeView addSubview:volumeView];
    [volumeView sizeToFit];
    
    
}

-(void)viewWillAppear:(BOOL)animated {
    self.screenName = @"ContentsView";
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moveSettingView)
                                                 name:_CMD_MOVE_SETTING_VIEW
                                               object:nil];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    
    [self resignFirstResponder];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:_CMD_MOVE_SETTING_VIEW object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void)moveSettingView
{
    if (IS_iOS_7) {
        GPSettingViewController *settingViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingView"];
        [self.navigationController pushViewController:settingViewController animated:YES];
    } else {
        GPSettingViewController *settingViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingView_iOS6"];
        [self.navigationController pushViewController:settingViewController animated:YES];
    }
}


- (void) updatePlaybackProgressFromTimer:(NSTimer *)timer {
    
    if (([UIApplication sharedApplication].applicationState == UIApplicationStateActive) &&
        (mainDelegate.audioPlayer.playbackState == MPMoviePlaybackStatePlaying)) {
        
        self.timeProgress.value = mainDelegate.audioPlayer.currentPlaybackTime;
        
        GetGPDataCenter.playbackTime = mainDelegate.audioPlayer.currentPlaybackTime;
        
        self.lbl_playtime.text = [NSString stringWithFormat:@"%@",[self convertIntToTime:(int)mainDelegate.audioPlayer.currentPlaybackTime]];
        
        self.lbl_lasttime.text = [NSString stringWithFormat:@"-%@",[self convertIntToTime:fabs((int)(mainDelegate.audioPlayer.currentPlaybackTime-mainDelegate.audioPlayer.duration))]];
    }
}

- (NSString*)convertIntToTime:(int)time
{
    int hou = time / 3600;
    int min = (time % 3600) / 60;
    int sec = (time % 3600) % 60;
    
    return [NSString stringWithFormat:@"%d:%02d:%02d",hou,min,sec];
}

- (void)moviePlayerLoadStateChanged:(NSNotification*)notification
{
    Class playingInfoCenter = NSClassFromString(@"MPNowPlayingInfoCenter");
    
    if (playingInfoCenter) {
        NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
        
        MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc] initWithImage:[self.img_thumb image]];
        
        [songInfo setObject:[self.dic_contents_data objectForKey:@"ctPhrase"] forKey:MPMediaItemPropertyTitle];
        [songInfo setObject:[self.dic_contents_data objectForKey:@"ctSpeaker"] forKey:MPMediaItemPropertyArtist];
        [songInfo setObject:[self.dic_contents_data objectForKey:@"ctName"] forKey:MPMediaItemPropertyAlbumTitle];
        [songInfo setObject:[NSString stringWithFormat:@"%f",[audioPlayer duration]] forKey:MPMediaItemPropertyPlaybackDuration];
        [songInfo setObject:albumArt forKey:MPMediaItemPropertyArtwork];
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(remoteControlEventNotification:) name:@"RemoteControlEventReceived" object:nil];
    
    self.btn_play.selected = YES;
    if (mainDelegate.audioPlayer.playbackState != MPMoviePlaybackStatePlaying) {
        [mainDelegate.audioPlayer play];
    }
    
    GetGPDataCenter.isAudioPlaying = YES;
    self.timeProgress.maximumValue = mainDelegate.audioPlayer.duration;
}

-(void)remoteControlReceivedWithEvent:(UIEvent *)event{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoteControlEventReceived" object:event];
}

-(void)remoteControlEventNotification:(NSNotification *)note
{
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

- (void) moviePlayBackDidFinish:(NSNotification*)notification {
    [mainDelegate.audioPlayer stop];
    
    self.timeProgress.value = 0;
    
    self.lbl_playtime.text =@"00:00:00";
    
    self.lbl_lasttime.text = [NSString stringWithFormat:@"-%@",[self convertIntToTime:(int)mainDelegate.audioPlayer.duration]];
    
    self.btn_play.selected = NO;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerLoadStateDidChangeNotification
                                                  object:nil];
    
    //[self.navigationController popViewControllerAnimated:YES];
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
    _img_back_btn.highlighted = !_img_back_btn.highlighted;
    if (isFileOpenFail) {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:MPMoviePlayerPlaybackDidFinishNotification
                                                      object:nil];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:MPMoviePlayerLoadStateDidChangeNotification
                                                      object:nil];
        
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
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


- (IBAction)buttonTouchUpInside:(UIButton*)sender
{
    switch (sender.tag) {
        case 2:
            if ( sender.selected ) {
                sender.selected = !sender.selected;
                [mainDelegate.audioPlayer pause];
            } else {
                sender.selected = !sender.selected;
                
                [mainDelegate.audioPlayer play];
            }
            break;
            
        case 3:
        {
            [mainDelegate.audioPlayer pause];
            if (mainDelegate.audioPlayer.currentPlaybackTime < 15.0) {
                mainDelegate.audioPlayer.currentPlaybackTime = 0;
            } else {
                mainDelegate.audioPlayer.currentPlaybackTime = mainDelegate.audioPlayer.currentPlaybackTime - 15;
            }
            [mainDelegate.audioPlayer play];
        }
            break;
        case 4:
        {
            [mainDelegate.audioPlayer pause];
            if (mainDelegate.audioPlayer.currentPlaybackTime + 15 > mainDelegate.audioPlayer.duration) {
                mainDelegate.audioPlayer.currentPlaybackTime = mainDelegate.audioPlayer.duration;
            } else {
                mainDelegate.audioPlayer.currentPlaybackTime = mainDelegate.audioPlayer.currentPlaybackTime + 15;
            }
            [mainDelegate.audioPlayer play];
        }
            break;
            
        default:
            break;
    }
}

- (IBAction)valueChanged
{
    [mainDelegate.audioPlayer pause];
    [mainDelegate.audioPlayer setCurrentPlaybackTime:self.timeProgress.value];
    [mainDelegate.audioPlayer play];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

@end