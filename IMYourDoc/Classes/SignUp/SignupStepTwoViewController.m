//
//  SignupStepTwoViewController.m
//  IMYourDoc
//
//  Created by Sarvjeet on 21/01/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import "SignupStepTwoViewController.h"
#import "SignupStepThreeViewController.h"


@interface SignupStepTwoViewController ()


@end


@implementation SignupStepTwoViewController


#pragma mark - View LifeCycle

- (void) viewDidLoad
{
    [super viewDidLoad];
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    

    [self setRequiredFont2];
    
    if (self.registrationType == RegistrationTypePhysician)
    {
        npiTF.text = [self.userInfo objectForKey:@"npi_code"];
        
        passwordVTopConst.constant = 0.142 * (self.view.frame.size.height - 50.0);
        
        npiV.hidden = NO;
    }
    
    else
    {
        passwordVTopConst.constant = 0;
        
        npiV.hidden = YES;
    }

    
    pinTF.text = [self.userInfo objectForKey:@"pincode"];
    
    passwordTF.text = [self.userInfo objectForKey:@"password"];
    
    confirmPassTF.text = [self.userInfo objectForKey:@"password"];

    securityAnsTF.text = [self.userInfo objectForKey:@"securityAnswer"];

    securityQuesTF.text = [self.userInfo objectForKey:@"securityQuestion"];
    
    
    [self numberPadAccessory];

    
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
    
    [self.view endEditing:YES];
    
    if (self.registrationType == RegistrationTypePhysician)
    {
        [self.userInfo setObject:(npiTF.text.length > 0 ? npiTF.text : @"") forKey:@"npi_code"];
    }
    

    [self.userInfo setObject:(pinTF.text.length > 0 ? pinTF.text : @"") forKey:@"pincode"];
    
    [self.userInfo setObject:(passwordTF.text.length > 0 ? passwordTF.text : @"") forKey:@"password"];

    [self.userInfo setObject:(securityAnsTF.text.length > 0 ? securityAnsTF.text : @"") forKey:@"securityAnswer"];

    [self.userInfo setObject:(securityQuesTF.text.length > 0 ? securityQuesTF.text : @"") forKey:@"securityQuestion"];
    
    
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)navForward
{
    if (([pinTF.text exactLength] == 0) || ([passwordTF.text exactLength] == 0) || ([confirmPassTF.text exactLength] == 0) || ([securityQuesTF.text exactLength] == 0) || ([securityAnsTF.text exactLength] == 0) || (([npiTF.text exactLength] == 0) && (self.registrationType == RegistrationTypePhysician)))
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"All fields are mandatory in Step 2." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        
        
        return;
    }

    if ([passwordTF.text isCorrectPassword] == NO)
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Oops! You forget to create your password. Password must contain at least\n  One upper case letter\n  One lower case letter\n  One digit\n  and be at least 6 characters" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        
        
        return;
    }
    
    else if ([confirmPassTF.text isEqualToString:passwordTF.text] == NO)
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Oops! Passwords do not match. Try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        
        
        return;
    }

    else if ([pinTF.text exactLength] != 4)
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"PIN should be 4 digits." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        
        
        return;
    }
    
    if (self.registrationType == RegistrationTypePhysician)
    {
        [self.userInfo setObject:npiTF.text forKey:@"npi_code"];
    }
    
    [self.userInfo setObject:pinTF.text forKey:@"pincode"];
    
    [self.userInfo setObject:passwordTF.text forKey:@"password"];
    
    [self.userInfo setObject:securityAnsTF.text forKey:@"securityAnswer"];

    [self.userInfo setObject:securityQuesTF.text forKey:@"securityQuestion"];
    

    
    [self.view endEditing:YES];

    UIEdgeInsets insets = UIEdgeInsetsMake(TFScroll.contentInset.top, 0, 0, 0);
    
    
    TFScroll.contentInset = insets;
    
    TFScroll.scrollIndicatorInsets = insets;
    
    TFScroll.contentOffset = CGPointMake(TFScroll.frame.origin.x, 0);


    
    SignupStepThreeViewController *signupThreeVC = [[SignupStepThreeViewController alloc] initWithNibName:@"SignupStepThreeViewController" bundle:nil];
    
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

    
    if (textField == npiTF && (([npiTF.text exactLength] ==10) || ([npiTF.text exactLength] == 0)))
    {
        [passwordTF becomeFirstResponder];
    }
    
    else  if (textField == npiTF && !((([npiTF.text exactLength] ==10) || ([npiTF.text exactLength] == 0))))
    {
        [npiTF becomeFirstResponder];
        
        [[[UIAlertView alloc] initWithTitle:nil message:@"NPI should be 10 digits." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    

    
    else if (textField == passwordTF && ([passwordTF.text exactLength] == 0))
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
        [pinTF becomeFirstResponder];
    }
    
    else if (textField == confirmPassTF && !([confirmPassTF.text isEqualToString:passwordTF.text]) && !([confirmPassTF.text exactLength] == 0))
    {
        [confirmPassTF becomeFirstResponder];
        
        
        [[[UIAlertView alloc] initWithTitle:nil message:@"Oops! Passwords do not match. Try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }

    

    
    else if (textField == pinTF && (([pinTF.text exactLength] ==4) || ([pinTF.text exactLength] == 0)))
    {
        [securityQuesTF becomeFirstResponder];
    }
    
    else if (textField == pinTF && ([pinTF.text exactLength] != 4) && !([pinTF.text exactLength] == 0))
    {
        [pinTF becomeFirstResponder];
        
        
        [[[UIAlertView alloc] initWithTitle:nil message:@"PIN should be 4 digits." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
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
    if (textField == npiTF && !((([npiTF.text exactLength] ==10) || ([npiTF.text exactLength] == 0))))
    {
        [npiTF becomeFirstResponder];
        
        [[[UIAlertView alloc] initWithTitle:nil message:@"NPI should be 10 digits." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }

    
    else if (textField == passwordTF && !([passwordTF.text isCorrectPassword]) && !([passwordTF.text exactLength] == 0))
    {
        [passwordTF becomeFirstResponder];
        
        
        [[[UIAlertView alloc] initWithTitle:nil message:@"Oops! You forget to create your password. Password must contain at least\n  One upper case letter\n  One lower case letter\n  One digit\n  and be at least 6 characters" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }

    
    else if (textField == confirmPassTF && !([confirmPassTF.text isEqualToString:passwordTF.text]) && !([confirmPassTF.text exactLength] == 0))
    {
        [confirmPassTF becomeFirstResponder];
        
        
        [[[UIAlertView alloc] initWithTitle:nil message:@"Oops! Passwords do not match. Try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }

    
    else if (textField == pinTF && ([pinTF.text exactLength] != 4) && !([pinTF.text exactLength] == 0))
    {
        [pinTF becomeFirstResponder];
        
        
        [[[UIAlertView alloc] initWithTitle:nil message:@"PIN should be 4 digits." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
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
    
    if (textField == npiTF)
    {
        tfOffset = TFScroll.frame.origin.y + npiV.frame.origin.y + npiV.frame.size.height ;
        
        
        if ((keyBRect.origin.y - tfOffset) < 0)
        {
            CGFloat y = (tfOffset - keyBRect.origin.y);
            
            TFScroll.contentOffset = CGPointMake(TFScroll.frame.origin.x, y);
        }
        
    }

    
    if (textField == passwordTF)
    {
        tfOffset = TFScroll.frame.origin.y + passwordV.frame.origin.y + passwordV.frame.size.height ;
        
        
        if ((keyBRect.origin.y - tfOffset) < 0)
        {
            CGFloat y = (tfOffset - keyBRect.origin.y);
            
            TFScroll.contentOffset = CGPointMake(TFScroll.frame.origin.x, y);
        }
        
    }
    
    if (textField == confirmPassTF)
    {
        tfOffset = TFScroll.frame.origin.y + confirmPassV.frame.origin.y + confirmPassV.frame.size.height ;
        
        
        if ((keyBRect.origin.y - tfOffset) < 0)
        {
            CGFloat y = (tfOffset - keyBRect.origin.y);
            
            TFScroll.contentOffset = CGPointMake(TFScroll.frame.origin.x, y);
        }
        
    }
    
    if (textField == pinTF)
    {
        tfOffset = TFScroll.frame.origin.y + pinV.frame.origin.y + pinV.frame.size.height ;
        
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



#pragma mark - Keyboard

- (void)numberPadAccessory
{
    UIToolbar *numberToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    
    numberToolbar.items = [NSArray arrayWithObjects:
                           
                           [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           
                           [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleDone target:self action:@selector(pinTFNumberPad)],
                           
                           nil];
    
    
    pinTF.inputAccessoryView = numberToolbar;
    
    
    
    UIToolbar *numberToolbar2 = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    
    numberToolbar2.items = [NSArray arrayWithObjects:
                           
                           [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           
                           [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleDone target:self action:@selector(npiTFNumberPad)],
                           
                           nil];
    
    
    npiTF.inputAccessoryView = numberToolbar2;

}


- (void)pinTFNumberPad
{
    if (([pinTF.text exactLength] ==4) || ([pinTF.text exactLength] == 0))
    {
        [securityQuesTF becomeFirstResponder];
    }
    
    else
    {
        [pinTF becomeFirstResponder];
        
        
        [[[UIAlertView alloc] initWithTitle:nil message:@"PIN should be 4 digits." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}


- (void)npiTFNumberPad
{
    if (([npiTF.text exactLength] ==10) || ([npiTF.text exactLength] == 0))
    {
        [passwordTF becomeFirstResponder];
    }
    
    else
    {
        [npiTF becomeFirstResponder];
        
        [[[UIAlertView alloc] initWithTitle:nil message:@"NPI should be 10 digits." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}



#pragma mark - Font Settings

- (void)setRequiredFont2
{
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [passwordTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:25.00]];
        
        [pinTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:25.00]];
        
        [confirmPassTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:25.00]];
        
        [securityAnsTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:25.00]];
        
        [securityQuesTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:25.00]];
        
        [npiTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:25.00]];
    }
    else
    {
        [passwordTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:18.00]];
        
        [pinTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:18.00]];
        
        [confirmPassTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:18.00]];
        
        [securityAnsTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:18.00]];
        
        [securityQuesTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:18.00]];
        
        [npiTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:18.00]];
    }
}


@end

