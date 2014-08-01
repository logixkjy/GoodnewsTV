//
//  GPSettingViewController.h
//  GoodNewsPodcast
//
//  Created by 김주영 on 2014. 7. 14..
//  Copyright (c) 2014년 GoodNews. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iVersion.h"

@interface GPSettingViewController : UIViewController <UIActionSheetDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIAlertViewDelegate, iVersionDelegate> {
    IBOutlet UIImageView    *_img_btn;
    
    IBOutlet UISwitch       *_sw_use3G;
    
    NSArray                 *_arr_viewList;
    
    IBOutlet UILabel        *_lbl_startPage;
    IBOutlet UILabel        *_lbl_AppStoreVer;
    IBOutlet UILabel        *_lbl_BundleVer;
}

@end
