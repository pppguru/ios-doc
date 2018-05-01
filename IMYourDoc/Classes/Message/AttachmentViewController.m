//
//  AttachmentViewController.m
//  IMYourDoc
//
//  Created by Harminder on 09/02/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import "AttachmentViewController.h"


@interface AttachmentViewController ()<UIScrollViewDelegate>


@end


@implementation AttachmentViewController


#pragma mark - View LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setRequiredFont2];
    
    if (self.url)
    {
//        [attchementImage downloadFromURL:[NSURL URLWithString:[self.url stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]]];
        //Changed the encoding module into UTF8 - Made By Ronald [10/26 Ronald]
        [attchementImage downloadFromURL:[NSURL URLWithString:[self.url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        
        
    }
}


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return attchementImage;
}



#pragma mark - Set Required Font


- (void)setRequiredFont2
{
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [titleL setFont:[UIFont fontWithName:@"CentraleSansRndMedium" size:25.00]];
    }
    else
    {
        [titleL setFont:[UIFont fontWithName:@"CentraleSansRndMedium" size:20.00]];
    }
}



@end

