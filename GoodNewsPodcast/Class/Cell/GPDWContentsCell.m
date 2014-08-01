//
//  GPDWContentsCell.m
//  GoodNewsPodcast
//
//  Created by 김주영 on 2014. 8. 1..
//  Copyright (c) 2014년 GoodNews. All rights reserved.
//

#import "GPDWContentsCell.h"
#import "TUNinePatchCache.h"

@implementation GPDWContentsCell

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

- (void)setContentsData:(NSDictionary *)datas indexPath:(NSIndexPath*)indexPath
{
    self.indexPath = indexPath;
    UIColor *textColor = UIColorFromRGB(0x949494);
    UIColor *textColor2 = UIColorFromRGB(0x002085);
    dic_fileinfo = [NSMutableDictionary dictionaryWithDictionary:datas];
    
    NSString *ctName = [dic_fileinfo objectForKey:@"ctName"];
    if ([[dic_fileinfo objectForKey:@"ctPhrase"] length] != 0) {
        ctName = [ctName stringByAppendingString:[dic_fileinfo objectForKey:@"ctPhrase"]];
    }
    [self.lbl_name setText:ctName];
    [self.lbl_date setText:[dic_fileinfo objectForKey:@"ctEventDate"]];
    if ([[dic_fileinfo objectForKey:@"ctDuration"] length] != 0) {
        self.lbl_date.text = [self.lbl_date.text stringByAppendingFormat:@" 재생시간 : %@",[dic_fileinfo objectForKey:@"ctDuration"]];
    }
    
    [self.img_btn_background setImage:[TUNinePatchCache imageOfSize:[self.img_btn_background bounds].size forNinePatchNamed:@"box_down"]];
    
    [self.btn_play setTitleColor:textColor forState:UIControlStateNormal];
    [self.btn_play setTitleColor:textColor2 forState:UIControlStateHighlighted];
    [self.btn_delete setTitleColor:textColor forState:UIControlStateNormal];
    [self.btn_delete setTitleColor:textColor2 forState:UIControlStateHighlighted];
    
    switch ([[dic_fileinfo objectForKey:@"ctFileType"] integerValue]) {
        case FILE_TYPE_VIDEO_NORMAL:
        {
            [self.btn_play setTitle:@"Video 고속" forState:UIControlStateNormal];
            [self.btn_play setTitle:@"Video 고속" forState:UIControlStateHighlighted];
        }
            break;
        case FILE_TYPE_VIDEO_LOW:
        {
            [self.btn_play setTitle:@"Video 저속" forState:UIControlStateNormal];
            [self.btn_play setTitle:@"Video 저속" forState:UIControlStateHighlighted];
        }
            break;
        case FILE_TYPE_AUDIO:
        {
            [self.btn_play setTitle:@"Audio" forState:UIControlStateNormal];
            [self.btn_play setTitle:@"Audio" forState:UIControlStateHighlighted];
        }
            break;
    }
}

- (IBAction)buttonTouchUpInside:(UIButton*)sender{
    switch (sender.tag) {
        case 2001:
        {
            userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                        @"P",           @"ButtonType",
                        self.indexPath, @"indexPath",
                        nil];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:_CMD_DOWN_BOX_EVENT object:nil userInfo:userInfo];
        }
            break;
        case 2002:
        {
            [GPAlertUtil alertWithMessage:@"파일을 삭제 하시겠습니까?" delegate:self tag:4];
        }
            break;
            
        default:
            break;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1005) {
        if (buttonIndex == 0) {
            userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                        @"D",           @"ButtonType",
                        self.indexPath, @"indexPath",
                        nil];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:_CMD_DOWN_BOX_EVENT object:nil userInfo:userInfo];
        }
    }
}

@end
