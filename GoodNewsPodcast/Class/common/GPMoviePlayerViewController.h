//
//  GPMoviePlayerViewController.h
//  GoodNewsPodcast
//
//  Created by 김주영 on 2014. 7. 15..
//  Copyright (c) 2014년 GoodNews. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>

@interface GPMoviePlayerViewController : MPMoviePlayerViewController {
    NSTimer *_timer;
}

@property (nonatomic) BOOL isPlaying;
@end
