//
//  UIViewController+IMYourDoc_ComposeAction.m
//  IMYourDoc
//
//  Created by Harminder on 06/02/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import "ChatViewController.h"
#import "UIViewController+IMYourDoc_ComposeAction.h"


@implementation UIViewController (IMYourDoc_ComposeAction)


- (IBAction)backAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)composeAction:(id)sender
{
    ChatViewController *chatVC = [[ChatViewController alloc] initWithNibName:@"ChatViewController" bundle:nil];
    
    chatVC.forChat = NO;
    
    [self.navigationController pushViewController:chatVC animated:YES];
}


@end

