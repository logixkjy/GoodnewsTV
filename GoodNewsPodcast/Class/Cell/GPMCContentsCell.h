//
//  GPMCContentsCell.h
//  GoodNewsPodcast
//
//  Created by 김주영 on 2014. 7. 31..
//  Copyright (c) 2014년 GoodNews. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GPMCContentsCell : UITableViewCell <UIAlertViewDelegate> {
    NSMutableDictionary *dic_fileinfo;
    NSInteger sel_btn;
    NSString *str_type;
    GPDownloadController *_downCont;
    
    BOOL isFileDown;
    
    AppDelegate *mainDelegate;
}

@property (nonatomic, strong) IBOutlet UILabel *lbl_name;
@property (nonatomic, strong) IBOutlet UILabel *lbl_date;
@property (nonatomic, strong) IBOutlet UIImageView *img_btn_background;
@property (nonatomic, strong) IBOutlet UIButton *btn_play;
@property (nonatomic, strong) IBOutlet UILabel *lbl_play;
@property (nonatomic, strong) IBOutlet UIImageView *img_play;
@property (nonatomic, strong) IBOutlet UIImageView *img_play_2;

- (void)setContentsData:(NSDictionary *)datas;

@end
