//
//  AppDelegate.h
//  GoodNewsPodcast
//
//  Created by 김주영 on 2014. 7. 14..
//  Copyright (c) 2014년 GoodNews. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iVersion.h"

@class GPDownloadController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, iVersionDelegate> {
    GPDownloadController *_downloadController;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) GPDownloadController *downloadController;

@end
