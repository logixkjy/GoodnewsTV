//
//  GPDataCenter.m
//  GoodNewsPodcast
//
//  Created by 김주영 on 2014. 7. 14..
//  Copyright (c) 2014년 GoodNews. All rights reserved.
//

#import "GPDataCenter.h"

static GPDataCenter* g_GPDataCenterInstance = nil;
@implementation GPDataCenter

+ (GPDataCenter*)shared
{
	if( g_GPDataCenterInstance == nil )
	{
		@synchronized(self)
        {
            if(g_GPDataCenterInstance == nil)
            {
                g_GPDataCenterInstance = [[self alloc] init];
            }
        }
	}
	
	return g_GPDataCenterInstance;
}

+ (void)terminate
{
	if( g_GPDataCenterInstance == nil ) return;
}

- (id) init {
    self = [super init];
    if (self != nil) {
        self.gpNetowrkStatus        = 0;
        
        self.isShow3GPopup          = NO;
        self.isExistingDownload     = NO;
        self.isFirstMove            = NO;
        self.isFirstView            = NO;
        self.isAudioPlaying         = NO;
        
        self.sendQueue              = [[NSMutableArray alloc] initWithCapacity:10];
        self.sendQueueForFileType   = [[NSMutableArray alloc] initWithCapacity:10];
        
        self.dic_fileInfo           = [[NSMutableDictionary alloc] init];
        
        self.str_fileType           = @"";
        self.str_AppStore           = @"";
    }
    return self;
}

@end
