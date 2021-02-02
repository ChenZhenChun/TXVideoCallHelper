//
//  TXVideoSmallView.m
//  ZJInternetHospital
//
//  Created by czc on 2021/1/14.
//  Copyright © 2021 zjjk. All rights reserved.
//

#import "TXVideoSmallView.h"

@interface TXVideoSmallView ()
@property (nonatomic,assign) CGSize intrinsicContentSize;
@property (nonatomic,assign) BOOL selected;
@property (nonatomic,assign) CGRect   oldFrame;
@end

@implementation TXVideoSmallView

- (instancetype)init {
    NSString *nibName = NSStringFromClass([self class]);
    self = [[[NSBundle bundleForClass:[self class]] loadNibNamed:nibName owner:self options:nil] lastObject];
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.autoresizingMask = UIViewAutoresizingNone;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap)];
    [self.videoView addGestureRecognizer:tap];
}


- (void)handleTap {
    if (!self.selected) {
        self.oldFrame = self.frame;
    }
    self.selected = !self.selected;
    if (self.selected) {
        [UIView animateWithDuration:0.2 animations:^{
            self.frame = self.superview.bounds;
            [self layoutIfNeeded];
            [self.superview bringSubviewToFront:self];
        }];
    }else {
        [UIView animateWithDuration:0.2 animations:^{
            self.frame = self.oldFrame;
            [self layoutIfNeeded];
        }];
    }
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.intrinsicContentSize = CGSizeMake(frame.size.width,frame.size.height);
}

@end
