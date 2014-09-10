//
//  GPGoodNewsCastViewController.h
//  GoodNewsPodcast
//
//  Created by 김주영 on 2014. 7. 14..
//  Copyright (c) 2014년 GoodNews. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "REFrostedViewController.h"

@interface GPGoodNewsCastViewController : UIViewController < UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate >
{
    IBOutlet UIImageView    *_img_btn;
    
}

@property (nonatomic, strong) NSMutableArray *arr_mainList;
@property (nonatomic, strong) NSMutableArray *arr_subList;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) IBOutlet UILabel *lbl_naviTitle;
@property (nonatomic, strong) IBOutlet UIButton *btn_nowplay;

- (IBAction)showMenu;

@end
