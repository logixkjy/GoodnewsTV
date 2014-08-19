//
//  GPProgressCell.m
//  GoodNewsPodcast
//
//  Created by 김주영 on 2014. 7. 22..
//  Copyright (c) 2014년 GoodNews. All rights reserved.
//

#import "GPProgressCell.h"

@implementation GPProgressCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setData:(NSDictionary*)fileInfo :(NSString*)fileType :(BOOL)isEdit :(NSIndexPath*)indexPath
{
    _indexPath = indexPath;
    _dic_fileInfo = [NSDictionary dictionaryWithDictionary:fileInfo];
    _str_fileType = fileType;
    switch ([fileType integerValue]) {
        case FILE_TYPE_VIDEO_NORMAL:
            self.lbl_title.text = [NSString stringWithFormat:@"%@_고속",[fileInfo objectForKey:@"ctName"]];
            break;
        case FILE_TYPE_VIDEO_LOW:
            self.lbl_title.text = [NSString stringWithFormat:@"%@_저속",[fileInfo objectForKey:@"ctName"]];
            break;
        case FILE_TYPE_AUDIO:
            self.lbl_title.text = [NSString stringWithFormat:@"%@_음성",[fileInfo objectForKey:@"ctName"]];
            break;
        default:
            break;
    }
    
    self.btn_cancel.tag = 202;
    [self.btn_cancel addTarget:self action:@selector(deleteItem) forControlEvents:UIControlEventTouchUpInside];
    
    self.lbl_down.text = @"다운로드 대기중...";
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fileDownloading:)
                                                 name:_CMD_FILE_DOWNLOADING
                                               object:nil];
}

- (void)fileDownloading:(NSNotification*)noti
{
    NSDictionary *userInfo = noti.userInfo;
    
    if ([[_dic_fileInfo objectForKey:@"ctName"] isEqualToString:[userInfo objectForKey:@"ctName"]] &&
        [_str_fileType isEqualToString:[userInfo objectForKey:@"ctFileType"]]) {
        NSNumber *num_progress = [userInfo objectForKey:@"PERCENT_COMP"];
        if (num_progress != nil) {
            self.progress.progress = [num_progress floatValue]/100;
            self.btn_cancel.tag = 201;
            [self.btn_cancel setTitle:@"중지" forState:UIControlStateNormal];
            self.lbl_down.text = @"다운로드 중...";
        }
    } else {
        self.progress.progress = 0;
    }
    
}

- (void)deleteItem
{
    if (_downCont == nil) {
        AppDelegate *mainDelegate = MAIN_APP_DELEGATE();
        _downCont = mainDelegate.downloadController;
    }
    NSDictionary *user_info = nil;
    if (self.btn_cancel.tag == 201) {
        user_info = [NSDictionary dictionaryWithObjectsAndKeys:_indexPath,@"INDEX_PATH",@"C",@"TYPE", nil];
    } else {
        user_info = [NSDictionary dictionaryWithObjectsAndKeys:_indexPath,@"INDEX_PATH",@"D",@"TYPE", nil];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:_CMD_FILE_DOWN_CANCEL object:self userInfo:user_info];
}
@end
