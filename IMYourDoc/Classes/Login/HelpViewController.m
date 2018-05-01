//
//  HelpViewController.m
//  IMYourDoc
//
//  Created by Sarvjeet on 17/01/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import "HelpViewController.h"


@interface HelpViewController ()


@end


@implementation HelpViewController


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
    
  //  [self setRequiredFont1];
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


- (IBAction)mailTap
{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
        
        mailComposer.mailComposeDelegate = self;
        
        [mailComposer setToRecipients:[NSArray arrayWithObject:[mailAddressLbl.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]]];
        
        [self presentViewController:mailComposer animated:YES completion:NULL];
    }
    
    else
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"You need to setup an email account on your device in order to send emails." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}


- (IBAction)phoneTap
{
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@", @"8004098078"]]])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@", @"8004098078"]]];
    }
    
    else
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Call facility is not available on your device." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}


#pragma mark - Mail

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    if (result == MFMailComposeResultSent)
    {
        [[[UIAlertView alloc] initWithTitle:@"Sent" message:@"Email has been sent successfully." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    
    else if (result == MFMailComposeResultSaved)
    {
        [[[UIAlertView alloc] initWithTitle:@"Saved" message:@"Mail has been saved successfully." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    
    else if (result == MFMailComposeResultFailed)
    {
        [[[UIAlertView alloc] initWithTitle:@"Failed" message:@"Oops. Email didn't send. Try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    
    else if (result == MFMailComposeResultCancelled)
    {
       
    }
    
    
    [controller dismissViewControllerAnimated:YES completion:NULL];
}



#pragma mark  - Font Settings

- (void)setRequiredFont1
{
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        
        [mailAddressLbl setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:25.00]];

        [phoneNumberLbl setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:25.00]];
        
    }
    else
    {
        [mailAddressLbl setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:18.00]];
        
        [phoneNumberLbl setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:18.00]];
    }
}


@end

