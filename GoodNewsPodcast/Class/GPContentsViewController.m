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
#import "GPMoviePlayerViewController.h"
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
    
    self.arr_contents_list = [[NSMutableArray alloc] initWithCapacity:10];
    [self setDatas];
    [self performSelector:@selector(connectionNetwork) withObject:nil afterDelay:0.0];
//    [self performSelectorOnMainThread:@selector(connectionNetwork) withObject:nil waitUntilDone:NO];
//    [self connectionNetwork];
    
    moreViewCnt = 20; // 더보기 카운트
    _arr_moreView = [[NSMutableArray alloc] initWithCapacity:20];
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
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:_CMD_MOVE_SETTING_VIEW object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:_CMD_FILE_DOWN_FINISHED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:_CMD_FILE_DOWN_START object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:_CMD_FILE_DOWN_ADD object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:_CMD_FILE_STREAMING object:nil];
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

- (void)setDatas
{
    [self.img_thumb setImageWithURL:[NSURL URLWithString:[self.dic_contents_data objectForKey:@"prThumbS"]] placeholderImage:[UIImage imageNamed:@"thumbnail_none.png"]];
    [self.lbl_Title setText:[self.dic_contents_data objectForKey:@"prTitle"]];
    [self.lbl_subTitle setText:[self.dic_contents_data objectForKey:@"prContent"]];
    
    CGSize maxSize = CGSizeMake(188, 10000);
    CGSize viewSize;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    NSDictionary *attributes = @{NSFontAttributeName:self.lbl_subTitle.font, NSParagraphStyleAttributeName: paragraphStyle};
    viewSize = [[self.dic_contents_data objectForKey:@"prContent"] boundingRectWithSize:maxSize options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                                                             attributes:attributes  context:nil].size;

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
        
        [dic setObject:[self.dic_contents_data objectForKey:@"prThumb"] forKey:@"prThumb"];
        [dic setObject:[self.dic_contents_data objectForKey:@"prCode"] forKey:@"prCode"];
        [dic setObject:[self.dic_contents_data objectForKey:@"prTitle"] forKey:@"prTitle"];
        
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.arr_contents_list count] > 20) {
        if ([self.arr_contents_list count] == moreViewCnt) {
            if (indexPath.row == [_arr_moreView count]) {
                NSIndexPath* ip = [NSIndexPath indexPathForRow: 0 inSection:0];
                [tableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionNone animated:YES];
            } else {
                self.dic_selected_data = [NSMutableDictionary dictionaryWithDictionary:[self.arr_contents_list objectAtIndex:indexPath.row]];
                
                UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"닫기" destructiveButtonTitle:nil otherButtonTitles:@"Video 고속",@"Video 저속",@"Audio",nil];
                
                UIView *keyView = [[[[UIApplication sharedApplication] keyWindow] subviews] objectAtIndex:0];
                [actionSheet showInView:keyView];
            }
        }
        if (indexPath.row == [_arr_moreView count]) {
            [self addMoreView];
        } else if (indexPath.row == [_arr_moreView count]+1) {
            NSIndexPath* ip = [NSIndexPath indexPathForRow: 0 inSection:0];
            [tableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionNone animated:YES];
        } else {
            self.dic_selected_data = [NSMutableDictionary dictionaryWithDictionary:[self.arr_contents_list objectAtIndex:indexPath.row]];
            
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"닫기" destructiveButtonTitle:nil otherButtonTitles:@"Video 고속",@"Video 저속",@"Audio",nil];
            
            UIView *keyView = [[[[UIApplication sharedApplication] keyWindow] subviews] objectAtIndex:0];
            [actionSheet showInView:keyView];
        }
    } else {
        self.dic_selected_data = [NSMutableDictionary dictionaryWithDictionary:[self.arr_contents_list objectAtIndex:indexPath.row]];
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"닫기" destructiveButtonTitle:nil otherButtonTitles:@"Video 고속",@"Video 저속",@"Audio",nil];
        
        UIView *keyView = [[[[UIApplication sharedApplication] keyWindow] subviews] objectAtIndex:0];
        [actionSheet showInView:keyView];
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
    BOOL isUse3G = [GPCommonUtil readBoolFromDefault:@"USE_3G"];
    int_selType = &buttonIndex;
    if (_downCont == nil) {
        AppDelegate *mainDelegate = MAIN_APP_DELEGATE();
        _downCont = mainDelegate.downloadController;
    }
    switch (buttonIndex) {
        case 0:
        case 1:
        {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSArray *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            
            NSString *str_file_path = @"";
            if (buttonIndex == 0) {
                str_file_path = [NSString stringWithFormat:@"%@/Contents/%@/%@_%@_N.mp4",
                                             [documentPath objectAtIndex:0],
                                             [self.dic_contents_data objectForKey:@"prCode"],
                                             [self.dic_selected_data objectForKey:@"ctEventDate"],
                                             [self.dic_selected_data objectForKey:@"ctSpeaker"]];
                
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
                                             [self.dic_selected_data objectForKey:@"ctEventDate"],
                                             [self.dic_selected_data objectForKey:@"ctSpeaker"]];
                
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
                    [_downCont downloadFileCheck:self.dic_selected_data FileType:buttonIndex isDown:NO];
                    return;
                }
            }
            
            _mpv_playVideo = [[GPMoviePlayerViewController alloc] initWithContentURL:url_path];
            _mpv_playVideo.view.backgroundColor = [UIColor blackColor];
            _mpv_playVideo.moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
            [self presentMoviePlayerViewControllerAnimated:_mpv_playVideo];
            
        }
            break;
        case 2:
        {
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
                    [_downCont downloadFileCheck:self.dic_selected_data FileType:buttonIndex isDown:NO];
                    return;
                }
            }
            
            GPAudioPlayerViewController *audioPlayer = [self.storyboard instantiateViewControllerWithIdentifier:@"AudioPlayer"];
            [self.dic_selected_data setObject:[self.dic_contents_data objectForKey:@"prThumbS"] forKey:@"prThumb"];
            audioPlayer.dic_contents_data = [NSMutableDictionary dictionaryWithDictionary:self.dic_selected_data];
            audioPlayer.prCode = [self.dic_contents_data objectForKey:@"prCode"];
            [self.navigationController pushViewController:audioPlayer animated:YES];
        }
            break;
        default:
            break;
    }
}

- (void)fileStreaming:(NSNotification*)noti
{
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:noti.userInfo];
    switch ([[userInfo objectForKey:@"FILE_TYPE"] integerValue]) {
        case 0:
        case 1:
        {
            if ([[userInfo objectForKey:@"FILE_TYPE"] integerValue] == 0) {
                url_path = [NSURL URLWithString:[userInfo objectForKey:@"ctVideoNormal"]];
            } else if ([[userInfo objectForKey:@"FILE_TYPE"] integerValue] == 1) {
                url_path = [NSURL URLWithString:[userInfo objectForKey:@"ctVideoLow"]];
            }
            
            _mpv_playVideo = [[GPMoviePlayerViewController alloc] initWithContentURL:url_path];
            _mpv_playVideo.view.backgroundColor = [UIColor blackColor];
            _mpv_playVideo.moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
            [self presentMoviePlayerViewControllerAnimated:_mpv_playVideo];
            
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
