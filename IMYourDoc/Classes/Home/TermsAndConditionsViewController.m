//
//  TermsAndConditionsViewController.m
//  IMYourDoc
//
//  Created by Sarvjeet on 14/05/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import "AppDelegate.h"
#import "ASIHTTPRequest.h"
#import "TermsAndConditionsViewController.h"


@interface TermsAndConditionsViewController ()

@end


@implementation TermsAndConditionsViewController


#pragma mark - View LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [titleLbl setFont:[UIFont fontWithName:@"CentraleSansRndMedium" size:25.00]];
    }
    else
    {
        [titleLbl setFont:[UIFont fontWithName:@"CentraleSansRndMedium" size:20.00]];
    }

    
    if ([AppDel isConnected])
    {
        secureL.text = @"Securely Connected";
        
        secureIcon.image = [UIImage imageNamed:@"secure_icon"];
    }
    
    else
    {
        secureL.text = @"Not Connected";
        
        secureIcon.image = [UIImage imageNamed:@"unsecure_icon"];
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateConnectivity:) name:XMPPREACHABILITY object:nil];

    
    
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:URLBUILER( @"https://api.imyourdoc.com/SERVICES_AGREEMENT.php")]];

    
    [request setValidatesSecureCertificate:YES];
    
    [request startAsynchronous];
    
    
    __weak ASIHTTPRequest *req = request;
    
    
    [request setCompletionBlock:^{
        
        [conditionsWebV loadData:req.responseData MIMEType:@"text/html" textEncodingName:@"utf-8" baseURL:nil];
    }];

}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [secureL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:15.00]];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [titleLbl setFont:[UIFont fontWithName:@"CentraleSansRndMedium" size:25.00]];
    }
    else
    {
        [titleLbl setFont:[UIFont fontWithName:@"CentraleSansRndMedium" size:20.00]];
    }
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - update Connectivity

- (void) updateConnectivity:(NSNotification *)note
{
    NSDictionary *dict = note.object;
    
    
    secureL.text = [dict objectForKey:@"status"];
    
    
    [secureIcon setImage:[UIImage imageNamed:[dict objectForKey:@"image"]]];
}


@end
