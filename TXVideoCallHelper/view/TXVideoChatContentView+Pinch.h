//
//  TXVideoChatContentView+Pinch.h
//  ZJJKMGDoctor
//
//  Created by czc on 2021/1/18.
//  Copyright © 2021 zjjk. All rights reserved.
//

#import "TXVideoChatContentView.h"

@interface TXVideoChatContentView (Pinch)

/// 注册手势事件
- (void)registerGestureRecognizer;

/// 缩小操作
/// @param sender smallTransferBtn
- (void)reduceBtnAction:(UIButton *)sender;
@end
