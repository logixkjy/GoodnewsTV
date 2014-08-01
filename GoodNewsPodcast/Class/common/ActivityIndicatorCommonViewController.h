//
//  ActivityIndicatorCommonViewController.h
//  trueFriend
// 
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface ActivityIndicatorCommonViewController : UIViewController {
	IBOutlet UIActivityIndicatorView *indicator;
    IBOutlet UIImageView *imageView;
    IBOutlet UIImageView *aniView;
    IBOutlet UILabel *loading_text;
}

@property (nonatomic,retain) IBOutlet UIImageView *imageView;
@property (nonatomic,retain) IBOutlet UIImageView *aniView;
@property (nonatomic,retain) IBOutlet UIActivityIndicatorView *indicator;
@property (nonatomic,retain) IBOutlet UILabel *loading_text;

- (void) rotateByAngle;
- (void)removeFromSuperViewFadeout;

@end
