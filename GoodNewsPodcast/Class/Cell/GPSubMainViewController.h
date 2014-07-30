//
//  GPSubMainViewController.h
//  GoodNewsPodcast
//
//  Created by 김주영 on 2014. 7. 22..
//  Copyright (c) 2014년 GoodNews. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "REFrostedViewController.h"

@interface GPSubMainViewController : UIViewController < UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate >
{
    IBOutlet UIImageView *_img_back_btn;
    IBOutlet UIImageView *_img_menu_btn;
    
}

@property (nonatomic, strong) NSMutableArray *arr_mainList;
@property (nonatomic, strong) NSMutableArray *arr_subList;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

- (IBAction)showMenu;

@end
