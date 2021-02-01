//
//  TXVideoChatContentView+TXLIVE.m
//  ZJJKMGDoctor
//
//  Created by czc on 2021/1/19.
//  Copyright © 2021 zjjk. All rights reserved.
//

#import "TXVideoChatContentView+TXLIVE.h"
#import <TXLiteAVSDK_Professional/TRTCCloud.h>

@implementation TXVideoChatContentView (TXLIVE)

- (void)onUserVideoAvailableLiveVideo:(NSString *)userId available:(BOOL)availabl {
    if (self.role==ZJTRTCRoleAnchor) {
        [[TRTCCloud sharedInstance] startLocalPreview:YES view:self.bigVideoView];
        [[TRTCCloud sharedInstance] startLocalAudio:TRTCAudioQualityDefault];
    }else {
        [[TRTCCloud sharedInstance] startRemoteView:userId streamType:TRTCVideoStreamTypeBig view:self.bigVideoView];
    }
}

/// 有用户加入当前房间
/// @param userId userId description
- (void)onRemoteUserEnterRoomLiveVideo:(NSString *)userId {
    NSLog(@"有用户进入房间");
}

/// 有用户离开房间
/// @param userId userId description
/// @param reason 离开原因，0表示用户主动退出房间，1表示用户超时退出，2表示被踢出房间。
- (void)onRemoteUserLeaveLiveRoom:(NSString *)userId reason:(NSInteger)reason {
    NSLog(@"有用户离开房间");
}
@end
