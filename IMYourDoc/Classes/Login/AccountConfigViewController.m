//
//  TempPasswordViewController.m
//  IMYourDoc
//
//  Created by Sarvjeet on 13/03/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import "AccountConfigViewController.h"
#import "AccountConfigServiceAgreementViewOneController.h"


@interface AccountConfigViewController ()


@end


@implementation AccountConfigViewController


#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    TFScroll.contentSize = CGSizeMake(TFScroll.frame.size.width, 550);
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

- (IBAction)submitTap
{
    if ([self validateData])
    {
        if ([AppDel appIsDisconnected])
        {
            [AppData showAlertWithTitle:nil andMessage:@"No Connection." inVC:self];
        }
        
        else
        {
            //[AppDel showSpinnerWithText:@"Checking account.."];
            
            self.dataDict = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:
                                                          @"configureProfile",
                                                          pwdTF.text,
                                                          pinTF.text,
                                                          [securityQuesTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]],
                                                          [securityAnsTF.text stringByTrimmingCharactersInSet:
                                                           [NSCharacterSet whitespaceAndNewlineCharacterSet]],
                                                          [AppData appData].XMPPmyJID, nil]
                                                 forKeys:[NSArray arrayWithObjects:
                                                          @"method",
                                                          @"password",
                                                          @"user_pin",
                                                          @"security_qus",
                                                          @"security_ans",
                                                          @"user_name", nil]];
            
            AccountConfigServiceAgreementViewOneController *acsa1VC = [[AccountConfigServiceAgreementViewOneController alloc] initWithNibName:@"AccountConfigServiceAgreementViewOneController" bundle:nil];
            
            acsa1VC.dataDict = self.dataDict;
            
            [self.navigationController pushViewController:acsa1VC animated:YES];
        }
        
    }
}

#pragma mark - TextField

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == pwdTF)
    {
        [confirmPwdTF becomeFirstResponder];
    }
    
    else if (textField == confirmPwdTF)
    {
        [pinTF becomeFirstResponder];
    }
    
    else if (textField == pinTF)
    {
        [confirmPinTF becomeFirstResponder];
    }
    
    else if (textField == confirmPinTF)
    {
        [securityQuesTF becomeFirstResponder];
    }
    
    else if (textField == securityQuesTF)
    {
        [securityAnsTF becomeFirstResponder];
    }
    
    else if (textField == securityAnsTF)
    {
        [securityAnsTF resignFirstResponder];
    }
    
    
    return YES;
}


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    float tfOffset = [self.view convertRect:textField.frame fromView:textField.superview].origin.y + textField.frame.size.height;
    
    tfOffset += TFScroll.contentOffset.y;
    
    
    float kbOffset = keyBRect.origin.y;
    
    
    [TFScroll setContentOffset:CGPointMake(0, (((kbOffset - tfOffset) < 0) ? (tfOffset - kbOffset) : 0)) animated:YES];
    
    
    
    if (textField == pwdTF && ([pwdTF.text exactLength] == 0))
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Password must be 6 or more characters and contain at least\n - One upper case letter\n - One lower case letter\n - One digit\n" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == pwdTF)
    {
        if (([pwdTF.text exactLength] > 0) && ![pwdTF.text isCorrectPassword])
        {
            [[[UIAlertView alloc] initWithTitle:nil message:@"Oops! You forgot to create your password. Password must be 6 or more characters and contain at least\n - One upper case letter\n - One lower case letter\n - One digit\n" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            
            
            pwdTF.text = @"";
            
            confirmPwdTF.text = @"";
        }
    }
    
    else if (textField == confirmPwdTF)
    {
        if (([pwdTF.text exactLength] > 0) && ([confirmPwdTF.text exactLength] > 0) && ([confirmPwdTF.text isEqualToString:pwdTF.text] == NO))
        {
            [[[UIAlertView alloc] initWithTitle:nil message:@"Oops! Passwords do not match. Try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            
            
            confirmPwdTF.text = @"";
        }
    }
    
    else if (textField == pinTF)
    {
        if (([pinTF.text exactLength] > 0) && ([pinTF.text exactLength] != 4))
        {
            [[[UIAlertView alloc] initWithTitle:nil message:@"Oops! PIN should be 4 digits." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            
            
            pinTF.text = @"";
            
            confirmPinTF.text = @"";
        }
    }
    
    else if (textField == confirmPinTF)
    {
        if (([pinTF.text exactLength] > 0) && ([confirmPinTF.text exactLength] > 0) && ([confirmPinTF.text isEqualToString:pinTF.text] == NO))
        {
            [[[UIAlertView alloc] initWithTitle:nil message:@"Oops! PIN does not match. Try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            
            
            confirmPinTF.text = @"";
        }
    }
}


#pragma mark - keyboard notification

- (void) keyboardWillShow: (NSNotification *) noti
{
    keyBRect = [[[noti userInfo] valueForKey:@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    
    
    NSDictionary *info = [noti userInfo];
    
    
    keyBRect = [info[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    
    UIEdgeInsets insets = UIEdgeInsetsMake(TFScroll.contentInset.top, 0, keyBRect.size.height, 0);
    
    
    TFScroll.contentInset = insets;
    
    TFScroll.scrollIndicatorInsets = insets;

    
    UITextField *textField;
    
    
    for (UIView *subV in TFScroll.subviews)
    {
        if ([subV isKindOfClass:[UITextField class]])
        {
            UITextField *demoTF = (UITextField *)subV;
            
            
            if (demoTF.isEditing)
            {
                textField = demoTF;
            }
        }
    }
    
    
    float tfOffset = [self.view convertRect:textField.frame fromView:textField.superview].origin.y + textField.frame.size.height;
    
    tfOffset += TFScroll.contentOffset.y;
    
    
    float kbOffset = keyBRect.origin.y;
    
    
    [TFScroll setContentOffset:CGPointMake(0, (((kbOffset - tfOffset) < 0) ? (tfOffset - kbOffset) : 0)) animated:YES];
}


- (void) keyboardWillHide: (NSNotification *) noti
{
    UIEdgeInsets insets = UIEdgeInsetsMake(TFScroll.contentInset.top, 0, 0, 0);
    
    
    TFScroll.contentInset = insets;
    
    TFScroll.scrollIndicatorInsets = insets;

    TFScroll.contentOffset = CGPointMake(0, 0);
}


#pragma mark - Keyboard

- (void)numberPadAccessory
{
    UIToolbar *numberToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    
    numberToolbar.items = [NSArray arrayWithObjects:
                           
                           [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           
                           [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleDone target:self action:@selector(pinTFNumberPad)],
                           
                           nil];
    
    
    pinTF.inputAccessoryView = numberToolbar;
    
    
    UIToolbar *numberToolbar2 = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    
    numberToolbar2.items = [NSArray arrayWithObjects:
                            
                            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                            
                            [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleDone target:self action:@selector(confirmPinTFNumberPad)],
                            
                            nil];
    
    
    confirmPinTF.inputAccessoryView = numberToolbar2;
}


- (void)pinTFNumberPad
{
    [confirmPinTF becomeFirstResponder];
}


- (void)confirmPinTFNumberPad
{
    [securityQuesTF becomeFirstResponder];
}


#pragma mark - Validate

- (BOOL)validateData
{
    if (([pwdTF.text exactLength] == 0) || ([confirmPwdTF.text exactLength] == 0) || ([securityAnsTF.text exactLength] == 0) || ([pinTF.text exactLength] == 0) || ([confirmPinTF.text exactLength] == 0))
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"All fields are mandatory." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        
        
        return NO;
    }
    
    
    if ([confirmPwdTF.text isEqualToString:pwdTF.text] == NO)
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Oops! Passwords do not match. Try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        
        
        pwdTF.text = @"";
        
        confirmPwdTF.text = @"";
        
        
        return NO;
    }
    
    
    if ([pinTF.text exactLength] != 4)
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Oops! PIN should be 4 digits." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        
        
        pinTF.text = @"";
        
        
        return NO;
    }
    
    
    if ([confirmPinTF.text isEqualToString:pinTF.text] == NO)
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Oops! PIN does not match. Try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        
        
        pinTF.text = @"";
        
        confirmPinTF.text = @"";
        
        
        return NO;
    }

    
    if ([pwdTF.text isCorrectPassword] == NO)
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Oops! You forget to create your password. Password must contain at least\n  One upper case letter\n  One lower case letter\n  One digit\n  and be at least 6 characters" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        
        
        pwdTF.text = @"";
        
        
        return NO;
    }
    
    
    return YES;
}


#pragma mark - Set Required Fonts


- (void)setRequiredFont1
{
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [titleLbl setFont:[UIFont fontWithName:@"CentraleSansRndMedium" size:25.00]];
        
        [pwdTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:25.00]];

        [confirmPwdTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:25.00]];
        
        [pinTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:25.00]];

        [confirmPinTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:25.00]];

        [securityQuesTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:25.00]];

        [securityAnsTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:25.00]];
    }
    else
    {
        [titleLbl setFont:[UIFont fontWithName:@"CentraleSansRndMedium" size:20.00]];
        
        [pwdTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
        
        [confirmPwdTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
        
        [pinTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
        
        [confirmPinTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
        
        [securityQuesTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
        
        [securityAnsTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
    }
}


@end

