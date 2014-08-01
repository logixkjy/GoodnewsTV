//
//  GPLiveCastViewController.m
//  GoodNewsPodcast
//
//  Created by 김주영 on 2014. 7. 29..
//  Copyright (c) 2014년 GoodNews. All rights reserved.
//

#import "GPLiveCastViewController.h"
#import "GPAudioPlayerViewController.h"
#import "GPSettingViewController.h"

@interface GPLiveCastViewController ()

@end

@implementation GPLiveCastViewController

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
    [self.view addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moveSettingView)
                                                 name:_CMD_MOVE_SETTING_VIEW
                                               object:nil];
    
    self.btn_nowplay.hidden = !GetGPDataCenter.isAudioPlaying;
    [self.btn_nowplay addTarget:self action:@selector(moveAudioPlayView) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:_CMD_MOVE_SETTING_VIEW object:nil];
}

#pragma mark -
#pragma mark Gesture recognizer

- (void)panGestureRecognized:(UIPanGestureRecognizer *)sender
{
    // Dismiss keyboard (optional)
    //
    [self.view endEditing:YES];
    [self.frostedViewController.view endEditing:YES];
    
    // Present the view controller
    //
    [self.frostedViewController panGestureRecognized:sender];
}

- (IBAction)pressBtn
{
    _img_btn.highlighted = !_img_btn.highlighted;
}

- (IBAction)showMenu
{
    // Dismiss keyboard (optional)
    //
    [self.view endEditing:YES];
    [self.frostedViewController.view endEditing:YES];
    
    // Present the view controller
    //
    [self.frostedViewController presentMenuViewController];
    _img_btn.highlighted = !_img_btn.highlighted;
}

- (void)moveAudioPlayView
{
    GPAudioPlayerViewController *audioPlayer = [self.storyboard instantiateViewControllerWithIdentifier:@"AudioPlayer"];
    audioPlayer.dic_contents_data = [NSMutableDictionary dictionaryWithDictionary:GetGPDataCenter.dic_playInfo];
    [self.navigationController pushViewController:audioPlayer animated:YES];
}

- (void)moveSettingView
{
    GPSettingViewController *settingViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingView"];
    [self.navigationController pushViewController:settingViewController animated:YES];
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

@end
