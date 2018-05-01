//
//  SimpleFontButton.m
//  IMYourDoc
//
//  Created by Sarvjeet on 13/02/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import "SimpleFontButton.h"

@implementation SimpleFontButton


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        
    }
    
    self.titleLabel.font = [UIFont fontWithName:@"CentraleSansRndLight" size:self.titleLabel.font.pointSize];
    
    return self;
}


@end
