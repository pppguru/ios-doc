//
//  FontTextView.m
//  IMYourDoc
//
//  Created by Sarvjeet on 27/01/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import "FontTextView.h"

@implementation FontTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        // Initialization code
    }
    
    return self;
}


- (void)awakeFromNib
{
    self.font = [UIFont fontWithName:@"CentraleSansRndLight" size:self.font.pointSize];
    
    [super awakeFromNib];
}

@end
