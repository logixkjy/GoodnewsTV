//
//  GPMenuViewController.m
//  GoodNewsPodcast
//
//  Created by 김주영 on 2014. 7. 14..
//  Copyright (c) 2014년 GoodNews. All rights reserved.
//

#import "GPMenuViewController.h"
#import "GPSettingTableViewCell.h"
#import "GPNavigationController.h"
#import "GPGoodNewsCastViewController.h"
#import "GPMyCastViewController.h"
#import "GPDownloadBoxViewController.h"
#import "GPLiveCastViewController.h"

@interface GPMenuViewController ()

@end

@implementation GPMenuViewController

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

- (IBAction)goSettingView {
    [[NSNotificationCenter defaultCenter] postNotificationName:_CMD_MOVE_SETTING_VIEW object:self];
    [self.frostedViewController hideMenuViewController];
}

#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    GPNavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"contentController"];
    
    if (indexPath.row == 0) {
        GPGoodNewsCastViewController *goodNewsCastViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GoodNewsCast"];
        navigationController.viewControllers = @[goodNewsCastViewController];
    } else if (indexPath.row == 1) {
        GPLiveCastViewController *liveCastViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LiveCast"];
        navigationController.viewControllers = @[liveCastViewController];
    } else if (indexPath.row == 2) {
        GPMyCastViewController *myCastViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MyCast"];
        navigationController.viewControllers = @[myCastViewController];
    } else if (indexPath.row == 3) {
        GPGoodNewsCastViewController *myCastViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DownloadBox"];
        navigationController.viewControllers = @[myCastViewController];
    }
    
    self.frostedViewController.contentViewController = navigationController;
    [self.frostedViewController hideMenuViewController];
}

#pragma mark -
#pragma mark UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    GPSettingTableViewCell *cell = (GPSettingTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[GPSettingTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSArray *icons = @[@"sidemenu_icon_home.png", @"sidemenu_icon_live.png", @"sidemenu_icon_mycast.png", @"sidemenu_icon_folder.png"];
    cell.img_icon.image = [UIImage imageNamed:icons[indexPath.row]];
    
    NSArray *titles = @[@"홈", @"생중계", @"마이 캐스트", @"다운로드"];
    cell.lbl_title.text = titles[indexPath.row];
    
    return cell;
}

@end
