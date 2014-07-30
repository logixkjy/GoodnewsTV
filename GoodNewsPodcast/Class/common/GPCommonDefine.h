//
//  GPCommonDefine.h
//  GoodNewsPodcast
//
//  Created by 김주영 on 2014. 7. 16..
//  Copyright (c) 2014년 GoodNews. All rights reserved.
//

#define IS_iOS_7 [[[UIDevice currentDevice] systemVersion] floatValue] >= 7

#define MAIN_APP_DELEGATE()	(AppDelegate *)[UIApplication sharedApplication].delegate

#define MAIN_SIZE() [UIScreen mainScreen].bounds.size

#define IS_4_INCH CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(320, 568)) || CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(568, 320))

#define kAFNetworkingIncompleteDownloadFolderName @"Incomplete"

//색상관련.
#define RGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]
#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define IS_iOS_7 [[[UIDevice currentDevice] systemVersion] floatValue] >= 7

enum NETWORK_STATUS {
    NETWORK_NONE = 0,
    NETWORK_WIFI,
    NETWORK_3G_LTE,
};
typedef NSInteger NETWORK_STATUS;

enum DOWN_FILE_TYPE {
    FILE_TYPE_VIDEO_NORMAL = 0,
    FILE_TYPE_VIDEO_LOW,
    FILE_TYPE_AUDIO,
};
typedef NSInteger DOWN_FILE_TYPE;

enum DOWNLOAD_STATUS {
    DOWNLOAD_STATUS_READY = 0,
    DOWNLOAD_STATUS_CANCEL,
    DOWNLOAD_STATUS_PAUSE,
};
typedef NSInteger DOWNLOAD_STATUS;

enum MENU_ID {
    MENU_ID_GOODNEWS_CAST = 0,
    MENU_ID_MY_CAST,
    MENU_ID_DOWN_BOX,
    MENU_ID_LIVE_TV,
};
typedef NSInteger MENU_ID;

#define netStatus_3G @"Wi-Fi로 연결되지 않아, 3G/LTE로 연결을 시도합니다. 요금부과 등의 문제로 3G/LTE로 사용을 원치 않으시면 설정에서 3G/LTE 접속 절정을 OFF로 설정바랍니다.          단, Wi-Fi/3G/LTE 네트워크 이동 환경에서는 어플 내 3G/LTE 설정이 OFF 상태여도 데이터 요금이 부과될 수 있으니 유의바랍니다. 요금 부과 방지를 위해서는 단말자체 3G/LTE 설정을 OFF 바랍니다."
#define netStatus_none @"네트워크에 얀결되어 있지 않습니다.\n다운로드 보관함에 저장된 목록만 사용할 수 있습니다."
#define netError @"네트워크 연결이 끊겨있습니다.\n네트워크 상태 체크 후에 다시 이용 부탁 드립니다"
#define netStatus_3G_view @"3G/LTE로 계속 시청을 원하시면 설정 화면에서 ON으로 설정하시기 바랍니다. Wi-Fi로 연결되지 않았습니다.\n(해외 로밍의 경우 국내 가입 요금제가 적용되지않아 과도한 요금이 청구될 수 있습니다)\n※ 3G/LTE 네트워크 이동 환경에서는 어플 내 3G/LTE 설정이 OFF 상태여도 데이터 요금이 부과될 수 있으니 유의바랍니다. 요금 부과 방지를 위해서는 단말자체 3G/LTE 설정을 OFF 바랍니다."
#define netStatus_3G_down @"3G/LTE로 계속 다운로드를 원하시면 설정 화면에서 ON으로 설정하시기 바랍니다. Wi-Fi로 연결되지 않았습니다.\n(해외 로밍의 경우 국내 가입 요금제가 적용되지않아 과도한 요금이 청구될 수 있습니다)\n※ 3G/LTE 네트워크 이동 환경에서는 어플 내 3G/LTE 설정이 OFF 상태여도 데이터 요금이 부과될 수 있으니 유의바랍니다. 요금 부과 방지를 위해서는 단말자체 3G/LTE 설정을 OFF 바랍니다."
#define existingDownlad @"기존에 저장된 다운로드 목록이 있습니다. 기존 저장된 목록 다운로드 후 지금 선택 하신 파일의 다운로드가 진행됩니다.\n기존에 저장된 목록을 다운로드하기 원치 않으시면 다운로드>다운로드 진행상태에서 취소하여 주시기 바랍니다."


#define _CMD_MOVE_SETTING_VIEW  @"move_setting_view"
#define _CMD_FILE_DOWN_ERROR    @"file_down_error"
#define _CMD_FILE_DOWN_FINISHED @"file_down_finished"
#define _CMD_FILE_DOWNLOADING   @"file_downloading"
#define _CMD_FILE_DOWN_START    @"file_down_start"
#define _CMD_FILE_DOWN_ADD      @"file_down_add"
#define _CMD_FILE_DOWN_CANCEL   @"file_down_cancel"
#define _CMD_FILE_STREAMING     @"file_streaming"

#define DEFAULT_URL @"http://goodnewstv.kr/assets/podcast"

#define NTC	[NSNotificationCenter defaultCenter]
#define	NUD	[NSUserDefaults standardUserDefaults]

// nine patch

typedef struct _TURGBAPixel {
	UInt8 red;
	UInt8 green;
	UInt8 blue;
	UInt8 alpha;
} TURGBAPixel;

/**
 Defined here, used as part of the pixel-tasting code. Helps make sure the memory representation of the bitmap context is made up of stuff that looks just like TURGBAPixel.
 */
#define TURGBABytesPerPixel (4)

/**
 This tests if a pixel is black. Here "black" means alpha isn't at zero (AKA: it's at least partially opaque) and r == g == b == 0.
 */
#define TURGBAPixelIsBlack(PIXEL) (((PIXEL.red == 0) && (PIXEL.green == 0) && (PIXEL.blue == 0) && (PIXEL.alpha != 0))?(YES):(NO))

#define TUNotFoundRange (NSMakeRange(NSNotFound,0))
#define TUIsNotFoundRange(RANGE) (NSEqualRanges(RANGE, TUNotFoundRange))

#define TUTruncateBelow(VALUE, FLOOR) ((( VALUE ) < ( FLOOR ))?(( FLOOR )):(( VALUE )))
#define TUTruncateAbove(VALUE, CEILING) ((( VALUE ) > ( CEILING ))?(( CEILING )):(( VALUE )))
#define TUTruncateWithin(VALUE, FLOOR, CEILING) ((( VALUE ) < ( FLOOR ))?(( FLOOR )):((( VALUE ) > ( CEILING ))?(( CEILING )):(( VALUE ))))
#define TUTruncateAtZero(VALUE) TUTruncateBelow(VALUE, 0.0f)

#define TUForceYesOrNo(ABOOL) ((ABOOL)?(YES):(NO))
#define TUYesOrNoString(ABOOL) ((( ABOOL ))?(@"YES"):(@"NO"))

#define TUWithinEpsilon(EPSILON, X, Y) TUForceYesOrNo((((X-Y) > (-1.0f * EPSILON)) || ((X-Y) < EPSILON)))

//#define DEBUG
//#define NP_ASSERTION_CHECKING
//#define IMAGEDEBUG

// DLog is almost a drop-in replacement for NSLog
// DLog();
// DLog(@"here");
// DLog(@"value: %d", x);
// Unfortunately this doesn't work DLog(aStringVariable); you have to do this instead DLog(@"%@", aStringVariable);
#ifdef DEBUG
#define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define DLog(...)
#endif

// ALog always displays output regardless of the DEBUG setting
#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

#define LLog(STR) DLog(@"%@",STR)

#define NPLogException(E) DLog(@"Caught '%@' < '%@', '%@' >.",[E name],[E reason],[E userInfo])
#define NPLogError(E) DLog(@"Error: '%@', '%@', '%@'.",[E localizedDescription],[E localizedFailureReason],[E localizedRecoveryOptions]);

#ifdef NP_ASSERTION_CHECKING
#define NPLogExceptionRethrowIfAssertionFailure(E) { \
NPLogException(E); \
if (E && [[E name] isEqualToString:NSInternalInconsistencyException]) { \
@throw E; \
}}
#else
#define NPLogExceptionRethrowIfAssertionFailure(E) NPLogException(E)
#endif

#ifdef NP_OUTPUT_LOGGING
#define NPFOutputLog(AFLOAT) DLog(@"returning %s: '%f'.",#AFLOAT,AFLOAT)
#define NPDOutputLog(ANINT) DLog(@"returning %s: '%d'.",#ANINT,ANINT)
#define NPOOutputLog(ANOBJ) DLog(@"returning %s: '%@'.",#ANOBJ,ANOBJ)
#define NPBOutputLog(ABOOL) DLog(@"returning %s: '%@'.",#ABOOL,TUYesOrNoString(ABOOL))
#define NPCGROutputLog(ARECT) DLog(@"returning %s: '%@'.",#ARECT,NSStringFromCGRect(ARECT))
#define NPCGSOutputLog(ASIZE) DLog(@"returning %s: '%@'.",#ASIZE,NSStringFromCGSize(ASIZE))
#define NPCGPOutputLog(APOINT) DLog(@"returning %s: '%@'.",#APOINT,NSStringFromCGPoint(APOINT))
#define NPNSROutputLog(ARANGE) DLog(@"returning %s: '%@'.",#ARANGE,NSStringFromRange(ARANGE))
#else
#define NPFOutputLog(...)
#define NPDOutputLog(...)
#define NPOOutputLog(...)
#define NPBOutputLog(...)
#define NPCGROutputLog(...)
#define NPCGSOutputLog(...)
#define NPCGPOutputLog(...)
#define NPNSROutputLog(...)
#endif

#ifdef NP_INPUT_LOGGING
#define NPAInputLog(...) DLog(##__VA_ARGS__)
// convenience input loggers for single-argument messages
#define NPAFInputLog(AFLOAT) DLog(@"%s: '%f'",#AFLOAT,AFLOAT)
#define NPADInputLog(ANINT) DLog(@"%s: '%d'",#ANINT,ANINT)
#define NPAOInputLog(ANOBJ) DLog(@"%s: '%@'",#ANOBJ,ANOBJ)
#define NPABInputLog(ABOOL) DLog(@"%s: '%@'",#ABOOL,TUYesOrNoString(ABOOL))
#else
#define NPAInputLog(...)
#define NPAFInputLog(AFLOAT)
#define NPADInputLog(ANINT)
#define NPAOInputLog(ANOBJ)
#define NPABInputLog(ABOOL)
#endif


#ifdef NP_ASSERTION_CHECKING
#define NPParameterAssert(COND) NSParameterAssert(COND)
#define NPCParameterAssert(COND) NSCParameterAssert(COND)
#define NPAssert(COND,DESC) NSAssert(COND,DESC)
#define NPCAssert(COND,DESC) NSCAssert(COND,DESC)
#else
#define NPParameterAssert(...)
#define NPCParameterAssert(...)
#define NPAssert(...)
#define NPCAssert(...)
#endif

#define STRINGIFY2( x) #x
#define STRINGIFY(x) STRINGIFY2(x)
#define PASTE2( a, b) a##b
#define PASTE( a, b) PASTE2( a, b)
#define PASSTHROUGH(X) X

#define NPOBJCStringOfToken(TOKEN) PASSTHROUGH(PASTE( PASSTHROUGH(@), PASSTHROUGH(STRINGIFY(TOKEN))))

#define NPSelfProperty(PROP) (self.PROP)
//#define NPSelfProperty(PROP) ([self PROP])

#define NPAssertPropertyNonNil(PROP) NPAssert((NPSelfProperty(PROP) != nil), ([NSString stringWithFormat:@"self.%s should never be nil.",( (#PROP) )]))

#define NPParameterAssertNotNilConformsToProtocol(OBJ,PROT) NPParameterAssert((OBJ != nil) && ([OBJ conformsToProtocol:@protocol(PROT)]))
#define NPParameterAssertNotNilIsKindOfClass(OBJ,CLASS) NPParameterAssert((OBJ != nil) && ([OBJ isKindOfClass:[CLASS class]]))

#define NPAssertNilOrConformsToProtocol(OBJ,PROT) NPAssert(((OBJ == nil) || ((OBJ != nil) && [OBJ conformsToProtocol:@protocol(PROT)])),([NSString stringWithFormat:@"Variable %s must either be nil or conform to %s protocol.", ( (#OBJ) ), ( (#PROT) )]))
#define NPAssertNilOrIsKindOfClass(OBJ,CLASS) NPAssert(((OBJ == nil) || ((OBJ != nil) && [OBJ isKindOfClass:[CLASS class]])), ([NSString stringWithFormat:@"Variable %s must either be nil or be kind of %s class.", (#OBJ), (#CLASS)]))

#define NPAssertWithinEpsilon(EPSILON,X,Y) NPAssert( (((X-Y) > (-1.0f * EPSILON)) || ((X-Y) < EPSILON)),([NSString stringWithFormat:@"Should have (%s,%s) within %f but instead (%f,%f).",#X,#Y,EPSILON,X,Y]))
#define NPAssertWithinOne(X,Y) NPAssertWithinEpsilon(1.0f,X,Y)

#define NPAssertThreeSubSizesSumCorrectlyOnOneAxis(AXIS,MASTERSIZE,SIZE_ONE,SIZE_TWO,SIZE_THREE) NPAssertWithinOne(MASTERSIZE.AXIS,( SIZE_ONE.AXIS + SIZE_TWO.AXIS + SIZE_THREE.AXIS ))
#define NPAssertCorrectSubsizeWidthDecomposition(MASTER,SIZE_ONE,SIZE_TWO,SIZE_THREE) NPAssertThreeSubSizesSumCorrectlyOnOneAxis(width, MASTER, SIZE_ONE, SIZE_TWO, SIZE_THREE)
#define NPAssertCorrectSubsizeHeightDecomposition(MASTER,SIZE_ONE,SIZE_TWO,SIZE_THREE) NPAssertThreeSubSizesSumCorrectlyOnOneAxis(height, MASTER, SIZE_ONE, SIZE_TWO, SIZE_THREE)

#define NPAssertCorrectSubimageWidthDecomposition(MASTER,IMAGE_ONE,IMAGE_TWO,IMAGE_THREE) NPAssertCorrectSubsizeWidthDecomposition([MASTER size],[IMAGE_ONE size],[IMAGE_TWO size],[IMAGE_THREE size])
#define NPAssertCorrectSubimageHeightDecomposition(MASTER,IMAGE_ONE,IMAGE_TWO,IMAGE_THREE) NPAssertCorrectSubsizeWidthDecomposition([MASTER size],[IMAGE_ONE size],[IMAGE_TWO size],[IMAGE_THREE size])

#ifdef IMAGEDEBUG
#define IMLog(IMAGE, IMAGENAME) TUImageLog(IMAGE,[[NSString stringWithFormat:@"debugImage.%.0f.%u.",[NSDate timeIntervalSinceReferenceDate],((NSUInteger) rand())] stringByAppendingString:( IMAGENAME )])
#else
#define IMLog(IMAGE, IMAGENAME)
#endif
