//
//  NotificationsViewController.m
//  IMYourDoc
//
//  Created by Sarvjeet on 28/01/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import "NotificationsViewController.h"


@interface NotificationsViewController ()


@end


@implementation NotificationsViewController


#pragma mark - View LifeCycle

- (void) viewDidLoad
{
    [super viewDidLoad];
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    [self setRequiredFont1];
    
    if ([AppDel isConnected])
    {
        secureL.text = @"Securely Connected";
        
        secureIcon.image = [UIImage imageNamed:@"secure_icon"];
    }
    
    else
    {
        secureL.text = @"Not Connected";
        
        secureIcon.image = [UIImage imageNamed:@"unsecure_icon"];
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateConnectivity:) name:XMPPREACHABILITY object:nil];

    
    
    [alertSwitch setOn:[[NSUserDefaults standardUserDefaults] boolForKey:@"Alerts"]];
    
    [soundSwitch setOn:[[NSUserDefaults standardUserDefaults] boolForKey:@"Sounds"]];
    
    [vibrateSwitch setOn:[[NSUserDefaults standardUserDefaults] boolForKey:@"Vibrate"]];
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

- (IBAction)navBack
{
	[self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)messageRingtone
{
    MessageRingtoneViewController *ringVC = [[MessageRingtoneViewController alloc] initWithNibName:@"MessageRingtoneViewController" bundle:nil];
    
    [self.navigationController pushViewController:ringVC animated:YES];
}


- (IBAction)switchChange:(UISwitch *)sender
{
    if (sender == alertSwitch)
    {
        [[NSUserDefaults standardUserDefaults] setBool:sender.isOn forKey:@"Alerts"];
    }
    
    else if (sender == soundSwitch)
    {
        [[NSUserDefaults standardUserDefaults] setBool:sender.isOn forKey:@"Sounds"];
    }
    
    else if (sender == vibrateSwitch)
    {
        [[NSUserDefaults standardUserDefaults] setBool:sender.isOn forKey:@"Vibrate"];
    }
    
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark - Update Connectivity

- (void)updateConnectivity:(NSNotification *)note
{
    NSDictionary *dict = note.object;
    
    
    secureL.text = [dict objectForKey:@"status"];
    
    
    [secureIcon setImage:[UIImage imageNamed:[dict objectForKey:@"image"]]];
}


#pragma mark - Set required font

- (void)setRequiredFont1
{
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [titleL setFont:[UIFont fontWithName:@"CentraleSansRndMedium" size:25.00]];
        
        [msgNotifyL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:18.00]];

        [selectL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:22.00]];

        [vibratL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:22.00]];

        [soundL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:22.00]];
    }
    else
    {
        [titleL setFont:[UIFont fontWithName:@"CentraleSansRndMedium" size:20.00]];
        
        [msgNotifyL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:13.00]];
        
        [selectL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:17.00]];
        
        [vibratL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:17.00]];
        
        [soundL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:17.00]];
    }
}



@end

