//
//  TXVideoChatContentView+TXLIVE.h
//  ZJJKMGDoctor
//
//  Created by czc on 2021/1/19.
//  Copyright © 2021 zjjk. All rights reserved.
//

#import "TXVideoChatContentView.h"

@interface TXVideoChatContentView (TXLIVE)

/// 远端用户是否存在可播放的主路画面
/// @param userId userId description
/// @param availabl 是否有效
- (void)onUserVideoAvailableLiveVideo:(NSString *)userId available:(BOOL)availabl;

/// 有用户加入当前房间
/// @param userId userId description
- (void)onRemoteUserEnterRoomLiveVideo:(NSString *)userId;

/// 有用户离开房间
/// @param userId userId description
/// @param reason 离开原因，0表示用户主动退出房间，1表示用户超时退出，2表示被踢出房间。
- (void)onRemoteUserLeaveLiveRoom:(NSString *)userId reason:(NSInteger)reason;
@end
