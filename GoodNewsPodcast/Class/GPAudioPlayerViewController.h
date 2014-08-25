//
//  GPAudioPlayerViewController.h
//  GoodNewsPodcast
//
//  Created by 김주영 on 2014. 7. 16..
//  Copyright (c) 2014년 GoodNews. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "REFrostedViewController.h"
#import "GAITrackedViewController.h"
#import "CBAutoScrollLabel.h"
@import MediaPlayer;
@import AVFoundation;
@import AudioToolbox;

@interface GPAudioPlayerViewController : GAITrackedViewController <AVAudioSessionDelegate> {
    IBOutlet UIImageView *_img_back_btn;
    IBOutlet UIImageView *_img_menu_btn;
    
    MPMoviePlayerController		*audioPlayer;
    BOOL                        isFileOpenFail;
    
    NSTimer                     *silderTimer;
    
    AppDelegate                 *mainDelegate;
}

@property (nonatomic, strong) IBOutlet UIView *playerView;
@property (nonatomic, strong) IBOutlet UIImageView *img_thumb;
@property (nonatomic, strong) IBOutlet CBAutoScrollLabel *asl_naviTitle;

@property (nonatomic, strong) IBOutlet UIView *toolbarView;
@property (nonatomic, strong) IBOutlet UIView *volumeView;
@property (nonatomic, strong) IBOutlet UISlider *timeProgress;
@property (nonatomic, strong) IBOutlet UILabel *lbl_title;
@property (nonatomic, strong) IBOutlet UILabel *lbl_subtitle;
@property (nonatomic, strong) IBOutlet UILabel *lbl_playtime;
@property (nonatomic, strong) IBOutlet UILabel *lbl_lasttime;
@property (nonatomic, strong) IBOutlet UIButton *btn_play;

@property (nonatomic, strong) NSMutableDictionary *dic_contents_data;
@property (nonatomic, strong) NSString *prCode;

@end
