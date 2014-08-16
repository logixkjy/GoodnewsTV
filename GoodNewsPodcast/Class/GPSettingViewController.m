//
//  GPSettingViewController.m
//  GoodNewsPodcast
//
//  Created by 김주영 on 2014. 7. 14..
//  Copyright (c) 2014년 GoodNews. All rights reserved.
//

#import "GPSettingViewController.h"
#import "GPNavigationController.h"
#import "GPSQLiteController.h"

@interface GPSettingViewController ()

@end

@implementation GPSettingViewController

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
    _sw_use3G.on = [GPCommonUtil readBoolFromDefault:@"USE_3G"];
    _arr_viewList = [[NSArray alloc] initWithObjects:@"",@"생방송",@"다시보기",@"마이캐스트",@"다운로드",nil];
    
    _lbl_AppStoreVer.text = [NSString stringWithFormat:@"최신 버전 (%@)",[GetGPDataCenter.str_AppStore length] == 0 ? [iVersion sharedInstance].applicationVersion : GetGPDataCenter.str_AppStore];
    _lbl_BundleVer.text = [NSString stringWithFormat:@"현재 버전 (%@)",[iVersion sharedInstance].applicationVersion];
    
    int menuID = [GPCommonUtil readIntFromDefault:@"ROOT_MENU_ID"];
    //        int menuID = 1;
    switch (menuID) {
        case MENU_ID_GOODNEWS_CAST:
        {
            _lbl_startPage.text = @"다시보기";
        }
            break;
        case MENU_ID_MY_CAST:
        {
            _lbl_startPage.text = @"마이캐스트";
        }
            break;
        case MENU_ID_DOWN_BOX:
        {
           _lbl_startPage.text = @"다운로드";
        }
            break;
        case MENU_ID_LIVE_TV:
        {
            _lbl_startPage.text = @"생방송";
        }
            break;
        default:
            break;
    }
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

- (IBAction)pressBtn
{
    _img_btn.highlighted = !_img_btn.highlighted;
}

- (IBAction)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
    _img_btn.highlighted = !_img_btn.highlighted;
}

- (IBAction)valueChange:(UISwitch*)sender
{
    [GPCommonUtil writeBoolToDefault:sender.on KEY:@"USE_3G"];
}

- (IBAction)viewDeveloperInfo
{
    [GPAlertUtil alertWithMessage:self MESSAGE:@"Team GIV\nhttp://volunteers.gnn.or.kr" TITLE:@"개발자 정보"];
}

- (IBAction)UPdateCheck
{
    NSString *appStoreVersion = [GetGPDataCenter.str_AppStore stringByReplacingOccurrencesOfString:@"." withString:@""];
    NSString *bundleVersion = [[iVersion sharedInstance].applicationVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
    
    if ([appStoreVersion intValue] > [bundleVersion intValue]) {
        [GPAlertUtil alertWithMessage:[NSString stringWithFormat:@"%@\n최신버전을 앱스토어에서 업데이트 하시기 바랍니다.",_lbl_AppStoreVer.text] delegate:self tag:2];
    } else {
        [GPAlertUtil alertWithMessage:self MESSAGE:[NSString stringWithFormat:@"%@\n현재 최신버전을 이용중입니다.",_lbl_AppStoreVer.text] TITLE:@"최신버전 정보"];
    }
}

- (IBAction)deleteDownloadDatas
{
    [GPAlertUtil alertWithMessage:@"다운로드 받은 모든 콘텐츠를\n삭제하시겠습니까?" delegate:self tag:3];
}

- (IBAction)setFirstView
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    actionSheet.delegate = self;
    
    [actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    
    CGRect pickerFrame = CGRectZero;
    if (IS_iOS_7) {
        pickerFrame = CGRectMake(0, 20, 320, 220);
    }else{
        pickerFrame = CGRectMake(0, 40, 320, 220);
    }
    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:pickerFrame];
    pickerView.showsSelectionIndicator = YES;
    pickerView.dataSource = self;
    pickerView.delegate = self;
    pickerView.backgroundColor = [UIColor clearColor];
    
    [actionSheet addSubview:pickerView];
    
    UIView *actionsheet_tool_box = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    [actionsheet_tool_box setBackgroundColor:[UIColor whiteColor]];
    UIImageView *lineView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 39, 320, 1)];
    [lineView setBackgroundColor:[UIColor grayColor]];
    [actionsheet_tool_box addSubview:lineView];
    
    UIButton *actionsheet_close_btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [actionsheet_close_btn setFrame:CGRectMake(274, 7, 37, 27)];
    [actionsheet_close_btn setTitle:@"닫기" forState:UIControlStateNormal];
    [actionsheet_close_btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [actionsheet_close_btn addTarget:actionSheet action:@selector(dismissWithClickedButtonIndex:animated:) forControlEvents:UIControlEventTouchUpInside];
    [actionsheet_tool_box addSubview:actionsheet_close_btn];
    
    [actionSheet addSubview:actionsheet_tool_box];
    
    [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
    [actionSheet setBounds:CGRectMake(0, 0, 320, 480)];
}

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [_arr_viewList count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    NSLog(@"_email_list ===> [%@]",[_arr_viewList objectAtIndex:row]);
    return [_arr_viewList objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (row != 0) {
        if ([[_arr_viewList objectAtIndex:row] isEqualToString:@"생방송"]) {
            [GPCommonUtil writeIntToDefault:MENU_ID_LIVE_TV KEY:@"ROOT_MENU_ID"];
            
        } else if ([[_arr_viewList objectAtIndex:row] isEqualToString:@"다시보기"]) {
            [GPCommonUtil writeIntToDefault:MENU_ID_GOODNEWS_CAST KEY:@"ROOT_MENU_ID"];
            
        } else if ([[_arr_viewList objectAtIndex:row] isEqualToString:@"마이캐스트"]) {
            [GPCommonUtil writeIntToDefault:MENU_ID_MY_CAST KEY:@"ROOT_MENU_ID"];
            
        } else if ([[_arr_viewList objectAtIndex:row] isEqualToString:@"다운로드"]) {
            [GPCommonUtil writeIntToDefault:MENU_ID_DOWN_BOX KEY:@"ROOT_MENU_ID"];
            
        }
        
        _lbl_startPage.text = [_arr_viewList objectAtIndex:row];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1003) {
        if (buttonIndex == 0) {
            if ([[UIApplication sharedApplication] canOpenURL:[iVersion sharedInstance].updateURL]) {
                [[UIApplication sharedApplication] openURL:[iVersion sharedInstance].updateURL];
            }
        }
    } else if (alertView.tag == 1004) {
        if (buttonIndex == 0) {
            [self funcDeleteDownloadDatas];
        }
    }
}

- (void)funcDeleteDownloadDatas
{
    [GetGPSQLiteController dropTable];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    [filemgr removeItemAtPath:[[paths objectAtIndex:0] stringByAppendingPathComponent:@"Contents"] error:nil];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

@end
