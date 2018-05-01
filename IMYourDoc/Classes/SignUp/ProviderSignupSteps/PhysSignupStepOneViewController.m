//
//  PhysSingupStepOneViewController.m
//  IMYourDoc
//
//  Created by Sarvjeet on 31/01/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import "SignupTypesViewController.h"
#import "PhysSignupStepTwoViewController.h"
#import "PhysSignupStepOneViewController.h"
#import "PhysSignupStepFourViewController.h"
#import "PhysSignupStepThreeViewController.h"


@interface PhysSignupStepOneViewController ()


@end


@implementation PhysSignupStepOneViewController


#pragma mark - View LifeCycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    
    if (self.userInfo == nil)
    {
        self.userInfo = [NSMutableDictionary dictionary];
    }
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    createPswdTF.text = [self.userInfo objectForKey:@"password"];
    
    confirmPswdTF.text = [self.userInfo objectForKey:@"password"];

    firstNameTF.text = [self.userInfo objectForKey:@"first_name"];
    
    lastNameTF.text = [self.userInfo objectForKey:@"last_name"];
    
    userNameTF.text = [self.userInfo objectForKey:@"user_name"];
    
   
    
    
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
    [self.userInfo setObject:(createPswdTF.text.length > 0 ? createPswdTF.text : @"") forKey:@"password"];
    
    [self.userInfo setObject:[userNameTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"user_name"];
    
    [self.userInfo setObject:[firstNameTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"first_name"];
    
    [self.userInfo setObject:[lastNameTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"last_name"];
    

    
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)navForward
{
    if ([self validateData])
    {
        PhysSignupStepTwoViewController *stepTwoVC = [[PhysSignupStepTwoViewController alloc] initWithNibName:@"PhysSignupStepTwoViewController" bundle:nil];
        
        stepTwoVC.registrationType = self.registrationType;
        
        stepTwoVC.userInfo = self.userInfo;
        
        [self.navigationController pushViewController:stepTwoVC animated:YES];
    }
}


#pragma mark - TextField

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{

    
    NSString *userName = [userNameTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    

    
    
    if (textField == firstNameTF)
    {
        [lastNameTF becomeFirstResponder];
    }
    
    else if (textField == lastNameTF)
    {
        [userNameTF becomeFirstResponder];
    }
    
    

    
    else if (textField == userNameTF && ([userName isCorrectUserName] || ([userName exactLength] == 0)))
    {
        
        [AppDel showSpinnerWithText:@"Checking Available."];
        
        NSString *signUpurl = @"https://www.imyourdoc.com/joomla/service.php";
        
        
        NSURL *url = [NSURL URLWithString:signUpurl];
        
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        
        [request setRequestMethod:@"POST"];
        
        [request addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
        
        request.postBody = [[NSJSONSerialization dataWithJSONObject:[NSDictionary dictionaryWithObjectsAndKeys:@"validate_user_name",@"method",userNameTF.text,@"user_name", nil] options:NSJSONWritingPrettyPrinted error:nil] mutableCopy];
        
        __weak ASIHTTPRequest * req=request;
        
        [request setCompletionBlock:^{
            
            [AppDel hideSpinner];
            
            NSDictionary * response=[NSJSONSerialization JSONObjectWithData:req.responseData options:NSJSONReadingMutableContainers error:nil];
            
            if([[response objectForKey:@"err-code"] intValue]==1)
            {
                [createPswdTF becomeFirstResponder];
                
                
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [userNameTF becomeFirstResponder];
                    
                    [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                });
            }
            
        }];
        
        [request setFailedBlock:^{
            
            [AppDel hideSpinnerAfterDelayWithText:@"Failed to connect to server." andImageName:@"error"];
        }];
        
        [request startAsynchronous];
        
    
    }
    
    else if (textField == createPswdTF && ([createPswdTF.text isCorrectPassword] || ([createPswdTF.text exactLength] == 0)))
    {
        [confirmPswdTF becomeFirstResponder];
    }
    
    else if (textField == createPswdTF && !([createPswdTF.text isCorrectPassword]) && !([createPswdTF.text exactLength] == 0))
    {
        [createPswdTF becomeFirstResponder];
        
        [[[UIAlertView alloc] initWithTitle:nil message:@"Oops! You forget to create your password. Password must contain at least\n  One upper case letter\n  One lower case letter\n  One digit\n  and be at least 6 characters" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }

    else if (textField == confirmPswdTF && ([confirmPswdTF.text isEqualToString:createPswdTF.text] || ([confirmPswdTF.text exactLength] == 0)))
    {
        [confirmPswdTF resignFirstResponder];
    }
    
    else if (textField == confirmPswdTF && !([confirmPswdTF.text isEqualToString:createPswdTF.text]) && !([confirmPswdTF.text exactLength] == 0))
    {
        [confirmPswdTF becomeFirstResponder];
        
        [[[UIAlertView alloc] initWithTitle:nil message:@"Oops! Passwords do not match. Try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        
    }

    
    return YES;
}


- (void)textFieldDidEndEditing:(FontTextField *)textField
{
 
    
    NSString *userName = [userNameTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    
    if (textField == userNameTF  && !([userName isCorrectUserName]) && ![userNameTF.text exactLength] == 0)
    {
        [userNameTF becomeFirstResponder];
        
        [[[UIAlertView alloc] initWithTitle:nil message:@"Special characters and spaces are not allowed in Username." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    
    else if (textField == createPswdTF && !([createPswdTF.text isCorrectPassword]) && !([createPswdTF.text exactLength] == 0))
    {
        [createPswdTF becomeFirstResponder];
        
        [[[UIAlertView alloc] initWithTitle:nil message:@"Oops! You forget to create your password. Password must contain at least\n  One upper case letter\n  One lower case letter\n  One digit\n  and be at least 6 characters" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    
    else if (textField == confirmPswdTF && !([confirmPswdTF.text isEqualToString:createPswdTF.text]) && !([confirmPswdTF.text exactLength] == 0))
    {
        [confirmPswdTF becomeFirstResponder];
        
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
    
    
    if (firstNameTF.isEditing)
    {
        tfOffset = TFScroll.frame.origin.y + firstNameV.frame.origin.y + firstNameV.frame.size.height ;
        
        
        if ((keyBRect.origin.y - tfOffset) < 0)
        {
            CGFloat y = (tfOffset - keyBRect.origin.y) ;
            
            TFScroll.contentOffset = CGPointMake(TFScroll.frame.origin.x, y);
        }
        
    }
    
    if (lastNameTF.isEditing)
    {
        tfOffset = TFScroll.frame.origin.y + lastNameV.frame.origin.y + lastNameV.frame.size.height;
        
        
        if ((keyBRect.origin.y - tfOffset) < 0)
        {
            CGFloat y = (tfOffset - keyBRect.origin.y);
            
            TFScroll.contentOffset = CGPointMake(TFScroll.frame.origin.x, y);
        }
        
    }
    
    if (userNameTF.isEditing)
    {
        tfOffset = TFScroll.frame.origin.y + userNameV.frame.origin.y + userNameV.frame.size.height;
        
        if ((keyBRect.origin.y - tfOffset) < 0)
        {
            CGFloat y = (tfOffset - keyBRect.origin.y);
            
            TFScroll.contentOffset = CGPointMake(TFScroll.frame.origin.x, y);
        }
        
    }
    
    if (createPswdTF.isEditing)
    {
        tfOffset = TFScroll.frame.origin.y + createPswdV.frame.origin.y + createPswdV.frame.size.height;
        
        if ((keyBRect.origin.y - tfOffset) < 0)
        {
            CGFloat y = (tfOffset - keyBRect.origin.y);
            
            TFScroll.contentOffset = CGPointMake(TFScroll.frame.origin.x, y);
        }
        
    }
    
    if (confirmPswdTF.isEditing)
    {
        tfOffset = TFScroll.frame.origin.y + confirmPswdV.frame.origin.y + confirmPswdV.frame.size.height;
        
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


#pragma mark - Validate

- (BOOL)validateData
{
    NSString *userName = [userNameTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString *firstName = [firstNameTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString *lastName = [lastNameTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    

    
    [UIView animateWithDuration:0.25f animations:^{
        
        self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    }];
    
    
    if (([firstName exactLength] == 0) || ([lastName exactLength] == 0) || ([createPswdTF.text exactLength] == 0) || ([userName exactLength] == 0) || ([confirmPswdTF.text exactLength] == 0))
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"All fields are mandatory in Step 1." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        
        
        return NO;
    }
    
    
    if ([confirmPswdTF.text isEqualToString:createPswdTF.text] == NO)
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Oops! Passwords do not match. Try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        
        
        return NO;
    }
    
    if ([createPswdTF.text isCorrectPassword] == NO)
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Oops! You forget to create your password. Password must contain at least\n  One upper case letter\n  One lower case letter\n  One digit\n  and be at least 6 characters" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        
        
        return NO;
    }
    

    
    
    if ([userName isCorrectUserName] == NO)
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Special characters and spaces are not allowed in Username." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        
        
        return NO;
    }
    
    
    [self.userInfo setObject:[userNameTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"user_name"];
    
    [self.userInfo setObject:[firstNameTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"first_name"];
    
    [self.userInfo setObject:[lastNameTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"last_name"];
    
    [self.userInfo setObject:createPswdTF.text forKey:@"password"];


    
    
    return YES;
}


#pragma mark - PushVC

- (void)pushToViewController: (UIViewController *)nextViewController
{
    [UIView animateWithDuration:0.75 animations:^{
        
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        
        
        [self.navigationController pushViewController:nextViewController animated:NO];
        
        
        [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.navigationController.view cache:NO];
    }];
}


@end

