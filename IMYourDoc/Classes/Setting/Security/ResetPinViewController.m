//
//  ResetPasswordViewController.m
//  IMYourDoc
//
//  Created by Sarvjeet on 30/01/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import "ResetPinViewController.h"


@interface ResetPinViewController ()


@end


@implementation ResetPinViewController


#pragma mark - View LifeCycle

- (void) viewDidLoad
{
    [super viewDidLoad];
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    [self setRequiredFont1];
    
    secQuesLbl.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"QuestionString"];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}


- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    

}


- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
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


- (IBAction)forwardTap
{
    if ([secAnsTF.text exactLength] == 0)
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Please enter security answer." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    
    else if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"AnswerString"] isEqualToString:[secAnsTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]])
    {
        ResetPinStepTwoViewController *rp2 = [[ResetPinStepTwoViewController alloc] initWithNibName:@"ResetPinStepTwoViewController" bundle:nil];
        
        [self.navigationController pushViewController:rp2 animated:YES];
    }
    
    else
    {
        [[[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"Please enter the correct security answer."] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}


- (IBAction)confirmPass
{
    if (secAnsTF.text.length == 0)
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Please enter security answer." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    
    else
    {
        if ([AppDel appIsDisconnected])
        {
            [AppData showAlertWithTitle:nil andMessage:@"No Connection." inVC:self];
        }
        
        else
        {
            [AppDel showSpinnerWithText:@"Requesting..."];
            
            
            [self.view endEditing:YES];
            
            
            [TFScroll setContentOffset:CGPointMake(0, 0) animated:YES];
            
            
            NSURL *url = [NSURL URLWithString:[IMYourDocAPIGeneratorClass resetPINURL]];
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
            [request setRequestMethod:@"POST"];
            [request addRequestHeader:@"Connection" value:@"close"];
            [request addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
            NSString *postContentString = [IMYourDocAPIGeneratorClass selfStringGeneratorRESETPIN:[AppData appData].XMPPmyJID withSecurityAnswer:secAnsTF.text];
            NSMutableData *postContentData = [NSMutableData dataWithBytes:[postContentString UTF8String] length:[postContentString length]];
            [request setPostBody:postContentData];
            [request setValidatesSecureCertificate:NO];
            [request setDelegate:self];
            [request startAsynchronous];
        }
    }
}


#pragma mark - TextField

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [secAnsTF resignFirstResponder];
    
    
    return YES;
}


#pragma mark - keyboard notification

- (void) keyboardWillShow: (NSNotification *) noti
{
    CGRect keyBFrame = [[[noti userInfo] valueForKey:@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    
    if (secAnsTF.isEditing)
    {
        if ( (keyBFrame.origin.y) < (secAnsV.frame.origin.y + secAnsV.frame.size.height + 50 + 30))
        {
            TFScroll.contentOffset = CGPointMake(0, (secAnsV.frame.origin.y + secAnsV.frame.size.height + 50 + 30) - (keyBFrame.origin.y));
        }
    }
}


- (void) keyboardWillHide: (NSNotification *) noti
{
    TFScroll.contentOffset = CGPointMake(0, 0);
}


#pragma mark - Alert View

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1)
    {
        [AppDel setLoginType:0];
        
        
        [AppDel signOutFromAppSilent];
    }
}


#pragma mark - ASIHTTP

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSString *trimmedString = [[[request responseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] mutableCopy];
    
    
    NSRange range = [trimmedString rangeOfString:@"Pin Reset Successfully. An Email has been sent to your regestered Email Address." options:NSCaseInsensitiveSearch];
    
    
    [AppDel hideSpinner];
    
    
    if (range.location == NSNotFound)
    {
        [[[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"Please enter the correct security answer."] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    
    else
    {
        
        UIAlertView *pinAlert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"%@.", trimmedString] delegate:self cancelButtonTitle:@"Logout" otherButtonTitles:nil];
        
        pinAlert.tag = 1;
        
        [pinAlert show];
    }
}


- (void)requestFailed:(ASIHTTPRequest *)request
{
    [AppDel hideSpinner];
    
    
    [[[UIAlertView alloc] initWithTitle:nil message:@"Unable to process your request. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}


- (void)setRequiredFont1
{
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [titleL setFont:[UIFont fontWithName:@"CentraleSansRndMedium" size:25.00]];
        
        [secQuesL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:25.00]];
        
        [secQuesLbl setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:25.00]];
        
        [secAnsTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:25.00]];
    }
    else
    {
        [titleL setFont:[UIFont fontWithName:@"CentraleSansRndMedium" size:20.00]];
        
        [secQuesL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
        
        [secQuesLbl  setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
        
        [secAnsTF  setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
    }
}


@end

