//
//  RegisteredDevicesViewController.m
//  IMYourDoc
//
//  Created by Manpreet on 05/02/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import "RegisteredDevicesViewController.h"


@interface RegisteredDevicesViewController ()
{
    BOOL bool_BDeviceFetchRetry,  bool_BDeviceFetchFirstTime;
}

@end


@implementation RegisteredDevicesViewController


#pragma mark - View LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.registeredArr = [[NSMutableArray alloc] init];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    [self setRequiredFont1];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    bool_BDeviceFetchFirstTime = YES;
    
    [self fetchRegisteredDeviceApi];
    
    [self setRequiredFont1];
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


#pragma mark - Void

- (void)fetchRegisteredDeviceApi
{
    if ([AppDel appIsDisconnected] && bool_BDeviceFetchFirstTime)
    {
        [AppData showAlertWithTitle:nil andMessage:@"No Connection." inVC:self];
    }
    
    else
    {
        if (bool_BDeviceFetchRetry && !bool_BDeviceFetchFirstTime)
        {
            [AppDel showSpinnerWithText:@"Retrying..."];
            
            bool_BDeviceFetchRetry = NO;
        }
        else
        {
            [AppDel showSpinnerWithText:@"Requesting..."];
            
            bool_BDeviceFetchRetry = YES;
            
            bool_BDeviceFetchFirstTime = NO;
        }
        
        
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              
                              @"showUserDevice", @"method",
                              
                              [[NSUserDefaults standardUserDefaults] objectForKey:@"loginToken"], @"login_token",
                              
                              nil];
        
        [[WebHelper sharedHelper] setWebHelperDelegate:self];
        
        [[WebHelper sharedHelper] sendRequest:dict tag:S_UserDevicesList delegate:self];
    }
    
}


#pragma mark - IBAction

- (IBAction)backTap
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Request


- (void)didReceivedresponse:(NSDictionary *)response
{
    [AppDel hideSpinner];
    
    if ([WebHelper sharedHelper].tag == S_UserDevicesList)
    {
        if ([[response objectForKey:@"err-code"] intValue] == 1)    // List of Devices
        {
            self.registeredArr = [response objectForKey:@"device_list"];
            
            if ([self.registeredArr count] > 0)
            {
                [registeredTable reloadData];
            }
            
            else
            {
                [[[UIAlertView alloc] initWithTitle:nil message:@"No Device Registered" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
        }
        
        else if ([[response objectForKey:@"err-code"] intValue] == 300)    // Unable to proceed
        {
            [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        
        else if ([[response objectForKey:@"err-code"] intValue] == 600)    // Session expire
        {
            [AppDel signOutFromAppSilent];
            
            [[RDCallbackAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] cancelButtonTitle:nil andCompletionHandler:^(int btnIndex)
             
             {
                
                 
             } otherButtonTitles:@"OK", nil];
        }
    }
}


- (void)didFailedWithError: (NSError *) error
{
    [AppDel hideSpinner];
    
    if ([WebHelper sharedHelper].tag == S_UserDevicesList)
    {
        if (bool_BDeviceFetchRetry)
        {
            [self performSelector:@selector(fetchRegisteredDeviceApi) withObject:nil afterDelay:0.9];
        }
        else
        {
            [[RDCallbackAlertView alloc] initWithTitle:nil message:@"Cannot detect Internet connection" cancelButtonTitle:nil andCompletionHandler:^(int btnIDX)
             {
                 
                 if (btnIDX==0)
                 {
                     bool_BDeviceFetchRetry = YES;
                     
                     [self fetchRegisteredDeviceApi];
                     
                 }
                 if (btnIDX==1)
                 {
                     bool_BDeviceFetchRetry = NO;
                 }
                 
             } otherButtonTitles:@"Retry" ,@"Try Later", nil];
            
        }
    }
    else
    {
    [[[UIAlertView alloc] initWithTitle:nil message:@"Unable to connect to the server, Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}


#pragma mark - Alert View

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.registeredArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];
    
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MyIdentifier"];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    
    cell.textLabel.font = [UIFont fontWithName:@"CentraleSansRndLight" size:cell.textLabel.font.pointSize];
    
    cell.textLabel.text = [[self.registeredArr objectAtIndex:indexPath.row] objectAtIndex:1];
    
    if ([[[self.registeredArr objectAtIndex:indexPath.row] objectAtIndex:2] isEqualToString:@"Active"])
    {
        cell.imageView.image = [UIImage imageNamed:@"unblock"];
    }
    else
    {
        cell.imageView.image = [UIImage imageNamed:@"block"];
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



#pragma mark - Set Required Fonts

- (void) setRequiredFont1
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [titleL setFont:[UIFont fontWithName:@"CentraleSansRndMedium" size:25.00]];
    }
    else
    {
        [titleL setFont:[UIFont fontWithName:@"CentraleSansRndMedium" size:20.00]];
    }
}


@end

