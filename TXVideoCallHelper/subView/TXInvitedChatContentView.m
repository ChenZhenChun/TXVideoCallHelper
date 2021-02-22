//
//  TXInvitedChatContentView.m
//  AiyoyouCocoapods
//
//  Created by czc on 2021/2/22.
//  Copyright © 2021 aiyoyou. All rights reserved.
//

#import "TXInvitedChatContentView.h"

@interface TXInvitedChatContentView ()
@property (nonatomic,assign) CGSize intrinsicContentSize;

@end

@implementation TXInvitedChatContentView

- (instancetype)init {
    NSString *nibName = NSStringFromClass([self class]);
    self = [[[NSBundle bundleForClass:[self class]] loadNibNamed:nibName owner:self options:nil] lastObject];
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.autoresizingMask = UIViewAutoresizingNone;
    
}


- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.intrinsicContentSize = CGSizeMake(frame.size.width,frame.size.height);
}

//缩小
- (IBAction)smallBtnClickAction:(UIButton *)sender {
    if (self.smallBtnClickBlock) {
        self.smallBtnClickBlock();
    }
}

//拒绝接听
- (IBAction)refuseBtnClickAction:(UIButton *)sender {
    if (self.refuseBtnClickBlock) {
        self.refuseBtnClickBlock();
    }
}

//接受接听
- (IBAction)agreeBtnClickAction:(UIButton *)sender {
    if (self.agreeBtnClickBlock) {
        self.agreeBtnClickBlock();
    }
}

@end
