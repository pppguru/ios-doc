//
//  ChangePasswordViewController.m
//  IMYourDoc
//
//  Created by Sarvjeet on 30/01/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import "ChangePasswordViewController.h"
#import "APIManager.h"


@interface ChangePasswordViewController ()
{
    BOOL bool_ChangePwdRetry, bool_ChangePwdFirstTime;
}

@end


@implementation ChangePasswordViewController


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


- (IBAction)savePassword
{
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    
    
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    
    
    if (networkStatus != NotReachable)
    {
        if (oldPassTF.text.length == 0)
        {
            [[[UIAlertView alloc] initWithTitle:nil message:@"Please put in your current password." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        
        else if (newPassTF.text.length == 0)
        {
            [[[UIAlertView alloc] initWithTitle:nil message:@"Please enter new password." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        
        else if (confirmPassTF.text.length == 0)
        {
            [[[UIAlertView alloc] initWithTitle:nil message:@"Please confirm password." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        
        else if (![newPassTF.text isEqualToString:confirmPassTF.text])
        {
            [[[UIAlertView alloc] initWithTitle:nil message:@"Passwords do not match." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        
        else
        {
            NSString *strPass = @"^\(?=.*\\d)\(?=.*[a-z])\(?=.*[A-Z]).{6,}$";
            
            
            NSPredicate *passTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", strPass];
            
            
            if ([passTest evaluateWithObject:newPassTF.text] == NO)
            {
                [[[UIAlertView alloc] initWithTitle:nil message:@"Oops! You forget to create your password. Password must contain at least\n  One upper case letter\n  One lower case letter\n  One digit\n  and be at least 6 characters" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
            
            else
            {
                
                //Check recently used password
                [self checkRecentlyUsedPassword];
                
                
                /*
                bool_ChangePwdFirstTime = YES;
                
                [self savePasswordMethod];
                 */
            }
        }
    }
    
    else
    {
        [AppData showAlertWithTitle:nil andMessage:@"No Connection." inVC:self];
    }
}


- (void)checkRecentlyUsedPassword{
    if ([AppDel appIsDisconnected])
    {
        [AppData showAlertWithTitle:nil andMessage:@"No Connection." inVC:self];
    }
    else
    {
        
        
        NSString *newPassword = newPassTF.text;//[[newPassTF.text dataUsingEncoding:NSUTF8StringEncoding]base64EncodedStringWithOptions:0];
        NSString *oldPassword = [AppData appData].XMPPmyJIDPassword;
        
        NSLog(@"New Password : %@", newPassword);
        NSLog(@"Old Password : %@", oldPassword);
        
        if (![oldPassword isEqualToString:oldPassTF.text]) {
            [[[UIAlertView alloc] initWithTitle:nil message:@"The old password is not correct." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            
            return;
        }
        
        if ([newPassword isEqualToString:oldPassword]) {
            [[[UIAlertView alloc] initWithTitle:nil message:@"The new password cannot be same as the old one." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            
            return;
        }
        
        [AppDel showSpinnerWithText:@"Trying to change the password"];
        
        
        
        LoginRequestModel *loginRequestModel = [LoginRequestModel new];
        loginRequestModel.user_name = [AppData appData].XMPPmyJID;
        loginRequestModel.password = [AppData appData].XMPPmyJIDPassword;
        
        [[APIManager sharedHTTPManager] refreshTokenWithRequestModel:loginRequestModel success:^{
            
            UpdateSecurityRequestModel *requestModel = [UpdateSecurityRequestModel new];
            requestModel.password = newPassword;
            
            [[APIManager sharedJSONManager] updateSecurityRequest:requestModel
                                                      success:^(id response){
                                                          [AppDel hideSpinner];
                                                          
                                                          [[AppData appData] setXMPPmyJIDPassword:newPassTF.text];
                                                          
                                                          [[RDCallbackAlertView alloc] initWithTitle:nil message:@"Your Password is successfully changed!" cancelButtonTitle:nil andCompletionHandler:^(int btnIndex)
                                                           {
                                                               [self.navigationController popViewControllerAnimated:YES];
                                                               
                                                           } otherButtonTitles:@"OK", nil];
                                                          
                                                      } failure:^(NSError *error) {
                                                          [AppDel hideSpinner];
                                                          
                                                          NSHTTPURLResponse *response = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
                                                          NSInteger statusCode = response.statusCode;
                                                          
                                                          NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
                                                          NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
                                                          
                                                          NSString *errMessage = @"Unable to connect to the server, Please try again later.";
                                                          if (statusCode == 422 && serializedData
                                                              && [serializedData objectForKey:@"message"]) {
                                                              errMessage = [serializedData objectForKey:@"message"];
                                                          }
                                                          
                                                          [[[UIAlertView alloc] initWithTitle:nil message:errMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                                                      }];

            
        } failure:^(NSError *error) {
            [AppDel hideSpinner];
            
            [[[UIAlertView alloc] initWithTitle:nil message:@"Unable to connect to the server, Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }];
        
    }
}


- (void)savePasswordMethod
{
    if ([AppDel appIsDisconnected] && bool_ChangePwdFirstTime)
    {
        [AppData showAlertWithTitle:nil andMessage:@"No Connection." inVC:self];
    }
    
    else
    {
        if (bool_ChangePwdRetry && !bool_ChangePwdFirstTime)
        {
            [AppDel showSpinnerWithText:@"Retrying..."];
            
            bool_ChangePwdRetry = NO;
        }
        else
        {
            [AppDel showSpinnerWithText:@"Requesting Change Password"];
            
            bool_ChangePwdRetry = YES;
            
            bool_ChangePwdFirstTime = NO;
        }
        

    
        
        [[oldPassTF.text dataUsingEncoding:NSUTF8StringEncoding]base64EncodedStringWithOptions:0];
        ;
        
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              
                              @"updatePassword", @"method",
                              
                              [[oldPassTF.text dataUsingEncoding:NSUTF8StringEncoding]base64EncodedStringWithOptions:0], @"current_password",
                              
                              [[newPassTF.text dataUsingEncoding:NSUTF8StringEncoding]base64EncodedStringWithOptions:0], @"new_password",
                              
                              [[NSUserDefaults standardUserDefaults] objectForKey:@"loginToken"], @"login_token",
                              
                              nil];
        
        [[WebHelper sharedHelper] setWebHelperDelegate:self];
        
        [[WebHelper sharedHelper]sendRequest:dict tag:S_UpdatePassword delegate:self];
    }
}

#pragma mark - Text Field

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == oldPassTF)
    {
        [newPassTF becomeFirstResponder];
    }
    
    else if (textField == newPassTF)
    {
        NSString *strPass = @"^\(?=.*\\d)\(?=.*[a-z])\(?=.*[A-Z]).{6,}$";
        
        
        NSPredicate *passTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", strPass];
        
        
        if ([passTest evaluateWithObject:newPassTF.text] == NO)
        {
            newPassTF.text = @"";
            
            
            [[[UIAlertView alloc] initWithTitle:nil message:@"Oops! You forget to create your password. Password must contain at least\n  One upper case letter\n  One lower case letter\n  One digit\n  and be at least 6 characters" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        
        else
        {
            [newPassTF resignFirstResponder];
            
            [confirmPassTF becomeFirstResponder];
        }
    }
    
    else if (textField == confirmPassTF)
    {
        [confirmPassTF resignFirstResponder];
    }
    
    
    return YES;
}


#pragma mark - Keyboard Notification

- (void) keyboardWillShow: (NSNotification *) noti
{
    CGRect keyBFrame = [[[noti userInfo] valueForKey:@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    
    
    if (oldPassTF.isEditing)
    {
        keyBoardFrame = [[[noti userInfo] valueForKey:@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
        
        
        if ( (keyBFrame.origin.y) < (oldPassV.frame.origin.y + oldPassV.frame.size.height + 50 + 30))
        {
            TFScroll.contentOffset = CGPointMake(0, (oldPassV.frame.origin.y + oldPassV.frame.size.height + 50 + 30) - (keyBFrame.origin.y));
        }
    }
    
    else if (newPassTF.isEditing)
    {
        if ( (keyBFrame.origin.y) < (newPassV.frame.origin.y + newPassV.frame.size.height + 50 + 30))
        {
            TFScroll.contentOffset = CGPointMake(0, (newPassV.frame.origin.y + newPassV.frame.size.height + 50 + 30) - (keyBFrame.origin.y));
        }
    }
    
    else if (confirmPassTF.isEditing)
    {
        if ( (keyBFrame.origin.y) < (confirmPassV.frame.origin.y + confirmPassV.frame.size.height + 50 + 30))
        {
            TFScroll.contentOffset = CGPointMake(0, (confirmPassV.frame.origin.y + confirmPassV.frame.size.height + 50 + 30) - (keyBFrame.origin.y));
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
        [self.navigationController popViewControllerAnimated:YES];
        

    }
}


#pragma mark - Response

- (void)didReceivedresponse:(NSDictionary *)response
{
    [AppDel hideSpinner];
    
    if ([WebHelper sharedHelper].tag == S_UpdatePassword)
    {
        if ([[response objectForKey:@"err-code"] intValue] == 1)    // Success
        {
            [[AppData appData] setXMPPmyJIDPassword:newPassTF.text];
            
            [[RDCallbackAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] cancelButtonTitle:nil andCompletionHandler:^(int btnIndex)
             
             {
                [self.navigationController popViewControllerAnimated:YES];
                 
             } otherButtonTitles:@"OK", nil];
            
            
        }
        
        else if ([[response objectForKey:@"err-code"] intValue] == 600)    // Session expired
        {
            [AppDel signOutFromAppSilent];
            
            [[RDCallbackAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] cancelButtonTitle:nil andCompletionHandler:^(int btnIndex)
             
             {
                 
                 
             } otherButtonTitles:@"OK", nil];
        }
        
        else if ([[response objectForKey:@"err-code"] intValue] == 300)    // Unable to proceed
        {
            [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        
        else if ([[response objectForKey:@"err-code"] intValue] == 500)    // Duplicate password
        {
            [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        
        else if ([[response objectForKey:@"err-code"] intValue] == 200)    // this password is used by you
        {
            [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        
        else if ([[response objectForKey:@"err-code"] intValue] == 404)    // Invalid old password
        {
            [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }
}


- (void)didFailedWithError: (NSError *) error
{
    [AppDel hideSpinner];
    
    if ([WebHelper sharedHelper].tag == S_UpdatePassword)
    {
        if (bool_ChangePwdRetry)
        {
            [self performSelector:@selector(savePasswordMethod) withObject:nil afterDelay:0.9];
        }
        else
        {
            [[RDCallbackAlertView alloc] initWithTitle:nil message:@"Cannot detect Internet connection" cancelButtonTitle:nil andCompletionHandler:^(int btnIDX)
             {
                 
                 if (btnIDX==0)
                 {
                     bool_ChangePwdRetry = YES;
                     
                     [self savePasswordMethod];
                     
                 }
                 if (btnIDX==1)
                 {
                     bool_ChangePwdRetry = NO;
                     
                     [self.navigationController popViewControllerAnimated:YES];
                 }
                 
             } otherButtonTitles:@"Retry" ,@"Try Later", nil];
            
        }
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Unable to connect to the server, Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}



- (void)setRequiredFont1
{
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [ttitleL setFont:[UIFont fontWithName:@"CentraleSansRndMedium" size:25.00]];
        
        [oldPassTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:25.00]];
        
        [newPassTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:25.00]];
        
        [confirmPassTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:25.00]];
    }
    else
    {
        [ttitleL setFont:[UIFont fontWithName:@"CentraleSansRndMedium" size:20.00]];
        
        [oldPassTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
        
        [newPassTF  setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
        
        [confirmPassTF  setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
    }
}


@end

