//
//  SignupStepOneViewController.m
//  IMYourDoc
//
//  Created by Sarvjeet on 21/01/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import "PatientStepOneViewController.h"
#import "PatientStepTwoViewController.h"


@interface PatientStepOneViewController ()


@end


@implementation PatientStepOneViewController


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
    
    
    [self setRequiredFont2];
    
    firstNameTF.text = [self.userInfo objectForKey:@"first_name"];
    
    lastNameTF.text = [self.userInfo objectForKey:@"last_name"];
    
    usernameTF.text = [self.userInfo objectForKey:@"user_name"];
    
    emailTF.text = [self.userInfo objectForKey:@"email"];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShows:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHides:) name:UIKeyboardWillHideNotification object:nil];
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
    [self.userInfo setObject:[usernameTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"user_name"];
    
    [self.userInfo setObject:[firstNameTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"first_name"];
    
    [self.userInfo setObject:[lastNameTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"last_name"];
    
    [self.userInfo setObject:[emailTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"email"];

    SignupTypesViewController *signVC = [[SignupTypesViewController alloc] initWithNibName:@"SignupTypesViewController" bundle:nil];
    
    [self.navigationController pushViewController:signVC animated:NO];
 
}


- (IBAction)navForward
{
    NSString *firstName = [firstNameTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString *lastName =  [lastNameTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    NSString *email = [emailTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    NSString *userName = [usernameTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    
    [UIView animateWithDuration:.25 animations:^{
        
        self.view.frame = CGRectMake(0,0, self.view.frame.size.width,self.view.frame.size.height);
    }];
    
    
    if (([firstName exactLength] == 0) || ([lastName exactLength] == 0) || ([email exactLength] == 0) || ([userName exactLength] == 0))
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"All fields are mandatory in Step 1." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        
        
        return;
    }
    
    
    if ([email isEmail] == NO)
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Please enter a valid email address." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        
        
        return;
    }
    
    
    if ([userName isCorrectUserName] == NO)
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Special characters and spaces are not allowed in Username." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        
        
        return;
    }
    

    PatientStepTwoViewController *signupTwoVC = [[PatientStepTwoViewController alloc] initWithNibName:@"PatientStepTwoViewController" bundle:nil];
    
    [self.userInfo setObject:userName forKey:@"user_name"];
    
    [self.userInfo setObject:firstName forKey:@"first_name"];
    
    [self.userInfo setObject:lastName forKey:@"last_name"];
    
    [self.userInfo setObject:email forKey:@"email"];

    
    signupTwoVC.registrationType = self.registrationType;
    
    signupTwoVC.userInfo = self.userInfo;
    
   
    

    [self.view endEditing:YES];
    
    UIEdgeInsets insets = UIEdgeInsetsMake(TFScroll.contentInset.top, 0, 0, 0);
    
    
    TFScroll.contentInset = insets;
    
    TFScroll.scrollIndicatorInsets = insets;
    
    TFScroll.contentOffset = CGPointMake(TFScroll.frame.origin.x, 0);

    
    
    

  
    if (!userNameChecked)
    {
        [AppDel showSpinnerWithText:@"Checking Available."];
        

        
        NSString *signUpurl =   BASE_URL;//@"https://www.imyourdoc.com/joomla/service.php";
        
        
        NSURL *url = [NSURL URLWithString:signUpurl];
        
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        
        [request setRequestMethod:@"POST"];
        
        [request addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
        
        request.postBody = [[NSJSONSerialization dataWithJSONObject:[NSDictionary dictionaryWithObjectsAndKeys:@"validateUserName",@"method",usernameTF.text,@"user_name", nil] options:NSJSONWritingPrettyPrinted error:nil] mutableCopy];
        
        __weak ASIHTTPRequest * req=request;
        
        [request setCompletionBlock:^{
            
            [AppDel hideSpinner];
            
            NSDictionary * response=[NSJSONSerialization JSONObjectWithData:req.responseData options:NSJSONReadingMutableContainers error:nil];
            
            if([[response objectForKey:@"err-code"] intValue]==1)
            {
                dispatch_async(dispatch_get_main_queue(), ^
                               {
                                   
                                   userNameChecked = YES;
                                   
                                   [self.navigationController pushViewController:signupTwoVC animated:YES];
                               });
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^
                               {
                                   
                                   [usernameTF becomeFirstResponder];
                                   
                                   [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                               });
            }
            
        }];
        
        [request setFailedBlock:^
         {
             
             [AppDel hideSpinnerAfterDelayWithText:@"Failed to connect to server." andImageName:@"error"];
         }];
        
        [request startAsynchronous];
    }
    
    else
    {
        [self.navigationController pushViewController:signupTwoVC animated:YES];
    }


    
    
    
    
    
}

#pragma mark - Service Response

- (void)didReceivedresponse:(NSDictionary *)response
{
    [AppDel hideSpinner];
    
    
    NSString *firstName = [firstNameTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString *lastName =  [lastNameTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString *email = [emailTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString *userName = [usernameTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    PatientStepTwoViewController *signupTwoVC = [[PatientStepTwoViewController alloc] initWithNibName:@"PatientStepTwoViewController" bundle:nil];
    
    
    [self.userInfo setObject:userName forKey:@"user_name"];
    
    [self.userInfo setObject:firstName forKey:@"first_name"];
    
    [self.userInfo setObject:lastName forKey:@"last_name"];
    
    [self.userInfo setObject:email forKey:@"email"];
    
    
    signupTwoVC.registrationType = self.registrationType;
    
    signupTwoVC.userInfo = self.userInfo;
    
    
    if ([WebHelper sharedHelper].tag == S_ValidateUserName )
    {
        
        if ([[response objectForKey:@"err-code"] intValue] == 1)
        {
            
            userNameChecked = YES;
            
            [self.navigationController pushViewController:signupTwoVC animated:YES];
            
        }
        else if([[response objectForKey:@"err-code"] intValue] == 700)
        {
            [usernameTF becomeFirstResponder];
            
            [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        
        
  
    }
}

- (void)didFailedWithError: (NSError *) error
{
    [AppDel hideSpinner];
    
    [[[UIAlertView alloc] initWithTitle:nil message:@"Unable to connect to the server, Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}


#pragma mark - TextField


-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == usernameTF)
    {
        userNameChecked = NO;
    }
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSString *email = [emailTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString *userName = [usernameTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    

    
    if (textField == firstNameTF)
    {
        [lastNameTF becomeFirstResponder];
    }
    
    else if (textField == lastNameTF)
    {
        [emailTF becomeFirstResponder];
    }
    
    else if (textField == emailTF && ([email isEmail] || ([email exactLength] == 0)))
    {
        [usernameTF becomeFirstResponder];
    }
    
    else if (textField == emailTF && !([email isEmail]) && !([emailTF.text isEqualToString:@""]))
    {
        [emailTF becomeFirstResponder];
        
        
        [[[UIAlertView alloc] initWithTitle:nil message:@"Please enter a valid email address." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    
    
    else if (textField == usernameTF  && !([userName isCorrectUserName]) && !([usernameTF.text exactLength] == 0))
    {
        [usernameTF becomeFirstResponder];
        
        
        [[[UIAlertView alloc] initWithTitle:nil message:@"Special characters and spaces are not allowed in Username." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    
    else if (textField == usernameTF && [userName isCorrectUserName] && ([usernameTF.text exactLength] != 0))
    {
        
        if ([AppDel appIsDisconnected])
        {
            [AppData showAlertWithTitle:nil andMessage:@"No Connection." inVC:self];
        }
        
        else
        {
            [AppDel showSpinnerWithText:@"Checking Available."];
            
            NSString *signUpurl =BASE_URL;
            
            
            NSURL *url = [NSURL URLWithString:signUpurl];
            
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
            
            [request setRequestMethod:@"POST"];
            
            [request addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
            
            request.postBody = [[NSJSONSerialization dataWithJSONObject:[NSDictionary dictionaryWithObjectsAndKeys:@"validateUserName",@"method",usernameTF.text,@"user_name", nil] options:NSJSONWritingPrettyPrinted error:nil] mutableCopy];
            
            __weak ASIHTTPRequest * req=request;
            
            [request setCompletionBlock:^{
                
                [AppDel hideSpinner];
                
                NSDictionary * response=[NSJSONSerialization JSONObjectWithData:req.responseData options:NSJSONReadingMutableContainers error:nil];
                
                if([[response objectForKey:@"err-code"] intValue]==1)
                {
                    [usernameTF resignFirstResponder];
                    
                    userNameChecked = YES;
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [usernameTF becomeFirstResponder];
                        
                        [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                        
                        userNameChecked = NO;
                    });
                }
                
            }];
            
            [request setFailedBlock:^{
                
                [AppDel hideSpinnerAfterDelayWithText:@"Failed to connect to server." andImageName:@"error"];
            }];
            
            [request startAsynchronous];
        }
    }
    
    else if (textField == usernameTF && ([usernameTF.text exactLength] == 0))
    {
        [usernameTF resignFirstResponder];
    }
    
    
    return YES;
}




#pragma mark - keyboard notification

- (void) keyboardShows: (NSNotification *) noti
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
    
    if (textField == firstNameTF)
    {
        tfOffset = TFScroll.frame.origin.y + firstNameV.frame.origin.y + firstNameV.frame.size.height ;
        
        
        if ((keyBRect.origin.y - tfOffset) < 0)
        {
            CGFloat y = (tfOffset - keyBRect.origin.y);
            
            TFScroll.contentOffset = CGPointMake(TFScroll.frame.origin.x, y);
        }
    }
    
    if (textField == lastNameTF)
    {
        tfOffset = TFScroll.frame.origin.y + lastNameV.frame.origin.y + lastNameV.frame.size.height ;
        
        
        if ((keyBRect.origin.y - tfOffset) < 0)
        {
            CGFloat y = (tfOffset - keyBRect.origin.y);
            
            TFScroll.contentOffset = CGPointMake(TFScroll.frame.origin.x, y);
        }
    }
    
    if (textField == usernameTF)
    {
        tfOffset = TFScroll.frame.origin.y + userNameV.frame.origin.y + userNameV.frame.size.height ;
        
        if ((keyBRect.origin.y - tfOffset) < 0)
        {
            CGFloat y = (tfOffset - keyBRect.origin.y);
            
            TFScroll.contentOffset = CGPointMake(TFScroll.frame.origin.x, y);
        }
    }
    
    if (textField == emailTF)
    {
        tfOffset = TFScroll.frame.origin.y + emailV.frame.origin.y + emailV.frame.size.height ;
        
        if ((keyBRect.origin.y - tfOffset) < 0)
        {
            CGFloat y = (tfOffset - keyBRect.origin.y);
            
            TFScroll.contentOffset = CGPointMake(TFScroll.frame.origin.x, y);
        }
    }
}


- (void) keyboardHides: (NSNotification *) noti
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
        [firstNameTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:25.00]];
        
        [lastNameTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:25.00]];

        [emailTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:25.00]];

        [usernameTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:25.00]];

    }
    else
    {
        [firstNameTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:18.00]];
        
        [lastNameTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:18.00]];
        
        [emailTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:18.00]];
        
        [usernameTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:18.00]];
    }
}


@end

