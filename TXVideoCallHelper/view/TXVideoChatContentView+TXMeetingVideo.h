//
//  TXVideoChatContentView+TXMeetingVideo.h
//  ZJInternetHospital
//
//  Created by czc on 2021/1/14.
//  Copyright © 2021 zjjk. All rights reserved.
//

#import "TXVideoChatContentView.h"
#define ScrollContentViewTop 90
#define ScrollContentViewBottom 135

@interface TXVideoChatContentView (TXMeetingVideo)
@property (nonatomic,readonly) NSMutableArray *meetingVideoViewArray;
@property (nonatomic,readonly) NSMutableDictionary *meetingVideoOnlineUser;//在线用户{"userId":"userId"}
@property (nonatomic,readonly) UIScrollView   *scrollView;

/// 远端用户是否存在可播放的主路画面
/// @param userId userId description
/// @param availabl 是否有效
- (void)onUserVideoAvailableMeetingVideo:(NSString *)userId available:(BOOL)availabl;


/// 有用户加入当前房间
/// @param userId userId description
- (void)onRemoteUserEnterRoomMeetingVideo:(NSString *)userId;


/// 有用户离开房间
/// @param userId userId description
/// @param reason 离开原因，0表示用户主动退出房间，1表示用户超时退出，2表示被踢出房间。
- (void)onRemoteUserLeaveMeetingRoom:(NSString *)userId reason:(NSInteger)reason;


@end
