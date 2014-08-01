//
//  ActivityIndicatorCommonViewController.m 
// 
//

#import "ActivityIndicatorCommonViewController.h"
@implementation ActivityIndicatorCommonViewController
@synthesize imageView;
@synthesize indicator;
@synthesize aniView;
@synthesize loading_text;
 
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setUserInteractionEnabled:YES];
//	[indicator startAnimating];
    
    [self.view setBackgroundColor:[UIColor clearColor]];
    
    UIImageView *backView = [[UIImageView alloc] initWithFrame:self.view.frame];
    [backView setBackgroundColor:[UIColor blackColor]];
    [backView setAlpha:0.6];
    [self.view addSubview:backView];
    
    CGSize size = MAIN_SIZE();
    
    [self.aniView setFrame:CGRectMake((size.width - 200) / 2 ,
                                     (size.height - 231) / 2,
                                      200, 231)];
    
    self.aniView.animationImages = [NSArray arrayWithObjects:
                               [UIImage imageNamed:@"loading_01@2x.png"],
                               [UIImage imageNamed:@"loading_02@2x.png"],
                               [UIImage imageNamed:@"loading_03@2x.png"],
                               [UIImage imageNamed:@"loading_04@2x.png"],
                               nil];
    
    [self.view addSubview:self.aniView];
    
    // all frames will execute in 0.7 seconds
    self.aniView.animationDuration = 1.5;
    
    // repeat the annimation forever
    self.aniView.animationRepeatCount = 0;
    
    // start animating
    [self.aniView startAnimating];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	[self.aniView stopAnimating];
}

- (void)removeFromSuperViewFadeout
{
    if ([UIView instancesRespondToSelector:@selector(animateWithDuration:animations:completion:)]) {
        
        [UIView animateWithDuration:0.2
                         animations:^{ self.view.alpha = 0.0; }
                         completion:^(BOOL finished){
                             
                             [self.view removeFromSuperview];
                         }];
        
    } else {
        [UIView beginAnimations:@"FadeIn" context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationDidStopSelector:@selector(removeFromSuperview)];
        
        // Make the animatable changes.
        self.view.alpha = 0.0;
        
        // Commit the changes and perform the animation.
        [UIView commitAnimations];
        
    }
    
    [self.view removeFromSuperview];
}

-(BOOL)shouldAutorotate
{
    return NO;
}

@end
