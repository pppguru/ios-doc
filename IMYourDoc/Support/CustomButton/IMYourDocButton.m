//
//  IMYourDocButton.m
//  IMYourDocBtn
//
//  Created by Manpreet Emobx on 20/01/15.
//  Copyright (c) 2015 Manpreet Singh. All rights reserved.
//


#import "IMYourDocButton.h"


@implementation IMYourDocButton


- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	
	if (self)
	{
		[self addTarget:self action:@selector(didTouchButton) forControlEvents:UIControlEventTouchUpInside];
	}
	
    self.titleLabel.font = [UIFont fontWithName:@"CentraleSansRndMedium" size:self.titleLabel.font.pointSize];
    
	return self;
}


- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	
	if (self)
	{
		[self addTarget:self action:@selector(didTouchButton) forControlEvents:UIControlEventTouchUpInside];
	}
	
	return self;
}


- (void) didTouchButton
{
	CGRect tempRect = self.layer.frame;
	
	tempRect.origin.x -= 2;
	tempRect.origin.y -= 2;
	
	tempRect.size.height += 4;
	tempRect.size.width += 4;
	
	self.layer.frame = tempRect;
	
	[self performSelector:@selector(removeEffect) withObject:nil afterDelay:0.2f];
}


- (void) removeEffect
{
	CGRect tempRect = self.layer.frame;
	
	tempRect.origin.x += 2;
	tempRect.origin.y += 2;
	
	tempRect.size.height -= 4;
	tempRect.size.width -= 4;
	
	self.layer.frame = tempRect;
}


@end
