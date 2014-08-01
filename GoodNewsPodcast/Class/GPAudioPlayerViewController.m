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
    [self.view addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)]];
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
        
        mainDelegate.audioPlayer =  [[MPMoviePlayerController alloc] initWithContentURL:url_path];
        
        
        
        mainDelegate.audioPlayer.controlStyle = MPMovieControlStyleNone;
        mainDelegate.audioPlayer.shouldAutoplay = YES;
        
        mainDelegate.audioPlayer.view.hidden = YES;
        
        [mainDelegate.audioPlayer prepareToPlay];
        
        GetGPDataCenter.dic_playInfo = [NSMutableDictionary dictionaryWithDictionary:self.dic_contents_data];
        
//        mainDelegate.audioPlayer = audioPlayer;
    }else {
        self.btn_play.selected = YES;
        self.timeProgress.maximumValue = mainDelegate.audioPlayer.duration;
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
        [self.playerView bringSubviewToFront:self.toolbarView];
        [self.toolbarView setFrame:CGRectMake(0, self.playerView.frame.size.height - self.toolbarView.frame.size.height, self.toolbarView.frame.size.width , self.toolbarView.frame.size.height)];
    }
    [self.img_thumb setImageWithURL:[NSURL URLWithString:[self.dic_contents_data objectForKey:@"prThumb"]]  placeholderImage:[UIImage imageNamed:@"thumbnail_none_square.png"]];
    [self.lbl_title setText:[NSString stringWithFormat:@"%@ %@",[self.dic_contents_data objectForKey:@"ctEventDate"],[self.dic_contents_data objectForKey:@"ctPhrase"]]];
    [self.lbl_subtitle setText:[self.dic_contents_data objectForKey:@"ctName"]];
    
    MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:self.volumeView.bounds];
    [self.volumeView addSubview:volumeView];
    [volumeView sizeToFit];
    
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updatePlaybackProgressFromTimer:) userInfo:nil repeats:YES];
}

-(void)viewWillAppear:(BOOL)animated {
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
    GPSettingViewController *settingViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingView"];
    [self.navigationController pushViewController:settingViewController animated:YES];
}


- (void) updatePlaybackProgressFromTimer:(NSTimer *)timer {
    
    if (([UIApplication sharedApplication].applicationState == UIApplicationStateActive) &&
        (mainDelegate.audioPlayer.playbackState == MPMoviePlaybackStatePlaying)) {
        
        self.timeProgress.value = mainDelegate.audioPlayer.currentPlaybackTime;
        
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
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerLoadStateDidChangeNotification
                                                  object:nil];
    
    [self.navigationController popViewControllerAnimated:YES];
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
