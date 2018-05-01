//
//  ServiceAgreementTwoViewController.m
//  IMYourDoc
//
//  Created by Sarvjeet on 19/01/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import "DeviceRegistrationViewController.h"
#import "ServiceAgreementTwoViewController.h"



@interface ServiceAgreementTwoViewController ()
{
    BOOL bool_RegRetry, bool_RegFirstTime;
}

@end


@implementation ServiceAgreementTwoViewController


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
               [self.navigationController popViewControllerAnimated:YES];
         } otherButtonTitles: nil];
        
    }
    else
    {
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:URLBUILER(@"https://api.imyourdoc.com/HIPAA_BUSINESS_ASSOCIATE_ADDENDUM.php") ]];
    

    
    [request setValidatesSecureCertificate:YES];
    
    [request startAsynchronous];
    
    
    __weak ASIHTTPRequest *req = request;
    
    
    [request setCompletionBlock:^{
        [agreement1WebV loadData:req.responseData MIMEType:@"text/html" textEncodingName:@"utf-8" baseURL:nil];
    }];
    [request setFailedBlock:^{
        
            [self.navigationController popViewControllerAnimated:YES];
        
    }];
    
    
    ASIHTTPRequest *request2 = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:URLBUILER(@"https://api.imyourdoc.com/SERVICES_AGREEMENT.php") ]];
   
    [request2 setValidatesSecureCertificate:YES];
    
    [request2 startAsynchronous];
    
    
    __weak ASIHTTPRequest *req2 = request2;
    
    
    [request2 setCompletionBlock:^{
        [agreement2WebV loadData:req2.responseData MIMEType:@"text/html" textEncodingName:@"utf-8" baseURL:nil];
    }];
    
    [request2 setFailedBlock:^{
        
        [self.navigationController popViewControllerAnimated:YES];
        
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


- (IBAction)userSubmitAgreement
{
    bool_RegFirstTime = YES;
    
    [self userSubmitAgreementMethod];
}


- (void)userSubmitAgreementMethod
{
    if (agreeBtn.selected)
    {
        if ([AppDel appIsDisconnected] && bool_RegFirstTime)
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

            
            
            
            NSDictionary *dict = nil;
            
            
            if (self.registrationType == RegistrationTypeStaff)
            {
                dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                        
                        @"staffRegistration", @"method",
                        
                        [self.userInfo objectForKey:@"user_name"], @"user_name",
                        
                        [self.userInfo objectForKey:@"email"], @"email",
                        
                        [self.userInfo objectForKey:@"password"], @"password",
                        
                        [self.userInfo objectForKey:@"pincode"], @"pin",
                        
                        [self.userInfo objectForKey:@"first_name"], @"first_name",
                        
                        [self.userInfo objectForKey:@"last_name"], @"last_name",
                        
                        [self.userInfo objectForKey:@"securityQuestion"], @"security_question",
                        
                        [self.userInfo objectForKey:@"securityAnswer"], @"security_answer",
                        
                        [self.userInfo objectForKey:@"zip"], @"zip",
                        
                        [self.userInfo objectForKey:@"phoneno"], @"phone_no",
                        
                        [OpenUDID value], @"device_id",
                        
                        [self.userInfo objectForKey:@"practice_type"], @"practice_type",
                        
                        [self.userInfo objectForKey:@"hosp_id"], @"primary_hosp_id",
                        
                        [self.userInfo objectForKey:@"job_title"], @"job_title",
                        
                        [self.userInfo objectForKey:@"sec_hosp_ids"], @"other_hospitals",
                        [self.userInfo objectForKey:@"designation_title"], @"designation",
                        
                        nil];
                
                
                
                [[WebHelper sharedHelper] setWebHelperDelegate:self];
                
                [[WebHelper sharedHelper]sendRequest:dict tag:S_StaffSignup delegate:self];
                
            }
            
            else if (self.registrationType == RegistrationTypePhysician)
            {
                
                dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                        
                        @"physicianRegistration", @"method",
                        
                        [self.userInfo objectForKey:@"user_name"], @"user_name",
                        
                        [self.userInfo objectForKey:@"email"], @"email",
                        
                        [self.userInfo objectForKey:@"password"], @"password",
                        
                        [self.userInfo objectForKey:@"pincode"], @"pin",
                        
                        [self.userInfo objectForKey:@"first_name"], @"first_name",
                        
                        [self.userInfo objectForKey:@"last_name"], @"last_name",
                        
                        [self.userInfo objectForKey:@"securityQuestion"], @"security_question",
                        
                        [self.userInfo objectForKey:@"securityAnswer"], @"security_answer",
                        
                        [self.userInfo objectForKey:@"zip"], @"zip",
                        
                        [self.userInfo objectForKey:@"phoneno"], @"phone_no",
                        
                        [self.userInfo objectForKey:@"npi_code"], @"npi",
                        
                        [OpenUDID value], @"device_id",
                        
                        [self.userInfo objectForKey:@"practice_type"], @"practice_type",
                        
                        [self.userInfo objectForKey:@"hosp_id"], @"primary_hosp_id",
                        
                        [self.userInfo objectForKey:@"sec_hosp_ids"], @"other_hospitals",
                        
                        [self.userInfo objectForKey:@"job_title"], @"job_title",
                        
                        [self.userInfo objectForKey:@"designation_title"], @"designation",
                        
                        nil];
                
                
                [[WebHelper sharedHelper]setWebHelperDelegate:self];
                
                [[WebHelper sharedHelper]sendRequest:dict tag:S_PhySignup delegate:self];
                
            }
        }
        
    }
    
    
    else
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"In order to join the IM Your Doc network, you must agree to the Terms of Service. Please contact Customer Service with any questions." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}


#pragma mark - ASIHTTP

- (void)didReceivedresponse:(NSDictionary *)response
{
    [AppDel hideSpinner];
    
    if ([WebHelper sharedHelper].tag == S_PhySignup ||  [WebHelper sharedHelper].tag == S_StaffSignup)
    {
        if ([[response objectForKey:@"err-code"] intValue] ==1)
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
    
    if ([WebHelper sharedHelper].tag == S_PhySignup ||  [WebHelper sharedHelper].tag == S_StaffSignup)
    {
        if (bool_RegRetry)
        {
            [self performSelector:@selector(userSubmitAgreementMethod) withObject:nil afterDelay:0.9];
        }
        else
        {
            [[RDCallbackAlertView alloc] initWithTitle:nil message:@"Cannot detect Internet connection" cancelButtonTitle:nil andCompletionHandler:^(int btnIDX)
             {
                 
                 if (btnIDX==0)
                 {
                     bool_RegRetry = YES;
                     
                     [self userSubmitAgreementMethod];
                     
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

#pragma mark - UI Setup

- (void)setRequiredFont2
{
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [navBarLbl setFont:[UIFont fontWithName:@"CentraleSansRndMedium" size:25.00]];
        
        [oathLbl setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
        
        [agreeBtn.titleLabel setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
        
        [disagreeBtn.titleLabel setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
    }
    else
    {
        [navBarLbl setFont:[UIFont fontWithName:@"CentraleSansRndMedium" size:20.00]];
        
        [oathLbl setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:17.00]];
        
        [agreeBtn.titleLabel setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:15.00]];
        
        [disagreeBtn.titleLabel setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:15.00]];
    }
}


@end

