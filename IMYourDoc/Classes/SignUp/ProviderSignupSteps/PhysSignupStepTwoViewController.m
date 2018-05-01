//
//  PhysSignupStepTwoViewController.m
//  IMYourDoc
//
//  Created by Sarvjeet on 31/01/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import "PhysSignupStepOneViewController.h"
#import "PhysSignupStepTwoViewController.h"
#import "PhysSignupStepFourViewController.h"
#import "PhysSignupStepThreeViewController.h"


@interface PhysSignupStepTwoViewController ()


@end


@implementation PhysSignupStepTwoViewController


#pragma mark - View LifeCycle

- (void) viewDidLoad
{
    [super viewDidLoad];
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    emailTF.text = [self.userInfo objectForKey:@"email"];
    
    pinTF.text = [self.userInfo objectForKey:@"pincode"];
    
    phoneTF.text = [self.userInfo objectForKey:@"phoneno"];

    secQuesTF.text = [self.userInfo objectForKey:@"securityQuestion"];
    
    secAnsTF.text = [self.userInfo objectForKey:@"securityAnswer"];
    
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
    [self.userInfo setObject:(secQuesTF.text.length > 0 ? secQuesTF.text : @"") forKey:@"securityQuestion"];
    
    [self.userInfo setObject:(secAnsTF.text.length > 0 ? secAnsTF.text : @"") forKey:@"securityAnswer"];
    
    [self.userInfo setObject:(phoneTF.text.length > 0 ? phoneTF.text : @"") forKey:@"phoneno"];
    
    [self.userInfo setObject:(pinTF.text.length > 0 ? pinTF.text : @"") forKey:@"pincode"];
    
    [self.userInfo setObject:[emailTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"email"];
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)navForward
{
    if ([self validateData])
    {
        PhysSignupStepThreeViewController *step3VC = [[PhysSignupStepThreeViewController alloc] initWithNibName:@"PhysSignupStepThreeViewController" bundle:nil];
        
        step3VC.registrationType = self.registrationType;
    
        step3VC.userInfo = self.userInfo;
        
        [self.navigationController pushViewController:step3VC animated:YES];
    }
}


#pragma mark - TextField

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
     NSString *email = [emailTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    

    
    if (textField == pinTF && (([pinTF.text exactLength] ==4) || ([pinTF.text exactLength] == 0)))
    {
        [phoneTF becomeFirstResponder];
    }
    
    else if (textField == pinTF && ([pinTF.text exactLength] != 4) && !([pinTF.text exactLength] == 0))
    {
        [pinTF becomeFirstResponder];
        
        [[[UIAlertView alloc] initWithTitle:nil message:@"PIN should be 4 digits." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }

    else if (textField == phoneTF && (([phoneTF.text exactLength] >= 10) || ([phoneTF.text exactLength] == 0)))
    {
        [emailTF becomeFirstResponder];
    }
    
    else if (textField == phoneTF  && ([phoneTF.text exactLength] < 10) && ![phoneTF.text exactLength] == 0)
    {
        [phoneTF becomeFirstResponder];
        
        [[[UIAlertView alloc] initWithTitle:nil message:@"Phone number should be 10 digits." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }


    else if (textField == emailTF && ([email isEmail] || ([email exactLength] == 0)))
    {
        [secQuesTF becomeFirstResponder];
    }
    
     else if (textField == secQuesTF)
    {
        [secAnsTF becomeFirstResponder];
    }
    
    else if (textField == secAnsTF)
    {
        [secAnsTF resignFirstResponder];
    }
    
    
    return YES;
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
     NSString *email = [emailTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (textField == emailTF && !([email isEmail]) && !([emailTF.text isEqualToString:@""]))
    {
        [emailTF becomeFirstResponder];
        
        
        [[[UIAlertView alloc] initWithTitle:nil message:@"Please enter a valid email address." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    
    else if (textField == pinTF && ([pinTF.text exactLength] != 4) && !([pinTF.text exactLength] == 0))
    {
        [pinTF becomeFirstResponder];
        
        [[[UIAlertView alloc] initWithTitle:nil message:@"PIN should be 4 digits." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    
    else if (textField == phoneTF  && ([phoneTF.text exactLength] < 10) && ![phoneTF.text exactLength] == 0)
    {
        [phoneTF becomeFirstResponder];
        
        [[[UIAlertView alloc] initWithTitle:nil message:@"Phone number should be 10 digits." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }


}

 

- (void) keyboardWillShow: (NSNotification *) noti
{
    
    NSDictionary *info = [noti userInfo];
    
    CGRect keyBRect = [info[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    
    UIEdgeInsets insets = UIEdgeInsetsMake(TFScroll.contentInset.top, 0, keyBRect.size.height / 1.4 , 0);
    
    TFScroll.contentInset = insets;
    
    TFScroll.scrollIndicatorInsets = insets;
    
    
    float tfOffset ;
    
    
    if (pinTF.isEditing)
    {
        tfOffset = TFScroll.frame.origin.y + pinV.frame.origin.y + pinV.frame.size.height ;
        
        
        if ((keyBRect.origin.y - tfOffset) < 0)
        {
            CGFloat y = (tfOffset - keyBRect.origin.y) ;
            
            TFScroll.contentOffset = CGPointMake(TFScroll.frame.origin.x, y);
        }
        
    }
    
    if (phoneTF.isEditing)
    {
        tfOffset = TFScroll.frame.origin.y + phoneV.frame.origin.y + phoneV.frame.size.height  ;
        
        
        if ((keyBRect.origin.y - tfOffset) < 0)
        {
            CGFloat y = (tfOffset - keyBRect.origin.y);
            
            TFScroll.contentOffset = CGPointMake(TFScroll.frame.origin.x, y);
        }
        
    }
    
    if (emailTF.isEditing)
    {
        tfOffset = TFScroll.frame.origin.y + emailV.frame.origin.y + emailV.frame.size.height;
        
        if ((keyBRect.origin.y - tfOffset) < 0)
        {
            CGFloat y = (tfOffset - keyBRect.origin.y);
            
            TFScroll.contentOffset = CGPointMake(TFScroll.frame.origin.x, y);
        }
        
    }
    
    if (secQuesTF.isEditing)
    {
        tfOffset = TFScroll.frame.origin.y + secQuesV.frame.origin.y + secQuesV.frame.size.height;
        
        if ((keyBRect.origin.y - tfOffset) < 0)
        {
            CGFloat y = (tfOffset - keyBRect.origin.y);
            
            TFScroll.contentOffset = CGPointMake(TFScroll.frame.origin.x, y);
        }
        
    }

    if (secAnsTF.isEditing)
    {
        tfOffset = TFScroll.frame.origin.y + secAnsV.frame.origin.y + secAnsV.frame.size.height;
        
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


#pragma mark - KeyBoard

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
                            
                            [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleDone target:self action:@selector(phoneTFNumberPad)],
                            
                            nil];
    
    
    phoneTF.inputAccessoryView = numberToolbar2;
}


- (void)pinTFNumberPad
{
    if (([pinTF.text exactLength] ==4) || ([pinTF.text exactLength] == 0))
    {
        [pinTF resignFirstResponder];
        
        [phoneTF becomeFirstResponder];
    }
    
    else
    {
        [pinTF becomeFirstResponder];
        
        [[[UIAlertView alloc] initWithTitle:nil message:@"PIN should be 4 digits." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}


- (void)phoneTFNumberPad
{
    if (([phoneTF.text exactLength] >= 10) || ([phoneTF.text exactLength] == 0))
    {
        [phoneTF resignFirstResponder];
        
        [emailTF becomeFirstResponder];
    }
    
    else
    {
        [phoneTF becomeFirstResponder];
        
        [[[UIAlertView alloc] initWithTitle:nil message:@"Phone number should be 10 digits." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}


#pragma mark - Validate

- (BOOL)validateData
{
    [UIView animateWithDuration:.25 animations:^{
        
        self.view.frame = CGRectMake(0,0, self.view.frame.size.width,self.view.frame.size.height);
    }];
    
    
    if (([pinTF.text exactLength] == 0) || ([phoneTF.text exactLength] == 0)  || ([emailTF.text exactLength] == 0) || ([secAnsTF.text exactLength] == 0) || ([secQuesTF.text exactLength] == 0))
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"All fields are mandatory in Step 2." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        
        
        return NO;
    }
    
    [self.userInfo setObject:phoneTF.text forKey:@"phoneno"];
    
    [self.userInfo setObject:pinTF.text forKey:@"pincode"];
    
    [self.userInfo setObject:secQuesTF.text forKey:@"securityQuestion"];
    
    [self.userInfo setObject:secAnsTF.text forKey:@"securityAnswer"];
    
    [self.userInfo setObject:[emailTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"email"];
    
    
    return YES;
}


- (void)pushToViewController: (UIViewController *)nextViewController
{
    [UIView animateWithDuration:0.75 animations:^{
        
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        
        
        [self.navigationController pushViewController:nextViewController animated:NO];
        
        
        [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.navigationController.view cache:NO];
    }];
}


@end

