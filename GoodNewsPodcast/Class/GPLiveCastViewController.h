//
//  GPLiveCastViewController.h
//  GoodNewsPodcast
//
//  Created by 김주영 on 2014. 7. 29..
//  Copyright (c) 2014년 GoodNews. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GPLiveCastViewController : UIViewController
{
    IBOutlet UIImageView    *_img_btn;
    
}

@property (nonatomic, strong) IBOutlet UIButton *btn_nowplay;

- (IBAction)showMenu;

@end
