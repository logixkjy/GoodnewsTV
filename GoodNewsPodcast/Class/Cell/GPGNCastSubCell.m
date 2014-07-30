//
//  GPGNCastSubCell.m
//  GoodNewsPodcast
//
//  Created by 김주영 on 2014. 7. 30..
//  Copyright (c) 2014년 GoodNews. All rights reserved.
//

#import "GPGNCastSubCell.h"

@implementation GPGNCastSubCell

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


- (void)setGNCastListData:(NSDictionary *)datas
{
    UIFont *font = [UIFont systemFontOfSize:17];
    CGSize maxSize;
    CGSize viewSize;
    
    [self.lbl_mainTitle setText:[datas objectForKey:@"prTitle"]];
    
    if ([datas objectForKey:@"pcSub"] != nil) {
        [self.img_plus setHidden:NO];
        maxSize = CGSizeMake(256, 22);
    } else {
        [self.img_plus setHidden:YES];
        maxSize = CGSizeMake(281, 22);
    }
   
    if ([[datas objectForKey:@"prNew"] isEqualToString:@"YES"]) {
        self.img_new.hidden = NO;
    }else{
        self.img_new.hidden = YES;
    }
    
    if (IS_iOS_7) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        paragraphStyle.alignment = NSTextAlignmentLeft;
        NSDictionary *attributes = @{NSFontAttributeName: font, NSParagraphStyleAttributeName: paragraphStyle};
        viewSize = [[datas objectForKey:@"prTitle"] boundingRectWithSize:maxSize options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                                              attributes:attributes  context:nil].size;
    }else{
        viewSize = [[datas objectForKey:@"prTitle"] sizeWithFont:font constrainedToSize:maxSize lineBreakMode:NSLineBreakByCharWrapping];
    }
    
    [self.lbl_mainTitle setFrame:CGRectMake(self.lbl_mainTitle.frame.origin.x,
                                            self.lbl_mainTitle.frame.origin.y,
                                            viewSize.width,
                                            viewSize.height)];
    
}

@end
