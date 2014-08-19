//
//  GPMCContentsCell.m
//  GoodNewsPodcast
//
//  Created by 김주영 on 2014. 7. 31..
//  Copyright (c) 2014년 GoodNews. All rights reserved.
//

#import "GPMCContentsCell.h"
#import "TUNinePatchCache.h"
#import "GPDownloadController.h"

@implementation GPMCContentsCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setContentsData:(NSDictionary *)datas
{
    mainDelegate = MAIN_APP_DELEGATE();
    UIColor *textColor = UIColorFromRGB(0x949494);
    UIColor *textColor2 = UIColorFromRGB(0xf74300);
    dic_fileinfo = [NSMutableDictionary dictionaryWithDictionary:datas];
    
    [self.lbl_name setText:[dic_fileinfo objectForKey:@"ctName"]];
    [self.lbl_phrase setText:[dic_fileinfo objectForKey:@"ctPhrase"]];
    [self.lbl_date setText:[dic_fileinfo objectForKey:@"ctEventDate"]];
//    if ([[dic_fileinfo objectForKey:@"ctDuration"] length] != 0) {
//        self.lbl_date.text = [self.lbl_date.text stringByAppendingFormat:@" 재생시간 : %@",[self convertIntToTime:[[dic_fileinfo objectForKey:@"ctDuration"] integerValue]]];
//    }
    [self.lbl_speaker setText:[dic_fileinfo objectForKey:@"ctSpeaker"]];
    [self.img_btn_background setImage:[TUNinePatchCache imageOfSize:[self.img_btn_background bounds].size forNinePatchNamed:@"box_down"]];
    
    _btn_play.enabled = NO;
    
    switch ([[dic_fileinfo objectForKey:@"ctFileType"] integerValue]) {
        case FILE_TYPE_VIDEO_NORMAL:
            _lbl_play.text = @"Video";
            break;
        case FILE_TYPE_AUDIO:
            _lbl_play.text = @"Audio";
            break;
    }
    
    if ([[dic_fileinfo objectForKey:@"ctFileStat"]
         isEqualToString:@"normal"])
    {
        _lbl_play.textColor = textColor;
        _img_play.hidden = NO;
        _img_play_2.hidden = YES;
        _btn_play.enabled = YES;
        [_img_play setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_down_normal" ofType:@"png"]]];
        
        [_btn_play removeTarget:self action:@selector(playFiles:) forControlEvents:UIControlEventTouchUpInside];
        [_btn_play addTarget:self action:@selector(fileDownload:) forControlEvents:UIControlEventTouchUpInside];
        
    } else if ([[dic_fileinfo objectForKey:@"ctFileStat"]
                isEqualToString:@"downloading"])
    {
        _lbl_play.textColor = textColor2;
        _img_play.hidden = YES;
        _img_play_2.hidden = NO;
        [self rotateImageView];
        _btn_play.enabled = NO;
        
    } else if ([[dic_fileinfo objectForKey:@"ctFileStat"]
                isEqualToString:@"wait"])
    {
        _lbl_play.textColor = textColor2;
        _img_play.hidden = NO;
        _img_play_2.hidden = YES;
        [_img_play setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_down_wait" ofType:@"png"]]];
        _btn_play.enabled = NO;
        
    } else if ([[dic_fileinfo objectForKey:@"ctFileStat"]
                isEqualToString:@"downloaded"])
    {
        _lbl_play.textColor = textColor2;
        _img_play.hidden = NO;
        _img_play_2.hidden = YES;
        [_img_play setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_downed" ofType:@"png"]]];
        _btn_play.enabled = YES;
        
        [_btn_play removeTarget:self action:@selector(playFiles:) forControlEvents:UIControlEventTouchUpInside];
        [_btn_play addTarget:self action:@selector(fileDownload:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)rotateImageView
{
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        [_img_play_2 setTransform:CGAffineTransformRotate(_img_play_2.transform, M_PI_2)];
    }completion:^(BOOL finished){
        if (finished) {
            [self rotateImageView];
        }
    }];
}

- (IBAction)buttonPress:(UIButton*)sender
{
    UIColor *textColor = UIColorFromRGB(0xf74300);
    _lbl_play.textColor = textColor;
    [_img_play setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_down_press" ofType:@"png"]]];
}

- (void)playFiles:(UIButton*)sender
{
    [self makeToast:@"다운로드된 콘텐츠를 재생합니다."];
    [[NSNotificationCenter defaultCenter] postNotificationName:_CMD_FILE_PLAYING object:self userInfo:dic_fileinfo];
}

- (IBAction)fileDownload:(UIButton*)sender
{
    BOOL isUse3G = [GPCommonUtil readBoolFromDefault:@"USE_3G"];
    
    [mainDelegate startAnimatedLodingView];
    
    UIColor *textColor = UIColorFromRGB(0x949494);
    _lbl_play.textColor = textColor;
    [_img_play setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_down_normal" ofType:@"png"]]];
    
    if (GetGPDataCenter.gpNetowrkStatus == NETWORK_3G_LTE && !isUse3G) {
        [mainDelegate stopAnimatedLodingView];
        [GPAlertUtil alertWithMessage:netStatus_3G_down delegate:self tag:1];
        return;
    }
    
    if (GetGPDataCenter.isExistingDownload) {
        [GPAlertUtil alertWithMessage:existingDownlad tag:1003 delegate:self];
    }else{
        if (_downCont == nil) {
           _downCont = mainDelegate.downloadController;
        }
        
        [_downCont downloadFileCheck:dic_fileinfo FileType:[[dic_fileinfo objectForKey:@"ctFileType"] integerValue] isDown:YES];
    }
    [mainDelegate stopAnimatedLodingView];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1002) {
        if (buttonIndex == 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:_CMD_MOVE_SETTING_VIEW object:self];
        }
    } else if (alertView.tag == 1003) {
        if (_downCont == nil) {
            _downCont = mainDelegate.downloadController;
        }
        
        [_downCont downloadFileCheck:dic_fileinfo FileType:sel_btn isDown:YES];
    }
}

@end
