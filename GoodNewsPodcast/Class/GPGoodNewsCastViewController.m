//
//  GPGoodNewsCastViewController.m
//  GoodNewsPodcast
//
//  Created by 김주영 on 2014. 7. 14..
//  Copyright (c) 2014년 GoodNews. All rights reserved.
//

#import "GPGoodNewsCastViewController.h"
#import "GPAlertUtil.h"
#import "JSON.h"
#import "GPGNCastCell.h"
#import "GPSettingViewController.h"
#import "GPContentsViewController.h"
#import "GPSubMainViewController.h"
#import "GPMyCastViewController.h"
#import "GPDownloadBoxViewController.h"
#import "GPLiveCastViewController.h"
#import "GPAudioPlayerViewController.h"
#import "GPMoviePlayerViewController.h"

@interface GPGoodNewsCastViewController ()

@end

@implementation GPGoodNewsCastViewController

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
    if (!GetGPDataCenter.isFirstMove) {
        GetGPDataCenter.isFirstMove = !GetGPDataCenter.isFirstMove;
        int menuID = [GPCommonUtil readIntFromDefault:@"ROOT_MENU_ID"];
//        int menuID = 1;
        switch (menuID) {
            case MENU_ID_MY_CAST:
            {
                GPMyCastViewController *myCastViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MyCast"];
                [self.navigationController pushViewController:myCastViewController animated:YES];
                return;
            }
                break;
            case MENU_ID_DOWN_BOX:
            {
                GPDownloadBoxViewController *downBoxViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DownloadBox"];
                [self.navigationController pushViewController:downBoxViewController animated:YES];
                return;
            }
                break;
            case MENU_ID_LIVE_TV:
            {
                GPLiveCastViewController *liveCastViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LiveCast"];
                [self.navigationController pushViewController:liveCastViewController animated:YES];
                return;
            }
                break;
            default:
                break;
        }
    }
    
    if (!GetGPDataCenter.isShow3GPopup)
    {
        GetGPDataCenter.isShow3GPopup= !GetGPDataCenter.isShow3GPopup;
        
        if (GetGPDataCenter.gpNetowrkStatus == NETWORK_3G_LTE) {
            [GPAlertUtil alertWithMessage:netStatus_3G delegate:self];
        } else if (GetGPDataCenter.gpNetowrkStatus == NETWORK_NONE) {
            [GPAlertUtil alertWithMessage:netStatus_none tag:8888 delegate:self];
            return;
        }
    }
    
    self.arr_mainList = [[NSMutableArray alloc] initWithCapacity:10];
    [self connectionNetwork];
    [self.tableView reloadData];
    
    if (!GetGPDataCenter.isFirstView) {
        GetGPDataCenter.isFirstView = !GetGPDataCenter.isFirstView;
        self.lbl_naviTitle.text = @"GOODNEWS TV";
        
        [NSTimer scheduledTimerWithTimeInterval: 5.0f
                                         target: self
                                       selector: @selector(changeNaviTitle)
                                       userInfo: nil
                                        repeats: NO];
    }
}

- (void)changeNaviTitle{
    self.lbl_naviTitle.text = @"다시보기";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moveSettingView)
                                                 name:_CMD_MOVE_SETTING_VIEW
                                               object:nil];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    self.btn_nowplay.hidden = !GetGPDataCenter.isAudioPlaying;
    [self.btn_nowplay addTarget:self action:@selector(moveAudioPlayView) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:_CMD_MOVE_SETTING_VIEW object:nil];
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

- (void)moveSettingView
{
    GPSettingViewController *settingViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingView"];
    [self.navigationController pushViewController:settingViewController animated:YES];
}

- (void)connectionNetwork {
    NSError                 *error  = nil;
    NSMutableURLRequest *request = [NSMutableURLRequest
                                    requestWithURL:[[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@/list.json",DEFAULT_URL]]
                                    cachePolicy:NSURLRequestReloadIgnoringCacheData
                                    timeoutInterval:60.0f];
    
    NSData *dataBuffer = [NSURLConnection sendSynchronousRequest:request returningResponse: nil error: &error];
    
    if (error) {
        [GPAlertUtil alertWithMessage:netError];
    }else {
        NSString *strJSON = [[NSString alloc] initWithData:dataBuffer encoding:NSUTF8StringEncoding];
        NSLog(@"recv : [%@]",strJSON);
        //                [KCCommonUtil fLog:@"RECV:[%@]", strJSON];
        
        SBJsonParser *sbParser = [[SBJsonParser alloc] init];
        if ([[sbParser objectWithString:strJSON] isKindOfClass:[NSMutableArray class]]) {
            self.arr_mainList = (NSMutableArray*)[sbParser objectWithString:strJSON];
        } else if ([[sbParser objectWithString:strJSON] isKindOfClass:[NSMutableDictionary class]]) {
            
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 9999) {
        exit(0);
    } else if (alertView.tag == 8888){
        GPDownloadBoxViewController *downBoxViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DownloadBox"];
        [self.navigationController pushViewController:downBoxViewController animated:YES];
    }
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

- (IBAction)goLive{
    GPLiveCastViewController *liveCastViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LiveCast"];
    [self.navigationController pushViewController:liveCastViewController animated:YES];
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

#pragma mark -
#pragma mark UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.arr_mainList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"GNCastCell";
    
    GPGNCastCell *cell = (GPGNCastCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[GPGNCastCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    [cell setGNCastListData:[self.arr_mainList objectAtIndex:indexPath.row]];
    return cell;
}

#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *dic_selected_data = [self.arr_mainList objectAtIndex:indexPath.row];
    
    if (![[dic_selected_data objectForKey:@"pcSub"] isKindOfClass:[NSArray class]]) {
        GPContentsViewController *contentsCont = [self.storyboard instantiateViewControllerWithIdentifier:@"ContentsView"];
        contentsCont.dic_contents_data = [NSMutableDictionary dictionaryWithDictionary:dic_selected_data];
        [self.navigationController pushViewController:contentsCont animated:YES];
    } else {
        GPSubMainViewController *contentsCont = [self.storyboard instantiateViewControllerWithIdentifier:@"subMainView"];
        contentsCont.arr_mainList = [[NSMutableArray alloc] initWithArray:[dic_selected_data objectForKey:@"pcSub"]];
        [self.navigationController pushViewController:contentsCont animated:YES];
    }
}

- (BOOL)shouldAutorotate
{
    return NO;
}
@end
