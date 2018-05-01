//
//  ForgotPswdStepOneViewController.m
//  IMYourDoc
//
//  Created by Sarvjeet on 02/02/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import "ForgotPswdStepOneViewController.h"
#import "ForgotPswdStepTwoViewController.h"
#import "ForgotPswdStepThreeViewController.h"


@interface ForgotPswdStepOneViewController ()
{
    BOOL bool_Step1Retry, bool_Step1FirstTime;
}

@end


@implementation ForgotPswdStepOneViewController


#pragma mark - View LifeCycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    
    if (self.pwdInfo == nil)
    {
        self.pwdInfo = [NSMutableDictionary dictionary];
    }
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setRequiredFont1];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    
    nameTF.text = [self.pwdInfo objectForKey:@"username"];
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

- (IBAction)next
{
    bool_Step1FirstTime = YES;
    
    [self nextMethod];
}


- (void)nextMethod
{
    if ([self validateData])
    {
        if ([AppDel appIsDisconnected] && bool_Step1FirstTime)
        {
            [AppData showAlertWithTitle:nil andMessage:@"No Connection." inVC:self];
        }
        
        else
        {
       
            
            if (bool_Step1Retry && !bool_Step1FirstTime)
            {
                [AppDel showSpinnerWithText:@"Retrying..."];
                
                bool_Step1Retry = NO;
            }
            else
            {
                [AppDel showSpinnerWithText:@"Requesting..."];
                
                bool_Step1Retry = YES;
                
                bool_Step1FirstTime = NO;
            }

            
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  
                                  @"forgetPasswordStep1", @"method",
                                  
                                  emailTF.text, @"email",
                                  
                                  [nameTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]], @"user_name",
                                  
                                  nil];
            
            
            [[WebHelper sharedHelper] setWebHelperDelegate:self];
            
            [[WebHelper sharedHelper]sendRequest:dict tag:S_ForgotPasswordStep1 delegate:self];
        }
    }
}


- (IBAction)navBack
{
    
    
    nameTF.text = @"";
    
    emailTF.text = @"";
    
    [self.view endEditing:YES];
    
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
    
    if ([WebHelper sharedHelper].tag == S_ForgotPasswordStep1)
    {
        if ([[response objectForKey:@"err-code"] intValue] == 1)    // Success
        {
            ForgotPswdStepTwoViewController *stepTwo = [[ForgotPswdStepTwoViewController alloc] initWithNibName:@"ForgotPswdStepTwoViewController" bundle:nil];
            
            
            stepTwo.pwdInfo = [response mutableCopy];
            
            stepTwo.secQuesStrg = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:[response objectForKey:@"security_question"] options:0] encoding:NSUTF8StringEncoding]];
            
            stepTwo.secAnsStrg = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:[response objectForKey:@"security_answer"] options:0] encoding:NSUTF8StringEncoding]];
            
            
            [stepTwo.pwdInfo setObject:nameTF.text forKey:@"username"];
            
            [self.pwdInfo setObject:nameTF.text forKey:@"username"];
            
            [self.navigationController pushViewController:stepTwo animated:YES];
            
        }
        
        else if ([[response objectForKey:@"err-code"] intValue] == 404)    // Username or email not found
        {
            [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
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
    
    if ([WebHelper sharedHelper].tag == S_ForgotPasswordStep1)
    {
        if (bool_Step1Retry)
        {
            [self performSelector:@selector(nextMethod) withObject:nil afterDelay:0.9];
        }
        else
        {
            [[RDCallbackAlertView alloc] initWithTitle:nil message:@"Cannot detect Internet connection" cancelButtonTitle:nil andCompletionHandler:^(int btnIDX)
             {
                 
                 if (btnIDX==0)
                 {
                     bool_Step1Retry = YES;
                     
                     [self nextMethod];
                     
                 }
                 if (btnIDX==1)
                 {
                     bool_Step1Retry=NO;
                     
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



#pragma mark - TextField

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSString *email = [emailTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString *userName = [nameTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    


    if (textField == nameTF && ([userName isCorrectUserName] || ([userName exactLength] == 0)))
    {
        [emailTF becomeFirstResponder];
    }
    
    else if (textField == nameTF  && !([userName isCorrectUserName]) && !([nameTF.text exactLength] == 0))
    {
        [nameTF becomeFirstResponder];
        
        
        [[[UIAlertView alloc] initWithTitle:nil message:@"Special characters and spaces are not allowed in Username." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }

    
    else if (textField == emailTF && ([email isEmail] || ([email exactLength] == 0)))
    {
        [emailTF resignFirstResponder];
        
        
        TFScroll.contentOffset = CGPointMake(0, 0);
    }
    
    else if (textField == emailTF && !([email isEmail]) && !([emailTF.text isEqualToString:@""]))
    {
        [emailTF becomeFirstResponder];
        
        
        [[[UIAlertView alloc] initWithTitle:nil message:@"Please enter a valid email address." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }

    
    return YES;
}


- (void)textFieldDidEndEditing:(FontTextField *)textField
{
    NSString *email = [emailTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString *userName = [nameTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    
    if (textField == emailTF && !([email isEmail]) && !([emailTF.text isEqualToString:@""]))
    {
        [emailTF becomeFirstResponder];
        
        
        [[[UIAlertView alloc] initWithTitle:nil message:@"Please enter a valid email address." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    
    else if (textField == nameTF  && !([userName isCorrectUserName]) && !([nameTF.text exactLength] == 0))
    {
        [nameTF becomeFirstResponder];
        
        
        [[[UIAlertView alloc] initWithTitle:nil message:@"Special characters and spaces are not allowed in Username." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
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

    
    
    if ([nameTF isFirstResponder])
    {
        tfOffset = [self.view convertRect:nameTF.frame fromView:nameTF.superview].origin.y + nameTF.frame.size.height;
    }
    
    else if ([emailTF isFirstResponder])
    {
        
        tfOffset = [self.view convertRect:emailTF.frame fromView:emailTF.superview].origin.y + emailTF.frame.size.height;
    }
    
    
    tfOffset += TFScroll.contentOffset.y;
    
    
    [TFScroll setContentOffset:CGPointMake(0, (((kbOffset - tfOffset) < 0) ? (tfOffset - kbOffset) : 0)) animated:YES];
}


- (void) keyboardWillHide: (NSNotification *) noti
{
    UIEdgeInsets insets = UIEdgeInsetsMake(TFScroll.contentInset.top, 0, 0, 0);
    
    
    TFScroll.contentInset = insets;
    
    TFScroll.scrollIndicatorInsets = insets;

    
    
    if ([nameTF resignFirstResponder])
    {
        TFScroll.contentOffset = CGPointMake(0, 0);
    }
}


#pragma mark - Void

- (BOOL)validateData
{
    NSString *userName = [nameTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    
    if ([userName isEqualToString:@""])
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Please enter the user name." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        
        
        return NO;
    }
    
    
    if ([userName isCorrectUserName] == NO)
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Special characters and spaces are not allowed in user name." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        
        
        return NO;
    }
    
    
    if ([emailTF.text isEmail] == NO)
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Please enter a valid email address." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        
        
        return NO;
    }
    
    
    return YES;
}



#pragma mark  - Font Settings

- (void)setRequiredFont1
{
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [nameTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:25.00]];
        
        [emailTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:25.00]];
    }
    else
    {
        [nameTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
        
        [emailTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
    }
}



@end

