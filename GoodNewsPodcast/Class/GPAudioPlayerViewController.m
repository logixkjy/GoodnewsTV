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
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *str_file_path = [NSString stringWithFormat:@"%@/Contents/%@/%@_%@_A.mp3",
                     [documentPath objectAtIndex:0],self.prCode,
                     [self.dic_contents_data objectForKey:@"ctEventDate"],
                     [self.dic_contents_data objectForKey:@"ctSpeaker"]];
    
    NSURL *url_path = nil;
    
    if ([fileManager fileExistsAtPath:str_file_path]) {
        url_path = [NSURL fileURLWithPath:str_file_path];
    } else {
        url_path = [NSURL URLWithString:[self.dic_contents_data objectForKey:@"ctAudioStream"]];
    }
    
    audioPlayer =  [[MPMoviePlayerController alloc] initWithContentURL:url_path];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayerLoadStateChanged:)
                                                 name:MPMoviePlayerLoadStateDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:audioPlayer];
    
    audioPlayer.controlStyle = MPMovieControlStyleNone;
    audioPlayer.shouldAutoplay = YES;
    
    audioPlayer.view.hidden = YES;
    
    [audioPlayer prepareToPlay];
    
    if (!IS_4_INCH) {
        [self.playerView bringSubviewToFront:self.toolbarView];
        [self.toolbarView setFrame:CGRectMake(0, self.playerView.frame.size.height - self.toolbarView.frame.size.height, self.toolbarView.frame.size.width , self.toolbarView.frame.size.height)];
    }
    [self.img_thumb setImageWithURL:[NSURL URLWithString:[self.dic_contents_data objectForKey:@"prThumb"]]];
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
        (audioPlayer.playbackState == MPMoviePlaybackStatePlaying)) {
        
        CGFloat progress = audioPlayer.currentPlaybackTime / audioPlayer.duration;
        
        self.timeProgress.progress = progress;
        
        self.lbl_playtime.text = [NSString stringWithFormat:@"%@",[self convertIntToTime:(int)audioPlayer.currentPlaybackTime]];
        
        self.lbl_lasttime.text = [NSString stringWithFormat:@"-%@",[self convertIntToTime:fabs((int)(audioPlayer.currentPlaybackTime-audioPlayer.duration))]];
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
    NSLog(@"%@",[self.dic_contents_data objectForKey:@"prThumb"]);
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[self.dic_contents_data objectForKey:@"prThumb"]] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60.0f];
    NSError *error = nil;
    NSData *dataBuffer = [NSURLConnection sendSynchronousRequest:request returningResponse: nil error: &error];
    UIImage *def_img = [UIImage imageWithData:dataBuffer];
    Class playingInfoCenter = NSClassFromString(@"MPNowPlayingInfoCenter");
    
    if (playingInfoCenter) {
        NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
        
        MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc] initWithImage:def_img];
        
        [songInfo setObject:[self.dic_contents_data objectForKey:@"ctPhrase"] forKey:MPMediaItemPropertyTitle];
        [songInfo setObject:[self.dic_contents_data objectForKey:@"ctSpeaker"] forKey:MPMediaItemPropertyArtist];
        [songInfo setObject:[self.dic_contents_data objectForKey:@"ctName"] forKey:MPMediaItemPropertyAlbumTitle];
        [songInfo setObject:[NSString stringWithFormat:@"%f",[audioPlayer duration]] forKey:MPMediaItemPropertyPlaybackDuration];
        [songInfo setObject:albumArt forKey:MPMediaItemPropertyArtwork];
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(remoteControlEventNotification:) name:@"RemoteControlEventReceived" object:nil];
    
    self.btn_play.selected = YES;
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
                [audioPlayer play];
                break;
            case UIEventSubtypeRemoteControlPause:
                [audioPlayer pause];
                break;
            case UIEventSubtypeRemoteControlStop:
                [audioPlayer stop];
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
                [audioPlayer pause];
            } else {
                sender.selected = !sender.selected;
                [audioPlayer play];
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
