#import <UIKit/UIKit.h>
@import WebRTC;
#import "EnxStream.h"
#import "EnxContants.h"

@class EnxStream;

@protocol EnxPlayerDelegate <NSObject>
@optional
-(void)didPlayerStats:(NSDictionary * _Nonnull)data;
-(void)didCapturedView:(UIImage*_Nonnull)snapShot;
@end

@interface EnxPlayerView : UIView <RTCVideoViewDelegate>
///-----------------------------------
/// @name Initializers
///-----------------------------------

- (instancetype)initWithFrame:(CGRect)frame;
// To set UIViewContentMode of playerView
//Note: Works only with devices which supports metal.
-(void)setContentMode:(UIViewContentMode)contentMode;
@property(nonatomic, readonly) __kindof UIView<RTCVideoRenderer> *remoteVideoView;
@property(nonatomic, strong) RTCCameraPreviewView *localVideoView;
@property(readonly) BOOL staTsFlag;
/// EnxPlayerDelegate were this Player will invoke methods as events.
@property (weak, nonatomic) id <EnxPlayerDelegate> _Nullable delegate;
-(void)enablePlayerStats:(BOOL)flag;
-(void)setUpdateStats:(NSDictionary * _Nonnull)data;
-(void)captureScreenShot;
@end
