//
//  ForgotPswdStepTwoViewController.m
//  IMYourDoc
//
//  Created by Sarvjeet on 02/02/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import "ForgotPswdStepTwoViewController.h"
#import "ForgotPswdStepThreeViewController.h"


@interface ForgotPswdStepTwoViewController ()


@end


@implementation ForgotPswdStepTwoViewController


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
    
    
    secAnsTF.text = [self.pwdInfo objectForKey:@"securityAnswer"];
    
    secQuesLbl.text = self.secQuesStrg;
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
    if ([self validateData])
    {
        if ([secAnsTF.text caseInsensitiveCompare:self.secAnsStrg] == NSOrderedSame)
        {
            ForgotPswdStepThreeViewController *stepThree = [[ForgotPswdStepThreeViewController alloc] initWithNibName:@"ForgotPswdStepThreeViewController" bundle:nil];
            
            
            [self.pwdInfo setObject:[secAnsTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"securityAnswer"];
            
            
            stepThree.pwdInfo = self.pwdInfo;
            
            [self.navigationController pushViewController:stepThree animated:YES];
        }
        
        else
        {
            [[[UIAlertView alloc] initWithTitle:nil message:@"Security answer mismatch" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
        }
    }
}


- (IBAction)navBack
{
    [self.pwdInfo setObject:[secAnsTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"securityAnswer"];

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


#pragma mark - TextField

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == secAnsTF)
    {
        [secAnsTF resignFirstResponder];
    }
    
    
    return YES;
}


#pragma mark - keyboard notification

- (void) keyboardWillShow: (NSNotification *) noti
{
    
    CGRect keyBRect = [[[noti userInfo] valueForKey:@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    
    
    UIEdgeInsets insets = UIEdgeInsetsMake(TFScroll.contentInset.top, 0, keyBRect.size.height/1.5, 0);
    
    
    TFScroll.contentInset = insets;
    
    TFScroll.scrollIndicatorInsets = insets;

    
    if ([secAnsTF isFirstResponder])
    {
        CGRect keyBFrame = [[[noti userInfo] valueForKey:@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
        
        
        if ((keyBFrame.origin.y) < (secAnsContainer.frame.origin.y + secAnsContainer.frame.size.height + 55 ))
        {
            TFScroll.contentOffset = CGPointMake(0, (secAnsContainer.frame.origin.y + secAnsContainer.frame.size.height + 55) - (keyBFrame.origin.y));
        }
    }
}


- (void) keyboardWillHide: (NSNotification *) noti
{
    UIEdgeInsets insets = UIEdgeInsetsMake(TFScroll.contentInset.top, 0, 0, 0);
    
    
    TFScroll.contentInset = insets;
    
    TFScroll.scrollIndicatorInsets = insets;

    
    if ([secAnsTF resignFirstResponder])
    {
        TFScroll.contentOffset = CGPointMake(0, 0);
    }
}


#pragma mark - BOOL

- (BOOL)validateData
{
    if ([secAnsTF.text isEqualToString:@""])
    {
     
        
        
        
        [[RDCallbackAlertView alloc] initWithTitle:nil message:@"Please enter your Security Answer"cancelButtonTitle:nil andCompletionHandler:^(int btnIndex)
         
         {
         [secAnsTF becomeFirstResponder];
             
         } otherButtonTitles:@"OK", nil];
        
        
        return NO;
    }
    
    
    return YES;
}


- (void)setRequiredFont1
{
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [secAnsTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:25.00]];
        
        [secQuesL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:25.00]];
        
        [secQuesLbl setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:25.00]];
    }
    else
    {
        [secAnsTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
        
        [secQuesL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
        
        [secQuesLbl setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];

    }
}


@end

