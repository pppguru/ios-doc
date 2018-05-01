//
//  ChangeEmailViewController.m
//  IMYourDoc
//
//  Created by Sarvjeet on 28/01/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import "ChangeEmailViewController.h"


@interface ChangeEmailViewController ()
{
    BOOL bool_ChangeEmailRetry, bool_ChangeEmailFirstTime;
}

@end


@implementation ChangeEmailViewController


#pragma mark - View LifeCycle

- (void) viewDidLoad
{
    [super viewDidLoad];
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    [self setRequiredFont1];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}


- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    [self setRequiredFont1];
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


- (IBAction)submitTap
{
    bool_ChangeEmailFirstTime = YES;
    
    [self submitTapMethod];
}


- (void)submitTapMethod
{
    NSString *strEmailMatchstring = @"\\b([a-zA-Z0-9%_.+\\-]+)@([a-zA-Z0-9.\\-]+?\\.[a-zA-Z]{2,6})\\b";
    
    
    NSPredicate *emailtest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", strEmailMatchstring];
    
    
    NSString *email = emailTF.text;
    
    
    if ([emailtest evaluateWithObject:email] == NO)
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Please enter a valid email address." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    
    else
    {
        if ([AppDel appIsDisconnected] && bool_ChangeEmailFirstTime)
        {
            [AppData showAlertWithTitle:nil andMessage:@"No Connection." inVC:self];
        }
        
        else if (![emailTF.text isEqualToString:confirmemailTF.text])
        {
            [[[UIAlertView alloc] initWithTitle:nil message:@"Email addresses do not match." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        
        else
        {
      
            
            if (bool_ChangeEmailRetry && !bool_ChangeEmailFirstTime)
            {
                [AppDel showSpinnerWithText:@"Retrying..."];
                
                bool_ChangeEmailRetry = NO;
            }
            else
            {
                [AppDel showSpinnerWithText:@"Requesting..."];
                
                bool_ChangeEmailRetry = YES;
                
                bool_ChangeEmailFirstTime = NO;
            }

            
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  
                                  @"updateEmail", @"method",
                                  
                                  emailTF.text, @"new_email",
                                  
                                  [[NSUserDefaults standardUserDefaults] objectForKey:@"loginToken"], @"login_token",
                                  
                                  nil];
            
            
            [[WebHelper sharedHelper] setWebHelperDelegate:self];
            
            [[WebHelper sharedHelper]sendRequest:dict tag:S_UpdateEmail delegate:self];
        }
    }
}


#pragma mark - TextField

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if (textField == emailTF)
    {
        [emailTF resignFirstResponder];
        
        
        [confirmemailTF becomeFirstResponder];
    }
    
    else if (textField == confirmemailTF)
    {
        [confirmemailTF resignFirstResponder];
    }
		
    return YES;
}


#pragma mark - Keyboard

- (void) keyboardWillShow: (NSNotification *) noti
{
    CGRect keyBFrame = [[[noti userInfo] valueForKey:@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];

    if (emailTF.isEditing)
    {
        if ( (keyBFrame.origin.y) < (emailV.frame.origin.y + emailV.frame.size.height + 50 + 30))
        {
            TFScroll.contentOffset = CGPointMake(0, (emailV.frame.origin.y + emailV.frame.size.height + 50 + 30) - (keyBFrame.origin.y));
        }
    }
    
    else if (confirmemailTF.isEditing)
    {
        if ( (keyBFrame.origin.y) < (confirmEmailV.frame.origin.y + confirmEmailV.frame.size.height + 50 + 30))
        {
            TFScroll.contentOffset = CGPointMake(0, (confirmEmailV.frame.origin.y + confirmEmailV.frame.size.height + 50 + 30) - (keyBFrame.origin.y));
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
    if (alertView.tag == 2)
    {
        [self navBack];
    }
}


#pragma mark - ASIHTTP


- (void)didReceivedresponse:(NSDictionary *)response
{
    [AppDel hideSpinner];
    
    if ([WebHelper sharedHelper].tag == S_UpdateEmail)
    {
        if ([[response objectForKey:@"err-code"] intValue] == 1)    // Success
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            alert.tag = 2;
            
            [alert show];
        }
        
        else if ([[response objectForKey:@"err-code"] intValue] == 600)    // Session expired
        { [AppDel signOutFromAppSilent];
            [[RDCallbackAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] cancelButtonTitle:nil andCompletionHandler:^(int btnIndex)
             
             {
                
                 
             } otherButtonTitles:@"OK", nil];
        }
        
        else if ([[response objectForKey:@"err-code"] intValue] == 300)    // Unable to proceed
        {
            [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }
}


- (void)didFailedWithError: (NSError *) error
{
    [AppDel hideSpinner];
    
    if ([WebHelper sharedHelper].tag == S_UpdateEmail)
    {
        if (bool_ChangeEmailRetry)
        {
            [self performSelector:@selector(submitTapMethod) withObject:nil afterDelay:0.9];
        }
        else
        {
            [[RDCallbackAlertView alloc] initWithTitle:nil message:@"Cannot detect Internet connection" cancelButtonTitle:nil andCompletionHandler:^(int btnIDX)
             {
                 
                 if (btnIDX==0)
                 {
                     bool_ChangeEmailRetry = YES;
                     
                     [self submitTapMethod];
                     
                 }
                 if (btnIDX==1)
                 {
                     bool_ChangeEmailRetry = NO;
                     
                     [self.navigationController popViewControllerAnimated: YES];
                 }
                 
             } otherButtonTitles:@"Retry" ,@"Try Later", nil];
            
        }
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Unable to connect to the server, Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}



#pragma mark - Set required font

- (void)setRequiredFont1
{
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [emailTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:25.00]];
        
        [confirmemailTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:25.00]];
    }
    else
    {
        [emailTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
        
        [confirmemailTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
    }
}

@end

