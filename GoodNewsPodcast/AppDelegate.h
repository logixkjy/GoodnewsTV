//
//  AppDelegate.h
//  GoodNewsPodcast
//
//  Created by 김주영 on 2014. 7. 14..
//  Copyright (c) 2014년 GoodNews. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iVersion.h"
@import MediaPlayer;

@class ActivityIndicatorCommonViewController;
@class GPDownloadController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, iVersionDelegate> {
    GPDownloadController *_downloadController;
    ActivityIndicatorCommonViewController *processingController;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) GPDownloadController *downloadController;
@property (strong, nonatomic) MPMoviePlayerController		*audioPlayer;

- (void)startAnimatedLodingView;
- (void)stopAnimatedLodingView;

@end