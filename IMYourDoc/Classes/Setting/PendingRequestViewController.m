//
//  PendingRequestViewController.m
//  IMYourDoc
//
//  Created by Sarvjeet on 31/01/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import "PendingRequestViewController.h"
#import "PendingPhysicianProfileViewController.h"
#import "PendingStaffProfileViewController.h"
#import "PendingPatientProfileViewController.h"

@interface PendingRequestViewController ()
{
    BOOL bool_FetchListRetry, bool_FetchListFirstTime, bool_RespondRetry, bool_RespondFirstTime;
}

@end


@implementation PendingRequestViewController


#pragma mark - View LifeCycle

- (void) viewDidLoad
{
    [super viewDidLoad];
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    [self setRequiredFont1];
}


- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    [self setRequiredFont1];
    
    bool_FetchListFirstTime = YES;
    
    [self getPendingRequestsAndShowSpinner:YES];
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


#pragma mark - Void

- (void)getPendingRequestsAndShowSpinner:(BOOL)showSpinner
{
    if ([AppDel appIsDisconnected] && bool_FetchListFirstTime)
    {
        [AppData showAlertWithTitle:nil andMessage:@"No Connection." inVC:self];
        
        
        return;
    }
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          
                          @"showRequests", @"method",
                          
                          [[NSUserDefaults standardUserDefaults] objectForKey:@"loginToken"], @"login_token",
                          
                          nil];
    
    [[WebHelper sharedHelper] setWebHelperDelegate:self];
    
    [[WebHelper sharedHelper] sendRequest:dict tag:S_ShowRequestList delegate:self];

    
    if (showSpinner)
    {
        if (bool_FetchListRetry && !bool_FetchListFirstTime)
        {
            [AppDel showSpinnerWithText:@"Retrying..."];
            
            bool_FetchListRetry = NO;
        }
        else
        {
            [AppDel showSpinnerWithText:@"Processing ..."];
            
            bool_FetchListRetry = YES;
            
            bool_FetchListFirstTime = NO;
        }
    }
}


#pragma mark - IBAction

- (IBAction)navBack
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)pendingList
{
    pendingBtn.selected = YES;
    
    declinedBtn.selected = NO;
    
    
    bool_FetchListFirstTime = YES;
    
    [listTB reloadData];
}


- (IBAction)declinedList
{
    pendingBtn.selected = NO;
    
    declinedBtn.selected = YES;
    
    bool_FetchListFirstTime = YES;
    
    [listTB reloadData];
}


#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (pendingBtn.selected)
    {
        return [[self.requestDict objectForKey:@"pending"] count];
    }
    
    else
    {
        return [[self.requestDict objectForKey:@"decline"] count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *tbCell = [tableView dequeueReusableCellWithIdentifier:@"LIST_TB_CELLID"];
    
    
    if (tbCell == nil)
    {
        tbCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"LIST_TB_CELLID"];
    }
    
    
    tbCell.textLabel.font = [UIFont fontWithName:@"CentraleSansRndLight" size:17];
    
    tbCell.detailTextLabel.font = [UIFont fontWithName:@"CentraleSansRndLight" size:14];
    
    
    tbCell.detailTextLabel.textColor = [UIColor lightGrayColor];
    
    
    if (pendingBtn.selected)
    {
        tbCell.textLabel.text = [[[self.requestDict objectForKey:@"pending"] objectAtIndex:indexPath.row] objectForKey:@"receiver_name"];
        
        
        tbCell.detailTextLabel.text = [[[self.requestDict objectForKey:@"pending"] objectAtIndex:indexPath.row] objectForKey:@"User_type"];
    }
    
    else
    {
        tbCell.textLabel.text = [[[self.requestDict objectForKey:@"decline"] objectAtIndex:indexPath.row] objectForKey:@"receiver_name"];
        
        
        tbCell.detailTextLabel.text = [[[self.requestDict objectForKey:@"decline"] objectAtIndex:indexPath.row] objectForKey:@"User_type"];
    }
    
    
    return tbCell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    if ([AppDel appIsDisconnected])
    {
        [AppData showAlertWithTitle:nil andMessage:@"No Connection." inVC:self];
        
        
        return;
    }
    
 
    if (pendingBtn.selected)
    {
        if ([[[[self.requestDict objectForKey:@"pending"] objectAtIndex:indexPath.row]objectForKey:@"user_type"] isEqualToString:@"Physician" ])
        {
            PendingPhysicianProfileViewController *objVC =[[PendingPhysicianProfileViewController alloc]initWithNibName:@"PendingPhysicianProfileViewController" bundle:[NSBundle mainBundle]];
            
            if (pendingBtn.selected)
            {
                objVC.dict_passingArumentsOfUser=[[self.requestDict objectForKey:@"pending"] objectAtIndex:indexPath.row];
                
            }
            else{
                objVC.dict_passingArumentsOfUser=[[self.requestDict objectForKey:@"decline"] objectAtIndex:indexPath.row];
            }
            
            [self.navigationController pushViewController:objVC animated:YES];
            
            
        }
        else        if ([[[[self.requestDict objectForKey:@"pending"] objectAtIndex:indexPath.row]objectForKey:@"user_type"] isEqualToString:@"Staff" ])
        {
            PendingStaffProfileViewController*objVC =[[PendingStaffProfileViewController alloc]initWithNibName:@"PendingStaffProfileViewController" bundle:[NSBundle mainBundle]];
            
            if (pendingBtn.selected)
            {
                objVC.dict_passingArumentsOfUser=[[self.requestDict objectForKey:@"pending"] objectAtIndex:indexPath.row];
                
            }
            else{
                objVC.dict_passingArumentsOfUser=[[self.requestDict objectForKey:@"decline"] objectAtIndex:indexPath.row];
            }
            
            [self.navigationController pushViewController:objVC animated:YES];
            
            
        }
        
        else    if ([[[[self.requestDict objectForKey:@"pending"] objectAtIndex:indexPath.row]objectForKey:@"user_type"] isEqualToString:@"Patient" ])
        {
            PendingPatientProfileViewController *objVC =[[PendingPatientProfileViewController alloc]initWithNibName:@"PendingPatientProfileViewController" bundle:[NSBundle mainBundle]];
            
            if (pendingBtn.selected)
            {
                objVC.dict_passingArumentsOfUser=[[self.requestDict objectForKey:@"pending"] objectAtIndex:indexPath.row];
                
            }
            else{
                objVC.dict_passingArumentsOfUser=[[self.requestDict objectForKey:@"decline"] objectAtIndex:indexPath.row];
            }
            
            [self.navigationController pushViewController:objVC animated:YES];
            
            
        }
        
    }
    else{
        
        if ([[[[self.requestDict objectForKey:@"decline"] objectAtIndex:indexPath.row]objectForKey:@"user_type"] isEqualToString:@"Physician" ])
        {
            PendingPhysicianProfileViewController *objVC =[[PendingPhysicianProfileViewController alloc]initWithNibName:@"PendingPhysicianProfileViewController" bundle:[NSBundle mainBundle]];
            
            if (pendingBtn.selected)
            {
                objVC.dict_passingArumentsOfUser=[[self.requestDict objectForKey:@"pending"] objectAtIndex:indexPath.row];
                
            }
            else{
                objVC.dict_passingArumentsOfUser=[[self.requestDict objectForKey:@"decline"] objectAtIndex:indexPath.row];
            }
            
            [self.navigationController pushViewController:objVC animated:YES];
            
            
        }
        else        if ([[[[self.requestDict objectForKey:@"decline"] objectAtIndex:indexPath.row]objectForKey:@"user_type"] isEqualToString:@"Staff" ])
        {
            PendingStaffProfileViewController*objVC =[[PendingStaffProfileViewController alloc]initWithNibName:@"PendingStaffProfileViewController" bundle:[NSBundle mainBundle]];
            
            if (pendingBtn.selected)
            {
                objVC.dict_passingArumentsOfUser=[[self.requestDict objectForKey:@"pending"] objectAtIndex:indexPath.row];
                
            }
            else{
                objVC.dict_passingArumentsOfUser=[[self.requestDict objectForKey:@"decline"] objectAtIndex:indexPath.row];
            }
            
            [self.navigationController pushViewController:objVC animated:YES];
            
            
        }
        
        else    if ([[[[self.requestDict objectForKey:@"decline"] objectAtIndex:indexPath.row]objectForKey:@"user_type"] isEqualToString:@"Patient" ])
        {
            PendingPatientProfileViewController *objVC =[[PendingPatientProfileViewController alloc]initWithNibName:@"PendingPatientProfileViewController" bundle:[NSBundle mainBundle]];
            
            if (pendingBtn.selected)
            {
                objVC.dict_passingArumentsOfUser=[[self.requestDict objectForKey:@"pending"] objectAtIndex:indexPath.row];
                
            }
            else{
                objVC.dict_passingArumentsOfUser=[[self.requestDict objectForKey:@"decline"] objectAtIndex:indexPath.row];
            }
            
            [self.navigationController pushViewController:objVC animated:YES];
            
            
        }
        
        
    }


    
    
}


- (void)respondToInvitationV2PendingMethod: (NSIndexPath *)indexPath withStatus: (NSString *)status
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          
                          @"respondToInvitationV2", @"method",
                          
                          [[NSUserDefaults standardUserDefaults] objectForKey:@"loginToken"], @"login_token",
                          
                          [[[self.requestDict objectForKey:@"pending"] objectAtIndex:indexPath.row] objectForKey:@"user_name"], @"user_name",
                          
                          status, @"status",
                          
                          nil];
    
    [[WebHelper sharedHelper] setWebHelperDelegate:self];
    
    [[WebHelper sharedHelper] sendRequest:dict tag:S_RespondToInvitationV2 delegate:self];
    
    
    if (bool_RespondRetry && !bool_RespondFirstTime)
    {
        [AppDel showSpinnerWithText:@"Retrying..."];
        
        bool_RespondRetry = NO;
    }
    else
    {
        [AppDel showSpinnerWithText:@"Processing ..."];
        
        bool_RespondRetry = YES;
        
        bool_RespondFirstTime = NO;
    }

    
 
}


- (void)respondToInvitationV2DeclineMethod: (NSIndexPath *)indexPath withStatus: (NSString *)status
{
    if (bool_RespondRetry && !bool_RespondFirstTime)
    {
        [AppDel showSpinnerWithText:@"Retrying..."];
        
        bool_RespondRetry = NO;
    }
    else
    {
        [AppDel showSpinnerWithText:@"Processing ..."];
        
        bool_RespondRetry = YES;
        
        bool_RespondFirstTime = NO;
    }

    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          
                          @"respondToInvitationV2", @"method",
                          
                          [[NSUserDefaults standardUserDefaults] objectForKey:@"loginToken"], @"login_token",
                          
                          [[[self.requestDict objectForKey:@"decline"] objectAtIndex:indexPath.row] objectForKey:@"user_name"], @"user_name",
                          
                          status, @"status",
                          
                          nil];
    
    [[WebHelper sharedHelper] setWebHelperDelegate:self];
    
    [[WebHelper sharedHelper] sendRequest:dict tag:S_RespondToInvitationV2 delegate:self];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}


#pragma mark - Service Response

- (void)didReceivedresponse:(NSDictionary *)response
{
    [AppDel hideSpinner];
    
    
    if ([WebHelper sharedHelper].tag == S_ShowRequestList)
    {
        if ([[response objectForKey:@"err-code"] intValue] == 1)    // Success
        {
            self.requestDict = [response mutableCopy];
            
            [NSMutableDictionary dictionaryWithDictionary:[response objectForKey:@"requests"]];
            
            
            [listTB reloadData];
        }
        
        else if ([[response objectForKey:@"err-code"] intValue] == 600)    // Session expired
        {  [AppDel signOutFromAppSilent];
            [[RDCallbackAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] cancelButtonTitle:nil andCompletionHandler:^(int btnIndex)
             
             {
               
                 
             } otherButtonTitles:@"OK", nil];
        }
        
        else if ([[response objectForKey:@"err-code"] intValue] == 300)    // Unable to proceed
        {
            [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }
    
    else if ([WebHelper sharedHelper].tag == S_RespondToInvitationV2)
    {
        if ([[response objectForKey:@"err-code"] intValue] == 1)    // Success
        {
            [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            [self getPendingRequestsAndShowSpinner:YES];
        }
        
        else if ([[response objectForKey:@"err-code"] intValue] == 600)    // Session expired
        { [AppDel signOutFromAppSilent];
            [[RDCallbackAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] cancelButtonTitle:nil andCompletionHandler:^(int btnIndex)
             
             {
                
                 
             } otherButtonTitles:@"OK", nil];
        }
        
        else if ([[response objectForKey:@"err-code"] intValue] == 300)    // Unable to proceed
        {
            [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        
        
        else if ([[response objectForKey:@"err-code"] intValue] == 700)    // Feature  disabled
        {
            [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }
}
- (void)didFailedWithError: (NSError *) error
{
    [AppDel hideSpinner];
    
    
    if ([WebHelper sharedHelper].tag == S_ShowRequestList)
    {
        if (bool_FetchListRetry)
        {
            double delayInSeconds = 0.02;
            
            dispatch_time_t delay = dispatch_time (DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            
            dispatch_after(delay, dispatch_get_main_queue(), ^{
               
                [self getPendingRequestsAndShowSpinner:YES];
                
            });
        }
        else
        {
            [[RDCallbackAlertView alloc] initWithTitle:nil message:@"Cannot detect Internet connection" cancelButtonTitle:nil andCompletionHandler:^(int btnIDX)
             {
                 if (btnIDX==0)
                 {
                     bool_FetchListRetry = YES;
                     
                     [self getPendingRequestsAndShowSpinner: YES];
                     
                 }
                 if (btnIDX==1)
                 {
                     bool_FetchListRetry = NO;
                 }
                 
             } otherButtonTitles:@"Retry" ,@"Try Later", nil];
        }
    }
    else if ([WebHelper sharedHelper].tag == S_RespondToInvitationV2)
    {
        if (pendingBtn.selected)
        {
            if (bool_RespondRetry)
            {
                double delayInSeconds = 0.02;
                
                dispatch_time_t delay = dispatch_time (DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                
                dispatch_after(delay, dispatch_get_main_queue(), ^{
                    
                    [self respondToInvitationV2PendingMethod:indexPathBlockParam withStatus:statusBlockParam];
                    
                });
            }
            else
            {
                [[RDCallbackAlertView alloc] initWithTitle:nil message:@"Cannot detect Internet connection" cancelButtonTitle:nil andCompletionHandler:^(int btnIDX)
                 {
                     if (btnIDX==0)
                     {
                         bool_RespondRetry = YES;
                         
                         [self getPendingRequestsAndShowSpinner: YES];
                         
                     }
                     if (btnIDX==1)
                     {
                         bool_RespondRetry = NO;
                     }
                     
                 } otherButtonTitles:@"Retry" ,@"Try Later", nil];
            }
        }
        else
        {
            if (bool_RespondRetry)
            {
                double delayInSeconds = 0.02;
                
                dispatch_time_t delay = dispatch_time (DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                
                dispatch_after(delay, dispatch_get_main_queue(), ^{
                    
                    [self respondToInvitationV2DeclineMethod:indexPathBlockParam withStatus:statusBlockParam];
                    
                });
            }
            else
            {
                [[RDCallbackAlertView alloc] initWithTitle:nil message:@"Cannot detect Internet connection" cancelButtonTitle:nil andCompletionHandler:^(int btnIDX)
                 {
                     if (btnIDX==0)
                     {
                         bool_RespondRetry = YES;
                         
                         [self getPendingRequestsAndShowSpinner: YES];
                         
                     }
                     if (btnIDX==1)
                     {
                         bool_RespondRetry = NO;
                     }
                     
                 } otherButtonTitles:@"Retry" ,@"Try Later", nil];
            }

        }
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Unable to connect to the server, Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}


#pragma mark - Set required font

- (void)setRequiredFont1
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

