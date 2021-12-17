//
//  TXVideoChatContentView.m
//  ZJJKMGDoctor
//
//  Created by czc on 2021/1/11.
//  Copyright © 2021 zjjk. All rights reserved.
//

#import "TXVideoChatContentView.h"
#import "TXVideoChatContentView+videoChatDelegate.h"
#import "TXVideoChatContentView+TXMeetingVideo.h"
#import "TXVideoChatContentView+TXLIVE.h"
#import "TXVideoChatContentView+Pinch.h"
#import "UIImageView+WebCache.h"
#import "NSObject+GLHUD.h"
#import "TXInvitedChatContentView.h"
#import "ZOEAlertView.h"

#define GetXMZJUIImage(NAME) [UIImage imageNamed:[NSString stringWithFormat:@"TXVideoCallHelper.bundle/%@",NAME] inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil]

@interface TXVideoChatContentView ()<TRTCCloudDelegate>
@property (nonatomic,assign) CGSize intrinsicContentSize;
@property (nonatomic,copy) NSString *userId;
@property (nonatomic,assign) ZJTRTCAppScene scene;

@property (nonatomic,strong) TXInvitedChatContentView  *invitedChatView;//语音通话被叫受邀页面
@end

@implementation TXVideoChatContentView

- (instancetype)initWithTRTCAppScene:(ZJTRTCAppScene)scene {
    return [TXVideoChatContentView initWithTRTCAppScene:scene];
}

+ (instancetype)initWithTRTCAppScene:(ZJTRTCAppScene)scene {
    //场景布局选择
    NSString *nibName = @"TXVideoChatContentView";
    switch (scene) {
        case ZJTRTCAppSceneVideoCall:
            nibName = @"TXVideoChatContentView";
            break;
        case ZJTRTCAppSceneAudioCall:
            nibName = @"TXAudioChatContentView";
            break;
        case ZJTRTCAppSceneVideoMeeting:
            nibName = @"TXMeetingVideoChatContentView";
        break;
        case ZJTRTCAppSceneLIVE:
            nibName = @"TXLiveChatContentView";
        break;
        default:
            nibName = @"TXVideoChatContentView";
            break;
    }
    TXVideoChatContentView *videoView = [[[NSBundle bundleForClass:[self class]] loadNibNamed:nibName owner:self options:nil] lastObject];
    videoView.scene = scene;
    videoView.layer.zPosition = MAXFLOAT;
    videoView.backgroundColor = [UIColor blackColor];
    videoView.layer.cornerRadius = 0;
    videoView.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.1].CGColor;
    videoView.layer.shadowOffset = CGSizeMake(0,0);
    videoView.layer.shadowOpacity = 1;
    videoView.layer.shadowRadius = 10;
    [videoView registerGestureRecognizer];
    return videoView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.autoresizingMask = UIViewAutoresizingNone;
    self.frame = CGRectMake(0,[UIScreen mainScreen].bounds.size.height,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height);
    self.tag = 786412876;
    _userNameL.text = nil;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self configUI];
    });

    //初始化SDK参数
    __weak typeof(self) weakSelf = self;
    self.initTXVideoSDKBlock = ^(NSMutableDictionary * _Nonnull dict) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [TRTCCloud sharedInstance].delegate = strongSelf;
        TRTCParams *params = [[TRTCParams alloc] init];
        params.sdkAppId = [dict[@"sdkAppId"] intValue];
        if (strongSelf.scene == ZJTRTCAppSceneLIVE) {
            params.role = strongSelf.role;
        }
        strongSelf.userId = dict[@"userId"];
        params.userId = strongSelf.userId;
        params.userSig = dict[@"userSig"];
        params.roomId = strongSelf.roomId;
        if (strongSelf.inquiryRecId && strongSelf.inquiryRecId.length>0) {
            params.userDefineRecordId = [NSString stringWithFormat:@"%@_%@",dict[@"orgCode"]?:@"",strongSelf.inquiryRecId] ;
        }
        
        //场景
        if (strongSelf.scene == ZJTRTCAppSceneVideoCall
            ||strongSelf.scene == ZJTRTCAppSceneVideoMeeting) {
            //视频会议、1对1视频通话
            [strongSelf permissionIdentify:1];
            [strongSelf permissionIdentify:2];
            [[TRTCCloud sharedInstance] setAudioRoute:TRTCAudioModeSpeakerphone];
            [[TRTCCloud sharedInstance] enterRoom:params appScene:TRTCAppSceneVideoCall];
        }else if (strongSelf.scene == ZJTRTCAppSceneAudioCall) {
            //语音通话
            [strongSelf permissionIdentify:2];
            [[TRTCCloud sharedInstance] setDefaultStreamRecvMode:YES video:NO];
            [[TRTCCloud sharedInstance] setAudioRoute:TRTCAudioModeEarpiece];
            [[TRTCCloud sharedInstance] enterRoom:params appScene:TRTCAppSceneAudioCall];
        }else if (strongSelf.scene == ZJTRTCAppSceneLIVE) {
            //直播
            [strongSelf permissionIdentify:1];
            [strongSelf permissionIdentify:2];
            [[TRTCCloud sharedInstance] setAudioRoute:TRTCAudioModeSpeakerphone];
            [[[TRTCCloud sharedInstance] getBeautyManager] setBeautyStyle:TXBeautyStylePitu];
            [[[TRTCCloud sharedInstance] getBeautyManager] setBeautyLevel:5];
            [[TRTCCloud sharedInstance] enterRoom:params appScene:TRTCAppSceneLIVE];
        }
    };
}

//对基本UI做额外的配置操作
- (void)configUI {
    if (self.isInvited) {
        //被叫
        self.audioTipL.text = nil;
        [self addSubview:self.invitedChatView];
        if (self.scene == ZJTRTCAppSceneAudioCall) {
            self.invitedChatView.tipLabel.text = @"邀请你进行语音通话…";
        }else if (self.scene == ZJTRTCAppSceneVideoCall) {
            self.invitedChatView.tipLabel.text = @"邀请你进行视频通话…";
        }else if (self.scene == ZJTRTCAppSceneVideoMeeting) {
            self.invitedChatView.tipLabel.text = @"邀请你进行视频会议…";
        }else if (self.scene == ZJTRTCAppSceneVoiceMeeting) {
            self.invitedChatView.tipLabel.text = @"邀请你进行语音会议…";
        }

        self.invitedChatView.userNameL.text = self.userName?:@"";
        [self.invitedChatView.photoImgV sd_setImageWithURL:[NSURL URLWithString:self.photoUrl] placeholderImage:GetXMZJUIImage(@"TXVideoCall_videoDefaultPhoto") options:SDWebImageAllowInvalidSSLCertificates completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            
        }];
    }else {
        //主叫
        
    }
    
}

#pragma mark - 挂断
- (IBAction)hangupAction:(UIButton *)sender {
    [self hidden];
}

#pragma mark - 切换摄像头
- (IBAction)switchCamera:(UIButton *)sender {
    TXDeviceManager *deviceManager = [[TRTCCloud sharedInstance] getDeviceManager];
    [deviceManager switchCamera:sender.selected];
    sender.selected = !sender.selected;
}

#pragma mark - 静音
- (IBAction)muteAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.isSelected) {
        //静音
        [sender setImage:GetXMZJUIImage(@"TXVideoCall_btn_mute_hl") forState:UIControlStateNormal];
        [[TRTCCloud sharedInstance] muteLocalAudio:YES];
    }else {
        //非静音
        [sender setImage:GetXMZJUIImage(@"TXVideoCall_btn_mute") forState:UIControlStateNormal];
        [[TRTCCloud sharedInstance] muteLocalAudio:NO];
    }
}

#pragma mark - 免提
- (IBAction)audioModeAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.isSelected) {
        //免提（扬声器）
        [sender setImage:GetXMZJUIImage(@"TXVideoCall_btn_audioMode_hl") forState:UIControlStateNormal];
        [[TRTCCloud sharedInstance] setAudioRoute:TRTCAudioModeSpeakerphone];
    }else {
        //非免提（听筒）
        [sender setImage:GetXMZJUIImage(@"TXVideoCall_btn_audioMode") forState:UIControlStateNormal];
        [[TRTCCloud sharedInstance] setAudioRoute:TRTCAudioModeEarpiece];
    }
}

- (void)dealloc {
    if (!self.roomId) {
        return;
    }
    if (self.status == ChatRoomStatus_Hangup) {
        //通话结束
        if (self.onCallDisconnected) {
            self.onCallDisconnected(nil);
            self.onCallDisconnected = nil;
        }
    }else if (self.status == ChatRoomStatus_Refuse) {
        //对方拒接
        if (self.onCallDisconnected) {
            self.onCallDisconnected([[NSError alloc] initWithDomain:@"" code:ChatRoomStatus_Refuse userInfo:nil]);
            self.onCallDisconnected = nil;
        }
        [self hud_showHintTip:@"对方拒绝接听"];
    }else if (self.status == ChatRoomStatus_TimeOut) {
        //对方无应答
        if (self.onCallDisconnected) {
            self.onCallDisconnected([[NSError alloc] initWithDomain:@"" code:ChatRoomStatus_TimeOut userInfo:nil]);
            self.onCallDisconnected = nil;
        }
        if (self.isInvited) {
            [self hud_showHintTip:@"通话超时"];
        }else {
            [self hud_showHintTip:@"对方无应答"];
        }
    }else if (self.status == ChatRoomStatus_Cancel) {
        //自己取消
        if (self.onCallDisconnected) {
            self.onCallDisconnected([[NSError alloc] initWithDomain:@"" code:ChatRoomStatus_Cancel userInfo:nil]);
            self.onCallDisconnected = nil;
        }
        if (self.scene != ZJTRTCAppSceneVideoMeeting) {
            [self hud_showHintTip:@"通话取消"];
        }
    }else if (self.status == ChatRoomStatus_RefuseHangup) {
        //拒绝邀请
        if (self.onCallDisconnected) {
            self.onCallDisconnected([[NSError alloc] initWithDomain:@"" code:ChatRoomStatus_RefuseHangup userInfo:nil]);
            self.onCallDisconnected = nil;
        }
        if (self.scene != ZJTRTCAppSceneVideoMeeting) {
            [self hud_showHintTip:@"通话已拒绝"];
        }
    }else {
        //取消通话（未接通前）
        if (self.onCallDisconnected) {
            self.onCallDisconnected([[NSError alloc] initWithDomain:@"" code:ChatRoomStatus_Cancel userInfo:nil]);
            self.onCallDisconnected = nil;
        }
        if (self.scene != ZJTRTCAppSceneVideoMeeting) {
            [self hud_showHintTip:@"通话取消"];
        }
    }
    [[TRTCCloud sharedInstance] exitRoom];
}

- (void)show {
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self];
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.25 animations:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.frame = CGRectMake(0,0,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height);
    }];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (void)hidden {
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.25 animations:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.frame = CGRectMake(0,[UIScreen mainScreen].bounds.size.height,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height);
    } completion:^(BOOL finished) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf removeFromSuperview];
    }];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

//获取受邀界面
- (UIView *)getInvitedView {
    if (self.isInvited&&self.status == 0) {
        return self.invitedChatView;
    }
    return nil;
}

- (void)setUserName:(NSString *)userName {
    _userName = userName;
    _userNameL.text = _userName?:@"";
}

- (void)setPhotoUrl:(NSString *)photoUrl {
    _photoUrl = photoUrl;
    [_photoImgV sd_setImageWithURL:[NSURL URLWithString:photoUrl] placeholderImage:GetXMZJUIImage(@"TXVideoCall_videoDefaultPhoto") options:SDWebImageAllowInvalidSSLCertificates completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        
    }];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.intrinsicContentSize = CGSizeMake(frame.size.width,frame.size.height);
}

- (TXInvitedChatContentView *)invitedChatView {
    if (_invitedChatView) return _invitedChatView;
    _invitedChatView = [[TXInvitedChatContentView alloc] init];
    _invitedChatView.frame = [UIScreen mainScreen].bounds;
    
    __weak typeof(self) weakSelf = self;
    _invitedChatView.smallBtnClickBlock = ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf reduceBtnAction:strongSelf.smallTransferBtn];
    };
    
    _invitedChatView.agreeBtnClickBlock = ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.agreeCallSDKBlock) {
            strongSelf.agreeCallSDKBlock();
        }
        strongSelf.invitedChatView.hidden = YES;
        [strongSelf.invitedChatView removeFromSuperview];
        strongSelf.invitedChatView = nil;
    };
    
    _invitedChatView.refuseBtnClickBlock = ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.refuseCallSDKBlock) {
            strongSelf.refuseCallSDKBlock();
        }
        strongSelf.invitedChatView.hidden = YES;
        [strongSelf.invitedChatView removeFromSuperview];
        strongSelf.invitedChatView = nil;
        strongSelf.status = ChatRoomStatus_RefuseHangup;
        [strongSelf hidden];
    };
    return _invitedChatView;
}


/// 授权判断
/// @param mediaType 1：摄像头  2：麦克风
- (void)permissionIdentify:(NSInteger)mediaType {
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
    }else {
        // iOS 8 后，全部都要授权
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:(mediaType==1?AVMediaTypeVideo:AVMediaTypeAudio)];
        switch (status) {
            case AVAuthorizationStatusNotDetermined: {
                // 许可对话没有出现，发起授权许可
                [AVCaptureDevice requestAccessForMediaType:(mediaType==1?AVMediaTypeVideo:AVMediaTypeAudio) completionHandler:^(BOOL granted) {
                    if (granted) {
                        //第一次用户接受
                    }else{
                        if (mediaType==1) {
                            [self hud_showHintTip:@"没有相机权限或设备相机无法访问"];
                        }else {
                            [self hud_showHintTip:@"没有麦克风权限或设备麦克风无法访问"];
                        }
                        
                    }
                }];
                break;
            }
            case AVAuthorizationStatusAuthorized: {
                // 已经开启授权，可继续
                break;
            }
            case AVAuthorizationStatusDenied:
            case AVAuthorizationStatusRestricted:
            {
                // 用户明确地拒绝授权，或者相机设备无法访问
                NSString *message;
                if (mediaType == 1) {
                    message = @"需要开启相机权限才能使用，是否去开启？";
                }else {
                    message = @"需要开启麦克风权限才能使用，是否去开启？";
                }
                ZOEAlertView *alertView = [[ZOEAlertView alloc] initWithTitle:@"提醒" message:message cancelButtonTitle:@"取消" otherButtonTitles:@"去开启", nil];
                [alertView setButtonTextColor:[UIColor colorWithRed:71/255.0 green:133/255.0 blue:255/255.0 alpha:1] buttonIndex:1];
                [alertView setButtonTextColor:[UIColor colorWithRed:142/255.0 green:142/255.0 blue:142/255.0 alpha:1] buttonIndex:0];
                [alertView showWithBlock:^(NSInteger buttonIndex) {
                    if (buttonIndex!=alertView.cancelButtonIndex) {
                        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                        if ([[UIApplication sharedApplication] canOpenURL:url]) {
                            [[UIApplication sharedApplication] openURL:url];
                        }
                    }
                }];
                break;
            }
            default:
                break;
        }
        
    }
}

@end
