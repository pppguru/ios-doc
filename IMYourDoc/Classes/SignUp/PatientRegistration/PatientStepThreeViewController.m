//
//  SignupStepThreeViewController.m
//  IMYourDoc
//
//  Created by Sarvjeet on 21/01/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import "IMConstants.h"
#import "HospitalSearchViewController.h"
#import "PatientStepThreeViewController.h"
#import "ServiceAgreementOneViewController.h"
#import "ServiceAgreementTwoViewController.h"


@interface PatientStepThreeViewController () 


@end


@implementation PatientStepThreeViewController


#pragma mark - View LifeCycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    [self numberPadAccessory];
    
    [self setRequiredFont2];
    
    
    zipcodeTF.text = [self.userInfo objectForKey:@"zip"];

    phoneTF.text = [self.userInfo objectForKey:@"phoneno"];
    
    pincodeTF.text = [self.userInfo objectForKey:@"pincode"];

    
    
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
    [self.userInfo setObject:(zipcodeTF.text.length > 0 ? zipcodeTF.text : @"") forKey:@"zip"];
    
    [self.userInfo setObject:(phoneTF.text.length > 0 ? phoneTF.text : @"") forKey:@"phoneno"];
    
    [self.userInfo setObject:(pincodeTF.text.length > 0 ? pincodeTF.text : @"") forKey:@"pincode"];

    
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)navForward
{
    if (([zipcodeTF.text exactLength] == 0) || ([phoneTF.text exactLength] == 0) || ([pincodeTF.text exactLength] == 0))
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"All fields are mandatory in Step 3." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        
        
        return;
    }

    else if ([pincodeTF.text exactLength] != 4)
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"PIN should be 4 digits." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        
        
        return;
    }
    

    else if ([phoneTF.text exactLength] < 10)
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Phone number should be 10 digits." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        
        
        return;
    }

    else if (!([zipcodeTF.text exactLength] >= 5))
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Zip Code should be atleast 5 digits." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        
        
        return ;
    }

    
    [self.userInfo setObject:zipcodeTF.text forKey:@"zip"];

    [self.userInfo setObject:phoneTF.text forKey:@"phoneno"];
    
    [self.userInfo setObject:pincodeTF.text forKey:@"pincode"];
    
    
    
    ServiceAgreementOneViewController *serviceVC = [[ServiceAgreementOneViewController alloc] initWithNibName:@"ServiceAgreementOneViewController" bundle:nil];
    
    serviceVC.registrationType = self.registrationType;
    
    serviceVC.userInfo = self.userInfo;
    
    [self.navigationController pushViewController:serviceVC animated:YES];
    
}


#pragma mark - TextField

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // pin
    
    if (textField == pincodeTF && (([pincodeTF.text exactLength] ==4) || ([pincodeTF.text exactLength] == 0)))
    {
        [phoneTF becomeFirstResponder];
    }
    
    else if (textField == pincodeTF && ([pincodeTF.text exactLength] != 4) && !([pincodeTF.text exactLength] == 0))
    {
        [pincodeTF becomeFirstResponder];
        
        
        [[[UIAlertView alloc] initWithTitle:nil message:@"PIN should be 4 digits." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    
    // phone
    
    else if (textField == phoneTF && (([phoneTF.text exactLength] >= 10) || ([phoneTF.text exactLength] == 0)) )
    {
        [zipcodeTF becomeFirstResponder];
    }
    
    else if (textField == phoneTF  && ([phoneTF.text exactLength] < 10) && ![phoneTF.text exactLength] == 0)
    {
        [phoneTF becomeFirstResponder];
        
        
        [[[UIAlertView alloc] initWithTitle:nil message:@"Phone number should be 10 digits." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }

    // zip
    
    else if (textField == zipcodeTF && (([zipcodeTF.text exactLength] >=5) || ([zipcodeTF.text exactLength] == 0)))
    {
        [zipcodeTF resignFirstResponder];
    }
    
    else if (textField == zipcodeTF && (!([zipcodeTF.text exactLength] >=5) && !([zipcodeTF.text exactLength] == 0)))
    {
        [zipcodeTF becomeFirstResponder];
        
        [[[UIAlertView alloc] initWithTitle:nil message:@"Zip Code should be atleast 5 digits." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    
    
    return YES;
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == pincodeTF && ([pincodeTF.text exactLength] != 4) && !([pincodeTF.text exactLength] == 0))
    {
        [pincodeTF becomeFirstResponder];
        
        
        [[[UIAlertView alloc] initWithTitle:nil message:@"PIN should be 4 digits." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    
    else if (textField == phoneTF  && ([phoneTF.text exactLength] < 10) && ![phoneTF.text exactLength] == 0)
    {
        [phoneTF becomeFirstResponder];
        
        
        [[[UIAlertView alloc] initWithTitle:nil message:@"Phone number should be 10 digits." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    
    else if (textField == zipcodeTF && (!([zipcodeTF.text exactLength] >=5) && !([zipcodeTF.text exactLength] == 0)))
    {
        [zipcodeTF becomeFirstResponder];
        
        [[[UIAlertView alloc] initWithTitle:nil message:@"Zip Code should be atleast 5 digits." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
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
    
    
    
    if (textField == pincodeTF)
    {
        tfOffset = TFScroll.frame.origin.y + pincodeV.frame.origin.y + pincodeV.frame.size.height ;
        
        
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
    
    
    if (textField == zipcodeTF)
    {
        tfOffset = TFScroll.frame.origin.y + zipcodeV.frame.origin.y + zipcodeV.frame.size.height ;
        
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
    
    
    pincodeTF.inputAccessoryView = numberToolbar;
    
    
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
    
    
    zipcodeTF.inputAccessoryView = numberToolbar3;
}


- (void)pinTFNumberPad
{
    if (([pincodeTF.text exactLength] ==4) || ([pincodeTF.text exactLength] == 0))
    {
        [phoneTF becomeFirstResponder];
    }
    
    else
    {
        [pincodeTF becomeFirstResponder];
        
        
        [[[UIAlertView alloc] initWithTitle:nil message:@"PIN should be 4 digits." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}


- (void)phoneTFNumberPad
{
    if (([phoneTF.text exactLength] >= 10) || ([phoneTF.text exactLength] == 0))
    {
        [zipcodeTF becomeFirstResponder];
    }
    
    else
    {
        [phoneTF becomeFirstResponder];
        
        
        [[[UIAlertView alloc] initWithTitle:nil message:@"Phone number should be 10 digits." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}


- (void)zipTFNumberPad
{
    if ( (([zipcodeTF.text exactLength] >=5) || ([zipcodeTF.text exactLength] == 0)))
    {
        [zipcodeTF resignFirstResponder];
    }
    
    else if (!([zipcodeTF.text exactLength] >= 5) && !([zipcodeTF.text exactLength] == 0))
    {
        [zipcodeTF becomeFirstResponder];
        
        [[[UIAlertView alloc] initWithTitle:nil message:@"Zip Code should be atleast 5 digits." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

// *phoneTF, *pincodeTF, *zipcodeTF;
#pragma mark - Font Settings

- (void)setRequiredFont2
{
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [phoneTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:25.00]];
        
        [pincodeTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:25.00]];
        
        [zipcodeTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:25.00]];
    }
    else
    {
        [phoneTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:18.00]];
        
        [pincodeTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:18.00]];
        
        [zipcodeTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:18.00]];
    }
}


@end

