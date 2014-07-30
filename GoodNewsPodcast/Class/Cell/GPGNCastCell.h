//
//  GPGNCastCell.h
//  GoodNewsPodcast
//
//  Created by 김주영 on 2014. 7. 15..
//  Copyright (c) 2014년 GoodNews. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GPGNCastCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIImageView *img_thumb;
@property (nonatomic, strong) IBOutlet UILabel *lbl_mainTitle;
@property (nonatomic, strong) IBOutlet UILabel *lbl_subTitle;
@property (nonatomic, strong) IBOutlet UIImageView *img_plus;
@property (nonatomic, strong) IBOutlet UIImageView *img_new;

- (void)setGNCastListData:(NSDictionary*)datas;

@end
