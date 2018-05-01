//
//  SignupStepOneViewController.m
//  IMYourDoc
//
//  Created by Sarvjeet on 21/01/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import "SignupStepOneViewController.h"
#import "SignupStepTwoViewController.h"


@interface SignupStepOneViewController ()


@end


@implementation SignupStepOneViewController


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
    
    zipTF.text = [self.userInfo objectForKey:@"zip"];
    
    emailTF.text = [self.userInfo objectForKey:@"email"];
    
    phoneTF.text = [self.userInfo objectForKey:@"phoneno"];

    lastNameTF.text = [self.userInfo objectForKey:@"last_name"];
    
    usernameTF.text = [self.userInfo objectForKey:@"user_name"];
    
    firstNameTF.text = [self.userInfo objectForKey:@"first_name"];



    [self numberPadAccessory];
    
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
    [self.view endEditing:YES];

    
    [self.userInfo setObject:(zipTF.text.length > 0 ? zipTF.text : @"") forKey:@"zip"];
    
    [self.userInfo setObject:(phoneTF.text.length > 0 ? phoneTF.text : @"") forKey:@"phoneno"];

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
    
    
    if (([firstName exactLength] == 0) || ([lastName exactLength] == 0) || ([emailTF.text exactLength] == 0) || ([phoneTF.text exactLength] == 0) || ([zipTF.text exactLength] == 0) || ([userName exactLength] == 0))
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"All fields are mandatory in Step 1." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        
        
        return;
    }

    else if ([userName isCorrectUserName] == NO)
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Special characters and spaces are not allowed in Username." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        
        
        return;
    }

    else if ([email isEmail] == NO)
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Please enter a valid email address." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        
        
        return;
    }

    else if ([phoneTF.text exactLength] < 10)
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Phone number should be 10 digits." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        
        
        return;
    }

    else if (!([zipTF.text exactLength] >= 5))
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Zip Code should be atleast 5 digits." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        
        
        return ;
    }
    
    
    
    SignupStepTwoViewController *signupTwoVC = [[SignupStepTwoViewController alloc] initWithNibName:@"SignupStepTwoViewController" bundle:nil];

    
    [self.userInfo setObject:email forKey:@"email"];

    [self.userInfo setObject:zipTF.text forKey:@"zip"];
    
    [self.userInfo setObject:lastName forKey:@"last_name"];

    [self.userInfo setObject:userName forKey:@"user_name"];
    
    [self.userInfo setObject:firstName forKey:@"first_name"];
    
    [self.userInfo setObject:phoneTF.text forKey:@"phoneno"];
    

    
    [self.view endEditing:YES];
    
    UIEdgeInsets insets = UIEdgeInsetsMake(TFScroll.contentInset.top, 0, 0, 0);
    
    
    TFScroll.contentInset = insets;
    
    TFScroll.scrollIndicatorInsets = insets;
    
    TFScroll.contentOffset = CGPointMake(TFScroll.frame.origin.x, 0);

    
    
    signupTwoVC.registrationType = self.registrationType;
    
    signupTwoVC.userInfo = self.userInfo;
    
    
    if (!userNameChecked)
    {
            [AppDel showSpinnerWithText:@"Checking Available."];
        
        NSString *signUpurl = BASE_URL;
        
        
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
    NSString *userName = [usernameTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    NSString *email = [emailTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    
    if (textField == firstNameTF)
    {
        [lastNameTF becomeFirstResponder];
    }
    
    else if (textField == lastNameTF )
    {
        [usernameTF becomeFirstResponder];
    }
    
    
    else if (textField == usernameTF  && !([userName isCorrectUserName]) && !([usernameTF.text exactLength] == 0))
    {
        [usernameTF becomeFirstResponder];
        
        
        [[[UIAlertView alloc] initWithTitle:nil message:@"Special characters and spaces are not allowed in Username." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
   
    else if (textField == usernameTF && ([userName isCorrectUserName]) && ([usernameTF.text exactLength] != 0))
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
                    [emailTF becomeFirstResponder];
                    
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
        [emailTF becomeFirstResponder];
    }
    
    
    else if (textField == emailTF && ([email isEmail] || ([email exactLength] == 0)))
    {
        [phoneTF becomeFirstResponder];
    }
    
    else if (textField == emailTF && !([email isEmail]) && !([emailTF.text isEqualToString:@""]))
    {
        [emailTF becomeFirstResponder];
        
        
        [[[UIAlertView alloc] initWithTitle:nil message:@"Please enter a valid email address." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }

    
    else if (textField == phoneTF && (([phoneTF.text exactLength] >= 10) || ([phoneTF.text exactLength] == 0)) )
    {
        [zipTF becomeFirstResponder];
    }
    
    else if (textField == phoneTF  && ([phoneTF.text exactLength] < 10) && ![phoneTF.text exactLength] == 0)
    {
        [phoneTF becomeFirstResponder];
        
        
        [[[UIAlertView alloc] initWithTitle:nil message:@"Phone number should be 10 digits." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }

    
    else if (textField == zipTF && (([zipTF.text exactLength] >=5) || ([zipTF.text exactLength] == 0)))
    {
        [zipTF resignFirstResponder];
    }
    
    else if (textField == zipTF && !([zipTF.text exactLength] >= 5))
    {
        [zipTF becomeFirstResponder];
        
        [[[UIAlertView alloc] initWithTitle:nil message:@"Zip Code should be atleast 5 digits." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
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

    if (textField == phoneTF)
    {
        tfOffset = TFScroll.frame.origin.y + phoneV.frame.origin.y + phoneV.frame.size.height ;
        
        if ((keyBRect.origin.y - tfOffset) < 0)
        {
            CGFloat y = (tfOffset - keyBRect.origin.y);
            
            TFScroll.contentOffset = CGPointMake(TFScroll.frame.origin.x, y);
        }
    }

    if (textField == zipTF)
    {
        tfOffset = TFScroll.frame.origin.y + zipV.frame.origin.y + zipV.frame.size.height ;
        
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


#pragma mark - Keyboard

- (void)numberPadAccessory
{
    UIToolbar *numberToolbar2 = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    
    numberToolbar2.items = [NSArray arrayWithObjects:
                            
                            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                            
                            [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleDone target:self action:@selector(phoneTFNumberPad)],
                            
                            nil];
    
    
    phoneTF.inputAccessoryView = numberToolbar2;
    
    
    UIToolbar *numberToolbar3 = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    
    numberToolbar3.items = [NSArray arrayWithObjects:
                            
                            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                            
                            [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(zipTFNumberPad)],
                            
                            nil];
    
    
    zipTF.inputAccessoryView = numberToolbar3;
}


- (void)phoneTFNumberPad
{
    if (([phoneTF.text exactLength] >= 10) || ([phoneTF.text exactLength] == 0))
    {
        [zipTF becomeFirstResponder];
    }
    
    else
    {
        [phoneTF becomeFirstResponder];
        
        
        [[[UIAlertView alloc] initWithTitle:nil message:@"Phone number should be 10 digits." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}


- (void)zipTFNumberPad
{
    if ( (([zipTF.text exactLength] >=5) || ([zipTF.text exactLength] == 0)))
    {
        [zipTF resignFirstResponder];
    }
    
    else if (!([zipTF.text exactLength] >= 5))
    {
        [zipTF becomeFirstResponder];
        
        [[[UIAlertView alloc] initWithTitle:nil message:@"Zip Code should be atleast 5 digits." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
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
        
        [zipTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:25.00]];

        [phoneTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:25.00]];
    }
    else
    {
        [firstNameTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:18.00]];
        
        [lastNameTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:18.00]];
        
        [emailTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:18.00]];
        
        [usernameTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:18.00]];
        
        [zipTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:18.00]];
        
        [phoneTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:18.00]];
    }
}

@end

