//
//  PendingGenricViewController.m
//  IMYourDoc
//
//  Created by OSX on 02/09/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import "PendingGenricViewController.h"

@interface PendingGenricViewController ()
{
        BOOL boolService_getUserProfileOther, boolService_respondToInvitationV2;
}

@end

@implementation PendingGenricViewController
@synthesize dict_passingArumentsOfUser,dict_profile;

- (void)viewDidLoad {
    [super viewDidLoad];
    boolService_getUserProfileOther=boolService_respondToInvitationV2=NO;
    
    [self service_getUserProfileOther];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark - actions

- (IBAction)mailTap
{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
        
        mailComposer.mailComposeDelegate = self;
        
        [mailComposer setToRecipients:[NSArray arrayWithObject:[dict_profile valueForKey:@"email"]]];
        
        [self presentViewController:mailComposer animated:YES completion:NULL];
    }
    
    else
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"You need to setup an email account on your device in order to send emails." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}
- (IBAction)phoneTap
{
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@", [dict_profile valueForKey:@"phone"]]]])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@", [dict_profile valueForKey:@"phone"]]]];
    }
    
    else
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Call facility is not available on your device." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}
- (IBAction)action_acceptTap{
    [self services_respondToInvitationV2PendingMethodWithStatus:@"approved"];

}
- (IBAction)action_DeclineTap{
    
    if ([[dict_passingArumentsOfUser objectForKey:@"status"]isEqualToString:@"declined"])
    {
        [[AppDel navController] popViewControllerAnimated:YES];
        
    }
    else{
          [self services_respondToInvitationV2PendingMethodWithStatus:@"declined"];
    }
    
}
- (IBAction)action_FlagTap{
        [self services_respondToInvitationV2PendingMethodWithStatus:@"flagged"];
}

#pragma mark - helper method
- (void)populateData
{
    lbl_nameDes.text=[NSString stringWithFormat:@"%@",[dict_profile objectForKey:@"name"]];
    lbl_jobProfile.text=[NSString stringWithFormat:@"%@",[dict_profile objectForKey:@"job_title"]];
    lbl_userName.text=[NSString stringWithFormat:@"%@",[dict_profile objectForKey:@"user_name"]];
    lbl_practiceType.text = [dict_profile valueForKey:@"practice_type"];
    lbl_HospitalNetwork.text = [dict_profile valueForKey:@"primary_hospital"];
    [mailBtn setTitle:[dict_profile valueForKey:@"email"] forState:UIControlStateNormal];
    [phoneBtn setTitle:[dict_profile  valueForKey:@"phone"] forState:UIControlStateNormal];
    
    
    if ([[dict_profile  valueForKey:@"designation"] isEqualToString: @""])
    {
        lbl_nameDes.text = [dict_profile  valueForKey:@"name"];
    }
    
    else
    {
        lbl_nameDes.text = [NSString stringWithFormat:@"%@, %@", [dict_profile  valueForKey:@"name" ], [dict_profile  valueForKey:@"designation"]];
    }
    
    
    
    
    if ([[dict_profile objectForKey:@"other_hospitals"] count]>0)
    {
        [hospListTB reloadData];
    }
    
    
    
}



-(void)service_getUserProfileOther
{
    
    

    
    
   
       if (boolService_getUserProfileOther )
       {
           [AppDel showSpinnerWithText:@"Retrying..."];
   
           boolService_getUserProfileOther = NO;
       }
       else
       {
           [AppDel showSpinnerWithText:@"Processing ..."];
   
           boolService_getUserProfileOther = YES;
   
 
       }
   
    
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"getUserProfileOther", @"method",
                          [dict_passingArumentsOfUser objectForKey:@"user_name"], @"to_user_name",
                          [[NSUserDefaults standardUserDefaults] objectForKey:@"loginToken"], @"login_token",
                          nil];
    [[WebHelper sharedHelper]servicesWebHelperWith:dict successBlock:^(BOOL succeeded, NSDictionary *response)
     {
         [AppDel hideSpinner];
         if ([[response objectForKey:@"err-code"] intValue] == 1)    // Success
         {
             dict_profile =[response mutableCopy];
             
             [self populateData ];
             
             
             
         }
         
         else if ([[response objectForKey:@"err-code"] intValue] == 600)    // Session expired
         {
             [AppDel signOutFromAppSilent];
             
             [[RDCallbackAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] cancelButtonTitle:nil andCompletionHandler:^(int btnIndex)
              
              {
                  
                  
              } otherButtonTitles:@"OK", nil];
         }
         
         else if ([[response objectForKey:@"err-code"] intValue] == 300)    // Unable to proceed
         {
             [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
         }
         
         
         
         
     } failureBlock:^(BOOL succeeded, NSDictionary *resultdict)
     {
         [AppDel hideSpinner];
         
         if (boolService_getUserProfileOther)
         {
             [self performSelector:@selector(service_getUserProfileOther) withObject:nil afterDelay:.9];
         }
         else
         {
             [[RDCallbackAlertView alloc] initWithTitle:nil message:@"Cannot detect Internet connection" cancelButtonTitle:nil andCompletionHandler:^(int btnIDX)
              {
                  
                  if (btnIDX==0)
                  {
                      boolService_getUserProfileOther=YES;
                      
                      [self service_getUserProfileOther];
                  }
                  if (btnIDX==1)
                  {
                      boolService_getUserProfileOther=NO;
                      
                      [[AppDel navController] popViewControllerAnimated:YES];
                  }
                  
              } otherButtonTitles:@"Retry" ,@"Try Later", nil];
         }
         
     }];
    
    
    

    
    
    
}





- (void)services_respondToInvitationV2PendingMethodWithStatus: (NSString *)status
{
    if (boolService_respondToInvitationV2)
    {
        [AppDel showSpinnerWithText:@"Retrying..."];
        
        boolService_respondToInvitationV2 = NO;
    }
    else
    {
        [AppDel showSpinnerWithText:@"Processing ..."];
        
        boolService_respondToInvitationV2 = YES;
        
        
    }
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          
                          @"respondToInvitationV2", @"method",
                          
                          [[NSUserDefaults standardUserDefaults] objectForKey:@"loginToken"], @"login_token",
                          
                          [dict_passingArumentsOfUser  objectForKey:@"user_name"], @"user_name",
                          
                          status, @"status",
                          
                          nil];
    [[WebHelper sharedHelper]servicesWebHelperWith:dict successBlock:^(BOOL succeeded, NSDictionary *response)
     {
           [AppDel hideSpinner];
         if ([[response objectForKey:@"err-code"] intValue] == 1)    // Success
         {
             [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
              [[AppDel navController] popViewControllerAnimated:YES];
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
              [[AppDel navController] popViewControllerAnimated:YES];
         }
         
         
         else if ([[response objectForKey:@"err-code"] intValue] == 700)    // Feature  disabled
         {
             [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
               [[AppDel navController] popViewControllerAnimated:YES];
         }
         
         
         
     } failureBlock:^(BOOL succeeded, NSDictionary *resultdict)
     {
             [AppDel hideSpinner];
         
         
         if (boolService_respondToInvitationV2)
         {
             [self performSelector:@selector(services_respondToInvitationV2PendingMethodWithStatus:) withObject:status afterDelay:.9];
         }
         else
         {
             [[RDCallbackAlertView alloc] initWithTitle:nil message:@"Cannot detect Internet connection" cancelButtonTitle:nil andCompletionHandler:^(int btnIDX)
              {
                  
                  if (btnIDX==0)
                  {
                      boolService_respondToInvitationV2=YES;
                      
                      [self services_respondToInvitationV2PendingMethodWithStatus:status];
                  }
                  if (btnIDX==1)
                  {
                      boolService_respondToInvitationV2=NO;
                      
                      [[AppDel navController] popViewControllerAnimated:YES];
                  }
                  
              } otherButtonTitles:@"Retry" ,@"Try Later", nil];
         }
         
         
     }];
    
    
    
    
    

    
    
    
}

#pragma mark- mail composer

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    if (result == MFMailComposeResultSent)
    {
        [[[UIAlertView alloc] initWithTitle:@"Sent" message:@"Email has been sent successfully." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    
    else if (result == MFMailComposeResultSaved)
    {
        [[[UIAlertView alloc] initWithTitle:@"Saved" message:@"Mail has been saved successfully." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    
    else if (result == MFMailComposeResultFailed)
    {
        [[[UIAlertView alloc] initWithTitle:@"Failed" message:@"Oops. Email didn't send. Try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    
    else if (result == MFMailComposeResultCancelled)
    {
        //[[[UIAlertView alloc] initWithTitle:@"Cancelled" message:@"Mail sending has been cancelled." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    
    
    [controller dismissViewControllerAnimated:YES completion:NULL];
}



#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[dict_profile objectForKey:@"other_hospitals"] count];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat ht;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        ht = 60;
    }
    
    else
    {
        ht = 45;
    }
    
    return ht;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HospitalListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HospitalListCell"];
    
    
    if (cell == nil)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"HospitalListCell" owner:self options:nil] lastObject];
    }
    
    
    cell.hospNameL.text = [NSString stringWithFormat:@"%@, %@", [[[dict_profile objectForKey:@"other_hospitals"] objectAtIndex:indexPath.row] valueForKey:@"name"], [[[dict_profile objectForKey:@"other_hospitals"] objectAtIndex:indexPath.row] valueForKey:@"city"]];
    
    
    return cell;
}


@end
