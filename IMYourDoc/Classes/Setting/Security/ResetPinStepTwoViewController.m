//
//  ResetPinStepTwoVC.m
//  IMYourDoc
//
//  Created by Sarvjeet on 17/03/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import "ResetPinStepTwoViewController.h"


@interface ResetPinStepTwoViewController ()
{
    BOOL bool_ResetPinRetry, bool_ResetPinFirstTime;
}

@end


@implementation ResetPinStepTwoViewController


#pragma mark - View LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    [self setRequiredFont1];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    
    [self numberPadAccessory];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    

}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
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

- (IBAction)saveTap
{
    [self.view endEditing:YES];
    
    
    if (oldPinTF.text.length == 0)
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Please put in your current PIN." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    
    else if (newPinTF.text.length == 0)
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Please enter new PIN." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    
    else if (confirmPinTF.text.length == 0)
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Please confirm PIN." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    
    else if (![newPinTF.text isEqualToString:confirmPinTF.text])
    {
        newPinTF.text = @"";
        
        confirmPinTF.text = @"";
        
        
        [[[UIAlertView alloc] initWithTitle:nil message:@"PIN does not match." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    
    else if ([AppDel appIsDisconnected])
    {
        [AppData showAlertWithTitle:nil andMessage:@"No Connection." inVC:self];
    }
    
    else
    {
        [self saveTapMethod];
    }
}


- (void)saveTapMethod
{
    if (bool_ResetPinRetry && !bool_ResetPinFirstTime)
    {
        [AppDel showSpinnerWithText:@"Retrying..."];
        
        bool_ResetPinRetry = NO;
    }
    else
    {
        [AppDel showSpinnerWithText:@"Changing PIN.."];
        
        bool_ResetPinRetry = YES;
        
        bool_ResetPinFirstTime = NO;
    }
    

 
    
    
    NSDictionary *jsonDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"updatePin",oldPinTF.text,newPinTF.text, [[NSUserDefaults standardUserDefaults] valueForKey:@"AnswerString"],[[NSUserDefaults standardUserDefaults] objectForKey:@"loginToken"],nil] forKeys:[NSArray arrayWithObjects:@"method",@"current_pin",@"new_pin",@"security_ans",@"login_token",nil]];
    
    [[WebHelper sharedHelper] setWebHelperDelegate:self];
    
    [[WebHelper sharedHelper]sendRequest:jsonDict tag: S_UpdatePin delegate:self];

}


#pragma mark - Text Field

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    
    
    if (textField == oldPinTF)
    {
        [newPinTF becomeFirstResponder];
    }
    
    else if (textField == newPinTF)
    {
        [confirmPinTF becomeFirstResponder];
    }
    
    else if (textField == confirmPinTF)
    {
        [confirmPinTF resignFirstResponder];
    }
    
    
    return YES;
}


#pragma mark - Keyboard Notification

- (void) keyboardWillShow: (NSNotification *) noti
{
    float kbOffset = [[[noti userInfo] valueForKey:@"UIKeyboardFrameEndUserInfoKey"] CGRectValue].origin.y;
    
    
    float tfOffset = 0;
    
    
    if (oldPinTF.isEditing)
    {
        tfOffset = [self.view convertRect:oldPinTF.frame fromView:oldPinTF.superview].origin.y + oldPinTF.frame.size.height;
    }
    
    else if (newPinTF.isEditing)
    {
        tfOffset = [self.view convertRect:newPinTF.frame fromView:newPinTF.superview].origin.y + newPinTF.frame.size.height;
    }
    
    else if (confirmPinTF.isEditing)
    {
        tfOffset = [self.view convertRect:confirmPinTF.frame fromView:confirmPinTF.superview].origin.y + confirmPinTF.frame.size.height;
    }
    
    
    tfOffset += TFScroll.contentOffset.y;
    
    
    [TFScroll setContentOffset:CGPointMake(0, (((kbOffset - tfOffset) < 0) ? (tfOffset - kbOffset) : 0)) animated:YES];
}


- (void) keyboardWillHide: (NSNotification *) noti
{
    TFScroll.contentOffset = CGPointMake(0, 0);
}


#pragma mark - Keyboard

- (void)numberPadAccessory
{
    UIToolbar *numberToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    
    numberToolbar.items = [NSArray arrayWithObjects:
                           
                           [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           
                           [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleDone target:self action:@selector(oldPinTFNumberPad)],
                           
                           nil];
    
    
    oldPinTF.inputAccessoryView = numberToolbar;
    
    
    UIToolbar *numberToolbar2 = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    
    numberToolbar2.items = [NSArray arrayWithObjects:
                            
                            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                            
                            [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleDone target:self action:@selector(newPinTFNumberPad)],
                            
                            nil];
    
    
    newPinTF.inputAccessoryView = numberToolbar2;
    
    
    UIToolbar *numberToolbar3 = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    
    numberToolbar3.items = [NSArray arrayWithObjects:
                            
                            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                            
                            [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(confirmPinTFNumberPad)],
                            
                            nil];
    
    
    confirmPinTF.inputAccessoryView = numberToolbar3;
}


- (void)oldPinTFNumberPad
{
    [oldPinTF resignFirstResponder];
    
    [newPinTF becomeFirstResponder];
}


- (void)newPinTFNumberPad
{
    [newPinTF resignFirstResponder];
    
    [confirmPinTF becomeFirstResponder];
}


- (void)confirmPinTFNumberPad
{
    [confirmPinTF resignFirstResponder];
}


#pragma mark - Alert

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popToViewController:[AppDel homeView] animated:YES];
}


#pragma mark - Request

- (void)didReceivedresponse:(NSDictionary *)response
{
    [AppDel hideSpinner];
    
    if ([WebHelper sharedHelper].tag == S_UpdatePin)
    {
        if ([[response objectForKey:@"err-code"] intValue] == 1)    // Success
        {
            [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            [[AppData appData] setUserPIN:[NSString stringWithFormat:@"%@", newPinTF.text]];
        }
        
        else if ([[response objectForKey:@"err-code"] intValue] == 600)    // Session expired
        {[AppDel signOutFromAppSilent];
            [[RDCallbackAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] cancelButtonTitle:nil andCompletionHandler:^(int btnIndex)
             
             {
                 
                 
             } otherButtonTitles:@"OK", nil];
        }
        
        else if ([[response objectForKey:@"err-code"] intValue] == 300)    // Unable to proceed
        {
            [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        else if ([[response objectForKey:@"err-code"] intValue] == 404)    // Unable to proceed
        {
            [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        else if ([[response objectForKey:@"err-code"] intValue] == 500)    // Unable to proceed
        {
            [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        
    }
}
- (void)didFailedWithError: (NSError *) error
{
    [AppDel hideSpinner];
    
    [[[UIAlertView alloc] initWithTitle:nil message:@"Unable to connect to the server, Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}



#pragma mark - Set required font

- (void)setRequiredFont1
{
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [titleL setFont:[UIFont fontWithName:@"CentraleSansRndMedium" size:25.00]];
        
        [oldPinTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:25.00]];
        
        [newPinTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:25.00]];
        
        [confirmPinTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:25.00]];
    }
    else
    {
        [titleL setFont:[UIFont fontWithName:@"CentraleSansRndMedium" size:20.00]];
        
        [oldPinTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
        
        [newPinTF  setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
        
        [confirmPinTF  setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
    }
}


@end

