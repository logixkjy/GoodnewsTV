//
//  GPLiveCastViewController.h
//  GoodNewsPodcast
//
//  Created by 김주영 on 2014. 7. 29..
//  Copyright (c) 2014년 GoodNews. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GPLiveCastViewController : UIViewController
{
    IBOutlet UIImageView    *_img_btn;
    int count;
    NSTimer *timer;
    
    BOOL    isFirst;
    
    NSString *str_selCh;
}

@property (nonatomic, strong) IBOutlet UIButton *btn_nowplay;
@property (nonatomic, strong) IBOutlet UILabel  *lbl_msg;

@property (nonatomic, strong) IBOutlet UIView       *view_major_TV;
@property (nonatomic, strong) IBOutlet UIImageView  *img_major_TV_bg;
@property (nonatomic, strong) IBOutlet UIButton     *btn_major_TV;
@property (nonatomic, strong) IBOutlet UILabel      *lbl_major_TV;
@property (nonatomic, strong) IBOutlet UIImageView  *img_major_TV_check;

@property (nonatomic, strong) IBOutlet UIView       *view_major_Audio;
@property (nonatomic, strong) IBOutlet UIImageView  *img_major_Audio_bg;
@property (nonatomic, strong) IBOutlet UIButton     *btn_major_Audio;
@property (nonatomic, strong) IBOutlet UILabel      *lbl_major_Audio;
@property (nonatomic, strong) IBOutlet UIImageView  *img_major_Audio_check;

@property (nonatomic, strong) IBOutlet UIView *menu_view;

@property (nonatomic, strong) NSMutableArray        *arr_views;
@property (nonatomic, strong) NSMutableArray        *arr_bg_img;
@property (nonatomic, strong) NSMutableArray        *arr_btns;
@property (nonatomic, strong) NSMutableArray        *arr_labels;

@property (nonatomic, strong) NSMutableArray *arr_channelList;
@property (nonatomic, strong) NSMutableDictionary *dic_MsgIfo;


- (IBAction)showMenu;

@end
