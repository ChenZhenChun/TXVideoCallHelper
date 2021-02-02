//
//  TXVideoChatContentView+videoChatDelegate.m
//  ZJJKMGDoctor
//
//  Created by czc on 2021/1/11.
//  Copyright © 2021 zjjk. All rights reserved.
//

#import "TXVideoChatContentView+videoChatDelegate.h"
#import "TXVideoChatContentView+TXMeetingVideo.h"
#import "TXVideoChatContentView+Pinch.h"
#import "TXVideoChatContentView+TXLIVE.h"
#import <TXLiteAVSDK_Professional/TRTCCloudDelegate.h>
#import "NSObject+GLHUD.h"
#import "TXVideoSmallView.h"

@interface TXVideoChatContentView ()<TRTCCloudDelegate>

@end

@implementation TXVideoChatContentView (videoChatDelegate)
/// @name 房间事件回调
/// @{
/**
 * 2.1 已加入房间的回调
 *
 * 调用 TRTCCloud 中的 enterRoom() 接口执行进房操作后，会收到来自 SDK 的 onEnterRoom(result) 回调：
 *
 * - 如果加入成功，result 会是一个正数（result > 0），代表加入房间的时间消耗，单位是毫秒（ms）。
 * - 如果加入失败，result 会是一个负数（result < 0），代表进房失败的错误码。
 * 进房失败的错误码含义请参见[错误码](https://cloud.tencent.com/document/product/647/32257)。
 *
 * @note 在 Ver6.6 之前的版本，只有进房成功会抛出 onEnterRoom(result) 回调，进房失败由 onError() 回调抛出。
 *       在 Ver6.6 及之后改为：进房成功返回正的 result，进房失败返回负的 result，同时进房失败也会有 onError() 回调抛出。
 *
 * @param result result > 0 时为进房耗时（ms），result < 0 时为进房错误码。
 */
- (void)onEnterRoom:(NSInteger)result {
    if (result) {
        if (self.scene == ZJTRTCAppSceneVideoCall) {
            [[TRTCCloud sharedInstance] startLocalPreview:YES view:self.smallVideoView];
            [[TRTCCloud sharedInstance] startLocalAudio:TRTCAudioQualityDefault];
        }else if (self.scene == ZJTRTCAppSceneVideoMeeting) {
            [self onUserVideoAvailableMeetingVideo:self.userId available:YES];
        }else if (self.scene == ZJTRTCAppSceneLIVE) {
            [self onUserVideoAvailableLiveVideo:self.userId available:YES];
        }else {
            [[TRTCCloud sharedInstance] startLocalAudio:TRTCAudioQualityDefault];
        }
    }
}

/// @name 错误事件和警告事件
/// @{
/**
 * 1.1 错误回调：SDK 不可恢复的错误，一定要监听，并分情况给用户适当的界面提示。
 *
 * @param errCode 错误码
 * @param errMsg  错误信息
 * @param extInfo 扩展信息字段，个别错误码可能会带额外的信息帮助定位问题
 */
- (void)onError:(TXLiteAVError)errCode errMsg:(nullable NSString *)errMsg extInfo:(nullable NSDictionary*)extInfo {
    [self hud_showHintTip:errMsg];
}

/**
 * 1.2 警告回调：用于告知您一些非严重性问题，例如出现了卡顿或者可恢复的解码失败。
 *
 * @param warningCode 警告码
 * @param warningMsg 警告信息
 * @param extInfo 扩展信息字段，个别警告码可能会带额外的信息帮助定位问题
 */
- (void)onWarning:(TXLiteAVWarning)warningCode warningMsg:(nullable NSString *)warningMsg extInfo:(nullable NSDictionary*)extInfo {
    NSLog(@"TXVideoChatContentView warnings:%@",warningMsg);
}

/**
 * 3.1 有用户加入当前房间
 *
 * 出于性能方面的考虑，在两种不同的应用场景下，该通知的行为会有差别：
 * - 通话场景（TRTCAppSceneVideoCall 和 TRTCAppSceneAudioCall）：该场景下用户没有角色的区别，任何用户进入房间都会触发该通知。
 * - 直播场景（TRTCAppSceneLIVE 和 TRTCAppSceneVoiceChatRoom）：该场景不限制观众的数量，如果任何用户进出都抛出回调会引起很大的性能损耗，所以该场景下只有主播进入房间时才会触发该通知，观众进入房间不会触发该通知。
 *
 *
 * @note 注意 onRemoteUserEnterRoom 和 onRemoteUserLeaveRoom 只适用于维护当前房间里的“成员列表”，如果需要显示远程画面，建议使用监听 onUserVideoAvailable() 事件回调。
 *
 * @param userId 用户标识
 */
- (void)onRemoteUserEnterRoom:(NSString *)userId {
    if (self.scene == ZJTRTCAppSceneVideoMeeting) {
        [self onRemoteUserEnterRoomMeetingVideo:userId];
        if (self.onCallEstablished) {
            self.onCallEstablished(self.roomId);
            self.status = ChatRoomStatus_Hangup;
            self.onCallEstablished = nil;
        }
    }else {
        if (self.onCallEstablished) {
            self.onCallEstablished(self.roomId);
            self.status = ChatRoomStatus_Hangup;
            self.onCallEstablished = nil;
            self.audioTipL.hidden = YES;
            self.hungUpLabel.text = @"挂断";
            [self hud_showHintTip:@"已接通"];
        }
    }
    
}

/**
 * 3.2 有用户离开当前房间
 *
 * 与 onRemoteUserEnterRoom 相对应，在两种不同的应用场景下，该通知的行为会有差别：
 * - 通话场景（TRTCAppSceneVideoCall 和 TRTCAppSceneAudioCall）：该场景下用户没有角色的区别，任何用户的离开都会触发该通知。
 * - 直播场景（TRTCAppSceneLIVE 和 TRTCAppSceneVoiceChatRoom）：只有主播离开房间时才会触发该通知，观众离开房间不会触发该通知。
 *
 * @param userId 用户标识
 * @param reason 离开原因，0表示用户主动退出房间，1表示用户超时退出，2表示被踢出房间。
 */
- (void)onRemoteUserLeaveRoom:(NSString *)userId reason:(NSInteger)reason {
    NSString *msg;
    if (self.scene == ZJTRTCAppSceneVideoMeeting) {
        [self onRemoteUserLeaveMeetingRoom:userId reason:reason];
    }else if (self.scene == ZJTRTCAppSceneLIVE) {
        [self onRemoteUserLeaveLiveRoom:userId reason:reason];
    }else {
        switch (reason) {
            case 0:
                msg = @"通话结束";
                break;
            case 1:
                msg = @"用户超时退出聊天";
                break;
            case 2:
                msg = @"用户被踢出房间";
                break;
            default:
                msg = @"用户已退出聊天";
                break;
        }
        [self hidden];
        [self hud_showHintTip:msg];
    }
}


/**
 * 3.3 远端用户是否存在可播放的主路画面（一般用于摄像头）
 *
 * 当您收到 onUserVideoAvailable(userid, YES) 通知时，表示该路画面已经有可用的视频数据帧到达。
 * 此时，您需要调用 startRemoteView(userid) 接口加载该用户的远程画面。
 * 然后，您会收到名为 onFirstVideoFrame(userid) 的首帧画面渲染回调。
 *
 * 当您收到 onUserVideoAvailable(userid, NO) 通知时，表示该路远程画面已被关闭，
 * 可能由于该用户调用了 muteLocalVideo() 或 stopLocalPreview()。
 *
 * @param userId 用户标识
 * @param available 画面是否开启
 */
- (void)onUserVideoAvailable:(NSString *)userId available:(BOOL)availabl {
    if (self.scene == ZJTRTCAppSceneVideoCall) {
        if (availabl) {
            [[TRTCCloud sharedInstance] startRemoteView:userId streamType:TRTCVideoStreamTypeBig view:self.bigVideoView];
        }else {
            [[TRTCCloud sharedInstance] stopRemoteView:userId streamType:TRTCVideoStreamTypeBig];
        }
    }else if (self.scene == ZJTRTCAppSceneVideoMeeting) {
        if (availabl) {
            [self onUserVideoAvailableMeetingVideo:userId available:availabl];
        }else {
            [[TRTCCloud sharedInstance] stopRemoteView:userId streamType:TRTCVideoStreamTypeSmall];
        }
    }else if (self.scene == ZJTRTCAppSceneLIVE) {
        if (availabl) {
            [self onUserVideoAvailableLiveVideo:userId available:availabl];
        }else {
            [[TRTCCloud sharedInstance] stopRemoteView:userId streamType:TRTCVideoStreamTypeBig];
        }
    }
}

/**
 * 3.5 远端用户是否存在可播放的音频数据
 *
 * @param userId 用户标识
 * @param available 声音是否开启
 */
- (void)onUserAudioAvailable:(NSString *)userId available:(BOOL)available {
    [[TRTCCloud sharedInstance] muteRemoteAudio:userId mute:!available];
}

/**
 * 3.6 开始渲染本地或远程用户的首帧画面
 *
 * 如果 userId == nil，代表开始渲染本地采集的摄像头画面，需要您先调用 startLocalPreview 触发。
 * 如果 userId != nil，代表开始渲染远程用户的首帧画面，需要您先调用 startRemoteView 触发。
 *
 * @note 只有当您调用 startLocalPreivew()、startRemoteView() 或 startRemoteSubStreamView() 之后，才会触发该回调。
 *
 * @param userId 本地或远程用户 ID，如果 userId == nil 代表本地，userId != nil 代表远程。
 * @param streamType 视频流类型：摄像头或屏幕分享。
 * @param width  画面宽度
 * @param height 画面高度
 */
- (void)onFirstVideoFrame:(NSString*)userId streamType:(TRTCVideoStreamType)streamType width:(int)width height:(int)height {
    //设置loading
    if (userId) {
        //远程用户画面首帧画面渲染
        
    }else {
        //自己画面首帧渲染
        if (self.inquiryRecId && self.inquiryRecId.length>0) {
            [self mixTranscodingConfig];
        }
    }
}

/**
 * 3.7 开始播放远程用户的首帧音频（本地声音暂不通知）
 *
 * @param userId 远程用户 ID
 */
- (void)onFirstAudioFrame:(NSString*)userId {
    //设置loading
    if (userId) {
        if (self.scene == ZJTRTCAppSceneAudioCall) {
            if (self.inquiryRecId && self.inquiryRecId.length>0) {
                [self mixTranscodingConfig];
            }
        }
    }
}

//云端混流录制参数配置（调用一次即可，云端会自动处理）
- (void)mixTranscodingConfig {
    TRTCTranscodingConfig *config = [[TRTCTranscodingConfig alloc] init];
    if (self.scene == ZJTRTCAppSceneAudioCall||self.scene==ZJTRTCAppSceneVoiceChatRoom) {
        config.mode = TRTCTranscodingConfigMode_Template_PureAudio;
        config.audioSampleRate = 48000;
        config.audioBitrate    = 64;
        config.audioChannels   = 2;
    }else {
        // 采用预排版模式
        config.mode = TRTCTranscodingConfigMode_Template_PresetLayout;
        // 设置分辨率为720 × 1280, 码率为1500kbps，帧率为20FPS
        config.videoWidth      = 720;
        config.videoHeight     = 1280;
        config.videoBitrate    = 1500;
        config.videoFramerate  = 20;
        config.videoGOP        = 2;
        config.audioSampleRate = 48000;
        config.audioBitrate    = 64;
        config.audioChannels   = 2;
    }

    NSMutableArray *mixUsers = [[NSMutableArray alloc] init];
    if (self.scene == ZJTRTCAppSceneVideoCall) {
        // 主播摄像头的画面位置
        TRTCMixUser* local = [TRTCMixUser new];
        local.userId = @"$PLACE_HOLDER_LOCAL_MAIN$";
        local.zOrder = 0;   // zOrder 为0代表主播画面位于最底层
        local.rect   = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        local.roomID = nil; // 本地用户不用填写 roomID，远程需要
        local.pureAudio = NO;
        [mixUsers addObject:local];
        
        // 连麦者的画面位置
        TRTCMixUser* remote1 = [TRTCMixUser new];
        remote1.userId = @"$PLACE_HOLDER_REMOTE$";
        remote1.zOrder = 1;
        remote1.rect   = CGRectMake([UIScreen mainScreen].bounds.size.width-139,0, 139, 182); //仅供参考
        remote1.roomID = [NSString stringWithFormat:@"%d",self.roomId]; // 本地用户不用填写 roomID，远程需要
        remote1.pureAudio = NO;
        [mixUsers addObject:remote1];
    }else if (self.scene == ZJTRTCAppSceneLIVE) {
        // 主播摄像头的画面位置
        if (self.role != ZJTRTCRoleAnchor) {
            return;
        }else {
            TRTCMixUser* local = [TRTCMixUser new];
            local.userId = @"$PLACE_HOLDER_LOCAL_MAIN$";
            local.zOrder = 0;   // zOrder 为0代表主播画面位于最底层
            local.rect   = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
            local.roomID = nil; // 本地用户不用填写 roomID，远程需要
            local.pureAudio = NO;
            [mixUsers addObject:local];
        }
    }else if (self.scene == ZJTRTCAppSceneVideoMeeting) {
        for (TXVideoSmallView *obj in self.meetingVideoViewArray) {
            TRTCMixUser* remote = [TRTCMixUser new];
            remote.userId = @"$PLACE_HOLDER_REMOTE$";
            remote.zOrder = 0;
            remote.rect   =  CGRectMake(obj.frame.origin.x,
                                        obj.frame.origin.y+ScrollContentViewTop,
                                        obj.frame.size.width,
                                        obj.frame.size.height);
            remote.roomID = [NSString stringWithFormat:@"%d",self.roomId]; // 本地用户不用填写 roomID，远程需要
            remote.pureAudio = NO;
            
            if ([obj.userId isEqualToString:self.userId]) {
                remote.userId = @"$PLACE_HOLDER_LOCAL_MAIN$";
                remote.roomID = nil; // 本地用户不用填写 roomID，远程需要
            }else {
                remote.userId = @"$PLACE_HOLDER_REMOTE$";
            }
            [mixUsers addObject:remote];
        }
    }
    
    config.mixUsers = mixUsers;
    
    // 发起云端混流
    [[TRTCCloud sharedInstance] setMixTranscodingConfig:config];
}

@end
