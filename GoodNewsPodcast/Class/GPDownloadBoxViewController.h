//
//  GPDownloadBoxViewController.h
//  GoodNewsPodcast
//
//  Created by 김주영 on 2014. 7. 14..
//  Copyright (c) 2014년 GoodNews. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "REFrostedViewController.h"

@interface GPDownloadBoxViewController : UIViewController < UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UIImageView    *_img_btn;
    GPDownloadController    *_downCont;
    BOOL                    isEdit;
}

@property (strong, nonatomic) IBOutlet UISegmentedControl *sc_selectView;
@property (strong, nonatomic) IBOutlet UIButton     *btn_downPause;
@property (strong, nonatomic) IBOutlet UIButton     *btn_downStart;
@property (strong, nonatomic) IBOutlet UIImageView  *img_downPause;
@property (strong, nonatomic) IBOutlet UIImageView  *img_downStart;

@property (strong, nonatomic) IBOutlet UIView       *view_fileList;
@property (strong, nonatomic) IBOutlet UITableView  *tb_fileList;

@property (strong, nonatomic) IBOutlet UIView       *view_downList;
@property (strong, nonatomic) IBOutlet UITableView  *tb_downList;

@property (nonatomic, strong) NSMutableArray *arr_downList;
@property (nonatomic, strong) NSMutableArray *arr_downList_fileType;

@property (nonatomic, strong) NSMutableArray *arr_downBox;
@property (nonatomic, strong) NSMutableArray *arr_downBoxSection;

- (IBAction)showMenu;

@end
