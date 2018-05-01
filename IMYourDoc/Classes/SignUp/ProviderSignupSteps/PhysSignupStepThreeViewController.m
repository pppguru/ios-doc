//
//  PhysSignupStepThreeViewController.m
//  IMYourDoc
//
//  Created by Sarvjeet on 31/01/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import "PhysSignupStepOneViewController.h"
#import "PhysSignupStepTwoViewController.h"
#import "PhysSignupStepFourViewController.h"
#import "PhysSignupStepThreeViewController.h"
#import "HospitalSearchViewController.h"

@interface PhysSignupStepThreeViewController () <HospitalSearchViewControllerDelegate>


@end


@implementation PhysSignupStepThreeViewController


#pragma mark - View LifeCycle

- (void) viewDidLoad
{
    [super viewDidLoad];
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    if (!fetchingHospital)
    {
        self.secondryHosp = [self.userInfo objectForKey:@"sec_hospital"];
        
        npiTF.text = [self.userInfo objectForKey:@"npi_code"];
        
        zipcodeTF.text = [self.userInfo objectForKey:@"zip"];
        
        
        if ([[self.userInfo objectForKey:@"pri_hospital"] isKindOfClass:[NSDictionary class]])
        {
            self.hospital = [self.userInfo objectForKey:@"pri_hospital"];
            
            
            primaryHospTF.text = [self.hospital objectForKey:@"name"];
        }
        
        
        NSArray *names = [self.secondryHosp valueForKey:@"name"];
        
        secondaryHospTF.text = [names componentsJoinedByString:@","];
    }

    
   
   
    

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    
    [self numberPadAccessory];
    
    fetchingHospital = NO;

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
    [self.userInfo setObject:(npiTF.text.length > 0 ? npiTF.text : @"") forKey:@"npi_code"];
    
    [self.userInfo setObject:(zipcodeTF.text.length > 0 ? zipcodeTF.text : @"") forKey:@"zip"];
    
    [self.userInfo setObject:([[self.hospital objectForKey:@"hosp_id"] length] > 0 ? [self.hospital objectForKey:@"hosp_id"] : @"") forKey:@"hosp_id"];
    
        [self.userInfo setObject:([[self.hospital allKeys] count] > 0 ? self.hospital : @"") forKey:@"pri_hospital"];
    
    
        if (self.secondryHosp)
        {
            [self.userInfo setObject:self.secondryHosp forKey:@"sec_hospital"];
       }
    
    
        NSArray *sec_ids = [self.secondryHosp valueForKey:@"hosp_id"];
    
    
       NSString *sec_hosps = [sec_ids componentsJoinedByString:@","];
    
    
        if (sec_hosps)
       {
           [self.userInfo setObject:sec_hosps forKey:@"sec_hosp_ids"];
       }
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)navForward
{
    if ([self validateData])
    {
        PhysSignupStepFourViewController *step4VC = [[PhysSignupStepFourViewController alloc] initWithNibName:@"PhysSignupStepFourViewController" bundle:nil];
        
        step4VC.registrationType = self.registrationType;
       
        step4VC.userInfo = self.userInfo;
        
        [self.navigationController pushViewController:step4VC animated:YES];
    }
}

- (IBAction)selectPrimaryHospital
{
    fetchingHospital = YES;
    
    
    HospitalSearchViewController *hospVC = [[HospitalSearchViewController alloc] initWithNibName:@"HospitalSearchViewController" bundle:nil];
    
    hospVC.hospitalSelectionMode = HospitalSelectionModeSingle;
    
    hospVC.delegate = self;
    
    [self.navigationController pushViewController:hospVC animated:YES];

}


- (IBAction)selectSecondaryHospital
{
    fetchingHospital = YES;
    
    
    HospitalSearchViewController *hospVC = [[HospitalSearchViewController alloc] initWithNibName:@"HospitalSearchViewController" bundle:nil];
    
    hospVC.hospitalSelectionMode = HospitalSelectionModeMultiple;
    
    hospVC.delegate = self;
    
    [self.navigationController pushViewController:hospVC animated:YES];
}


#pragma mark - TextField

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
   // [self.view endEditing:YES];
    
    
    if (textField == npiTF && (([npiTF.text exactLength] ==10) || ([npiTF.text exactLength] == 0)))
    {
        [zipcodeTF becomeFirstResponder];
    }
    else  if (textField == npiTF && !((([npiTF.text exactLength] ==10) || ([npiTF.text exactLength] == 0))))
    {
          [npiTF becomeFirstResponder];
        
        [[[UIAlertView alloc] initWithTitle:nil message:@"NPI should be 10 digits." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    if (textField == zipcodeTF && (([zipcodeTF.text exactLength] >=5) || ([zipcodeTF.text exactLength] == 0)))
    {
        [self selectPrimaryHospital];
    }
    else  if (textField == zipcodeTF && !([zipcodeTF.text exactLength] >= 5))
    {
        [zipcodeTF becomeFirstResponder];
        
        [[[UIAlertView alloc] initWithTitle:nil message:@"Zip Code should be atleast 5 digits." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
   
    
    
    return YES;
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == npiTF && (([npiTF.text exactLength] ==10) || ([npiTF.text exactLength] == 0)))
    {
        [zipcodeTF becomeFirstResponder];
    }
    else  if (textField == npiTF && !((([npiTF.text exactLength] ==10) || ([npiTF.text exactLength] == 0))))
    {
        [npiTF becomeFirstResponder];
        
        [[[UIAlertView alloc] initWithTitle:nil message:@"NPI should be 10 digits." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    if (textField == zipcodeTF && (([zipcodeTF.text exactLength] >=5) || ([zipcodeTF.text exactLength] == 0)))
    {
        [self selectPrimaryHospital];
    }
    else  if (textField == zipcodeTF && !([zipcodeTF.text exactLength] >= 5))
    {
        [zipcodeTF becomeFirstResponder];
        
        [[[UIAlertView alloc] initWithTitle:nil message:@"Oops! You forget to enter your ZIP code." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
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
    
    
    if (npiTF.isEditing)
    {
        tfOffset = TFScroll.frame.origin.y + npiV.frame.origin.y + npiV.frame.size.height;
        
        
        if ((keyBRect.origin.y - tfOffset) < 0)
        {
            CGFloat y = (tfOffset - keyBRect.origin.y) ;
            
            TFScroll.contentOffset = CGPointMake(TFScroll.frame.origin.x, y);
        }
        
    }
    
    if (zipcodeTF.isEditing)
    {
        tfOffset = TFScroll.frame.origin.y + zipcodeV.frame.origin.y + zipcodeV.frame.size.height;
        
        
        if ((keyBRect.origin.y - tfOffset) < 0)
        {
            CGFloat y = (tfOffset - keyBRect.origin.y);
            
            TFScroll.contentOffset = CGPointMake(TFScroll.frame.origin.x, y);
        }
        
    }
    
    if (primaryHospTF.isEditing)
    {
        tfOffset = TFScroll.frame.origin.y + primaryHospV.frame.origin.y + primaryHospV.frame.size.height;
        
        if ((keyBRect.origin.y - tfOffset) < 0)
        {
            CGFloat y = (tfOffset - keyBRect.origin.y);
            
            TFScroll.contentOffset = CGPointMake(TFScroll.frame.origin.x, y);
        }
        
    }
    
    if (secondaryHospTF.isEditing)
    {
        tfOffset = TFScroll.frame.origin.y + secondaryHospV.frame.origin.y + secondaryHospV.frame.size.height;
        
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
    UIToolbar *numberToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    
    numberToolbar.items = [NSArray arrayWithObjects:
                           
                           [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           
                           [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleDone target:self action:@selector(pinTFNumberPad)],
                           
                           nil];
    
    
    npiTF.inputAccessoryView = numberToolbar;
    
    
    UIToolbar *numberToolbar2 = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    
    numberToolbar2.items = [NSArray arrayWithObjects:
                            
                            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                            
                            [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleDone target:self action:@selector(phoneTFNumberPad)],
                            
                            nil];
    
    
    zipcodeTF.inputAccessoryView = numberToolbar2;
    
}


- (void)pinTFNumberPad
{
    if (([npiTF.text exactLength] ==10) || ([npiTF.text exactLength] == 0))
    {
        [npiTF resignFirstResponder];
        
        [zipcodeTF becomeFirstResponder];
    }
    
    else
    {
        [npiTF becomeFirstResponder];
        
        [[[UIAlertView alloc] initWithTitle:nil message:@"NPI should be 10 digits." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}


- (void)phoneTFNumberPad
{
    if (([zipcodeTF.text exactLength] >= 5) || ([zipcodeTF.text exactLength] == 0))
    {
        [zipcodeTF resignFirstResponder];
        
        
    }
    
    else
    {
        [zipcodeTF becomeFirstResponder];
        
        [[[UIAlertView alloc] initWithTitle:nil message:@"Zip Code should be atleast 5 digits." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}


- (void)zipTFNumberPad
{
    [zipcodeTF resignFirstResponder];
    
    
    [TFScroll setContentOffset:CGPointMake(0, 0) animated:YES];
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


#pragma mark - Validate

- (BOOL)validateData
{
    [UIView animateWithDuration:.25 animations:^{
        
        self.view.frame = CGRectMake(0,0, self.view.frame.size.width,self.view.frame.size.height);
    }];
    
    
    
    
    
    if ([npiTF.text exactLength] != 10)
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"NPI should be 10 digits." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        
        
        return NO;
    }
    
    
    if (!([zipcodeTF.text exactLength] >= 5))
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Zip Code should be atleast 5 digits." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        
        
        return NO;
    }
    
 
    
    [self.userInfo setObject:npiTF.text forKey:@"npi_code"];
    
    [self.userInfo setObject:zipcodeTF.text forKey:@"zip"];
    
    [self.userInfo setObject:self.hospital forKey:@"pri_hospital"];
    
    
   if (self.secondryHosp)
   {
      [self.userInfo setObject:self.secondryHosp forKey:@"sec_hospital"];
    }
 
  
    [self.userInfo setObject:[self.hospital objectForKey:@"hosp_id"] forKey:@"hosp_id"];
 

   NSArray *sec_ids = [self.secondryHosp valueForKey:@"hosp_id"];


      NSString *sec_hosps = [sec_ids componentsJoinedByString:@","];


  if (sec_hosps)
   {
       [self.userInfo setObject:sec_hosps forKey:@"sec_hosp_ids"];
    }
    
    
    return YES;
}

#pragma mark - Hospital management

- (NSMutableArray *)selectedHospitals:(HospitalSearchViewController *)controller
{
    if (controller.hospitalSelectionMode == HospitalSelectionModeSingle)
    {
        return [NSMutableArray arrayWithObjects:self.hospital, nil];
    }
    
    
    if (self.secondryHosp == nil)
    {
        self.secondryHosp = [NSMutableArray array];
    }
    
    
    return self.secondryHosp;
}


- (void)HospitalController:(HospitalSearchViewController *)controller selectedHosptials:(NSMutableArray *)selectedHosps
{
    if (controller.hospitalSelectionMode == HospitalSelectionModeSingle)
    {
       self.hospital = [selectedHosps lastObject];

      primaryHospTF.text = [self.hospital objectForKey:@"name"];
        
       TFScroll.contentOffset = CGPointMake(TFScroll.contentOffset.x, 2 * secondaryHospV.frame.size.height);
    }

   else
   {
       self.secondryHosp = selectedHosps;

        NSArray *names = [self.secondryHosp valueForKey:@"name"];

       secondaryHospTF.text = [names componentsJoinedByString:@","];
       
       TFScroll.contentOffset = CGPointMake(0,0);
  }
}


@end

