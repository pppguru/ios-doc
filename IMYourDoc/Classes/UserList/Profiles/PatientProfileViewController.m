//
//  PatientProfileViewController.m
//  IMYourDoc
//
//  Created by Sarvjeet on 04/02/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import "ChatViewController.h"
#import "PatientProfileViewController.h"



@interface PatientProfileViewController ()
{
    BOOL bool_PatProfileRetry, bool_fetchFirstTime, bool_SendInvitation, bool_RemoveXmppUser, bool_InvitationFirstTime, bool_RemoveUserFirstTime;
}

@end


@implementation PatientProfileViewController


#pragma mark - View LifeCycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    
    self.profileDict = [[NSMutableDictionary alloc] init];
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    [self setRequiredFont2];
    
    profileImg.layer.cornerRadius = profileImg.frame.size.height / 2;
    
    profileImg.layer.masksToBounds = YES;


    if ([AppDel isConnected])
    {
        secureL.text = @"Securely Connected";
        
        secureIcon.image = [UIImage imageNamed:@"secure_icon"];
    }
    
    else
    {
        secureL.text = @"Not Connected";
        
        secureIcon.image = [UIImage imageNamed:@""];
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateConnectivity:) name:XMPPREACHABILITY object:nil];
    
    
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"UserType"] isEqualToString:@"Patient"] || [[[NSUserDefaults standardUserDefaults] valueForKey:@"UserType"] isEqualToString:@"Physician"])
    {
        patientBtn.hidden = YES;
    }
    
    
    XMPPUserCoreDataStorageObject * user=[AppDel fetchUserForJIDString:[[NSString stringWithFormat:@"%@@imyourdoc.com", self.toUserName] lowercaseString]];
    
    if ([user.subscription isEqualToString:@"both"] || [user.subscription isEqualToString:@"from"] )
    {
        
            
            patientBtn.hidden = YES;
            
            removeUserBtn.hidden = NO;

    }
    else
    {
        patientBtn.hidden = NO;
        
        removeUserBtn.hidden = YES;
    }
    
}


- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    
    [self setRequiredFont2];
    
    profileImg.layer.cornerRadius = profileImg.frame.size.height / 2;
    
    profileImg.layer.masksToBounds = YES;

    

    
    NSData *imgData = [[AppDel xmppvCardAvatarModule] photoDataForJID:[XMPPJID jidWithString:[self.toUserName stringByAppendingString:@"@imyourdoc.com"]]];
    
    if (imgData)
    {
        profileImg.image = [UIImage imageWithData:[[AppDel xmppvCardAvatarModule] photoDataForJID:[XMPPJID jidWithString:[self.toUserName stringByAppendingString:@"@imyourdoc.com"]]]];
    }
    
    else
    {
        [profileImg downloadFromURL:[NSURL URLWithString:[NSString stringWithFormat:URLBUILER(@"https://api.imyourdoc.com/profilepic.php?user_name=%@") , self.toUserName]]];
        
        

    }

    
    bool_fetchFirstTime = YES;
    
    [self fetchProfile];
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

- (void)fetchProfile
{
    if ([AppDel appIsDisconnected]  && bool_fetchFirstTime)
    {
        [AppData showAlertWithTitle:nil andMessage:@"No Connection." inVC:self];
        
        return;
    }
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          
                          @"getUserProfileOther", @"method",
                          
                          self.toUserName, @"to_user_name",
                          
                          [[NSUserDefaults standardUserDefaults] objectForKey:@"loginToken"], @"login_token",
                          
                          nil];
    
    

    
    if (bool_PatProfileRetry && !bool_fetchFirstTime)
    {
        [AppDel showSpinnerWithText:@"Retrying..."];
        
        bool_PatProfileRetry = NO;
    }
    else
    {
        [AppDel showSpinnerWithText:@"Fetching..."];
        
        bool_PatProfileRetry = YES;
        
        bool_fetchFirstTime = NO;
    }

    
    
    [[WebHelper sharedHelper] setWebHelperDelegate:self];
    
    [[WebHelper sharedHelper]sendRequest:dict tag:S_GetPatientProfile delegate:self];
}


- (void)populateData
{
    nameLbl.text = [self.profileDict valueForKey:@"name"];
    
    userNameLbl.text = [NSString stringWithFormat:@"(%@)",[self.profileDict valueForKey:@"user_name"]];
    
    picNumLbl.text = [self.profileDict valueForKey:@"pic_no"];
    
    
    [mailBtn setTitle:[self.profileDict valueForKey:@"email"] forState:UIControlStateNormal];
    
    [phoneBtn setTitle:[self.profileDict valueForKey:@"phone"] forState:UIControlStateNormal];
}


- (void)composeAction:(id)sender
{
    XMPPUserCoreDataStorageObject *user = [AppDel fetchUserForJIDString:[self.toUserName stringByAppendingString:@"@imyourdoc.com"]];
    
    
    ChatViewController *chatViewController = [[ChatViewController alloc] initWithNibName:@"ChatViewController" bundle:nil];
    
    
    if (user)
    {
        chatViewController.forChat = YES;
        if([user.subscription isEqualToString:@"both"])
        chatViewController.user = user;
        
        chatViewController.jid = user.jid;
    }
    
    
    [self.navigationController pushViewController:chatViewController animated:YES];
}


#pragma mark - IBAction

- (IBAction)mailTap
{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
        
        mailComposer.mailComposeDelegate = self;
        
        [mailComposer setToRecipients:[NSArray arrayWithObject:[self.profileDict valueForKey:@"email"]]];
        
        [self presentViewController:mailComposer animated:YES completion:NULL];
    }
    
    else
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"You need to setup an email account on your device in order to send emails." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}


- (IBAction)backTap
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)phoneTap
{
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@", [self.profileDict valueForKey:@"phone"]]]])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@", [self.profileDict valueForKey:@"phone"]]]];
    }
    
    else
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Call facility is not available on your device." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}


- (IBAction)addPatientTap
{
    bool_InvitationFirstTime = YES;
    
    [self addPatientTapMethod];
}


- (void)addPatientTapMethod
{
    if ([AppDel appIsDisconnected])
    {
        [AppData showAlertWithTitle:nil andMessage:@"No Connection." inVC:self];
        
        return;
    }
    
    
    if (self.fromSearch)
    {

        
        if (bool_SendInvitation && !bool_InvitationFirstTime)
        {
            [AppDel showSpinnerWithText:@"Retrying..."];
            
            bool_SendInvitation = NO;
        }
        else
        {
            [AppDel showSpinnerWithText:@"Processing..."];
            
            bool_SendInvitation = YES;
            
            bool_InvitationFirstTime = NO;
        }

        
        
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              
                              @"sendInvitation", @"method",
                              
                              self.toUserName, @"to_user",
                              
                              [[NSUserDefaults standardUserDefaults] objectForKey:@"loginToken"], @"login_token",
                              
                              nil];
        
        [[WebHelper sharedHelper] setWebHelperDelegate:self];
        
        [[WebHelper sharedHelper] sendRequest:dict tag:S_SendInvitation delegate:self];
    }
}


- (IBAction)removeUserTap
{
    bool_RemoveUserFirstTime = YES;
    
    [self removeUserTapMethod];
}


- (void)removeUserTapMethod
{

    
    if (bool_RemoveXmppUser && !bool_RemoveUserFirstTime)
    {
        [AppDel showSpinnerWithText:@"Retrying..."];
        
        bool_RemoveXmppUser = NO;
    }
    else
    {
        [AppDel showSpinnerWithText:@"Processing..."];
        
        bool_RemoveXmppUser = YES;
        
        bool_RemoveUserFirstTime = NO;
    }

    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          
                          @"removeOpenFireUser", @"method",
                          
                          [[NSUserDefaults standardUserDefaults] objectForKey:@"loginToken"], @"login_token",
                          
                          self.toUserName, @"user_name",
                          
                          nil];
    
    [[WebHelper sharedHelper] setWebHelperDelegate:self];
    
    [[WebHelper sharedHelper] sendRequest:dict tag:S_RemoveXMPPUser delegate:self];
}


#pragma mark - Update Connectivity

- (void) updateConnectivity:(NSNotification *)note
{
    NSDictionary *dict = note.object;
    
    
    secureL.text = [dict objectForKey:@"status"];
    
    
    [secureIcon setImage:[UIImage imageNamed:[dict objectForKey:@"image"]]];
}


#pragma mark - Alert View

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Mail

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
       
    }
    
    
    [controller dismissViewControllerAnimated:YES completion:NULL];
}
#pragma mark - Service Response

- (void)didReceivedresponse:(NSDictionary *)response
{
    [AppDel hideSpinner];
    
    if ([WebHelper sharedHelper].tag == S_GetPatientProfile)
    {
        if ([[response objectForKey:@"err-code"] intValue] ==1)    // Success
        {
            self.profileDict = [response mutableCopy];
            
            [self populateData];
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
    }
    
    else if ([WebHelper sharedHelper].tag == S_SendInvitation)
    {
        if ([[response objectForKey:@"err-code"] intValue] == 1)    // Success
        {
            [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        
        else if ([[response objectForKey:@"err-code"] intValue] == 600)    // Session expired
        {    [AppDel signOutFromAppSilent];
            [[RDCallbackAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] cancelButtonTitle:nil andCompletionHandler:^(int btnIndex)
             
             {
             
                 
             } otherButtonTitles:@"OK", nil];
        }
        
        else if ([[response objectForKey:@"err-code"] intValue] == 300)    // Unable to proceed
        {
            [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        
        else if ([[response objectForKey:@"err-code"] intValue] == 404)    // User not found
        {
            [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        
        
    }
    
    else if ([WebHelper sharedHelper].tag == S_RemoveXMPPUser)
    {
        if ([[response objectForKey:@"err-code"] intValue] == 1)    // Success
        {
            [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            
            [self.navigationController popViewControllerAnimated:YES];
        }
        
        else if ([[response objectForKey:@"err-code"] intValue] == 600)    // Session expired
        {[AppDel signOutFromAppSilent];
            [[RDCallbackAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] cancelButtonTitle:nil andCompletionHandler:^(int btnIndex)
             
             {
                 
                 
             } otherButtonTitles:@"OK", nil];
        }
        
        else if ([[response objectForKey:@"err-code"] intValue] == 300)    // Unable to proceed
        {
            [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }
    
    else if ([WebHelper sharedHelper].tag == S_SendInvitationV2)
    {
        if ([[response objectForKey:@"err-code"] intValue] == 1)    // Success
        {
            [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        
        else if ([[response objectForKey:@"err-code"] intValue] == 600)    // Session expired
        {    [AppDel signOutFromAppSilent];
            [[RDCallbackAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] cancelButtonTitle:nil andCompletionHandler:^(int btnIndex)
             
             {
                 
                 
             } otherButtonTitles:@"OK", nil];
        }
        
        /*
        if ([[response objectForKey:@"err-code"] intValue] == 900)    // Success
        {
            
            
            [[RDCallbackAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] cancelButtonTitle:nil andCompletionHandler:^(int btnIndex)
             
             {
                 if (btnIndex==0)
                 {
                     dispatch_sync(dispatch_get_main_queue(),^
                                   {
                                       
                                       
                                       if ([AppDel appIsDisconnected])
                                       {
                                           [AppData showAlertWithTitle:nil andMessage:@"No Connection." inVC:self];
                                           
                                           return;
                                       }
                                       
                                       
                                       [AppDel showSpinnerWithText:@"Processing..."];
                                       
                                       
                                       NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                             
                                                             @"getPaymentKeyDetails", @"method",
                                                             
                                                             
                                                             
                                                             [[NSUserDefaults standardUserDefaults] objectForKey:@"loginToken"], @"login_token",
                                                             
                                                             nil];
                                       
                                       [[WebHelper sharedHelper] setWebHelperDelegate:self];
                                       
                                       [[WebHelper sharedHelper] sendRequest:dict tag:S_GetPaymentKeyDetails delegate:self];

                                   } );
                     
                 }
                 
                 
             } otherButtonTitles:@"YES",@"NO", nil];
            
        }
        
         */
        
        else if ([[response objectForKey:@"err-code"] intValue] == 300)    // Unable to proceed
        {
            [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        
        else if ([[response objectForKey:@"err-code"] intValue] == 404)    // User not found
        {
            [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        
        
    }
    
    /*
    else if ([WebHelper sharedHelper].tag == S_GetPaymentKeyDetails)
    {
        [AppDel hideSpinner];
        if ([[response objectForKey:@"err-code"] intValue] == 1)    // Success
        {
            [AppDel hideSpinner];
            
            [self stripeWithPublishable_key:[response objectForKey:@"publishable_key"] withPayment_amount:[response objectForKey:@"payment_amount"]];
            
            
            
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
        
        
    }
    */
    
    
    else if ([WebHelper sharedHelper].tag == S_SubscribeUser)
    {
        [AppDel hideSpinner];
        if ([[response objectForKey:@"err-code"] intValue] == 1)    // Success
        {
            
            
            [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            
            
        }
        else if ([[response objectForKey:@"err-code"] intValue] == 700)    // Unable to proceed
        {
            [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
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
        
        
    }
    
    
    
}

- (void)didFailedWithError: (NSError *) error
{
    [AppDel hideSpinner];
    
    if ([WebHelper sharedHelper].tag == S_GetPatientProfile)
    {
        if (bool_PatProfileRetry)
        {
            [self performSelector:@selector(fetchProfile) withObject:nil afterDelay:0.9];
        }
        else
        {
            [[RDCallbackAlertView alloc] initWithTitle:nil message:@"Cannot detect Internet connection" cancelButtonTitle:nil andCompletionHandler:^(int btnIDX)
             {
                 
                 if (btnIDX==0)
                 {
                     bool_PatProfileRetry = YES;
                     
                     [self fetchProfile];
                     
                 }
                 if (btnIDX==1)
                 {
                     bool_PatProfileRetry = NO;
                     
                     [self.navigationController popViewControllerAnimated:YES];
                 }
                 
             } otherButtonTitles:@"Retry" ,@"Try Later", nil];
            
        }
    }
    else if ([WebHelper sharedHelper].tag == S_SendInvitationV2)
    {
        if (bool_SendInvitation)
        {
            [self performSelector:@selector(addPatientTapMethod) withObject:nil afterDelay:0.9];
        }
        else
        {
            [[RDCallbackAlertView alloc] initWithTitle:nil message:@"Cannot detect Internet connection" cancelButtonTitle:nil andCompletionHandler:^(int btnIDX)
             {
                 
                 if (btnIDX==0)
                 {
                     bool_SendInvitation = YES;
                     
                     [self fetchProfile];
                     
                 }
                 if (btnIDX==1)
                 {
                     bool_SendInvitation = NO;
                     
                     [self.navigationController popViewControllerAnimated:YES];
                 }
                 
             } otherButtonTitles:@"Retry" ,@"Try Later", nil];
            
        }
    }
    else if ([WebHelper sharedHelper].tag == S_RemoveXMPPUser)
    {
        if (bool_RemoveXmppUser)
        {
            [self performSelector:@selector(removeUserTapMethod) withObject:nil afterDelay:0.9];
        }
        else
        {
            [[RDCallbackAlertView alloc] initWithTitle:nil message:@"Cannot detect Internet connection" cancelButtonTitle:nil andCompletionHandler:^(int btnIDX)
             {
                 
                 if (btnIDX==0)
                 {
                     bool_RemoveXmppUser = YES;
                     
                     [self fetchProfile];
                     
                 }
                 if (btnIDX==1)
                 {
                     bool_RemoveXmppUser = NO;
                     
                     [self.navigationController popViewControllerAnimated:YES];
                 }
                 
             } otherButtonTitles:@"Retry" ,@"Try Later", nil];
        }
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Unable to connect to the server, Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}


#pragma mark - Set Required Font


- (void)setRequiredFont2
{
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [nameLbl setFont:[UIFont fontWithName:@"CentraleSansRndBold" size:28.00]];
        
        
        [userNameLbl setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:17.00]];
        
        [mailBtn.titleLabel setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:15.00]];
        
        [phoneBtn.titleLabel setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:15.00]];
        
        [removeUserBtn.titleLabel setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:15.00]];
    }
    else
    {
        [nameLbl setFont:[UIFont fontWithName:@"CentraleSansRndBold" size:25.00]];
        
        
        [userNameLbl setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:14.00]];
        
        [mailBtn.titleLabel setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:12.00]];
        
        [phoneBtn.titleLabel setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:12.00]];
        
        [removeUserBtn.titleLabel setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:13.00]];
        
    }
}


@end

