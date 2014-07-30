//
//  NSNumber+ByteUnit.m
//  GoodNewsPodcast
//
//  Created by 김주영 on 2014. 7. 19..
//  Copyright (c) 2014년 GoodNews. All rights reserved.
//

#import "NSNumber+ByteUnit.h"

@implementation NSNumber (ByteUnit)
- (float)measuredByteValue {
    double          value = [self longLongValue];
    
    value /= pow(1024.0, [self measuredByteUnit]);
    return value;
}
- (NSUInteger)measuredByteUnit {
    double          value = [self longLongValue];
    NSUInteger      unit = NSNumberByteUnitNone;
    
    while( value >= 1000.0 ){
        value /= 1024.0;
        unit++;
    }
    return unit;
}
- (NSString *)measuredByteSymbol {
    switch( [self measuredByteUnit] ){
        case NSNumberByteUnitNone:
            return @"byte";
        case NSNumberByteUnitKilo:
            return @"KB";
        case NSNumberByteUnitMega:
            return @"MB";
        case NSNumberByteUnitGiga:
            return @"GB";
        case NSNumberByteUnitTera:
            return @"TB";
        case NSNumberByteUnitPeta:
            return @"PB";
    }
    return nil;
}
- (NSString *)measuredByteStringWithSymbol:(BOOL)b {
    NSMutableString     * string;
    float               value = [self measuredByteValue];
    NSUInteger          unit = [self measuredByteUnit];
    
    string = [NSMutableString stringWithCapacity:64];
    if( value<10 && unit!=NSNumberByteUnitNone ){
        [string appendFormat:@"%.1f", [self measuredByteValue]];
    }else{
        [string appendFormat:@"%.0f", [self measuredByteValue]];
    }
    if( b==YES ){
        [string appendFormat:@"%@", [self measuredByteSymbol]];
    }
    return string;
}
@end