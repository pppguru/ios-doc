//
//  FontBoldLabel.m
//  IMYourDoc
//
//  Created by Sarvjeet on 29/01/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import "FontBoldLabel.h"

@implementation FontBoldLabel


//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    
//    if (self)
//    {
//        //[super awakeFromNib];
//    }
//    
//    return self;
//}
//
//


- (id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder])
    {
        self.font = [UIFont fontWithName:@"CentraleSansRndBold" size:self.font.pointSize];
    }
    
    return self;
}

//- (void)awakeFromNib
//{
//    
//    [super awakeFromNib];
//    
//    self.font = [UIFont fontWithName:@"CentraleSansRndBold" size:self.font.pointSize];
//    
//}
//
//
//- (id)initWithFrame:(CGRect)frame
//{
//    if (self = [super initWithFrame:frame])
//    {
//        [self setup];
//    }
//    return self;
//}
//
//- (void)setup
//{
//    CGFloat fontSize = self.font.pointSize;
//    
//    self.font = [UIFont fontWithName:@"CentraleSansRndBold" size:80.00];
//    
//}


@end
