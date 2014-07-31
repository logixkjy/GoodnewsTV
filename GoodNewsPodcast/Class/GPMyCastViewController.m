//
//  GPMyCastViewController.m
//  GoodNewsPodcast
//
//  Created by 김주영 on 2014. 7. 14..
//  Copyright (c) 2014년 GoodNews. All rights reserved.
//

#import "GPMyCastViewController.h"
#import "GPSettingViewController.h"
#import "GPAddMyCastViewController.h"
#import "GPMyCastContentsViewController.h"
#import "GPSQLiteController.h"

@interface GPMyCastViewController ()

@end

@implementation GPMyCastViewController

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
    
    panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
    [self.view addGestureRecognizer:panGesture];
    
    if (!GetGPDataCenter.isFirstView) {
        GetGPDataCenter.isFirstView = !GetGPDataCenter.isFirstView;
        self.lbl_naviTitle.text = @"GOODNEWS TV";
        
        [NSTimer scheduledTimerWithTimeInterval: 5.0f
                                         target: self
                                       selector: @selector(changeNaviTitle)
                                       userInfo: nil
                                        repeats: NO];
    }
}

- (void)changeNaviTitle{
    self.lbl_naviTitle.text = @"마이캐스트";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moveSettingView)
                                                 name:_CMD_MOVE_SETTING_VIEW
                                               object:nil];
    
    self.arr_myCast = [[NSMutableArray alloc] initWithCapacity:5];
    self.arr_myCast = [GetGPSQLiteController GetRecordsMyCast];
    
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
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
    if (!self.tableView.editing) {
        // Dismiss keyboard (optional)
        //
        [self.view endEditing:YES];
        [self.frostedViewController.view endEditing:YES];
        
        // Present the view controller
        //
        [self.frostedViewController panGestureRecognized:sender];
    }
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

- (IBAction)editTable
{
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    
    if (self.tableView.editing) {
        [self.view removeGestureRecognizer:panGesture];
    }else{
//        panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
        [self.view addGestureRecognizer:panGesture];
    }
}

- (IBAction)addMyCast
{
    GPAddMyCastViewController *addMyCastViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MyCastAdd"];
    [self presentViewController:addMyCastViewController animated:YES completion:nil];
}

#pragma mark -
#pragma mark UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.arr_myCast count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSDictionary *dic = [self.arr_myCast objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [dic objectForKey:@"prTitle"];
    
    return cell;
}

#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item1 = [NSDictionary dictionaryWithDictionary:[self.arr_myCast objectAtIndex:indexPath.row]];
    
    GPMyCastContentsViewController *contentsCont = [self.storyboard instantiateViewControllerWithIdentifier:@"MCContentsView"];
    contentsCont.dic_contents_data = [NSMutableDictionary dictionaryWithDictionary:item1];
    [self.navigationController pushViewController:contentsCont animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSDictionary *item1 = [NSDictionary dictionaryWithDictionary:[self.arr_myCast objectAtIndex:indexPath.row]];
        [self.arr_myCast removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationBottom];
        
        [GetGPSQLiteController deleteMyCastWithNo:[[item1 objectForKey:@"_ID"] intValue]];
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
	if (fromIndexPath.row != toIndexPath.row) {
		NSDictionary *item1 = [NSDictionary dictionaryWithDictionary:[self.arr_myCast objectAtIndex:fromIndexPath.row]];
		[self.arr_myCast removeObject:item1];
		[self.arr_myCast insertObject:item1 atIndex:toIndexPath.row];
        
        for (int i = 0 ; i < [self.arr_myCast count]; i++) {
            [GetGPSQLiteController updateMyCastWithNo:[[[self.arr_myCast objectAtIndex:i] objectForKey:@"_ID"] intValue] CastIndex:i];
        }
	}
}



- (BOOL)shouldAutorotate
{
    return NO;
}

@end
