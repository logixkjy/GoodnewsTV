//
//  GPMoviePlayerViewController.m
//  GoodNewsPodcast
//
//  Created by 김주영 on 2014. 7. 15..
//  Copyright (c) 2014년 GoodNews. All rights reserved.
//

#import "GPMoviePlayerViewController.h"

@interface GPMoviePlayerViewController ()

@end

@implementation GPMoviePlayerViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

-(BOOL)shouldAutorotate
{
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return 0;
}

- (id) initWithContentURL:(NSURL *)contentURL {
    self = [super initWithContentURL:contentURL];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(detectOrientation) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
    }
    return self;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)detectOrientation {
    UIDeviceOrientation toInterfaceOrientation = [[UIDevice currentDevice] orientation];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationCurve:2];
    
    CGSize size = [UIScreen mainScreen].bounds.size;
    if(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft){
        self.view.transform = CGAffineTransformMakeRotation(-M_PI_2);
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft];
        self.view.bounds = CGRectMake(0, 0, size.height, size.width);
    } else if(toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        self.view.transform = CGAffineTransformMakeRotation(M_PI_2);
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight];
        self.view.bounds = CGRectMake(0, 0, size.height, size.width);
    } else if(toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        self.view.transform = CGAffineTransformMakeRotation(M_PI);
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortraitUpsideDown];
        self.view.bounds = CGRectMake(0, 0, size.width, size.height);
    } else if(toInterfaceOrientation == UIInterfaceOrientationPortrait) {
        self.view.transform = CGAffineTransformMakeRotation(0);
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
        self.view.bounds = CGRectMake(0, 0, size.width, size.height);
    }
    
    [UIView commitAnimations];
    
    [[UIApplication sharedApplication] setStatusBarOrientation:[self interfaceOrientation] animated:NO];
}

@end
