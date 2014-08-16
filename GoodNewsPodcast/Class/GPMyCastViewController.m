//
//  GPMyCastViewController.m
//  GoodNewsPodcast
//
//  Created by 김주영 on 2014. 7. 14..
//  Copyright (c) 2014년 GoodNews. All rights reserved.
//

#import "GPMyCastViewController.h"
#import "GPSettingViewController.h"
#import "GPAddMyCastViewController.h"
#import "GPMyCastContentsViewController.h"
#import "GPSQLiteController.h"
#import "GPAudioPlayerViewController.h"
#import "GPMoviePlayerViewController.h"

@interface GPMyCastViewController ()

@end

@implementation GPMyCastViewController

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
    
    panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
    [self.view addGestureRecognizer:panGesture];
    
    if (!GetGPDataCenter.isFirstView) {
        GetGPDataCenter.isFirstView = !GetGPDataCenter.isFirstView;
        self.lbl_naviTitle.text = @"굿뉴스TV";
        
        [NSTimer scheduledTimerWithTimeInterval: 5.0f
                                         target: self
                                       selector: @selector(changeNaviTitle)
                                       userInfo: nil
                                        repeats: NO];
    }
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(longPressGestureRecognized:)];
    lpgr.minimumPressDuration = 2.0; //seconds
    lpgr.delegate = self;
    [self.tableView addGestureRecognizer:lpgr];
}

- (void)changeNaviTitle{
    self.lbl_naviTitle.text = @"마이캐스트";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moveSettingView)
                                                 name:_CMD_MOVE_SETTING_VIEW
                                               object:nil];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    self.arr_myCast = [[NSMutableArray alloc] initWithCapacity:5];
    self.arr_myCast = [GetGPSQLiteController GetRecordsMyCast];
    
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    
    self.btn_nowplay.hidden = !GetGPDataCenter.isAudioPlaying;
    [self.btn_nowplay addTarget:self action:@selector(moveAudioPlayView) forControlEvents:UIControlEventTouchUpInside];
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

- (void)moveSettingView
{
    GPSettingViewController *settingViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingView"];
    [self.navigationController pushViewController:settingViewController animated:YES];
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
#pragma mark Gesture recognizer

- (void)panGestureRecognized:(UIPanGestureRecognizer *)sender
{
    if (!self.tableView.editing) {
        // Dismiss keyboard (optional)
        //
        [self.view endEditing:YES];
        [self.frostedViewController.view endEditing:YES];
        
        // Present the view controller
        //
        [self.frostedViewController panGestureRecognized:sender];
    }
}

- (IBAction)longPressGestureRecognized:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint p = [gestureRecognizer locationInView:self.tableView];
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    if (indexPath == nil) {
        NSLog(@"long press on table view but not on a row");
    }
    else
        if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
            NSLog(@"long press on table view at row %d", indexPath.row);
            NSDictionary *dic = [self.arr_myCast objectAtIndex:indexPath.row];
            
            [[UIPasteboard generalPasteboard] setString:[dic objectForKey:@"prXmlAddress"]];
            [GPAlertUtil alertWithMessage:@"클립보드에 내용이 복사되었습니다."];
            
        }
        else {
            NSLog(@"gestureRecognizer.state = %d", gestureRecognizer.state);
        }
}
- (void)moveAudioPlayView
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *str_file_path = @"";
    NSURL *url_path = nil;
    
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

- (IBAction)editTable
{
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    
    if (self.tableView.editing) {
        [self.view removeGestureRecognizer:panGesture];
    }else{
//        panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
        [self.view addGestureRecognizer:panGesture];
    }
}

- (IBAction)addMyCast
{
    GPAddMyCastViewController *addMyCastViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MyCastAdd"];
    [self presentViewController:addMyCastViewController animated:YES completion:nil];
}

#pragma mark -
#pragma mark UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.arr_myCast count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSDictionary *dic = [self.arr_myCast objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [dic objectForKey:@"prTitle"];
    longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:cell action:@selector(longPressGestureRecognized:)];
    
    return cell;
}

#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item1 = [NSDictionary dictionaryWithDictionary:[self.arr_myCast objectAtIndex:indexPath.row]];
    
    GPMyCastContentsViewController *contentsCont = [self.storyboard instantiateViewControllerWithIdentifier:@"MCContentsView"];
    contentsCont.dic_contents_data = [NSMutableDictionary dictionaryWithDictionary:item1];
    [self.navigationController pushViewController:contentsCont animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSDictionary *item1 = [NSDictionary dictionaryWithDictionary:[self.arr_myCast objectAtIndex:indexPath.row]];
        [self.arr_myCast removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationBottom];
        
        [GetGPSQLiteController deleteMyCastWithNo:[[item1 objectForKey:@"_ID"] intValue]];
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
	if (fromIndexPath.row != toIndexPath.row) {
		NSDictionary *item1 = [NSDictionary dictionaryWithDictionary:[self.arr_myCast objectAtIndex:fromIndexPath.row]];
		[self.arr_myCast removeObject:item1];
		[self.arr_myCast insertObject:item1 atIndex:toIndexPath.row];
        
        for (int i = 0 ; i < [self.arr_myCast count]; i++) {
            [GetGPSQLiteController updateMyCastWithNo:[[[self.arr_myCast objectAtIndex:i] objectForKey:@"_ID"] intValue] CastIndex:i];
        }
	}
}



- (BOOL)shouldAutorotate
{
    return NO;
}

@end
