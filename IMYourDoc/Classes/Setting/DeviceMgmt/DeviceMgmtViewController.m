//
//  DeviceMgmtViewController.m
//  IMYourDoc
//
//  Created by Manpreet on 05/02/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import "DeviceMgmtViewController.h"
#import "BlockedDevicesViewController.h"
#import "RegisteredDevicesViewController.h"


@interface DeviceMgmtViewController ()


@end


@implementation DeviceMgmtViewController


#pragma mark - View LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    [self setRequiredFont1];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    [self setRequiredFont1];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - IBAction

- (IBAction)backTap
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)deviceMgmtTap:(UIButton *)sender
{
    if (sender.tag == 1)
    {
        RegisteredDevicesViewController *rdVC = [[RegisteredDevicesViewController alloc] initWithNibName:@"RegisteredDevicesViewController" bundle:nil];
        
        [self.navigationController pushViewController:rdVC animated:YES];
    }
    
    else if (sender.tag == 2)
    {
        BlockedDevicesViewController *bdVC = [[BlockedDevicesViewController alloc] initWithNibName:@"BlockedDevicesViewController" bundle:nil];
        
        [self.navigationController pushViewController:bdVC animated:YES];
    }
}


- (void)setRequiredFont1
{
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [titleL setFont:[UIFont fontWithName:@"CentraleSansRndMedium" size:25.00]];
        
        [registerBtn.titleLabel setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];

        [blockedBtn.titleLabel setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
    }
    else
    {
        [titleL setFont:[UIFont fontWithName:@"CentraleSansRndMedium" size:20.00]];
        
        [registerBtn.titleLabel setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:17.00]];
        
        [blockedBtn.titleLabel setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:17.00]];
    }
}


@end

