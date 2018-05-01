//
//  SecurityViewController.m
//  IMYourDoc
//
//  Created by Sarvjeet on 30/01/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import "SecurityViewController.h"


@interface SecurityViewController ()


@end


@implementation SecurityViewController


#pragma mark - View LifeCycle

- (void) viewDidLoad
{
    [super viewDidLoad];
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    [self setRequiredFont1];
}


- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    [self setRequiredFont1];
}


- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}


- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - IBAction

- (IBAction)backTap
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)resetPin
{
    ResetPinViewController *rpVC = [[ResetPinViewController alloc] initWithNibName:@"ResetPinViewController" bundle:nil];
    
    rpVC.topL.text = @"Reset Password";
    
    [self.navigationController pushViewController:rpVC animated:YES];
}


- (IBAction)changePassword
{
    ChangePasswordViewController *cpVC = [[ChangePasswordViewController alloc] initWithNibName:@"ChangePasswordViewController" bundle:nil];
    
    [self.navigationController pushViewController:cpVC animated:YES];
}

- (IBAction)changeSecurityQuestionAndAnser
{
    ChangeSecurityQuestionViewController *rpVC = [[ChangeSecurityQuestionViewController alloc] initWithNibName:@"ChangeSecurityQuestionViewController" bundle:nil];
    
  
    
    [self.navigationController pushViewController:rpVC animated:YES];
}

- (void)setRequiredFont1
{
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [titleL setFont:[UIFont fontWithName:@"CentraleSansRndMedium" size:25.00]];
        
        [changePassL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:25.00]];
        
        [changePinL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:25.00]];
    }
    else
    {
        [titleL setFont:[UIFont fontWithName:@"CentraleSansRndMedium" size:20.00]];
        
        [changePassL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
        
        [changePinL  setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
    }
}


@end

