//
//  GPContentsViewController.h
//  GoodNewsPodcast
//
//  Created by 김주영 on 2014. 7. 15..
//  Copyright (c) 2014년 GoodNews. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "REFrostedViewController.h"
#import "GAITrackedViewController.h"
#import "GPDownloadController.h"
#import "GPMoviePlayerViewController.h"
#import "CoreDataHelper.h"
#import "FileInfo.h"

@interface GPContentsViewController : GAITrackedViewController < UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate > {
    IBOutlet UIImageView *_img_back_btn;
    IBOutlet UIImageView *_img_menu_btn;
    
    GPMoviePlayerViewController *_mpv_playVideo;
    
    BOOL _isRotation;
    
    NSURL *url_path;
    
    NSInteger *int_selType;
    int selBtnType;
    GPDownloadController    *_downCont;
    CoreDataHelper          *_dataHelper;
    
    int moreViewCnt;
}

@property (nonatomic, strong) IBOutlet UILabel *lbl_naviTitle;
@property (nonatomic, strong) IBOutlet UIImageView *img_thumb;
@property (nonatomic, strong) IBOutlet UIImageView *img_line;
@property (nonatomic, strong) IBOutlet UILabel *lbl_Title;
@property (nonatomic, strong) IBOutlet UILabel *lbl_subTitle;
@property (nonatomic, strong) IBOutlet UITextView *tv_contents;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableDictionary *dic_contents_data;
@property (nonatomic, strong) NSMutableDictionary *dic_selected_data;
@property (nonatomic, strong) NSMutableArray *arr_contents_list;
@property (nonatomic, strong) NSMutableArray *arr_moreView;
@property (nonatomic, strong) IBOutlet UIButton *btn_nowplay;

@end
