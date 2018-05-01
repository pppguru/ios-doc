//
//  SearchPatientViewController.m
//  IMYourDoc
//
//  Created by Sarvjeet on 30/01/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import "SearchViewController.h"
#import "SearchPatientViewController.h"


@interface SearchPatientViewController ()
{
    BOOL bool_SearchPatRetry, bool_SearchPatFirstTime;
}

@end


@implementation SearchPatientViewController


#pragma mark - View LifeCycle

- (void) viewDidLoad
{
    [super viewDidLoad];
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    [self setRequiredFont2];
    
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
}


- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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

- (IBAction) navBack
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)searchPatient
{
    [self.view endEditing:YES];
    
    
    if (txt_userName.text.length == 0 && patientNameTF.text.length == 0 )
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Please enter the patient's first or last name." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        
        
        return;
    }
    
    
    if ([AppDel appIsDisconnected])
    {
        [AppData showAlertWithTitle:nil andMessage:@"No Connection." inVC:self];
        
        
        return;
    }
    
    bool_SearchPatFirstTime = YES;
    
    [self searchPatientMethod];
}


- (void)searchPatientMethod
{
    NSString *patientName = ([patientNameTF.text exactLength] == 0 ? @"" : [patientNameTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]);
    NSString *userName = ([txt_userName.text exactLength] == 0 ? @"" : [txt_userName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]);
    
    
    
    searchDict = [NSDictionary dictionaryWithObjectsAndKeys:
                  
                  @"search", @"method",
                  
                  @"Patient", @"user_type",
                  
                  userName, @"username",
                  
                  patientName, @"name",
                  
                  [[NSUserDefaults standardUserDefaults] objectForKey:@"loginToken"], @"login_token",
                  
                  [NSNumber numberWithInt:0], @"start",
                  
                  nil];
    
    
    if (bool_SearchPatRetry && !bool_SearchPatFirstTime)
    {
        [AppDel showSpinnerWithText:@"Retrying..."];
        
        bool_SearchPatRetry = NO;
    }
    else
    {
        [AppDel showSpinnerWithText:@"Searching..."];
        
        bool_SearchPatRetry = YES;
        
        bool_SearchPatFirstTime = NO;
    }

    //[AppDel showSpinnerWithText:@"Searching..."];
    
    [[WebHelper sharedHelper] setWebHelperDelegate:self];
    
    [[WebHelper sharedHelper] sendRequest:searchDict tag:S_SearchPatient delegate:self];
}


#pragma mark - Update Connectivity

- (void)updateConnectivity:(NSNotification *)note
{
    NSDictionary *dict = note.object;
    
    
    secureL.text = [dict objectForKey:@"status"];
    
    
    [secureIcon setImage:[UIImage imageNamed:[dict objectForKey:@"image"]]];
}


#pragma mark - TextField

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == txt_userName)
    {
        [txt_userName resignFirstResponder];
        
        [patientNameTF becomeFirstResponder];
        
    }
    
    
    else if (textField == patientNameTF)
    {
        [patientNameTF resignFirstResponder];
    }
    
    
    return YES;
}


#pragma mark - Request

- (void)didReceivedresponse:(NSDictionary *)response
{
    [AppDel hideSpinner];
    
    
    if ([WebHelper sharedHelper].tag == S_SearchPatient)    // Search Patient
    {
        if ([[response objectForKey:@"err-code"] isEqualToString:@"1"])
        {
            if ([[response objectForKey:@"users"] count])
            {
                SearchViewController *sVC = [[SearchViewController alloc] initWithNibName:@"SearchViewController" bundle:nil];
                
                sVC.searchParam = [NSMutableDictionary dictionaryWithDictionary:searchDict];
                
                [sVC.searchParam setObject:[response objectForKey:@"has_more"] forKey:@"hasMore"];
                
                [sVC.searchParam setObject:([patientNameTF.text exactLength] == 0 ? @"" : [patientNameTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]) forKey:@"patName"];
                
                sVC.searchType = 3;
                
                sVC.searchArr = [[response objectForKey:@"users"] mutableCopy];
                
                [sVC.searchArr sortUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"first_name" ascending:YES]]];
                
                [self.navigationController pushViewController:sVC animated:YES];
            }
            
            else
            {
                [[[UIAlertView alloc] initWithTitle:nil message:@"No User found." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
            }
            
        }
        
        else if ([[response objectForKey:@"err-code"] intValue] == 600)    // Session expired
        {
            
            [AppDel signOutFromAppSilent];
            
            
            [[RDCallbackAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] cancelButtonTitle:nil andCompletionHandler:^(int btnIndex)
             
             {
                 
                 
             } otherButtonTitles:@"OK", nil];
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
    if ([WebHelper sharedHelper].tag == S_SearchPatient)    // Search Patient
    {
        if (bool_SearchPatRetry)
        {
            [self performSelector:@selector(searchPatientMethod) withObject:nil afterDelay:0.9];
        }
        else
        {
            [[RDCallbackAlertView alloc] initWithTitle:nil message:@"Cannot detect Internet connection" cancelButtonTitle:nil andCompletionHandler:^(int btnIDX)
             {
                 
                 if (btnIDX==0)
                 {
                     bool_SearchPatRetry = YES;
                     
                     [self searchPatientMethod];
                     
                 }
                 if (btnIDX==1)
                 {
                     bool_SearchPatRetry = NO;
                 }
                 
             } otherButtonTitles:@"Retry" ,@"Try Later", nil];
        }
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Unable to connect to the server, please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

#pragma mark - Set Required Font

- (void)setRequiredFont2
{
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [titleL setFont:[UIFont fontWithName:@"CentraleSansRndMedium" size:25.00]];
        
        [patientNameTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
    }
    else
    {
        [titleL setFont:[UIFont fontWithName:@"CentraleSansRndMedium" size:25.00]];
        
        [patientNameTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:17.00]];
    }
}


@end

