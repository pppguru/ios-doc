//
//  AccountConfigServiceAgreementOneViewController.m
//  IMYourDoc
//
//  Created by Manpreet on 26/03/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import "AccountConfigServiceAgreementViewOneController.h"
#import "LoginViewController.h"


@interface AccountConfigServiceAgreementViewOneController ()


@end


@implementation AccountConfigServiceAgreementViewOneController


#pragma mark - View LifeCycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    [self setRequiredFont1];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    [self setRequiredFont1];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:URLBUILER(@"https://api.imyourdoc.com/SERVICES_AGREEMENT.php")  ]];
    
   if (self.isSecondAgreement)
   {
       request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:URLBUILER(@"https://api.imyourdoc.com/HIPAA_BUSINESS_ASSOCIATE_ADDENDUM.php?full_name=%@"), [[NSUserDefaults standardUserDefaults] objectForKey:@"UserFullName"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
   }
    
    [request setValidatesSecureCertificate:YES];
    
    [request startAsynchronous];
    
    __weak ASIHTTPRequest *req = request;
    
    
    [request setCompletionBlock:^{
        
        [agreementWebV loadData:req.responseData MIMEType:@"text/html" textEncodingName:@"utf-8" baseURL:nil];
    }];
}

-(void)viewDidDisappear:(BOOL)animated
{
    self.isSecondAgreement = NO;
}

#pragma mark - IBAction

- (IBAction)submitTap
{
    if (agreeBtn.selected)
    {
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        
        if (self.isSecondAgreement || appDelegate.isFromPhysician == 1)
        {
            if ([AppDel appIsDisconnected])
            {
                [AppData showAlertWithTitle:nil andMessage:@"No Connection." inVC:self];
            }
            
            else
            {
                [AppDel showSpinnerWithText:@"Configuring account.."];
                
                
                [[WebHelper sharedHelper] setWebHelperDelegate:self];
                
                [[WebHelper sharedHelper] sendRequest:self.dataDict tag:S_AccountConfig delegate:self];
            }
        }
        else
        {
            
            AccountConfigServiceAgreementViewOneController *acsa1VC = [[AccountConfigServiceAgreementViewOneController alloc] initWithNibName:@"AccountConfigServiceAgreementViewOneController" bundle:nil];
            
            acsa1VC.dataDict = self.dataDict;
            
            acsa1VC.isSecondAgreement = YES;
            
            [self.navigationController pushViewController:acsa1VC animated:YES];
        }
    }
    
    else
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"In order to join the IM Your Doc network, you must agree to the Terms of Service. Please contact Customer Service with any questions." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}


- (IBAction)agreeTap:(UIButton *)sender
{
    agreeBtn.selected = disagreeBtn.selected = NO;
    
    
    sender.selected = YES;
}


#pragma mark - Request


- (void)didReceivedresponse:(NSDictionary *)responseDict
{
    if ([WebHelper sharedHelper].tag == S_AccountConfig)
    {
        if ([[responseDict valueForKey:@"err-code"] intValue] == 1)             //Configured
        {
            [[[UIAlertView alloc] initWithTitle:nil message:[responseDict valueForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];

            [[NSUserDefaults standardUserDefaults] setObject:[self.dataDict objectForKey:@"security_qus"] forKey:@"QuestionString"];
            [[NSUserDefaults standardUserDefaults] setObject:[self.dataDict objectForKey:@"security_ans"] forKey:@"AnswerString"];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"required_config"];
            
            [[AppData appData] setXMPPmyJIDPassword:[self.dataDict objectForKey:@"password"]];
            [[AppData appData] setUserPIN:[self.dataDict objectForKey:@"user_pin"]];
            
            [[NSUserDefaults standardUserDefaults] synchronize];
            [AppData connectXMPPServer];
        }
        
        else    // Try again later == 300
        {
            [AppDel hideSpinner];
            
            [[[UIAlertView alloc] initWithTitle:nil message:[responseDict valueForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }
}


- (void)didFailedWithError: (NSError *) error
{
    [AppDel hideSpinner];
    
    [[[UIAlertView alloc] initWithTitle:nil message:@"Unable to connect to the server, Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}


#pragma mark - Set Required Fonts


- (void)setRequiredFont1
{
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [navBarLbl setFont:[UIFont fontWithName:@"CentraleSansRndMedium" size:25.00]];
        
        [oathLbl setFont:[UIFont fontWithName:@"CentraleSansRndMedium" size:25.00]];
        
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

