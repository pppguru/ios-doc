//
//  ForgotPswdStepThreeViewController.m
//  IMYourDoc
//
//  Created by Sarvjeet on 02/02/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import "LoginViewController.h"
#import "AccountConfigViewController.h"
#import "ForgotPswdStepOneViewController.h"
#import "ForgotPswdStepThreeViewController.h"




@interface ForgotPswdStepThreeViewController ()
{
    BOOL bool_Step2Retry, bool_Step2FirstTime;
}

@end


@implementation ForgotPswdStepThreeViewController


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

- (IBAction)submit
{
    bool_Step2FirstTime = YES;
    
    [self submitMethod];
    
}


- (void)submitMethod
{
    if ([self validateData])
    {
        
        if ([AppDel appIsDisconnected]  && bool_Step2Retry)
        {
            [AppData showAlertWithTitle:nil andMessage:@"No Connection." inVC:self];
        }
        
        else
        {

            
            if (bool_Step2Retry && !bool_Step2FirstTime)
            {
                [AppDel showSpinnerWithText:@"Retrying..."];
                
                bool_Step2Retry = NO;
            }
            else
            {
                [AppDel showSpinnerWithText:@"Requesting Forgot Password"];
                
                bool_Step2Retry = YES;
                
                bool_Step2FirstTime = NO;
            }
            
            
            NSData *dataTake2 = [newPwdTF.text dataUsingEncoding:NSUTF8StringEncoding];
        
            NSData *base64Data = [dataTake2 base64EncodedDataWithOptions:0];

            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  
                                  @"forgetPasswordStep2", @"method",
                                  
                                  [[NSString alloc] initWithData:base64Data encoding:NSUTF8StringEncoding], @"password",
                                  
                                  [self.pwdInfo objectForKey:@"uid"], @"uid",
                                  
                                  nil];
            
            
            [[WebHelper sharedHelper] setWebHelperDelegate:self];
            
            [[WebHelper sharedHelper]sendRequest:dict tag:S_ForgotPasswordStep2 delegate:self];
            
        }
    }
}



- (IBAction)navBack
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)step1Method
{
    
}


- (IBAction)step2Method
{
    
}


- (IBAction)step3Method
{
    
}


#pragma mark - Service Response

- (void)didReceivedresponse:(NSDictionary *)response
{
    [AppDel hideSpinner];
    
    if ([WebHelper sharedHelper].tag == S_ForgotPasswordStep2)
    {
        if ([[response objectForKey:@"err-code"] intValue] == 1)    // Success
        {
            [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        
        else if ([[response objectForKey:@"err-code"] intValue] == 500)    // Duplicate password
        {
            [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        
        else if ([[response objectForKey:@"err-code"] intValue] == 300)    // Unable to proceed
        {
            [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }
    
    else if ([WebHelper sharedHelper].tag == S_Login)
    {
        if ([[response objectForKey:@"err-code"] intValue] == 1)    // Login
        {
            [AppDel hideSpinner];
            
            //Store the user credentials
            [[AppData appData] setXMPPmyJID:[self.pwdInfo objectForKey:@"username"]];
            [[AppData appData] setXMPPmyJIDPassword:newPwdTF.text];
            
            //Try to login
            [AppData loginWithResponseJSON:response withNavController:self.navigationController];
            
        }
        
        //else if ([[response objectForKey:@"err-code"] intValue] == 300)     // Device Blocked
        
        else if ([[response objectForKey:@"err-code"] intValue] == 700)       // Login Failed
        {
            [AppDel hideSpinner];
            
            if (!(AppDel).loginUserName)
            {
                (AppDel).loginFailCount++;
                
                
                (AppDel).loginUserName = [[[self.pwdInfo objectForKey:@"username"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
                
                
                [AppDel hideSpinner];
                
                
                [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                
                
                return;
            }
            
            else if ([[[[self.pwdInfo objectForKey:@"username"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString] isEqualToString:(AppDel).loginUserName])
            {
                (AppDel).loginFailCount++;
            }
            
            else
            {
                (AppDel).loginFailCount = 1;
                
                (AppDel).loginUserName = [[[self.pwdInfo objectForKey:@"username"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
            }
            
            
            
            if ((AppDel).loginFailCount == 2)
            {
                [AppDel hideSpinner];
                
                [[[UIAlertView alloc] initWithTitle:nil message:@"You have the last login chance, Please fill correct credentials else your device will get blocked." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                
                return;
            }
            
            else if ((AppDel).loginFailCount == 3)
            {
                return;
            }
            
            [AppDel hideSpinner];
            
            [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        
        //else if ([[response objectForKey:@"err-code"] intValue] == 400)    // User blocked
        
        //else if ([[response objectForKey:@"err-code"] intValue] == 404)    // User name not found
        
        else
        {
            [AppDel hideSpinner];
            
            [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        
    }
}


- (void)didFailedWithError: (NSError *) error
{
    [AppDel hideSpinner];
    
    if ([WebHelper sharedHelper].tag == S_ForgotPasswordStep2)
    {
        if (bool_Step2Retry)
        {
            [self performSelector:@selector(submitMethod) withObject:nil afterDelay:0.9];
        }
        else
        {
            [[RDCallbackAlertView alloc] initWithTitle:nil message:@"Cannot detect Internet connection" cancelButtonTitle:nil andCompletionHandler:^(int btnIDX)
             {
                 
                 if (btnIDX==0)
                 {
                     bool_Step2Retry = YES;
                     
                     [self submitMethod];
                     
                 }
                 if (btnIDX==1)
                 {
                     bool_Step2Retry = NO;
                 }
                 
             } otherButtonTitles:@"Retry" ,@"Try Later", nil];
            
        }
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Unable to connect to the server, Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}


#pragma mark - Alert

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([AppDel appIsDisconnected])
    {
        [AppData showAlertWithTitle:nil andMessage:@"No Connection." inVC:self];
    }
    
    else
    {
                
        NSDictionary *dict ;
        
        dict = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:@"login", [[[self.pwdInfo objectForKey:@"username"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString], newPwdTF.text, [[NSUserDefaults standardUserDefaults] stringForKey:@"openUUID"], @"IOS", [[NSUserDefaults standardUserDefaults] stringForKey:@"deviceToken"],nil] forKeys:[NSArray arrayWithObjects:@"method", @"user_name", @"password", @"device_id", @"device_type", @"device_token",nil]];
        
        
  
        
        [[WebHelper sharedHelper] setWebHelperDelegate:self];
        
        [[WebHelper sharedHelper] sendRequest:dict tag:S_Login delegate:self];
    }
}


#pragma mark - TextField

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
  //  [self.view endEditing:YES];
    
    
    if (textField == newPwdTF && ([newPwdTF.text isCorrectPassword] || ([newPwdTF.text exactLength] == 0)))
    {
        [confirmPwdTF becomeFirstResponder];
    }
    
    else if (textField == newPwdTF && !([newPwdTF.text isCorrectPassword]) && !([newPwdTF.text exactLength] == 0))
    {
        [newPwdTF becomeFirstResponder];
        
        
        [[[UIAlertView alloc] initWithTitle:nil message:@"Oops! You forget to create your password. Password must contain at least\n  One upper case letter\n  One lower case letter\n  One digit\n  and be at least 6 characters" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }

    
    else if (textField == confirmPwdTF && ([confirmPwdTF.text isEqualToString:newPwdTF.text] || ([confirmPwdTF.text exactLength] == 0)))
    {
        [confirmPwdTF resignFirstResponder];
    }
    
    else if (textField == confirmPwdTF && !([confirmPwdTF.text isEqualToString:newPwdTF.text]) && !([confirmPwdTF.text exactLength] == 0))
    {
        [confirmPwdTF becomeFirstResponder];
        
        
        [[[UIAlertView alloc] initWithTitle:nil message:@"Oops! Passwords do not match. Try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }

    
    return YES;
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == newPwdTF && !([newPwdTF.text isCorrectPassword]) && !([newPwdTF.text exactLength] == 0))
    {
        [newPwdTF becomeFirstResponder];
        
        
        [[[UIAlertView alloc] initWithTitle:nil message:@"Oops! You forget to create your password. Password must contain at least\n  One upper case letter\n  One lower case letter\n  One digit\n  and be at least 6 characters" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    
    else if (textField == confirmPwdTF && !([confirmPwdTF.text isEqualToString:newPwdTF.text]) && !([confirmPwdTF.text exactLength] == 0))
    {
        [confirmPwdTF becomeFirstResponder];
        
        
        [[[UIAlertView alloc] initWithTitle:nil message:@"Oops! Passwords do not match. Try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}


#pragma mark - keyboard notification

- (void) keyboardWillShow: (NSNotification *) noti
{
    float kbOffset = [[[noti userInfo] valueForKey:@"UIKeyboardFrameEndUserInfoKey"] CGRectValue].origin.y;
    
    
    float tfOffset = 0;
    
    
    CGRect keyBRect = [[[noti userInfo] valueForKey:@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    
    
    UIEdgeInsets insets = UIEdgeInsetsMake(TFScroll.contentInset.top, 0, keyBRect.size.height/1.5, 0);
    
    
    TFScroll.contentInset = insets;
    
    TFScroll.scrollIndicatorInsets = insets;

    
    
    
    if (newPwdTF.isEditing)
    {
        tfOffset = [self.view convertRect:newPwdTF.frame fromView:newPwdTF.superview].origin.y + newPwdTF.frame.size.height;
    }
    
    else if (confirmPwdTF.isEditing)
    {
        tfOffset = [self.view convertRect:confirmPwdTF.frame fromView:confirmPwdTF.superview].origin.y + confirmPwdTF.frame.size.height;
    }

    
    tfOffset += TFScroll.contentOffset.y;
    
    
    [TFScroll setContentOffset:CGPointMake(0, (((kbOffset - tfOffset) < 0) ? (tfOffset - kbOffset) : 0)) animated:YES];
}


- (void) keyboardWillHide: (NSNotification *) noti
{
    UIEdgeInsets insets = UIEdgeInsetsMake(TFScroll.contentInset.top, 0, 0, 0);
    
    
    TFScroll.contentInset = insets;
    
    TFScroll.scrollIndicatorInsets = insets;

    
    TFScroll.contentOffset = CGPointMake(0, 0);
}


#pragma mark - Void

- (BOOL)validateData
{
    if ([newPwdTF.text isCorrectPassword] == NO)
    {
    
        
        
        [[RDCallbackAlertView alloc] initWithTitle:nil message:@"Oops! You forget to create your password. Password must contain at least\n  One upper case letter\n  One lower case letter\n  One digit\n  and be at least 6 characters"cancelButtonTitle:nil andCompletionHandler:^(int btnIndex)
         
         {
             [newPwdTF becomeFirstResponder];
             
         } otherButtonTitles:@"OK", nil];
        
        
        
        
        
        return NO;
    }
    
    
    if ([newPwdTF.text isEqualToString:confirmPwdTF.text] == NO)
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Oops! Passwords do not match. Try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        
        return NO;
    }
    
    
    return YES;
}
    


- (void)setRequiredFont1
{
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [newPwdTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:25.00]];
        
        [confirmPwdTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:25.00]];
    }
    else
    {
        [newPwdTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
        
        [confirmPwdTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
        
    }
}


@end

