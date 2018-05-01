//
//  DeviceRegistrationViewController.m
//  IMYourDoc
//
//  Created by Sarvjeet on 02/02/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import "DeviceRegistrationViewController.h"


@interface DeviceRegistrationViewController ()
{
    BOOL bool_DeviceRegRetry;
}

@end


@implementation DeviceRegistrationViewController


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
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
  
    
}
- (void)appEnterBackground: (NSNotification *)noti
{
    [deviceNameTF resignFirstResponder];
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
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
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

- (IBAction)registerDevice
{
    [self.view endEditing:YES];
    
    
    if (deviceNameTF.text.length>0)
    {
        if ([AppDel appIsDisconnected])
        {
            [AppData showAlertWithTitle:nil andMessage:@"No Connection." inVC:self];
        }
        
        else
        {
            
            NSDictionary *dict = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:@"addUserDevice",
                                                                        [AppData appData].XMPPmyJID ,
                                                                        [[NSUserDefaults standardUserDefaults] stringForKey:@"openUUID"],
                                                                        deviceNameTF.text, nil]
                                                               forKeys:[NSArray arrayWithObjects:@"method", @"user_name", @"device_id", @"device_name", nil]];
            
            [[WebHelper sharedHelper] setWebHelperDelegate:self];
            
            [[WebHelper sharedHelper] sendRequest:dict tag:S_DeviceRegistration delegate:self];
            
            
            if (bool_DeviceRegRetry)
            {
                [AppDel showSpinnerWithText:@"Retrying.."];
            }
            else
            {
                [AppDel showSpinnerWithText:@"Registering Device.."];
            }
        }
    }
    else{
          [[[UIAlertView alloc] initWithTitle:nil message:@"Please provide a name for this device." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }

    

}


#pragma mark - Request


- (void)didReceivedresponse:(NSDictionary *)response
{
    if ([WebHelper sharedHelper].tag == S_DeviceRegistration)
    {
       
        
        
        if ([[response objectForKey:@"err-code"] intValue] == 1)    // Device Registered Successfully
        {
             [AppDel processAfterDeviceRegistration];
        }
                
        else
        {
            [AppDel hideSpinner];
            
            [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        
    }
}

- (void)didFailedWithError: (NSError *) error
{
      [ AppDel hideSpinner];
    
      [[[UIAlertView alloc] initWithTitle:nil message:@"Unable to connect to the server, Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}


#pragma mark - TextField

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [deviceNameTF resignFirstResponder];
    
    
    return YES;
}


#pragma mark - keyboard notification

- (void) keyboardWillShow: (NSNotification *) noti
{
    if ([deviceNameTF isFirstResponder])
    {
        CGRect keyBFrame = [[[noti userInfo] valueForKey:@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
        
        
        if ( (keyBFrame.origin.y) < (TFScroll.frame.origin.y + TFScroll.frame.size.height ))
        {
            TFScroll.contentOffset = CGPointMake(0, (TFScroll.frame.origin.y + TFScroll.frame.size.height ) - (keyBFrame.origin.y));
        }
    }
}


- (void) keyboardWillHide: (NSNotification *) noti
{
    if ([deviceNameTF resignFirstResponder])
    {
        TFScroll.contentOffset = CGPointMake(0, 0);
    }
}



#pragma mark - Setting Fonts

- (void)setRequiredFont1
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [titleLbl setFont:[UIFont fontWithName:@"CentraleSansRndMedium" size:25.00]];
        
        [deviceNameTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
    }
    else
    {
        [titleLbl setFont:[UIFont fontWithName:@"CentraleSansRndMedium" size:20.00]];
        
        [deviceNameTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:15.00]];
        
        deviceNameTF.minimumFontSize = 13.00;
    }

}


@end

