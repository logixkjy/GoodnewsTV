//
//  GPNavigationController.h
//  GoodNewsPodcast
//
//  Created by 김주영 on 2014. 7. 14..
//  Copyright (c) 2014년 GoodNews. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "REFrostedViewController.h"

@interface GPNavigationController : UINavigationController

- (void)panGestureRecognized:(UIPanGestureRecognizer *)sender;

@end
