//
//  GPGNContentCell.m
//  GoodNewsPodcast
//
//  Created by 김주영 on 2014. 7. 15..
//  Copyright (c) 2014년 GoodNews. All rights reserved.
//

#import "GPGNContentCell.h"
#import "GPDownloadController.h"
#import "GPSettingViewController.h"
#import "TUNinePatchCache.h"
#import "GPDownload.h"
#import "GPAlertUtil.h"
#import "GPDataCenter.h"

#define BTN_DOWN_VIDEO_N 0
#define BTN_DOWN_VIDEO_L 1
#define BTN_DOWN_AUDIO_A 2

@implementation GPGNContentCell

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

- (void)setContentsData:(NSDictionary *)datas :(NSString*)prCode
{
    mainDelegate = MAIN_APP_DELEGATE();
    dic_fileinfo = [NSMutableDictionary dictionaryWithDictionary:datas];
    _prCode = prCode;
    
    [self.lbl_name setText:[dic_fileinfo objectForKey:@"ctName"]];
    [self.lbl_phrase setText:[dic_fileinfo objectForKey:@"ctPhrase"]];
    [self.lbl_date setText:[NSString stringWithFormat:@"%@  재생시간 : %@",[dic_fileinfo objectForKey:@"ctEventDate"],[dic_fileinfo objectForKey:@"ctDuration"]]];
    [self.lbl_speaker setText:[dic_fileinfo objectForKey:@"ctSpeaker"]];
    [self.img_btn_background setImage:[TUNinePatchCache imageOfSize:[self.img_btn_background bounds].size forNinePatchNamed:@"box_down"]];
    
    int btnCnt = 3;
    if ([[dic_fileinfo objectForKey:@"ctVideoNormal"] length] == 0 ||
        [dic_fileinfo objectForKey:@"ctVideoNormal"] == nil) {
        btnCnt--;
    }
    if ([[dic_fileinfo objectForKey:@"ctVideoLow"] length] == 0 ||
        [dic_fileinfo objectForKey:@"ctVideoLow"] == nil) {
        btnCnt--;
    }
    if ([[dic_fileinfo objectForKey:@"ctAudioDown"] length] == 0 ||
        [dic_fileinfo objectForKey:@"ctAudioDown"] == nil) {
        btnCnt--;
    }
    [self setButton:btnCnt];
}

- (void)setButton:(int)btnCnt
{
    UIColor *textColor = UIColorFromRGB(0x949494);
    UIColor *textColor2 = UIColorFromRGB(0xf74300);
    if (btnCnt == 0) {
        self.lbl_video_n.hidden = YES;
        self.lbl_video_l.hidden = YES;
        self.lbl_audio.hidden = YES;
        self.img_video_n.hidden = YES;
        self.img_video_n2.hidden = YES;
        self.img_video_l.hidden = YES;
        self.img_video_l2.hidden = YES;
        self.img_audio.hidden = YES;
        self.img_audio2.hidden = YES;
        self.btn_video_l.hidden = YES;
        self.btn_video_n.hidden = YES;
        self.btn_audio.hidden = YES;
        self.img_line_1.hidden = YES;
        self.img_line_2.hidden = YES;
        self.img_btn_background.hidden = YES;
    }
    else if (btnCnt == 1)
    {
        self.lbl_video_n.hidden = YES;
        self.lbl_video_l.hidden = YES;
        self.img_video_n.hidden = YES;
        self.img_video_n2.hidden = YES;
        self.img_video_l.hidden = YES;
        self.img_video_l2.hidden = YES;
        self.btn_video_l.hidden = YES;
        self.btn_video_n.hidden = YES;
        self.img_line_1.hidden = YES;
        self.img_line_2.hidden = YES;
        
        [self.img_btn_background setFrame:CGRectMake(193, 0, 97, 28)];
        
        if ([dic_fileinfo objectForKey:@"ctVideoNormal"] != nil) {
            _lbl_audio.text = @"Video 고속";
            _btn_audio.tag = BTN_DOWN_VIDEO_N;
            if ([[dic_fileinfo objectForKey:@"ctVideoNormalStat"]
                 isEqualToString:@"normal"])
            {
                _lbl_audio.textColor = textColor;
                _img_audio.hidden = NO;
                _img_audio2.hidden = YES;
                _btn_audio.enabled = YES;
                [_img_audio setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_down_normal" ofType:@"png"]]];
                
            } else if ([[dic_fileinfo objectForKey:@"ctVideoNormalStat"]
                        isEqualToString:@"downloading"])
            {
                _lbl_audio.textColor = textColor2;
                _img_audio.hidden = YES;
                _img_audio2.hidden = NO;
                [self rotateImageView:_img_audio2];
                _btn_audio.enabled = NO;
                
            } else if ([[dic_fileinfo objectForKey:@"ctVideoNormalStat"]
                        isEqualToString:@"wait"])
            {
                _lbl_audio.textColor = textColor2;
                _img_audio.hidden = NO;
                _img_audio2.hidden = YES;
                [_img_audio setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_down_wait" ofType:@"png"]]];
                _btn_audio.enabled = NO;
                
            } else if ([[dic_fileinfo objectForKey:@"ctVideoNormalStat"]
                        isEqualToString:@"downloaded"])
            {
                _lbl_audio.textColor = textColor2;
                _img_audio.hidden = NO;
                _img_audio2.hidden = YES;
                [_img_audio setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_downed" ofType:@"png"]]];
                
                _btn_audio.enabled = NO;
            }
        }
        if ([dic_fileinfo objectForKey:@"ctVideoLow"] != nil) {
            _lbl_audio.text = @"Video 저속";
            _btn_audio.tag = BTN_DOWN_VIDEO_N;
            if ([[dic_fileinfo objectForKey:@"ctVideoLowStat"]
                 isEqualToString:@"normal"])
            {
                _lbl_audio.textColor = textColor;
                _img_audio.hidden = NO;
                _img_audio2.hidden = YES;
                _btn_audio.enabled = YES;
                [_img_audio setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_down_normal" ofType:@"png"]]];
                
            } else if ([[dic_fileinfo objectForKey:@"ctVideoLowStat"]
                        isEqualToString:@"downloading"])
            {
                _lbl_audio.textColor = textColor2;
                _img_audio.hidden = YES;
                _img_audio2.hidden = NO;
                [self rotateImageView:_img_audio2];
                _btn_audio.enabled = NO;
                
            } else if ([[dic_fileinfo objectForKey:@"ctVideoLowStat"]
                        isEqualToString:@"wait"])
            {
                _lbl_audio.textColor = textColor2;
                _img_audio.hidden = NO;
                _img_audio2.hidden = YES;
                [_img_audio setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_down_wait" ofType:@"png"]]];
                _btn_audio.enabled = NO;
                
            } else if ([[dic_fileinfo objectForKey:@"ctVideoLowStat"]
                        isEqualToString:@"downloaded"])
            {
                _lbl_audio.textColor = textColor2;
                _img_audio.hidden = NO;
                _img_audio2.hidden = YES;
                [_img_audio setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_downed" ofType:@"png"]]];
                
                _btn_audio.enabled = NO;
            }
        }
        if ([dic_fileinfo objectForKey:@"ctAudioDown"] != nil) {
            _lbl_audio.text = @"Audio";
            _btn_audio.tag = BTN_DOWN_AUDIO_A;
            if ([[dic_fileinfo objectForKey:@"ctAudioDownStat"]
                 isEqualToString:@"normal"])
            {
                _lbl_audio.textColor = textColor;
                _img_audio.hidden = NO;
                _img_audio2.hidden = YES;
                _btn_audio.enabled = YES;
                [_img_audio setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_down_normal" ofType:@"png"]]];
                
            } else if ([[dic_fileinfo objectForKey:@"ctAudioDownStat"]
                        isEqualToString:@"downloading"])
            {
                _lbl_audio.textColor = textColor2;
                _img_audio.hidden = YES;
                _img_audio2.hidden = NO;
                [self rotateImageView:_img_audio2];
                _btn_audio.enabled = NO;
                
            } else if ([[dic_fileinfo objectForKey:@"ctAudioDownStat"]
                        isEqualToString:@"wait"])
            {
                _lbl_audio.textColor = textColor2;
                _img_audio.hidden = NO;
                _img_audio2.hidden = YES;
                [_img_audio setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_down_wait" ofType:@"png"]]];
                _btn_audio.enabled = NO;
                
            } else if ([[dic_fileinfo objectForKey:@"ctAudioDownStat"]
                        isEqualToString:@"downloaded"])
            {
                _lbl_audio.textColor = textColor2;
                _img_audio.hidden = NO;
                _img_audio2.hidden = YES;
                [_img_audio setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_downed" ofType:@"png"]]];
                
                _btn_audio.enabled = NO;
            }
        }
    }
    else if (btnCnt == 2)
    {
        self.lbl_video_n.hidden = YES;
        self.img_video_n.hidden = YES;
        self.img_video_n2.hidden = YES;
        self.btn_video_n.hidden = YES;
        self.img_line_1.hidden = YES;
        
        [self.img_btn_background setFrame:CGRectMake(97, 0, 193, 28)];
        
        if ([dic_fileinfo objectForKey:@"ctAudioDown"] != nil) {
            _lbl_audio.text = @"Audio";
            _btn_audio.tag = BTN_DOWN_AUDIO_A;
            if ([[dic_fileinfo objectForKey:@"ctAudioDownStat"]
                 isEqualToString:@"normal"])
            {
                _lbl_audio.textColor = textColor;
                _img_audio.hidden = NO;
                _img_audio2.hidden = YES;
                _btn_audio.enabled = YES;
                [_img_audio setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_down_normal" ofType:@"png"]]];
                
            } else if ([[dic_fileinfo objectForKey:@"ctAudioDownStat"]
                        isEqualToString:@"downloading"])
            {
                _lbl_audio.textColor = textColor2;
                _img_audio.hidden = YES;
                _img_audio2.hidden = NO;
                [self rotateImageView:_img_audio2];
                _btn_audio.enabled = NO;
                
            } else if ([[dic_fileinfo objectForKey:@"ctAudioDownStat"]
                        isEqualToString:@"wait"])
            {
                _lbl_audio.textColor = textColor2;
                _img_audio.hidden = NO;
                _img_audio2.hidden = YES;
                [_img_audio setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_down_wait" ofType:@"png"]]];
                _btn_audio.enabled = NO;
                
            } else if ([[dic_fileinfo objectForKey:@"ctAudioDownStat"]
                        isEqualToString:@"downloaded"])
            {
                _lbl_audio.textColor = textColor2;
                _img_audio.hidden = NO;
                _img_audio2.hidden = YES;
                [_img_audio setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_downed" ofType:@"png"]]];
                
                _btn_audio.enabled = NO;
            }
        }
        
        if ([dic_fileinfo objectForKey:@"ctVideoLow"] != nil) {
            if ([dic_fileinfo objectForKey:@"ctAudioDown"] == nil) {
                _lbl_audio.text = @"Video 저속";
                _btn_audio.tag = BTN_DOWN_VIDEO_L;
                if ([[dic_fileinfo objectForKey:@"ctVideoLowStat"]
                     isEqualToString:@"normal"])
                {
                    _lbl_audio.textColor = textColor;
                    _img_audio.hidden = NO;
                    _img_audio2.hidden = YES;
                    _btn_audio.enabled = YES;
                    [_img_audio setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_down_normal" ofType:@"png"]]];
                    
                } else if ([[dic_fileinfo objectForKey:@"ctVideoLowStat"]
                            isEqualToString:@"downloading"])
                {
                    _lbl_audio.textColor = textColor2;
                    _img_audio.hidden = YES;
                    _img_audio2.hidden = NO;
                    [self rotateImageView:_img_audio2];
                    _btn_audio.enabled = NO;
                    
                } else if ([[dic_fileinfo objectForKey:@"ctVideoLowStat"]
                            isEqualToString:@"wait"])
                {
                    _lbl_audio.textColor = textColor2;
                    _img_audio.hidden = NO;
                    _img_audio2.hidden = YES;
                    [_img_audio setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_down_wait" ofType:@"png"]]];
                    _btn_audio.enabled = NO;
                    
                } else if ([[dic_fileinfo objectForKey:@"ctVideoLowStat"]
                            isEqualToString:@"downloaded"])
                {
                    _lbl_audio.textColor = textColor2;
                    _img_audio.hidden = NO;
                    _img_audio2.hidden = YES;
                    [_img_audio setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_downed" ofType:@"png"]]];
                    
                    _btn_audio.enabled = NO;
                }
            } else {
                _lbl_video_l.text = @"Video 저속";
                _btn_video_l.tag = BTN_DOWN_VIDEO_L;
                if ([[dic_fileinfo objectForKey:@"ctVideoLowStat"]
                     isEqualToString:@"normal"])
                {
                    _lbl_video_l.textColor = textColor;
                    _img_video_l.hidden = NO;
                    _img_video_l2.hidden = YES;
                    _btn_video_l.enabled = YES;
                    [_img_video_l setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_down_normal" ofType:@"png"]]];
                    
                } else if ([[dic_fileinfo objectForKey:@"ctVideoLowStat"]
                            isEqualToString:@"downloading"])
                {
                    _lbl_video_l.textColor = textColor2;
                    _img_video_l.hidden = YES;
                    _img_video_l2.hidden = NO;
                    [self rotateImageView:_img_video_l2];
                    _btn_video_l.enabled = NO;
                    
                } else if ([[dic_fileinfo objectForKey:@"ctVideoLowStat"]
                            isEqualToString:@"wait"])
                {
                    _lbl_video_l.textColor = textColor2;
                    _img_video_l.hidden = NO;
                    _img_video_l2.hidden = YES;
                    [_img_video_l setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_down_wait" ofType:@"png"]]];
                    _btn_video_l.enabled = NO;
                    
                } else if ([[dic_fileinfo objectForKey:@"ctVideoLowStat"]
                            isEqualToString:@"downloaded"])
                {
                    _lbl_video_l.textColor = textColor2;
                    _img_video_l.hidden = NO;
                    _img_video_l2.hidden = YES;
                    [_img_video_l setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_downed" ofType:@"png"]]];
                    
                    _btn_video_l.enabled = NO;
                }
            }
            
        }
        
        if ([dic_fileinfo objectForKey:@"ctVideoNormal"] != nil) {
            _lbl_video_l.text = @"Video 고속";
            _btn_video_l.tag = BTN_DOWN_VIDEO_N;
            if ([[dic_fileinfo objectForKey:@"ctVideoLowStat"]
                 isEqualToString:@"normal"])
            {
                _lbl_video_l.textColor = textColor;
                _img_video_l.hidden = NO;
                _img_video_l2.hidden = YES;
                _btn_video_l.enabled = YES;
                [_img_video_l setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_down_normal" ofType:@"png"]]];
                
            } else if ([[dic_fileinfo objectForKey:@"ctVideoLowStat"]
                        isEqualToString:@"downloading"])
            {
                _lbl_video_l.textColor = textColor2;
                _img_video_l.hidden = YES;
                _img_video_l2.hidden = NO;
                [self rotateImageView:_img_video_l2];
                _btn_video_l.enabled = NO;
                
            } else if ([[dic_fileinfo objectForKey:@"ctVideoLowStat"]
                        isEqualToString:@"wait"])
            {
                _lbl_video_l.textColor = textColor2;
                _img_video_l.hidden = NO;
                _img_video_l2.hidden = YES;
                [_img_video_l setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_down_wait" ofType:@"png"]]];
                _btn_video_l.enabled = NO;
                
            } else if ([[dic_fileinfo objectForKey:@"ctVideoLowStat"]
                        isEqualToString:@"downloaded"])
            {
                _lbl_video_l.textColor = textColor2;
                _img_video_l.hidden = NO;
                _img_video_l2.hidden = YES;
                [_img_video_l setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_downed" ofType:@"png"]]];
                
                _btn_video_l.enabled = NO;
            }
        }
    } else {
        if ([[dic_fileinfo objectForKey:@"ctVideoNormalStat"]
             isEqualToString:@"normal"])
        {
            _lbl_video_n.textColor = textColor;
            _img_video_n.hidden = NO;
            _img_video_n2.hidden = YES;
            _btn_video_n.enabled = YES;
            [_img_video_n setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_down_normal" ofType:@"png"]]];
            
        } else if ([[dic_fileinfo objectForKey:@"ctVideoNormalStat"]
                    isEqualToString:@"downloading"])
        {
            _lbl_video_n.textColor = textColor2;
            _img_video_n.hidden = YES;
            _img_video_n2.hidden = NO;
            [self rotateImageView:_img_video_n2];
            _btn_video_n.enabled = NO;
            
        } else if ([[dic_fileinfo objectForKey:@"ctVideoNormalStat"]
                    isEqualToString:@"wait"])
        {
            _lbl_video_n.textColor = textColor2;
            _img_video_n.hidden = NO;
            _img_video_n2.hidden = YES;
            [_img_video_n setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_down_wait" ofType:@"png"]]];
            _btn_video_n.enabled = NO;
            
        } else if ([[dic_fileinfo objectForKey:@"ctVideoNormalStat"]
                    isEqualToString:@"downloaded"])
        {
            _lbl_video_n.textColor = textColor2;
            _img_video_n.hidden = NO;
            _img_video_n2.hidden = YES;
            [_img_video_n setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_downed" ofType:@"png"]]];
            
            _btn_video_n.enabled = NO;
        }
        
        if ([[dic_fileinfo objectForKey:@"ctVideoLowStat"]
             isEqualToString:@"normal"])
        {
            _lbl_video_l.textColor = textColor;
            _img_video_l.hidden = NO;
            _img_video_l2.hidden = YES;
            _btn_video_l.enabled = YES;
            [_img_video_l setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_down_normal" ofType:@"png"]]];
            
        } else if ([[dic_fileinfo objectForKey:@"ctVideoLowStat"]
                    isEqualToString:@"downloading"])
        {
            _lbl_video_l.textColor = textColor2;
            _img_video_l.hidden = YES;
            _img_video_l2.hidden = NO;
            [self rotateImageView:_img_video_l2];
            _btn_video_l.enabled = NO;
            
        } else if ([[dic_fileinfo objectForKey:@"ctVideoLowStat"]
                    isEqualToString:@"wait"])
        {
            _lbl_video_l.textColor = textColor2;
            _img_video_l.hidden = NO;
            _img_video_l2.hidden = YES;
            [_img_video_l setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_down_wait" ofType:@"png"]]];
            _btn_video_l.enabled = NO;
            
        } else if ([[dic_fileinfo objectForKey:@"ctVideoLowStat"]
                    isEqualToString:@"downloaded"])
        {
            _lbl_video_l.textColor = textColor2;
            _img_video_l.hidden = NO;
            _img_video_l2.hidden = YES;
            [_img_video_l setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_downed" ofType:@"png"]]];
            
            _btn_video_l.enabled = NO;
        }
        
        if ([[dic_fileinfo objectForKey:@"ctAudioDownStat"]
             isEqualToString:@"normal"])
        {
            _lbl_audio.textColor = textColor;
            _img_audio.hidden = NO;
            _img_audio2.hidden = YES;
            _btn_audio.enabled = YES;
            [_img_audio setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_down_normal" ofType:@"png"]]];
            
        } else if ([[dic_fileinfo objectForKey:@"ctAudioDownStat"]
                    isEqualToString:@"downloading"])
        {
            _lbl_audio.textColor = textColor2;
            _img_audio.hidden = YES;
            _img_audio2.hidden = NO;
            [self rotateImageView:_img_audio2];
            _btn_audio.enabled = NO;
            
        } else if ([[dic_fileinfo objectForKey:@"ctAudioDownStat"]
                    isEqualToString:@"wait"])
        {
            _lbl_audio.textColor = textColor2;
            _img_audio.hidden = NO;
            _img_audio2.hidden = YES;
            [_img_audio setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_down_wait" ofType:@"png"]]];
            _btn_audio.enabled = NO;
            
        } else if ([[dic_fileinfo objectForKey:@"ctAudioDownStat"]
                    isEqualToString:@"downloaded"])
        {
            _lbl_audio.textColor = textColor2;
            _img_audio.hidden = NO;
            _img_audio2.hidden = YES;
            [_img_audio setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_downed" ofType:@"png"]]];
            
            _btn_audio.enabled = NO;
        }
    }
}

- (void)rotateImageView:(UIImageView*)imageView
{
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        [imageView setTransform:CGAffineTransformRotate(imageView.transform, M_PI_2)];
    }completion:^(BOOL finished){
        if (finished) {
            [self rotateImageView:imageView];
        }
    }];
}

- (IBAction)buttonPress:(UIButton*)sender
{
    UIColor *textColor = UIColorFromRGB(0xf74300);
    switch (sender.tag) {
        case BTN_DOWN_VIDEO_N:
            _lbl_video_n.textColor = textColor;
            [_img_video_n setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_down_press" ofType:@"png"]]];
            break;
        case BTN_DOWN_VIDEO_L:
            _lbl_video_l.textColor = textColor;
            [_img_video_l setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_down_press" ofType:@"png"]]];
            break;
        case BTN_DOWN_AUDIO_A:
            _lbl_audio.textColor = textColor;
            [_img_audio setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_down_press" ofType:@"png"]]];
            break;
        default:
            break;
    }
}

- (IBAction)fileDownload:(UIButton*)sender
{
    BOOL isUse3G = [GPCommonUtil readBoolFromDefault:@"USE_3G"];
    
    [mainDelegate startAnimatedLodingView];
    UIColor *textColor = UIColorFromRGB(0x949494);
    [dic_fileinfo setValue:_prCode forKey:@"prCode"];
    switch (sender.tag) {
        case BTN_DOWN_VIDEO_N:
            sel_btn = FILE_TYPE_VIDEO_NORMAL;
            _lbl_video_n.textColor = textColor;
            [_img_video_n setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_down_normal" ofType:@"png"]]];
            break;
        case BTN_DOWN_VIDEO_L:
            sel_btn = FILE_TYPE_VIDEO_LOW;
            _lbl_video_l.textColor = textColor;
            [_img_video_l setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_down_normal" ofType:@"png"]]];
            break;
        case BTN_DOWN_AUDIO_A:
            sel_btn = FILE_TYPE_AUDIO;
            _lbl_audio.textColor = textColor;
            [_img_audio setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_down_normal" ofType:@"png"]]];
            break;
        default:
            break;
    }
    
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
        
        [_downCont downloadFileCheck:dic_fileinfo FileType:sel_btn isDown:YES];
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
