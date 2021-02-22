//
//  TXInvitedChatContentView.h
//  AiyoyouCocoapods
//  语音通话 被叫接听页面
//  Created by czc on 2021/2/22.
//  Copyright © 2021 aiyoyou. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TXInvitedChatContentView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *photoImgV;
@property (weak, nonatomic) IBOutlet UILabel *userNameL;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;

//最小化
@property (nonatomic,copy) void(^smallBtnClickBlock)(void);
//受邀人接受邀请
@property (nonatomic,copy) void(^agreeBtnClickBlock)(void);
//受邀人拒绝邀请
@property (nonatomic,copy) void(^refuseBtnClickBlock)(void);
@end

NS_ASSUME_NONNULL_END
