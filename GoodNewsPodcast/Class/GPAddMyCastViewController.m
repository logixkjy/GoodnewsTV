//
//  GPAddMyCastViewController.m
//  GoodNewsPodcast
//
//  Created by KimJooYoung on 2014. 7. 30..
//  Copyright (c) 2014년 GoodNews. All rights reserved.
//

#import "GPAddMyCastViewController.h"
#import "NinePatch.h"
#import "GPSQLiteController.h"
#import "SMXMLDocument.h"

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

- (IBAction)addMyCastItem
{
    [self connectionNetwork];
}

- (void)connectionNetwork {
    NSError                 *error  = nil;
    NSMutableURLRequest *request = [NSMutableURLRequest
                                    requestWithURL:[[NSURL alloc] initWithString:self.tf_xml_address.text]
                                    cachePolicy:NSURLRequestReloadIgnoringCacheData
                                    timeoutInterval:60.0f];
//    NSMutableURLRequest *request = [NSMutableURLRequest
//                                    requestWithURL:[[NSURL alloc] initWithString:@"http://wizard2.sbs.co.kr/w3/podcast/V0000364436.xml"]
//                                    cachePolicy:NSURLRequestReloadIgnoringCacheData
//                                    timeoutInterval:60.0f];

    //    @"http://goodnewstv.kr/xml/6mins.xml"
    //    @"http://goodnewstv.kr/xml/41wcdd.xml"
    //    @"http://wizard2.sbs.co.kr/w3/podcast/V0000328482.xml"
    //    @"http://wizard2.sbs.co.kr/w3/podcast/V0000364436.xml"
    NSData *dataBuffer = [NSURLConnection sendSynchronousRequest:request returningResponse: nil error: &error];
    
    if (error) {
        [GPAlertUtil alertWithMessage:@"주소가 잘못되었습니다.\n다시 확인하여 주시기 바랍니다."];
    }else {
        SMXMLDocument *document = [SMXMLDocument documentWithData:dataBuffer error:&error];
        if (error) {
            [GPAlertUtil alertWithMessage:@"주소가 잘못되었습니다.\n다시 확인하여 주시기 바랍니다."];
            return;
        }
        int cnt = [GetGPSQLiteController getSameMyCastAddress:self.tf_xml_address.text];
        if (cnt > 0) {
            [GPAlertUtil alertWithMessage:@"이미 등록하신 주소입나다."];
            self.tf_xml_address.text = @"http://";
            return;
        }
        // demonstrate -description of document/element classes
        
        // Pull out the <channel> node
        SMXMLElement *channel = [document childNamed:@"channel"];
        
        SMXMLElement *itunes_image = [channel childNamed:@"image"];
        
        NSString *img_url = @"";
        
        if ([[itunes_image attributeNamed:@"href"] length] == 0 ||
            [[itunes_image attributeNamed:@"href"] isEqualToString:@""]) {
            img_url = [itunes_image valueWithPath:@"url"];
        }else{
            img_url = [itunes_image attributeNamed:@"href"];
        }
        
        self.parserObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                             [channel valueWithPath:@"title"],          @"prTitle",
                             [channel valueWithPath:@"description"],    @"prSubTitle",
                             self.tf_xml_address.text,                  @"prXmlAddress",
                             img_url,                                   @"prThumb",
                             nil];
        
        
        [self.parserObject setValue:self.tf_xml_address.text forKey:@"prXmlAddress"];
        if ([GetGPSQLiteController addMyCast:self.parserObject]) {
            [GPAlertUtil alertWithMessage:@"등록되었습니다."];
            self.tf_xml_address.text = @"http://";
        }
    }
}

- (IBAction)closeAddView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

@end
