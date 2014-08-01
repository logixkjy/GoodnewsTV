//
//  GPDWContentsCell.h
//  GoodNewsPodcast
//
//  Created by 김주영 on 2014. 8. 1..
//  Copyright (c) 2014년 GoodNews. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GPDWContentsCell : UITableViewCell <UIAlertViewDelegate>
{
    NSMutableDictionary *dic_fileinfo;
    NSDictionary *userInfo;
}


@property (nonatomic, strong) IBOutlet UILabel *lbl_name;
@property (nonatomic, strong) IBOutlet UILabel *lbl_date;
@property (nonatomic, strong) IBOutlet UIImageView *img_btn_background;
@property (nonatomic, strong) IBOutlet UIButton *btn_play;
@property (nonatomic, strong) IBOutlet UIButton *btn_delete;
@property (nonatomic, strong) NSIndexPath *indexPath;

- (void)setContentsData:(NSDictionary *)datas indexPath:(NSIndexPath*)indexPath;

@end
