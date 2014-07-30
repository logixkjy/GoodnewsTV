//
//  GPProgressCell.h
//  GoodNewsPodcast
//
//  Created by 김주영 on 2014. 7. 22..
//  Copyright (c) 2014년 GoodNews. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPDownloadController.h"

@interface GPProgressCell : UITableViewCell {
    GPDownloadController    *_downCont;
    NSIndexPath             *_indexPath;
    NSDictionary            *_dic_fileInfo;
    NSString                *_str_fileType;
}

@property (strong, nonatomic) IBOutlet UILabel *lbl_title;
@property (strong, nonatomic) IBOutlet UIButton *btn_cancel;
@property (strong, nonatomic) IBOutlet UIProgressView *progress;
@property (strong, nonatomic) IBOutlet UILabel *lbl_down;

- (void)setData:(NSDictionary*)fileInfo :(NSString*)fileType :(BOOL)isEdit :(NSIndexPath*)indexPath;
@end
