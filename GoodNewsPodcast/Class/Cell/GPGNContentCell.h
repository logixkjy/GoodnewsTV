//
//  GPGNContentCell.h
//  GoodNewsPodcast
//
//  Created by 김주영 on 2014. 7. 15..
//  Copyright (c) 2014년 GoodNews. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GPGNContentCell : UITableViewCell <UIAlertViewDelegate> {
    NSMutableDictionary *dic_fileinfo;
    NSInteger sel_btn;
    NSString *str_type;
    NSString *_prCode;
    GPDownloadController *_downCont;
    
    BOOL isFileDown;
    
    AppDelegate *mainDelegate;
}

@property (nonatomic, strong) IBOutlet UILabel *lbl_name;
@property (nonatomic, strong) IBOutlet UILabel *lbl_date;
@property (nonatomic, strong) IBOutlet UIImageView *img_btn_background;
@property (nonatomic, strong) IBOutlet UIButton *btn_video_n;
@property (nonatomic, strong) IBOutlet UIButton *btn_video_l;
@property (nonatomic, strong) IBOutlet UIButton *btn_audio;
@property (nonatomic, strong) IBOutlet UILabel *lbl_video_n;
@property (nonatomic, strong) IBOutlet UILabel *lbl_video_l;
@property (nonatomic, strong) IBOutlet UILabel *lbl_audio;
@property (nonatomic, strong) IBOutlet UIImageView *img_video_n;
@property (nonatomic, strong) IBOutlet UIImageView *img_video_l;
@property (nonatomic, strong) IBOutlet UIImageView *img_audio;
@property (nonatomic, strong) IBOutlet UIImageView *img_video_n2;
@property (nonatomic, strong) IBOutlet UIImageView *img_video_l2;
@property (nonatomic, strong) IBOutlet UIImageView *img_audio2;

- (void)setContentsData:(NSDictionary *)datas :(NSString*)prCode;

@end
