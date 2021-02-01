//
//  TXVideoChatContentView+TXMeetingVideo.m
//  ZJInternetHospital
//  多人会议室视频聊天处理
//  Created by czc on 2021/1/14.
//  Copyright © 2021 zjjk. All rights reserved.
//

#import "TXVideoChatContentView+TXMeetingVideo.h"
#import <TXLiteAVSDK_Professional/TRTCCloud.h>
#import <objc/runtime.h>

@interface TXVideoChatContentView()
//多人会议视频聊天
@property (nonatomic,strong) NSMutableArray *meetingVideoViewArray;
@property (nonatomic,strong) NSMutableDictionary *meetingVideoOnlineUser;//在线用户
@property (nonatomic,strong) UIScrollView   *scrollView;
@end

@implementation TXVideoChatContentView (TXMeetingVideo)
static char *vidoChat_meetingVideoViewArray = "vidoChat_meetingVideoViewArray";
static char *vidoChat_scrollView = "vidoChat_scrollView";
static char *vidoChat_meetingVideoOnlineUser = "vidoChat_meetingVideoOnlineUser";


/// 远端用户是否存在可播放的主路画面
/// @param userId userId description
/// @param availabl availabl description
- (void)onUserVideoAvailableMeetingVideo:(NSString *)userId available:(BOOL)availabl {
    if (!self.meetingVideoViewArray) {
        self.meetingVideoViewArray = [[NSMutableArray alloc] init];
    }
    
    //缓存中查找是不是旧用户
    TXVideoSmallView *videoView;
    for (TXVideoSmallView *obj in self.meetingVideoViewArray) {
        if ([obj.userId isEqualToString:userId]) {
            videoView = obj;
            break;
        }
    }
    
    //新用户创建视图小窗
    if (!videoView) {
        //新加入的用户创建一个小窗口给他
        videoView = [[TXVideoSmallView alloc] init];
        videoView.userId = userId;
        videoView.tag = self.meetingVideoViewArray.count;
//        [self configFrameVideoView:videoView];
        [self.meetingVideoViewArray addObject:videoView];
        [self configAllVideoViewFrame];
    }
    
    //视图视频流渲染
    videoView.availabl = availabl;
    if ([self.userId isEqualToString:userId]) {
        //是自己，渲染本地摄像头采集的视频流
        [[TRTCCloud sharedInstance] startLocalPreview:YES view:videoView.videoView];
    }else {
        [[TRTCCloud sharedInstance] startRemoteView:userId streamType:TRTCVideoStreamTypeSmall view:videoView.videoView];
    }
    
    //将用户视图加入滚动视图中
    if (!self.scrollView) {
        self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0,ScrollContentViewTop,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height-ScrollContentViewTop-ScrollContentViewBottom)];
        self.scrollView.backgroundColor = [UIColor clearColor];
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = YES;
        self.scrollView.pagingEnabled = NO;
        [self addSubview:self.scrollView];
    }
    [self.scrollView addSubview:videoView];
    [[TRTCCloud sharedInstance] startLocalAudio:TRTCAudioQualityDefault];
}


/// 有用户加入当前房间
/// @param userId userId description
- (void)onRemoteUserEnterRoomMeetingVideo:(NSString *)userId {
    if (!self.meetingVideoOnlineUser) {
        self.meetingVideoOnlineUser = [[NSMutableDictionary alloc] init];
    }
    [self.meetingVideoOnlineUser setValue:userId forKey:userId];
}


/// 有用户离开房间
/// @param userId userId description
/// @param reason 离开原因，0表示用户主动退出房间，1表示用户超时退出，2表示被踢出房间。
- (void)onRemoteUserLeaveMeetingRoom:(NSString *)userId reason:(NSInteger)reason {
    if (!self.meetingVideoOnlineUser) {
        self.meetingVideoOnlineUser = [[NSMutableDictionary alloc] init];
    }
    [self.meetingVideoOnlineUser removeObjectForKey:userId];
    TXVideoSmallView *videoView;
    for (TXVideoSmallView *obj in self.meetingVideoViewArray) {
        if ([obj.userId isEqualToString:userId]) {
            videoView = obj;
            break;
        }
    }
    [self.meetingVideoViewArray removeObject:videoView];
    [self configAllVideoViewFrame];
    
}

- (void)configFrameVideoView:(TXVideoSmallView *)videoView {
    NSInteger index = videoView.tag;
    NSInteger column;//列
    CGFloat w;//宽度
    CGFloat h;//高度
    CGFloat y;
    CGFloat x;
    if ((self.meetingVideoViewArray.count+1) <= 4) {
        column = self.meetingVideoViewArray.count+1;
        w = [UIScreen mainScreen].bounds.size.width/(CGFloat)column;
    }else {
        column = 4;
        w = [UIScreen mainScreen].bounds.size.width/4.0;
    }
    h = w;
    x = index%4*w;
    y = (index/4)*h;
    videoView.frame = CGRectMake(x,y, w, h);
}

- (void)configAllVideoViewFrame {
    static NSInteger count = 0;
    if (count == 0) {
        count = 1;
        NSInteger column;//列
        CGFloat w;//宽度
        CGFloat h;//高度
        if (self.meetingVideoViewArray.count <= 4) {
            column = self.meetingVideoViewArray.count;
            w = [UIScreen mainScreen].bounds.size.width/(CGFloat)column;
        }else {
            column = 4;
            w = [UIScreen mainScreen].bounds.size.width/4.0;
        }
        h = w;
        [UIView animateWithDuration:0.2 animations:^{
            for (int index=0; index<self.meetingVideoViewArray.count; index++) {
                
                id value = [self.meetingVideoViewArray objectAtIndex:index];
                if (value == [NSNull null]) {
                    continue;
                }
                TXVideoSmallView *videoView = value;
                videoView.tag = index;
                CGFloat y;
                CGFloat x;
                x = index%4*w;
                y = (index/4)*h;
                videoView.frame = CGRectMake(x,y, w, h);
                [videoView layoutIfNeeded];
            }
        }completion:^(BOOL finished) {
            if (count == -1) {
                count = 0;
                [self configAllVideoViewFrame];
            }else {
                count = 0;
            }
        }];
    }else {
        count = -1;
    }
}

- (void)setMeetingVideoViewArray:(NSMutableArray *)meetingVideoViewArray {
    objc_setAssociatedObject(self,vidoChat_meetingVideoViewArray,meetingVideoViewArray,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray *)meetingVideoViewArray {
    return objc_getAssociatedObject(self,vidoChat_meetingVideoViewArray);
}

- (void)setScrollView:(UIScrollView *)scrollView {
    objc_setAssociatedObject(self,vidoChat_scrollView,scrollView,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIScrollView *)scrollView {
    return objc_getAssociatedObject(self,vidoChat_scrollView);
}

- (void)setMeetingVideoOnlineUser:(NSMutableDictionary *)meetingVideoOnlineUser {
    objc_setAssociatedObject(self,vidoChat_meetingVideoOnlineUser,meetingVideoOnlineUser,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary *)meetingVideoOnlineUser {
    return objc_getAssociatedObject(self,vidoChat_meetingVideoOnlineUser);
}



@end
