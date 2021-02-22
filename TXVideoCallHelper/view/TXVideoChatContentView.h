//
//  TXVideoChatContentView.h
//  ZJJKMGDoctor
//
//  Created by czc on 2021/1/11.
//  Copyright © 2021 zjjk. All rights reserved.
//
#import <TXLiteAVSDK_Professional/TRTCCloud.h>
typedef enum : NSUInteger {
    ChatRoomStatus_RefuseHangup = -3,//拒绝接听
    ChatRoomStatus_TimeOut = -2,//超时，无应答
    ChatRoomStatus_Refuse = -1,//对方决绝接听
    ChatRoomStatus_Cancel = 0,//自己取消
    ChatRoomStatus_Hangup = 1,//接通后挂断（正常通话结束或者异常挂断）
} ChatRoomStatus;

typedef enum : NSUInteger {
    /// 视频通话场景
    /// 适合：[1对1视频通话]
    ZJTRTCAppSceneVideoCall      = 0,
    
    /// 视频直播
    /// 适合：[视频低延时直播]
    ZJTRTCAppSceneLIVE           = 1,
    
    /// 语音通话场景
    /// 适合：[1对1语音通话]
    ZJTRTCAppSceneAudioCall      = 2,
    
    /// 适合：[语音低延时直播]、[语音直播连麦]、[语聊房]、[K 歌房]、[FM 电台]等。<br>
    ZJTRTCAppSceneVoiceChatRoom  = 3,
    
    /// 适合：会议室视频通话
    ZJTRTCAppSceneVideoMeeting  = 4,
    
    /// 适合：会议室语音通话
    ZJTRTCAppSceneVoiceMeeting  = 5,
} ZJTRTCAppScene;

//typedef NS_ENUM(NSInteger, ZJTRTCRoleType) {
//    ZJTRTCRoleAnchor            =  20,   ///< 主播
//    ZJTRTCRoleAudience          =  21,   ///< 观众
//};

@interface TXVideoChatContentView : UIView
@property (weak, nonatomic) IBOutlet UIButton *smallTransferBtn;//缩放按钮
@property (nonatomic,readonly) ZJTRTCAppScene scene;//通话场景 语音or视频
@property (nonatomic,assign) int32_t roomId;
@property (nonatomic,readonly) NSString *userId;
@property (nonatomic,copy) NSString *inquiryRecId;//没有不云端录制
@property (nonatomic,assign) BOOL isInvited;//是否是受邀（被叫），默认是主叫

@property (nonatomic,strong) IBOutlet UIButton *hungUpBtn;   //挂断按钮
@property (weak, nonatomic) IBOutlet UILabel *hungUpLabel;

//视频
@property (weak, nonatomic) IBOutlet UIImageView *bigVideoView;
@property (weak, nonatomic) IBOutlet UIImageView *smallVideoView;
@property (nonatomic,strong) IBOutlet UIButton *switchCameraBtn; //切换前后摄像头
@property (weak, nonatomic) IBOutlet UILabel *switchCameraLabel;

//语音
@property (weak, nonatomic) IBOutlet UILabel *audioTipL;//语音等待接听提示
@property (weak, nonatomic) IBOutlet UIView *audioSmallView;//缩小后的显示view
@property (weak, nonatomic) IBOutlet UIImageView *photoImgV;
@property (weak, nonatomic) IBOutlet UILabel *userNameL;
@property (weak, nonatomic) IBOutlet UIButton *muteBtn;//静音
@property (weak, nonatomic) IBOutlet UILabel *muteL;
@property (weak, nonatomic) IBOutlet UIButton *audioModeBtn;//免提
@property (weak, nonatomic) IBOutlet UILabel *audioModeL;
@property (nonatomic,copy) NSString *photoUrl;
@property (nonatomic,copy) NSString *userName;

//直播
@property (nonatomic, assign) TRTCRoleType role;//角色

@property (nonatomic,assign) ChatRoomStatus status;//是否建立过连接  -3：拒绝接听 -2：对方无应答 -1:对方拒绝接听 0：自己取消 1：接通挂断
@property (nonatomic,copy) void(^onCallEstablished)(UInt64 roomId);//建立连接
@property (nonatomic,copy) void(^onCallDisconnected)(NSError *error);//断开连接回调
@property (nonatomic,copy) void(^initTXVideoSDKBlock)(NSMutableDictionary *dict);//初始化腾讯视频SDK

//受邀人接受邀请
@property (nonatomic,copy) void(^agreeCallSDKBlock)(void);
//受邀人拒绝邀请
@property (nonatomic,copy) void(^refuseCallSDKBlock)(void);


/// 根据scene标识加载布局页面
/// @param scene TRTCAppSceneVideoCall:视频通话  TRTCAppSceneAudioCall：语音通话
- (instancetype)initWithTRTCAppScene:(ZJTRTCAppScene)scene;
- (void)show;
- (void)hidden;

/// 获取受邀界面
- (UIView *)getInvitedView;
@end
