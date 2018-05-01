//
//  FontSegmentedControl.m
//  IMYourDoc
//
//  Created by Sarvjeet on 19/03/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import "FontSegmentedControl.h"


@implementation FontSegmentedControl


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
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor clearColor];
    
    [[UISegmentedControl appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                             [UIColor blackColor], NSForegroundColorAttributeName,
                                                             shadow, NSShadowAttributeName,
                                                             [UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0], NSFontAttributeName, nil] forState:UIControlStateNormal];
    
    
    NSShadow *shadow2 = [[NSShadow alloc] init];
    shadow2.shadowColor = [UIColor clearColor];
    shadow2.shadowOffset = CGSizeMake(0, 1);
    
    [[UISegmentedControl appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                             [UIColor colorWithRed:135.0/255.0 green:135.0/255.0 blue:135.0/255.0 alpha:1.0], NSForegroundColorAttributeName,
                                                             shadow2, NSShadowAttributeName,
                                                             [UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0], NSFontAttributeName, nil] forState:UIControlStateSelected];
    
    
    [super awakeFromNib];
}


@end

