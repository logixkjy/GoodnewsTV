//
//  GPDownloadBoxViewController.m
//  GoodNewsPodcast
//
//  Created by 김주영 on 2014. 7. 14..
//  Copyright (c) 2014년 GoodNews. All rights reserved.
//

#import "GPDownloadBoxViewController.h"
#import "GPSettingViewController.h"
#import "GPDownloadController.h"
#import "GPProgressCell.h"
#import "GPMoviePlayerViewController.h"
#import "GPAudioPlayerViewController.h"
#import "GPDWContentsCell.h"

@interface GPDownloadBoxViewController ()

@end

@implementation GPDownloadBoxViewController

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
    if (GetGPDataCenter.gpNetowrkStatus != NETWORK_NONE) {
        [self.view addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)]];
    } else {
        _img_btn.hidden = YES;
        self.sc_selectView.selectedSegmentIndex = 0;
    }
    
    isEdit = NO;
    
    self.arr_downList = [[NSMutableArray alloc] initWithCapacity:5];
    self.arr_downList_fileType = [[NSMutableArray alloc] initWithCapacity:5];
    
    if ([GetGPDataCenter.str_fileType length] != 0) {
        [self.arr_downList addObject:GetGPDataCenter.dic_fileInfo];
        [self.arr_downList_fileType addObject:GetGPDataCenter.str_fileType];
        for (int i = 0; i < [GetGPDataCenter.sendQueue count]; i++) {
            [self.arr_downList addObject:[GetGPDataCenter.sendQueue objectAtIndex:i]];
            [self.arr_downList_fileType addObject:[GetGPDataCenter.sendQueueForFileType objectAtIndex:i]];
        }
        [self.tb_downList reloadData];
        
        self.sc_selectView.selectedSegmentIndex = 1;
        self.view_downList.hidden = NO;
        self.view_fileList.hidden = YES;
    } else {
        if ([GetGPDataCenter.sendQueue count] > 0){
            for (int i = 0; i < [GetGPDataCenter.sendQueue count]; i++) {
                [self.arr_downList addObject:[GetGPDataCenter.sendQueue objectAtIndex:i]];
                [self.arr_downList_fileType addObject:[GetGPDataCenter.sendQueueForFileType objectAtIndex:i]];
            }
            [self.tb_downList reloadData];
            
            self.sc_selectView.selectedSegmentIndex = 1;
            self.view_downList.hidden = NO;
            self.view_fileList.hidden = YES;
        } else {
            self.sc_selectView.selectedSegmentIndex = 0;
            self.view_downList.hidden = YES;
            self.view_fileList.hidden = NO;
        }
    }
    _img_downPause.backgroundColor = UIColorFromRGB(0x676767);
    _img_downStart.backgroundColor = UIColorFromRGB(0x676767);
    
    self.arr_downBox = [[NSMutableArray alloc] initWithCapacity:5];
    self.arr_downBox = [GetGPSQLiteController GetRecordsDownList];
    self.arr_downBoxSection= [[NSMutableArray alloc] initWithCapacity:5];
    self.arr_downBoxSection = [GetGPSQLiteController GetRecordsDownListSection];
    
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
    self.lbl_naviTitle.text = @"다운로드";
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fileDownCancel:)
                                                 name:_CMD_FILE_DOWN_CANCEL
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fileDownStart:)
                                                 name:_CMD_FILE_DOWN_FINISHED
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(downBoxEvent:)
                                                 name:_CMD_DOWN_BOX_EVENT
                                               object:nil];
    
    AppDelegate *mainDelegate = MAIN_APP_DELEGATE();
    if (mainDelegate.audioPlayer.playbackState == MPMoviePlaybackStatePlaying) {
        self.btn_nowplay.hidden = NO;
        [self.btn_nowplay addTarget:self action:@selector(moveAudioPlayView) forControlEvents:UIControlEventTouchUpInside];
    }else{
        self.btn_nowplay.hidden = YES;
        GetGPDataCenter.isAudioPlaying = NO;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:_CMD_MOVE_SETTING_VIEW object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:_CMD_FILE_DOWN_CANCEL object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:_CMD_FILE_DOWN_FINISHED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:_CMD_DOWN_BOX_EVENT object:nil];
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

- (void)fileDownCancel:(NSNotification*)noti
{
    if (_downCont == nil) {
        AppDelegate *mainDelegate = MAIN_APP_DELEGATE();
        _downCont = mainDelegate.downloadController;
    }
    NSDictionary *userInfo = noti.userInfo;
    NSIndexPath *indexPath = [userInfo objectForKey:@"INDEX_PATH"];
    if ([[userInfo objectForKey:@"TYPE"] isEqualToString:@"C"]) {
        [self.arr_downList removeObjectAtIndex:indexPath.row];
        [_downCont downloadCanlcel];
    } else {
        
        [self.arr_downList removeObjectAtIndex:indexPath.row];
        
        if ([GetGPDataCenter.str_fileType length] == 0) {
            [GetGPDataCenter.sendQueue removeObjectAtIndex:indexPath.row];
            [GetGPDataCenter.sendQueueForFileType removeObjectAtIndex:indexPath.row];
            
        } else {
            if (indexPath.row == 0) {
                GetGPDataCenter.dic_fileInfo = nil;
                GetGPDataCenter.str_fileType = @"";
                [GPCommonUtil writeObjectToDefault:GetGPDataCenter.dic_fileInfo KEY:@"DOWN_FILE_INFO"];
                [GPCommonUtil writeObjectToDefault:GetGPDataCenter.str_fileType KEY:@"DOWN_FILE_TYPE"];
            } else {
                [GetGPDataCenter.sendQueue removeObjectAtIndex:indexPath.row-1];
                [GetGPDataCenter.sendQueueForFileType removeObjectAtIndex:indexPath.row-1];
            }
        }
        
        [GPCommonUtil writeObjectToDefault:GetGPDataCenter.sendQueue KEY:@"SEND_QUEUE"];
        [GPCommonUtil writeObjectToDefault:GetGPDataCenter.sendQueueForFileType KEY:@"SEND_QUEUE_FILE_TYPE"];
        
        if ([self.arr_downList count] == 0) {
            GetGPDataCenter.isExistingDownload = NO;
        }
        
    }
    
    [self.tb_downList performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

- (void)fileDownStart:(NSNotification*)noti{
    NSDictionary *userInfo = noti.userInfo;
    
    if ([self.arr_downList count] > 0) {
        for (int i = 0; i < [self.arr_downList count]; i++) {
            if ([[userInfo objectForKey:@"ctName"] isEqualToString:[[self.arr_downList objectAtIndex:i] objectForKey:@"ctName"]] && [[userInfo objectForKey:@"FILE_TYPE"] isEqualToString:[self.arr_downList_fileType objectAtIndex:i]]) {
                [self.arr_downList removeObjectAtIndex:i];
                [self.arr_downList_fileType removeObjectAtIndex:i];
                break;
            }
        }
    }else{
        GetGPDataCenter.isExistingDownload = NO;
    }
    
    [self.tb_downList performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    
    self.arr_downBox = [[NSMutableArray alloc] initWithCapacity:5];
    self.arr_downBox = [GetGPSQLiteController GetRecordsDownList];
    self.arr_downBoxSection= [[NSMutableArray alloc] initWithCapacity:5];
    self.arr_downBoxSection = [GetGPSQLiteController GetRecordsDownListSection];
    
    [self.tb_fileList performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
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
    GPAudioPlayerViewController *audioPlayer = [self.storyboard instantiateViewControllerWithIdentifier:@"AudioPlayer"];
    audioPlayer.dic_contents_data = [NSMutableDictionary dictionaryWithDictionary:GetGPDataCenter.dic_playInfo];
    [self.navigationController pushViewController:audioPlayer animated:YES];
}

- (IBAction)pressBtn:(UIButton*)sender
{
    switch (sender.tag) {
        case 0:
            _img_btn.highlighted = !_img_btn.highlighted;
            break;
        case 101:
            _img_downStart.backgroundColor = UIColorFromRGB(0x002085);
            break;
        case 102:
            _img_downPause.backgroundColor = UIColorFromRGB(0x002085);
            break;
        default:
            break;
    }
}

- (IBAction)showMenu
{
    if (GetGPDataCenter.gpNetowrkStatus == NETWORK_NONE) {
        return;
    }
    
    // Dismiss keyboard (optional)
    //
    [self.view endEditing:YES];
    [self.frostedViewController.view endEditing:YES];
    
    // Present the view controller
    //
    [self.frostedViewController presentMenuViewController];
    _img_btn.highlighted = !_img_btn.highlighted;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (IBAction)buttonTouchUpInside:(UIButton*)sender
{
    if (_downCont == nil) {
        AppDelegate *mainDelegate = MAIN_APP_DELEGATE();
        _downCont = mainDelegate.downloadController;
    }
    switch (sender.tag) {
        case 101:
            _img_downStart.backgroundColor = UIColorFromRGB(0x676767);
            if (GetGPDataCenter.sendQueue.count > 0 && [GetGPDataCenter.str_fileType length] == 0) {
                [_downCont beginCommunicator];
            } else {
                
                [_downCont downloadRestart];
            }
            break;
        case 102:
            _img_downPause.backgroundColor = UIColorFromRGB(0x676767);
            [_downCont downloadPause];
            break;
            
        default:
            break;
    }
}

- (IBAction)valueChanged
{
    if (GetGPDataCenter.gpNetowrkStatus == NETWORK_NONE) {
        self.sc_selectView.selectedSegmentIndex = 0;
        return;
    }
    
    if (self.sc_selectView.selectedSegmentIndex == 1) {
        self.view_downList.hidden = NO;
        self.view_fileList.hidden = YES;
    } else {
        self.view_downList.hidden = YES;
        self.view_fileList.hidden = NO;
    }
}

#pragma mark -
#pragma mark UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.tb_downList) {
        return 1;
    } else if (tableView == self.tb_fileList) {
        return [self.arr_downBoxSection count];
    }
    return 1;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//	if (tableView == self.tb_fileList) {
//		return [[self.arr_downBoxSection objectAtIndex:section] objectForKey:@"prTitle"];
//	}
//    return nil;
//}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView == self.tb_fileList) {
		UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 58)];
        headerView.backgroundColor = UIColorFromRGB(0xf0eff4);
        UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 31, 300, 18)];
        lblTitle.font = [UIFont systemFontOfSize:17];
        lblTitle.text = [[self.arr_downBoxSection objectAtIndex:section] objectForKey:@"prTitle"];
        lblTitle.textColor = UIColorFromRGB(0x002085);
        [headerView addSubview:lblTitle];
        return headerView;
	}
    return nil;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tb_downList) {
        return [self.arr_downList count];
    } else if (tableView == self.tb_fileList) {
        NSNumber *number = [[self.arr_downBoxSection objectAtIndex:section] objectForKey:@"prCount"];
        return [number intValue];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    static NSString *cellIdentifier = @"GNCastCell";
    
    if (tableView == self.tb_downList) {
        GPProgressCell *cell = (GPProgressCell*)[tableView dequeueReusableCellWithIdentifier:@"progressCell"];
        
        if (cell == nil) {
            cell = [[GPProgressCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"progressCell"];
        }
        
        [cell setData:[self.arr_downList objectAtIndex:indexPath.row] :[self.arr_downList_fileType objectAtIndex:indexPath.row] :isEdit :indexPath];
        
        return cell;
    } else if (tableView == self.tb_fileList) {
        GPDWContentsCell *cell = (GPDWContentsCell*)[tableView dequeueReusableCellWithIdentifier:@"DWContentCell"];
        
        if (cell == nil) {
            cell = [[GPDWContentsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DWContentCell"];
        }
        
        int indexNow = 0;
        for (int i = 0; i < indexPath.section; i++) {
            NSNumber *number = [[self.arr_downBoxSection objectAtIndex:i] objectForKey:@"prCount"];
            indexNow += [number intValue];
        }
        
        indexNow += indexPath.row;
        
        NSDictionary *dic_fileInfo = [self.arr_downBox objectAtIndex:indexNow];
        
        [cell setContentsData:dic_fileInfo indexPath:indexPath];
        return cell;
    }
    
    return nil;
}

#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tb_fileList) {
        int indexNow = 0;
        for (int i = 0; i < indexPath.section; i++) {
            NSNumber *number = [[self.arr_downBoxSection objectAtIndex:i] objectForKey:@"prCount"];
            indexNow += [number intValue];
        }
        
        indexNow += indexPath.row;
        
        NSDictionary *dic_fileInfo = [self.arr_downBox objectAtIndex:indexNow];
        
        [self showPlayerView:dic_fileInfo];
    }
}

- (void)downBoxEvent:(NSNotification*)noti{
    NSDictionary *userInfo = noti.userInfo;
    
    NSIndexPath *indexPath = [userInfo objectForKey:@"indexPath"];
    int indexNow = 0;
    for (int i = 0; i < indexPath.section; i++) {
        NSNumber *number = [[self.arr_downBoxSection objectAtIndex:i] objectForKey:@"prCount"];
        indexNow += [number intValue];
    }
    
    indexNow += indexPath.row;
    
    NSDictionary *dic_fileInfo = [self.arr_downBox objectAtIndex:indexNow];
    
    if ([[userInfo objectForKey:@"ButtonType"] isEqualToString:@"P"]) {
        [self showPlayerView:dic_fileInfo];
    } else {
        if ([[GetGPDataCenter.dic_playInfo objectForKey:@"ctName"] isEqualToString:[dic_fileInfo objectForKey:@"ctName"]]) {
            [GPAlertUtil alertWithMessage:@"현재 재생 중인 파일입니다.\n 먼저 종료 후에 삭제하여 주십시요"];
            return;
        }
        [GetGPSQLiteController deleteDownFileWithNo:[[dic_fileInfo objectForKey:@"_ID"] intValue]];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        NSString *str_file_path = [NSString stringWithFormat:@"%@/Contents/%@/%@",
                                   [documentPath objectAtIndex:0],
                                   [dic_fileInfo objectForKey:@"prCode"],
                                   [dic_fileInfo objectForKey:@"ctFileName"]];
        
        if ([fileManager removeItemAtPath:str_file_path error:nil]) {
            [GPAlertUtil alertWithMessage:@"삭제 되었습니다." tag:7777 delegate:self];
        }
    }
}

- (void)showPlayerView:(NSDictionary*)fileDic
{
    if ([[fileDic objectForKey:@"ctFileType"] integerValue] == FILE_TYPE_AUDIO) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        NSString *str_file_path = [NSString stringWithFormat:@"%@/Contents/%@/%@",
                                   [documentPath objectAtIndex:0],
                                   [fileDic objectForKey:@"prCode"],
                                   [fileDic objectForKey:@"ctFileName"]];
       
        if (![fileManager fileExistsAtPath:str_file_path]) {
            return;
        }
        
        GPAudioPlayerViewController *audioPlayer = [self.storyboard instantiateViewControllerWithIdentifier:@"AudioPlayer"];
        audioPlayer.dic_contents_data = [NSMutableDictionary dictionaryWithDictionary:fileDic];
        audioPlayer.prCode = [fileDic objectForKey:@"prCode"];
        [self.navigationController pushViewController:audioPlayer animated:YES];
    } else {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        NSString *str_file_path = [NSString stringWithFormat:@"%@/Contents/%@/%@",
                                   [documentPath objectAtIndex:0],
                                   [fileDic objectForKey:@"prCode"],
                                   [fileDic objectForKey:@"ctFileName"]];
        
        if (![fileManager fileExistsAtPath:str_file_path]) {
            return;
        }
        
        _mpv_playVideo = [[GPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:str_file_path]];
        _mpv_playVideo.view.backgroundColor = [UIColor blackColor];
        _mpv_playVideo.moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
        [self presentMoviePlayerViewControllerAnimated:_mpv_playVideo];

    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 7777) {
        self.arr_downBox = [[NSMutableArray alloc] initWithCapacity:5];
        self.arr_downBox = [GetGPSQLiteController GetRecordsDownList];
        self.arr_downBoxSection= [[NSMutableArray alloc] initWithCapacity:5];
        self.arr_downBoxSection = [GetGPSQLiteController GetRecordsDownListSection];
        
        [self.tb_fileList performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];

    }
}

@end
