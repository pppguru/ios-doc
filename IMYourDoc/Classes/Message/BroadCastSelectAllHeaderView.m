//
//  BroadCastSelectAllHeaderView.m
//  IMYourDoc
//
//  Created by OSX on 08/02/16.
//  Copyright (c) 2016 Sarvjeet. All rights reserved.
//

#import "BroadCastSelectAllHeaderView.h"

@implementation BroadCastSelectAllHeaderView
@synthesize btn_all;;




//- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
//{
//    self = [super initWithReuseIdentifier:reuseIdentifier];
//    if (self)
//    {
//        NSArray* objects = [[NSBundle mainBundle] loadNibNamed:@"BroadCastSelectAllHeaderView"
//                                                         owner:self
//                                                       options:nil];
//        UIView *nibView = [objects firstObject];
//        UIView *contentView = self.contentView;
//        CGSize contentViewSize = contentView.frame.size;
//        nibView.frame = CGRectMake(0, 0, contentViewSize.width, contentViewSize.height);
//        [contentView addSubview:nibView];
//        
//                 
//    }
//    return self;
//}
- (IBAction)action_select:(id)sender
{
    btn_all.selected=!btn_all.selected;
    self ->_callBackBlockHeaderView(btn_all.selected);
}
@end
