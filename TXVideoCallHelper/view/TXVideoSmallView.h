//
//  TXVideoSmallView.h
//  ZJInternetHospital
//
//  Created by czc on 2021/1/14.
//  Copyright © 2021 zjjk. All rights reserved.
//

@interface TXVideoSmallView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *videoView;
@property (nonatomic,copy) NSString *userId;
@property (nonatomic,assign) BOOL availabl;//是否存在视频流（用户是否还开着摄像头）
@end
