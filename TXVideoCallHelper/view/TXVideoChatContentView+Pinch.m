//
//  TXVideoChatContentView+Pinch.m
//  ZJJKMGDoctor
//
//  Created by czc on 2021/1/18.
//  Copyright © 2021 zjjk. All rights reserved.
//

#import "TXVideoChatContentView+Pinch.h"
#import "TXVideoChatContentView+TXMeetingVideo.h"
@interface TXVideoChatContentView()

@end

@implementation TXVideoChatContentView (Pinch)

- (void)registerGestureRecognizer {
    self.userInteractionEnabled = YES;
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self addGestureRecognizer:pan];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewControllerBigAnimation)];
    [self addGestureRecognizer:tap];
}


#pragma mark - 缩小
- (IBAction)reduceBtnAction:(UIButton *)sender {
    if (!sender.isSelected) {
        sender.hidden = YES;
        [self getInvitedView].hidden = YES;
        if (self.scene == ZJTRTCAppSceneVideoCall) {
            self.smallVideoView.hidden = YES;
            self.hungUpBtn.hidden = YES;
            self.hungUpLabel.hidden = YES;
            self.switchCameraBtn.hidden = YES;
            self.switchCameraLabel.hidden = YES;
        }else if (self.scene == ZJTRTCAppSceneAudioCall) {
            self.photoImgV.hidden = YES;
            self.userNameL.hidden = YES;
            if (self.status != ChatRoomStatus_Hangup) {
                self.audioTipL.hidden = YES;
            }
            self.muteBtn.hidden = YES;
            self.muteL.hidden = YES;
            self.hungUpBtn.hidden = YES;
            self.hungUpLabel.hidden = YES;
            self.audioModeBtn.hidden = YES;
            self.audioModeL.hidden = YES;
            self.layer.cornerRadius = 5;
            self.audioSmallView.hidden = NO;
        }else if (self.scene == ZJTRTCAppSceneVideoMeeting) {
            self.muteBtn.hidden = YES;
            self.muteL.hidden = YES;
            self.hungUpBtn.hidden = YES;
            self.hungUpLabel.hidden = YES;
            self.switchCameraBtn.hidden = YES;
            self.switchCameraLabel.hidden = YES;
            self.scrollView.hidden = YES;
        }else if (self.scene == ZJTRTCAppSceneLIVE) {
            self.hungUpBtn.hidden = YES;
            self.hungUpLabel.hidden = YES;
            self.switchCameraBtn.hidden = YES;
            self.switchCameraLabel.hidden = YES;
        }
        [self imageViewControllerSmallAnimation];
    }
    sender.selected = YES;
}

//放大刚刚创建缩小后的视图
- (void)imageViewControllerBigAnimation {
    if (!self.smallTransferBtn.isSelected) return;
    self.smallTransferBtn.selected = NO;
    self.smallTransferBtn.hidden = NO;
    self.layer.cornerRadius = 0;
    [self getInvitedView].hidden = NO;
    if (self.scene == ZJTRTCAppSceneVideoCall) {
        self.smallVideoView.hidden = NO;
        self.hungUpBtn.hidden = NO;
        self.hungUpLabel.hidden = NO;
        self.switchCameraBtn.hidden = NO;
        self.switchCameraLabel.hidden = NO;
    }else if (self.scene == ZJTRTCAppSceneAudioCall) {
        self.photoImgV.hidden = NO;
        self.userNameL.hidden = NO;
        if (self.status != ChatRoomStatus_Hangup) {
            self.audioTipL.hidden = NO;
        }
        self.muteBtn.hidden = NO;
        self.muteL.hidden = NO;
        self.hungUpBtn.hidden = NO;
        self.hungUpLabel.hidden = NO;
        self.audioModeBtn.hidden = NO;
        self.audioModeL.hidden = NO;
        self.audioSmallView.hidden = YES;
    }else if (self.scene == ZJTRTCAppSceneVideoMeeting) {
        self.muteBtn.hidden = NO;
        self.muteL.hidden = NO;
        self.hungUpBtn.hidden = NO;
        self.hungUpLabel.hidden = NO;
        self.switchCameraBtn.hidden = NO;
        self.switchCameraLabel.hidden = NO;
        self.scrollView.hidden = NO;
    }else if (self.scene == ZJTRTCAppSceneLIVE) {
        self.hungUpBtn.hidden = NO;
        self.hungUpLabel.hidden = NO;
        self.switchCameraBtn.hidden = NO;
        self.switchCameraLabel.hidden = NO;
    }
    UIViewAnimationOptions options = UIViewAnimationCurveLinear | UIViewAnimationOptionAllowUserInteraction;
        [UIView animateWithDuration:0.2 delay:0.0 options:options animations:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                self.frame = CGRectMake(0,0,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height);
            });
        } completion:^(BOOL finished) {

        }];
    
}

- (void)imageViewControllerSmallAnimation {
    UIViewAnimationOptions options = UIViewAnimationCurveLinear | UIViewAnimationOptionAllowUserInteraction;
    [UIView animateWithDuration:0.2 delay:0.0 options:options animations:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.scene == ZJTRTCAppSceneAudioCall) {
                self.frame = CGRectMake(0,
                                        [UIScreen mainScreen].bounds.size.width/2.0+([[UIApplication sharedApplication] statusBarFrame].size.height+44)+50,
                                        80-1,
                                        80-1);
            }else {
                self.frame = CGRectMake(0,
                                        [UIScreen mainScreen].bounds.size.width/2.0+([[UIApplication sharedApplication] statusBarFrame].size.height+44)+50,
                                        94,
                                        168);
            }
        });
        
    } completion:nil];
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
    if (self.smallTransferBtn.isSelected) {
        if (recognizer.state == UIGestureRecognizerStateBegan) {
            NSLog(@"FlyElephant---视图拖动开始");
        } else if (recognizer.state == UIGestureRecognizerStateChanged) {
            CGPoint location = [recognizer locationInView:self];
            
            if (location.y < 0 || location.y > self.bounds.size.height) {
                return;
            }
            CGPoint translation = [recognizer translationInView:self];
            
            NSLog(@"当前视图在View的位置:%@----平移位置:%@",NSStringFromCGPoint(location),NSStringFromCGPoint(translation));
            recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,recognizer.view.center.y + translation.y);
            [recognizer setTranslation:CGPointZero inView:self];
            
        } else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
            NSLog(@"FlyElephant---视图拖动结束");
        }
    }
}

@end
