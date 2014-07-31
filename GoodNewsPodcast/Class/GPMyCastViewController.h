//
//  GPMyCastViewController.h
//  GoodNewsPodcast
//
//  Created by 김주영 on 2014. 7. 14..
//  Copyright (c) 2014년 GoodNews. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "REFrostedViewController.h"

@interface GPMyCastViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UIImageView    *_img_btn;
    
    UIPanGestureRecognizer *panGesture;
}

@property (nonatomic, strong) NSMutableArray *arr_myCast;
@property (strong, nonatomic) IBOutlet UITableView  *tableView;
@property (nonatomic, strong) IBOutlet UILabel *lbl_naviTitle;

- (IBAction)showMenu;

@end
