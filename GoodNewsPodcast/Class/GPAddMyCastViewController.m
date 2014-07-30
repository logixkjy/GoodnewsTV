//
//  GPAddMyCastViewController.m
//  GoodNewsPodcast
//
//  Created by KimJooYoung on 2014. 7. 30..
//  Copyright (c) 2014년 GoodNews. All rights reserved.
//

#import "GPAddMyCastViewController.h"
#import "NinePatch.h"

@interface GPAddMyCastViewController ()

@end

@implementation GPAddMyCastViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [_btn_mycast_add setBackgroundImage:[TUNinePatchCache imageOfSize:[_btn_mycast_add bounds].size forNinePatchNamed:@"box_btn"] forState:UIControlStateNormal];
    [_img_xml_address setImage:[TUNinePatchCache imageOfSize:[_img_xml_address bounds].size forNinePatchNamed:@"box_add"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)closeAddView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

@end
