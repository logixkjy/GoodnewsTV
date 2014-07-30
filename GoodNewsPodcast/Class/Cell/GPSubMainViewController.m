//
//  GPSubMainViewController.m
//  GoodNewsPodcast
//
//  Created by 김주영 on 2014. 7. 22..
//  Copyright (c) 2014년 GoodNews. All rights reserved.
//

#import "GPSubMainViewController.h"
#import "GPGNCastCell.h"
#import "GPSettingViewController.h"
#import "GPContentsViewController.h"

@interface GPSubMainViewController ()

@end

@implementation GPSubMainViewController

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
    
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moveSettingView)
                                                 name:_CMD_MOVE_SETTING_VIEW
                                               object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:_CMD_MOVE_SETTING_VIEW object:nil];
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

- (void)moveSettingView
{
    GPSettingViewController *settingViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingView"];
    [self.navigationController pushViewController:settingViewController animated:YES];
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

- (IBAction)pressBtn:(UIButton*)sender
{
    if (sender.tag == 0) {
        _img_back_btn.highlighted = !_img_back_btn.highlighted;
    }else{
        _img_menu_btn.highlighted = !_img_menu_btn.highlighted;
    }
    
}

- (IBAction)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
    _img_back_btn.highlighted = !_img_back_btn.highlighted;
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
    _img_menu_btn.highlighted = !_img_menu_btn.highlighted;
}

#pragma mark -
#pragma mark UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.arr_mainList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"GNCastCell";
    
    GPGNCastCell *cell = (GPGNCastCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[GPGNCastCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    [cell setGNCastListData:[self.arr_mainList objectAtIndex:indexPath.row]];
    return cell;
}

#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *dic_selected_data = [self.arr_mainList objectAtIndex:indexPath.row];
    
    if ([dic_selected_data objectForKey:@"pcSub"] == nil) {
        GPContentsViewController *contentsCont = [self.storyboard instantiateViewControllerWithIdentifier:@"ContentsView"];
        contentsCont.dic_contents_data = [NSMutableDictionary dictionaryWithDictionary:dic_selected_data];
        [self.navigationController pushViewController:contentsCont animated:YES];
    }
}

- (BOOL)shouldAutorotate
{
    return NO;
}
@end
