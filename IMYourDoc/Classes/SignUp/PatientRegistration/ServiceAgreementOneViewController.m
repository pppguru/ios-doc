//
//  ServiceAgreementOneViewController.m
//  IMYourDoc
//
//  Created by Sarvjeet on 19/01/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import "AccountConfigViewController.h"
#import "DeviceRegistrationViewController.h"
#import "ServiceAgreementOneViewController.h"
#import "ServiceAgreementTwoViewController.h"



@interface ServiceAgreementOneViewController ()
{
    BOOL bool_RegRetry, bool_RegFirstTime;
}

@end


@implementation ServiceAgreementOneViewController


#pragma mark - View LifeCycle

- (void) viewDidLoad
{
    [super viewDidLoad];
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    [self setRequiredFont2];
    
    if ([AppDel appIsDisconnected])
    {
    
        [[RDCallbackAlertView alloc] initWithTitle:nil message:@"No Connection."cancelButtonTitle:@"OK" andCompletionHandler:^(int btnIndex)
         {
             
         } otherButtonTitles: nil];
        
        
        
        
    }
    else{
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:URLBUILER(@"https://api.imyourdoc.com/SERVICES_AGREEMENT.php") ]];
        

        
        [request setValidatesSecureCertificate:YES];
        
        [request startAsynchronous];
        
        
        __weak ASIHTTPRequest *req = request;
        
        
        [request setCompletionBlock:^{
            
            [serviceWebV loadData:req.responseData MIMEType:@"text/html" textEncodingName:@"utf-8" baseURL:nil];
        }];
    }
    
    
   
}


- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    [self setRequiredFont2];
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

- (IBAction)navBack
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)userAgree
{
	agreeImgV.image = [UIImage imageNamed:@"Radio_button_Selected"];
	
	disagreeImgV.image = [UIImage imageNamed:@"Radio_button_unselected"];
    
    
    agreeBtn.selected = YES;
    
    disagreeBtn.selected = NO;
}


- (IBAction)userDisagree
{
	disagreeImgV.image = [UIImage imageNamed:@"Radio_button_Selected"];
	
	agreeImgV.image = [UIImage imageNamed:@"Radio_button_unselected"];
    
    
    agreeBtn.selected = NO;
    
    disagreeBtn.selected = YES;
}


- (IBAction)submitAgreement
{
    bool_RegFirstTime = YES;
    
    [self submitAgreementMethod];
}


- (void)submitAgreementMethod
{
    if (agreeBtn.selected)
    {
        if ([AppDel appIsDisconnected]  && bool_RegFirstTime)
        {
            [AppData showAlertWithTitle:nil andMessage:@"No Connection." inVC:self];
        }
        
        else
        {
   
            
            if (bool_RegRetry && !bool_RegFirstTime)
            {
                [AppDel showSpinnerWithText:@"Retrying..."];
                
                bool_RegRetry = NO;
            }
            else
            {
                [AppDel showSpinnerWithText:@"Uploading information"];
                
                bool_RegRetry = YES;
                
                bool_RegFirstTime = NO;
            }

            
            NSDictionary *dict= [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:
                                                                       @"patientRegistration",
                                                                       [self.userInfo objectForKey:@"first_name"],
                                                                       [self.userInfo objectForKey:@"last_name"],
                                                                       [self.userInfo objectForKey:@"email"],
                                                                       [self.userInfo objectForKey:@"user_name"],
                                                                       [self.userInfo objectForKey:@"password"],
                                                                       [self.userInfo objectForKey:@"securityQuestion"],
                                                                       [self.userInfo objectForKey:@"securityAnswer"],
                                                                       [self.userInfo objectForKey:@"pincode"],
                                                                       [self.userInfo objectForKey:@"phoneno"],
                                                                       [self.userInfo objectForKey:@"zip"],
                                                                       [OpenUDID value],nil]
                                                              forKeys:[NSArray arrayWithObjects:
                                                                       @"method",
                                                                       @"first_name",
                                                                       @"last_name",
                                                                       @"email",
                                                                       @"user_name",
                                                                       @"password",
                                                                       @"security_question",
                                                                       @"security_answer",
                                                                       @"pin",
                                                                       @"phone_no",
                                                                       @"zip",
                                                                       @"device_id" , nil]];
            
            [[WebHelper sharedHelper] setWebHelperDelegate:self];
            
            [[WebHelper sharedHelper] sendRequest:dict tag:S_PatientSignup delegate:self];
        }
    }
    
    else
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"In order to join the IM Your Doc network, you must agree to the Terms of Service. Please contact Customer Service with any questions." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}


#pragma mark - ASIRequestDelegate

- (void)didReceivedresponse:(NSDictionary *)response
{
    [AppDel hideSpinner];
    
    if ([WebHelper sharedHelper].tag == S_PatientSignup)
    {
        if ([[response objectForKey:@"err-code"] intValue] == 1)
        {
            [[RDCallbackAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] cancelButtonTitle:@"OK" andCompletionHandler:^(int btnIndex)
             {
                 
                 {
                     [[AppData appData] setXMPPmyJID:[self.userInfo objectForKey:@"user_name"]];
                     [[AppData appData] setXMPPmyJIDPassword:[self.userInfo objectForKey:@"password"]];
                     
                     //Try to login
                     [AppData loginWithResponseJSON:response withNavController:self.navigationController];
                 }
             } otherButtonTitles: nil];
        }
        
        else
        {
            [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        }
        
    }
    
}


- (void)didFailedWithError: (NSError *) error
{
    [AppDel hideSpinner];
    
    if ([WebHelper sharedHelper].tag == S_PatientSignup)
    {
        if (bool_RegRetry)
        {
            [self performSelector:@selector(submitAgreementMethod) withObject:nil afterDelay:0.9];
        }
        else
        {
            [[RDCallbackAlertView alloc] initWithTitle:nil message:@"Cannot detect Internet connection" cancelButtonTitle:nil andCompletionHandler:^(int btnIDX)
             {
                 
                 if (btnIDX==0)
                 {
                     bool_RegRetry = YES;
                     
                     [self submitAgreementMethod];
                     
                 }
                 if (btnIDX==1)
                 {
                     bool_RegRetry=NO;
                 }
                 
             } otherButtonTitles:@"Retry" ,@"Try Later", nil];
            
        }
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Unable to connect to the server, Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    
}



#pragma mark - XML genration

- (NSString *) generateStringWithFN: (NSString *) fn andLN: (NSString *) ln andEmail: (NSString *) email andUN: (NSString *) un andP: (NSString *) p andSQ: (NSString *) sq andSA: (NSString *) sa andPIN: (NSString *) pin andPhone: (NSString *) phone andZIP: (NSString *) zip
{
    NSString *firstString = @"<?xml version='1.0' encoding='UTF-8'?>";
    
    
    NSString *secondString;
    
    secondString = [firstString stringByAppendingString:@"<PatientReg>"];
    
    secondString = [secondString stringByAppendingString:[NSString stringWithFormat:@"<Fname>%@</Fname>", fn]];
    
    secondString = [secondString stringByAppendingString:[NSString stringWithFormat:@"<Lname>%@</Lname>", ln]];
    
    secondString = [secondString stringByAppendingString:[NSString stringWithFormat:@"<Email>%@</Email>", email]];
    
    secondString = [secondString stringByAppendingString:[NSString stringWithFormat:@"<UserName>%@</UserName>", un]];
    
    secondString = [secondString stringByAppendingString:[NSString stringWithFormat:@"<Password>%@</Password>", p]];
    
    secondString = [secondString stringByAppendingString:[NSString stringWithFormat:@"<SecQus>%@</SecQus>", sq]];
    
    secondString = [secondString stringByAppendingString:[NSString stringWithFormat:@"<SecAns>%@</SecAns>", sa]];
    
    secondString = [secondString stringByAppendingString:[NSString stringWithFormat:@"<UserPin>%@</UserPin>", pin]];
    
    secondString = [secondString stringByAppendingString:[NSString stringWithFormat:@"<Phone>%@</Phone>", phone]];
    
    secondString = [secondString stringByAppendingString:[NSString stringWithFormat:@"<Zip>%@</Zip>", zip]];
    
    secondString = [secondString stringByAppendingString:[NSString stringWithFormat:@"<device_id>%@</device_id>", [OpenUDID value]]];
    
    secondString = [secondString stringByAppendingFormat:@"</PatientReg>"];
    
    
    return secondString;
}

#pragma mark - Font Settings

- (void)setRequiredFont2
{
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [navBarLbl setFont:[UIFont fontWithName:@"CentraleSansRndMedium" size:25.00]];
        
        [oathLbl setFont:[UIFont fontWithName:@"CentraleSansRndMedium" size:20.00]];
        
        [agreeBtn.titleLabel setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
        
        [disagreeBtn.titleLabel setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
    }
    else
    {
        [navBarLbl setFont:[UIFont fontWithName:@"CentraleSansRndMedium" size:20.00]];
        
        [oathLbl setFont:[UIFont fontWithName:@"CentraleSansRndMedium" size:15.00]];
        
        [agreeBtn.titleLabel setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:15.00]];
        
        [disagreeBtn.titleLabel setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:15.00]];
    }
}


@end

