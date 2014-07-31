//
//  GPDataCenter.h
//  GoodNewsPodcast
//
//  Created by 김주영 on 2014. 7. 14..
//  Copyright (c) 2014년 GoodNews. All rights reserved.
//

#import <Foundation/Foundation.h>
#define GetGPDataCenter [GPDataCenter shared]

@interface GPDataCenter : NSObject

@property (nonatomic) NSInteger gpNetowrkStatus;
@property (nonatomic) BOOL      isShow3GPopup;
@property (nonatomic) BOOL      isExistingDownload;
@property (nonatomic) BOOL      isFirstMove;
@property (nonatomic) BOOL      isFirstView;

@property (nonatomic, strong) NSMutableArray *sendQueue;
@property (nonatomic, strong) NSMutableArray *sendQueueForFileType;
@property (nonatomic, strong) NSMutableDictionary *dic_fileInfo;
@property (nonatomic, strong) NSString *str_fileType;
@property (nonatomic, strong) NSString *str_AppStore;

+ (GPDataCenter*)shared;
+ (void)terminate;

@end
