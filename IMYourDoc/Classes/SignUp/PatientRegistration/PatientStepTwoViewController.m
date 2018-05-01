//
//  SignupStepTwoViewController.m
//  IMYourDoc
//
//  Created by Sarvjeet on 21/01/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import "PatientStepTwoViewController.h"
#import "PatientStepThreeViewController.h"


@interface PatientStepTwoViewController ()


@end


@implementation PatientStepTwoViewController


#pragma mark - View LifeCycle

- (void) viewDidLoad
{
    [super viewDidLoad];
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    [self setRequiredFont2];
    
    passwordTF.text = [self.userInfo objectForKey:@"password"];
    
    confirmPassTF.text = [self.userInfo objectForKey:@"password"];
    
    securityQuesTF.text = [self.userInfo objectForKey:@"securityQuestion"];
    
    securityAnsTF.text = [self.userInfo objectForKey:@"securityAnswer"];
    
    
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
    [self.userInfo setObject:(passwordTF.text.length > 0 ? passwordTF.text : @"") forKey:@"password"];
    
    [self.userInfo setObject:(securityQuesTF.text.length > 0 ? securityQuesTF.text : @"") forKey:@"securityQuestion"];
    
    [self.userInfo setObject:(securityAnsTF.text.length > 0 ? securityAnsTF.text : @"") forKey:@"securityAnswer"];

    
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)navForward
{
    if (([passwordTF.text exactLength] == 0) || ([confirmPassTF.text exactLength] == 0) || ([securityQuesTF.text exactLength] == 0) || ([securityAnsTF.text exactLength] == 0))
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"All fields are mandatory in Step 2." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        
        
        return;
    }
    
    
    if ([confirmPassTF.text isEqualToString:passwordTF.text] == NO)
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Oops! Passwords do not match. Try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        
        
        return;
    }
    
    
    if ([passwordTF.text isCorrectPassword] == NO)
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Oops! You forget to create your password. Password must contain at least\n  One upper case letter\n  One lower case letter\n  One digit\n  and be at least 6 characters" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        
        
        return;
    }
    
    
    [self.userInfo setObject:passwordTF.text forKey:@"password"];
    
    [self.userInfo setObject:securityQuesTF.text forKey:@"securityQuestion"];
    
    [self.userInfo setObject:securityAnsTF.text forKey:@"securityAnswer"];
    
    
    
    
    [self.view endEditing:YES];
    
    UIEdgeInsets insets = UIEdgeInsetsMake(TFScroll.contentInset.top, 0, 0, 0);
    
    
    TFScroll.contentInset = insets;
    
    TFScroll.scrollIndicatorInsets = insets;
    
    TFScroll.contentOffset = CGPointMake(TFScroll.frame.origin.x, 0);

    
    PatientStepThreeViewController *signupThreeVC = [[PatientStepThreeViewController alloc] initWithNibName:@"PatientStepThreeViewController" bundle:nil];
    
    signupThreeVC.registrationType = self.registrationType;
    
    signupThreeVC.userInfo = self.userInfo;
    
    [self.navigationController pushViewController:signupThreeVC animated:YES];
}


#pragma mark - TextField


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == passwordTF && ([passwordTF.text exactLength] == 0))
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Password must contain at least\n  One upper case letter\n  One lower case letter\n  One digit\n  and be at least 6 characters" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    if (textField == passwordTF && ([passwordTF.text exactLength] == 0))
    {
        [passwordTF becomeFirstResponder];

        [[[UIAlertView alloc] initWithTitle:nil message:@"Oops! You forget to create your password. Password must contain at least\n  One upper case letter\n  One lower case letter\n  One digit\n  and be at least 6 characters" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    
    else if (textField == passwordTF && [passwordTF.text isCorrectPassword])
    {
        [confirmPassTF becomeFirstResponder];
    }
    
    else if (textField == passwordTF && !([passwordTF.text isCorrectPassword]) && !([passwordTF.text exactLength] == 0))
    {
        [passwordTF becomeFirstResponder];
        
        
        [[[UIAlertView alloc] initWithTitle:nil message:@"Password must contain at least\n  One upper case letter\n  One lower case letter\n  One digit\n  and be at least 6 characters" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    
    
   
    
    else if (textField == confirmPassTF && ([confirmPassTF.text isEqualToString:passwordTF.text] || ([confirmPassTF.text exactLength] == 0)))
    {
        [securityQuesTF becomeFirstResponder];
    }
    
    else if (textField == confirmPassTF && !([confirmPassTF.text isEqualToString:passwordTF.text]) && !([confirmPassTF.text exactLength] == 0))
    {
        [confirmPassTF becomeFirstResponder];
        
        
        [[[UIAlertView alloc] initWithTitle:nil message:@"Oops! Passwords do not match. Try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
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


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == passwordTF && !([passwordTF.text isCorrectPassword]) && !([passwordTF.text exactLength] == 0))
    {
        [passwordTF becomeFirstResponder];
        
        
        [[[UIAlertView alloc] initWithTitle:nil message:@"Oops! You forget to create your password. Password must contain at least\n  One upper case letter\n  One lower case letter\n  One digit\n  and be at least 6 characters" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    
    else if (textField == confirmPassTF && !([confirmPassTF.text isEqualToString:passwordTF.text]) && !([confirmPassTF.text exactLength] == 0))
    {
        [confirmPassTF becomeFirstResponder];
        
        
        [[[UIAlertView alloc] initWithTitle:nil message:@"Oops! Passwords do not match. Try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}


#pragma mark - keyboard notification

- (void) keyboardWillShow: (NSNotification *) noti
{
    
    NSDictionary *info = [noti userInfo];
    
    CGRect keyBRect = [info[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    
    UIEdgeInsets insets = UIEdgeInsetsMake(TFScroll.contentInset.top, 0, keyBRect.size.height / 1.4 , 0);
    
    TFScroll.contentInset = insets;
    
    TFScroll.scrollIndicatorInsets = insets;
    
    
    float tfOffset ;
    
    
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
    
    
    
    if (textField == passwordTF)
    {
        tfOffset = TFScroll.frame.origin.y + pwdV.frame.origin.y + pwdV.frame.size.height ;
        
        
        if ((keyBRect.origin.y - tfOffset) < 0)
        {
            CGFloat y = (tfOffset - keyBRect.origin.y);
            
            TFScroll.contentOffset = CGPointMake(TFScroll.frame.origin.x, y);
        }
        
    }
    
    if (textField == confirmPassTF)
    {
        tfOffset = TFScroll.frame.origin.y + confirmPwdV.frame.origin.y + confirmPwdV.frame.size.height ;
        
        
        if ((keyBRect.origin.y - tfOffset) < 0)
        {
            CGFloat y = (tfOffset - keyBRect.origin.y);
            
            TFScroll.contentOffset = CGPointMake(TFScroll.frame.origin.x, y);
        }
        
    }
    
    
    if (textField == securityQuesTF)
    {
        tfOffset = TFScroll.frame.origin.y + secQuesV.frame.origin.y + secQuesV.frame.size.height ;
        
        if ((keyBRect.origin.y - tfOffset) < 0)
        {
            CGFloat y = (tfOffset - keyBRect.origin.y);
            
            TFScroll.contentOffset = CGPointMake(TFScroll.frame.origin.x, y);
        }
        
    }
    
    if (textField == securityAnsTF)
    {
        tfOffset = TFScroll.frame.origin.y + secAnsV.frame.origin.y + secAnsV.frame.size.height ;
        
        if ((keyBRect.origin.y - tfOffset) < 0)
        {
            CGFloat y = (tfOffset - keyBRect.origin.y);
            
            TFScroll.contentOffset = CGPointMake(TFScroll.frame.origin.x, y);
        }
        
    }
}


- (void) keyboardWillHide: (NSNotification *) noti
{
    UIEdgeInsets insets = UIEdgeInsetsMake(TFScroll.contentInset.top, 0, 0, 0);
    
    
    TFScroll.contentInset = insets;
    
    TFScroll.scrollIndicatorInsets = insets;
    
    TFScroll.contentOffset = CGPointMake(TFScroll.frame.origin.x, 0);
}



#pragma mark - Font Settings

- (void)setRequiredFont2
{
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [passwordTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:25.00]];
        
        [confirmPassTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:25.00]];
        
        [securityQuesTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:25.00]];
        
        [securityAnsTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:25.00]];
        
    }
    else
    {
        [passwordTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:18.00]];
        
        [confirmPassTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:18.00]];
        
        [securityQuesTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:18.00]];
        
        [securityAnsTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:18.00]];
    }
}


@end

