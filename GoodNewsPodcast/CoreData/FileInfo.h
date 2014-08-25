//
//  FileInfo.h
//  GoodNewsPodcast
//
//  Created by 김주영 on 2014. 8. 20..
//  Copyright (c) 2014년 GoodNews. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface FileInfo : NSManagedObject

@property (nonatomic, retain) NSString * ctName;
@property (nonatomic, retain) NSString * ctFileName;
@property (nonatomic, retain) NSNumber * ctFIleType;
@property (nonatomic, retain) NSNumber * ctPlayTime;
@property (nonatomic, retain) NSString * ctPrCode;
@property (nonatomic, retain) NSString * ctFullFilePath;

@end
