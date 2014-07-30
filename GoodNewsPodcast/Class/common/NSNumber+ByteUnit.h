//
//  NSNumber+ByteUnit.h
//  GoodNewsPodcast
//
//  Created by 김주영 on 2014. 7. 19..
//  Copyright (c) 2014년 GoodNews. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @enum NSNumberByteUnit
 
 @discussion 디지털 표현식의 단위를 나타냅니다.
 
 @constant NSNumberByteUnitNone Byte
 @constant NSNumberByteUnitKilo KiloByte (KB)
 @constant NSNumberByteUnitMega MegaByte (MB)
 @constant NSNumberByteUnitGiga GigaByte (GB)
 @constant NSNumberByteUnitTera TeraByte (TB)
 @constant NSNumberByteUnitPeta PetaByte (PB)
 */
enum
{
    NSNumberByteUnitNone = 0,
    NSNumberByteUnitKilo,
    NSNumberByteUnitMega,
    NSNumberByteUnitGiga,
    NSNumberByteUnitTera,
    NSNumberByteUnitPeta
};
typedef NSUInteger NSNumberByteUnit;
/***************************************************************************
 
 Interface NSNumber (ByteUnit)
 
 디지털 표현식의 단위 변환을 쉽게할 수 있게 도와줍니다.
 
 - 1024 의 경우 1KB 로 표현할 수 있습니다.
 - 1048576(=1024x1024) 의 경우 1MB 로 표현할 수 있습니다.
 - Peta Byte 까지 표현가능합니다.
 
 @code
 NSNumber    * number;
 
 number = [NSNumber numberWithInt:1024];
 NSLog(@"Digital Value : %@", [number measuredByteStringWithSymbol:YES]);
 @endcode
 
 ***************************************************************************/
@interface NSNumber (ByteUnit)
/**
 @return     디지털 표현식의 숫자
 
 디지털 표현식으로 변환 할 경우 숫자 영역을 알려줍니다.
 */
- (float)measuredByteValue;
/**
 @return     디지털 표현식의 단위
 
 디지털 표현식으로 변환 할 경우 단위 영역을 알려줍니다.
 */
- (NSUInteger)measuredByteUnit;
/**
 @return     디지털 표현식의 단위 표시
 
 디지털 표현식으로 변환 할 경우 단위의 표시를 알려줍니다.
 */
- (NSString *)measuredByteSymbol;
/**
 @param[in]  단위 표시 여부
 
 @return     디지털 표현식
 
 숫자를 디지털 표현식으로 변환해 줍니다.
 self 의 값이 1024 일 경우 1KB 로 표현됩니다.
 self 의 값이 2048 일 경우 2KB 로 표현됩니다.
 */
- (NSString *)measuredByteStringWithSymbol:(BOOL)b;
@end