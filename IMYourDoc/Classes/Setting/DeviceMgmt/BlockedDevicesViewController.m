//
//  BlockedDevicesViewController.m
//  IMYourDoc
//
//  Created by Manpreet on 05/02/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import "BlockedDevicesViewController.h"


@interface BlockedDevicesViewController ()
{
    BOOL bool_BDeviceFetchRetry, bool_BDeviceRetry, bool_BDeviceFetchFirstTime, bool_BDeviceFirstTime;

}

@end


@implementation BlockedDevicesViewController


#pragma mark - View LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.selectedDevice = [[NSMutableArray alloc] init];
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
    
    [self blockDeviceFetch];
    
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

- (void)blockDeviceFetch
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
            self.blockedArr = [response objectForKey:@"device_list"];
            
            if ([self.blockedArr count] > 0)
            {
                [blockedTable reloadData];
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
        {    [AppDel signOutFromAppSilent];
            [[RDCallbackAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] cancelButtonTitle:nil andCompletionHandler:^(int btnIndex)
             
             {
             

             } otherButtonTitles:@"OK", nil];
        }
    }
    
    if ([WebHelper sharedHelper].tag == S_BlockDevice)
    {
        if ([[response objectForKey:@"err-code"] intValue] == 600)    // Session expired
        {
            
            [AppDel signOutFromAppSilent];
            
            
            [[RDCallbackAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] cancelButtonTitle:nil andCompletionHandler:^(int btnIndex)
             
             {
                 
                 
             } otherButtonTitles:@"OK", nil];
        }

        else
        {
            [[[UIAlertView alloc] initWithTitle:@"" message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
            
            [self blockDeviceFetch];
        }
        
    }
    
    else if ([WebHelper sharedHelper].tag == S_UnblockDevice)
    {
        if ([[response objectForKey:@"err-code"] intValue] == 600)    // Session expired
        {
            
            [AppDel signOutFromAppSilent];
            
            
            [[RDCallbackAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] cancelButtonTitle:nil andCompletionHandler:^(int btnIndex)
             
             {
                 
                 
             } otherButtonTitles:@"OK", nil];
        }

        else
        {
            [[[UIAlertView alloc] initWithTitle:@"" message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
            
            [self blockDeviceFetch];
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
            [self performSelector:@selector(blockDeviceFetch) withObject:nil afterDelay:0.9];
        }
        else
        {
            [[RDCallbackAlertView alloc] initWithTitle:nil message:@"Cannot detect Internet connection" cancelButtonTitle:nil andCompletionHandler:^(int btnIDX)
             {
                 
                 if (btnIDX==0)
                 {
                     bool_BDeviceFetchRetry = YES;
                     
                     [self blockDeviceFetch];
                     
                 }
                 if (btnIDX==1)
                 {
                     bool_BDeviceFetchRetry = NO;
                     
                     [self.navigationController popViewControllerAnimated:YES];
                 }
                 
             } otherButtonTitles:@"Retry" ,@"Try Later", nil];
            
        }
    }
    else if ([WebHelper sharedHelper].tag == S_BlockDevice)
    {
        if (bool_BDeviceRetry)
        {
            [self performSelector:@selector(blockMethod) withObject:nil afterDelay:0.9];
        }
        else
        {
            [[RDCallbackAlertView alloc] initWithTitle:nil message:@"Cannot detect Internet connection" cancelButtonTitle:nil andCompletionHandler:^(int btnIDX)
             {
                 
                 if (btnIDX==0)
                 {
                     bool_BDeviceRetry = YES;
                     
                     [self blockMethod];
                     
                 }
                 if (btnIDX==1)
                 {
                     bool_BDeviceRetry = NO;
                 }
                 
             } otherButtonTitles:@"Retry" ,@"Try Later", nil];
            
        }

    }
    else if ([WebHelper sharedHelper].tag == S_UnblockDevice)
    {
        if (bool_BDeviceRetry)
        {
            [self performSelector:@selector(unblockMethod) withObject:nil afterDelay:0.9];
        }
        else
        {
            [[RDCallbackAlertView alloc] initWithTitle:nil message:@"Cannot detect Internet connection" cancelButtonTitle:nil andCompletionHandler:^(int btnIDX)
             {
                 
                 if (btnIDX==0)
                 {
                     bool_BDeviceRetry = YES;
                     
                     [self unblockMethod];
                     
                 }
                 if (btnIDX==1)
                 {
                     bool_BDeviceRetry = NO;
                 }
                 
             } otherButtonTitles:@"Retry" ,@"Try Later", nil];
            
        }
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Unable to connect to the server, Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}


#pragma mark - XML Parser

- (void)processCompleted:(NSDictionary *)object
{
    self.blockedArr = [[NSUserDefaults standardUserDefaults] objectForKey:@"BlockDevices"];
    
    
    [blockedTable reloadData];
    
    
    [AppDel hideSpinner];
}


- (void)processHasErrors
{
    [AppDel hideSpinner];
    
    
    [[[UIAlertView alloc] initWithTitle:nil message:@"Unable to fetch devices. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}


#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.blockedArr.count;
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
    
    cell.textLabel.text = [[self.blockedArr objectAtIndex:indexPath.row] objectAtIndex:1];
    
    
    if ([[[self.blockedArr objectAtIndex:indexPath.row] objectAtIndex:2] isEqualToString:@"Active"])
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
    
    
    self.selectedDevice = [self.blockedArr objectAtIndex:indexPath.row];
    
    
    if ([[[self.blockedArr objectAtIndex:indexPath.row] objectAtIndex:2] isEqualToString:@"Active"])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Are you sure you want to block this device?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Block", nil];
        
        alert.tag = 2;
        
        bool_BDeviceFirstTime = YES;
        
        [alert show];
    }
    
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Are you sure you want to unblock this device?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Unblock", nil];
        
        alert.tag = 3;
        
        bool_BDeviceFirstTime = YES;
        
        [alert show];
    }
}


#pragma mark - Alert

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 2)         //Block
    {
        if (buttonIndex != alertView.cancelButtonIndex)
        {
            if ([AppDel appIsDisconnected] && bool_BDeviceFirstTime)
            {
                [AppData showAlertWithTitle:nil andMessage:@"No Connection." inVC:self];
            }
            
            else
            {
                [self blockMethod];
            }
        }
        else
        {
        }
    }
    
    else if (alertView.tag == 3)    //Unblock
    {
        if (buttonIndex != alertView.cancelButtonIndex)
        {
            if ([AppDel appIsDisconnected])
            {
                [AppData showAlertWithTitle:nil andMessage:@"No Connection." inVC:self];
            }
            
            else
            {
                [self unblockMethod];
            }
        }
    }
    
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }

 }


- (void)blockMethod
{
    if (bool_BDeviceRetry && !bool_BDeviceFirstTime)
    {
        [AppDel showSpinnerWithText:@"Retrying..."];
        
        bool_BDeviceRetry = NO;
    }
    else
    {
        [AppDel showSpinnerWithText:@"Blocking..."];
        
        bool_BDeviceRetry = YES;
        
        bool_BDeviceFirstTime = NO;
    }
    
    
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          
                          @"manageUserDevice", @"method",
                          
                          [[NSUserDefaults standardUserDefaults] objectForKey:@"loginToken"], @"login_token",
                          
                          [self.selectedDevice objectAtIndex:0], @"device_id",
                          
                          @"Active", @"status",
                          
                          nil];
    
    [[WebHelper sharedHelper] setWebHelperDelegate:self];
    
    [[WebHelper sharedHelper] sendRequest:dict tag:S_BlockDevice delegate:self];
}


- (void)unblockMethod
{
    if (bool_BDeviceRetry && !bool_BDeviceFirstTime)
    {
        [AppDel showSpinnerWithText:@"Retrying..."];
        
        bool_BDeviceRetry = NO;
    }
    else
    {
        [AppDel showSpinnerWithText:@"Unblocking..."];
        
        bool_BDeviceRetry = YES;
        
        bool_BDeviceFirstTime = NO;
    }
    
   
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          
                          @"manageUserDevice", @"method",
                          
                          [[NSUserDefaults standardUserDefaults] objectForKey:@"loginToken"], @"login_token",
                          
                          [self.selectedDevice objectAtIndex:0], @"device_id",
                          
                          @"Blocked", @"status",
                          
                          nil];
    
    [[WebHelper sharedHelper] setWebHelperDelegate:self];
    
    [[WebHelper sharedHelper] sendRequest:dict tag:S_UnblockDevice delegate:self];
}


#pragma mark - Set required fonts

- (void)setRequiredFonts
{
    
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

