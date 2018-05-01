//
//  AccountSettingViewController.m
//  IMYourDoc
//
//  Created by Sarvjeet on 23/01/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import "SecurityViewController.h"
#import "DeviceMgmtViewController.h"
#import "ProfilePicViewController.h"
#import "ChangeEmailViewController.h"
#import "PersonalInfoViewController.h"
#import "NotificationsViewController.h"
#import "AccountSettingViewController.h"
#import "PendingRequestViewController.h"
#import "ChatMessage+ClassMethod.h"



@interface AccountSettingViewController ()
{
}

@end


@implementation AccountSettingViewController


#pragma mark - View LifeCycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    
    self.isFwdNav = YES;
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"UserType"] isEqualToString:@"Patient"])
    {
        if ([[UIDevice currentDevice].systemVersion floatValue] < 8.0)
        {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                scrlV.contentSize = CGSizeMake(self.view.frame.size.width, 886.0);
            }
            else
            {
                scrlV.contentSize = CGSizeMake(self.view.frame.size.width, 611.0);
            }

        }
        else
        {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
            }
            else
            {
            }

        }
        
    }
    else
    {
        
        if ([[UIDevice currentDevice].systemVersion floatValue] < 8.0)
        {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                scrlV.contentSize = CGSizeMake(self.view.frame.size.width, 824.0);
            }
            else
            {
                scrlV.contentSize = CGSizeMake(self.view.frame.size.width, 571.0);
            }
            
        }
        else
        {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                personalSettingTop.constant = -127.00;
                [self.view layoutIfNeeded];
            }
            else
            {
                personalSettingTop.constant = -88.00;
                
                [self.view layoutIfNeeded];

            }
            
        }
    }
    
    
    [self setRequiredFont1];
    
    
    
    
    
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
    
    
    [self updateMessagCount];
}


- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"UserType"] isEqualToString:@"Patient"])
    {
        if ([[UIDevice currentDevice].systemVersion floatValue] < 8.0)
        {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                scrlV.contentSize = CGSizeMake(self.view.frame.size.width, 886.0);
            }
            else
            {
                scrlV.contentSize = CGSizeMake(self.view.frame.size.width, 611.0);
            }
            
        }
        else
        {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
            }
            else
            {
            }
            
        }
        
    }
    else
    {
        
        if ([[UIDevice currentDevice].systemVersion floatValue] < 8.0)
        {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                scrlV.contentSize = CGSizeMake(self.view.frame.size.width, 824.0);
            }
            else
            {
                scrlV.contentSize = CGSizeMake(self.view.frame.size.width, 571.0);
            }
            
        }
        else
        {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                personalSettingTop.constant = -127.00;
                 [self.view layoutIfNeeded];
            }
            else
            {
                personalSettingTop.constant = -88.00;
                
                [self.view layoutIfNeeded];
                
            }
            
        }
    }

    
    [self setRequiredFont1];
    
    if (self.isFwdNav)
    {
        
        
        
        self.isFwdNav = NO;
    }
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

- (void)valueChange:(UISlider *)slider
{
    UILabel *value = (UILabel *) [slider.superview viewWithTag:1003];
    
    value.text = [NSString stringWithFormat:@"%d sec", (int)slider.value];
}


#pragma mark - IBAction

- (IBAction)navBack
{
	[self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)logoutTap
{
    [AppDel setLoginType:0];
    
    (AppDel).bool_SignoutFirstTime = YES;
    
    [AppDel signOutFromApp];
}


- (IBAction)accountSettingsTap:(UIButton *)sender
{
    if (sender.tag == 1)        //Pending request
    {
        PendingRequestViewController *prVC = [[PendingRequestViewController alloc] initWithNibName:@"PendingRequestViewController" bundle:nil];
        
        [self.navigationController pushViewController:prVC animated:YES];
    }
    
    else if (sender.tag == 2)   //Profile Picture
    {
        ProfilePicViewController *proflPicVC = [[ProfilePicViewController alloc] initWithNibName:@"ProfilePicViewController" bundle:nil];
        
        [self.navigationController pushViewController:proflPicVC animated:YES];
    }
    
    else if (sender.tag == 3)   //Personal Info
    {
        PersonalInfoViewController *prsnlInfoVC = [[PersonalInfoViewController alloc] initWithNibName:@"PersonalInfoViewController" bundle:nil];
        
        [self.navigationController pushViewController:prsnlInfoVC animated:YES];
    }
    
    else if (sender.tag == 4)   //Email Address
    {
        ChangeEmailViewController *changeMailVC = [[ChangeEmailViewController alloc] initWithNibName:@"ChangeEmailViewController" bundle:nil];
        
        [self.navigationController pushViewController:changeMailVC animated:YES];
    }
    
    else if (sender.tag == 5)   //Device Management
    {
        DeviceMgmtViewController *dmVC = [[DeviceMgmtViewController alloc] initWithNibName:@"DeviceMgmtViewController" bundle:nil];
        
        [self.navigationController pushViewController:dmVC animated:YES];
    }
    
    else if (sender.tag == 6)   //Notification Method
    {
        NotificationsViewController *notifyVC = [[NotificationsViewController alloc] initWithNibName:@"NotificationsViewController" bundle:nil];
        
        [self.navigationController pushViewController:notifyVC animated:YES];
    }
    
    else if (sender.tag == 7)   //Security
    {
        SecurityViewController *sVC = [[SecurityViewController alloc] initWithNibName:@"SecurityViewController" bundle:nil];
        
        [self.navigationController pushViewController:sVC animated:YES];
    }
    
    else if (sender.tag == 8)   //Last Updated Location
    {

    }
    
    else if (sender.tag == 9)   //Notification Settings
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notification Settings" message:@"Delivery confirmation delay" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        
        alert.tag = 3;
        
        
        notiSlider = [[UISlider alloc] initWithFrame:CGRectMake(30, 0, 200, 30)];
        
        notiSlider.maximumValue = 60.0;
        
        notiSlider.minimumValue = 5.0;
        
        notiSlider.value = ([[NSUserDefaults standardUserDefaults] integerForKey:@"delay"] == 0) ? 45 : [[NSUserDefaults standardUserDefaults] integerForKey:@"delay"];
        
        [notiSlider addTarget:self action:@selector(valueChange:) forControlEvents:UIControlEventValueChanged];
        
        notiSlider.backgroundColor = [UIColor clearColor];
        
        
        UILabel *valueLb = [[UILabel alloc] initWithFrame:CGRectMake(30, 30, 200, 30)];
        
        valueLb.text = [NSString stringWithFormat:@"%d sec", (int)notiSlider.value];
        
        valueLb.backgroundColor = [UIColor clearColor];
        
        valueLb.textAlignment = NSTextAlignmentCenter;
        
        valueLb.textColor = [UIColor blackColor];
        
        valueLb.tag = 1003;
        
        
        UIView *myContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 60)];
        
        [myContentView setBackgroundColor:[UIColor clearColor]];
        
        [myContentView addSubview:notiSlider];
        
        [myContentView addSubview:valueLb];
        
        
        [alert setValue:myContentView forKey:@"accessoryView"];
        
        [alert show];
    }
    
    else if (sender.tag ==12 )   //Report Problem
    {
        if ([MFMailComposeViewController canSendMail])
        {
            MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
            
            mailComposer.mailComposeDelegate = self;
            //support@imyourdoc.com
            [mailComposer setToRecipients:[NSArray arrayWithObject:[@"support@imyourdoc.com" stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]]];

            [mailComposer setSubject:[NSString stringWithFormat:@"iOS Diagnostic log from %@" , [AppData appData].XMPPmyJID]];
         
            
            [mailComposer setMessageBody:
             [NSString stringWithFormat: @"IM Your Doc Customer Support, \n\nI have encountered a problem while using IM Your Doc. \n\n(Replace this text with a description of your problem.) \n\n——— Do not make changes below this line. ——— \nIM Your Doc Diagnostic Information \nUsername:  %@ \nDevice Name: %@ \nDevice OS Version: %@ \nApplication Version: %@ \nBuild: %@",
                                            [AppData appData].XMPPmyJID,
                                            [[UIDevice currentDevice] name],
                                            [[UIDevice currentDevice] systemVersion],
                                            [[[NSBundle mainBundle] infoDictionary] objectForKey: @"CFBundleShortVersionString"],
                                            [[[NSBundle mainBundle] infoDictionary] objectForKey: @"CFBundleVersion"]
                                            //APP_TARGET
                                            ]isHTML:NO];
            
            
            
            [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__] operation:@"Report Problem" Content:@"" parameter:@""];
            
            [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__] operation:@"MessageIDS" Content:[NSString stringWithFormat:@"%@",[ChatMessage getAllMessageIds]] parameter:@""];
            
            
            NSData *myData = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@",[AppDel dataFilePath] ]];
            
            [mailComposer addAttachmentData:myData
                                         mimeType:@"text/csv"
                                         fileName:@"Application_Log.csv"];
            

            
            [self presentViewController:mailComposer animated:YES completion:NULL];
        }
        
        else
        {
            [[[UIAlertView alloc] initWithTitle:nil message:@"You need to setup an email account on your device in order to send emails." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
   
    }
    
    else if (sender.tag == 10)    //Share
    {

        
        
        subAlert = [[UIAlertView alloc] initWithTitle:@"" message:@"Are you sure you want to cancel your subscription? All providers on your contact list and conversations will be removed from your device." delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
              [subAlert show];
        
    }
    else if(sender.tag==11)
    {
//        {    if ([AppDel appIsDisconnected])
//        {
//            [AppData showAlertWithTitle:nil andMessage:@"No Connection." inVC:self];
//            
//            return;
//        }
//            
//            
//            [AppDel showSpinnerWithText:@"Processing..."];
//            
//            
//            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
//                                  
//                                  @"getPaymentKeyDetails", @"method",
//                                  
//                                  
//                                  
//                                  [[NSUserDefaults standardUserDefaults] objectForKey:@"loginToken"], @"login_token",
//                                  
//                                  nil];
//            
//            [[WebHelper sharedHelper] setWebHelperDelegate:self];
//            
//            [[WebHelper sharedHelper] sendRequest:dict tag:S_GetPaymentKeyDetails delegate:self];
//            
//        }
    }
    
}


#pragma mark - update Connectivity

- (void) updateConnectivity:(NSNotification *)note
{
    NSDictionary *dict = note.object;
    
    
    secureL.text = [dict objectForKey:@"status"];
    
    
    [secureIcon setImage:[UIImage imageNamed:[dict objectForKey:@"image"]]];
}


- (void)updateMessagCount
{
    
    if ([AppDel request_count] > 0)
    {
        pendingCountL.text = [NSString stringWithFormat:@"Pending Request (%d)", [AppDel request_count]];
    }
    
    else
    {
        pendingCountL.text = @"Pending Request";
    }
}





#pragma mark - Alert View

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 3)
    {
        if (buttonIndex != alertView.cancelButtonIndex)
        {
            [[NSUserDefaults standardUserDefaults] setInteger:notiSlider.value forKey:@"delay"];
            
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    
    if (alertView == subAlert)
    {
        if (buttonIndex != alertView.cancelButtonIndex)
        {
            if ([AppDel appIsDisconnected])
            {
                [AppData showAlertWithTitle:nil andMessage:@"No Connection." inVC:self];
            }
            
            else
            {
                
                [AppDel showSpinnerWithText:@"Cancelling Subscription.."];
                
                
                
                NSDictionary *dict = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:@"unsubscribeUser",
                                                                            [AppData appData].XMPPmyJID,
                                                                            [[NSUserDefaults standardUserDefaults] objectForKey:@"loginToken"], nil]
                                                                   forKeys:[NSArray arrayWithObjects:@"method", @"user_name", @"login_token", nil]];
                
                [[WebHelper sharedHelper] setWebHelperDelegate:self];
                
                [[WebHelper sharedHelper] sendRequest:dict tag:S_CancelSubscription delegate:self];
            }
        }
            
    }
}



#pragma mark - ASIHTTP

- (void)didFailedWithError: (NSError *) error{
        [AppDel hideSpinner];
}
- (void)didReceivedresponse:(NSDictionary *)response
{
    [AppDel hideSpinner];
    
    if ([WebHelper sharedHelper].tag == S_CancelSubscription)
    {
        if ([[response objectForKey:@"err-code"] intValue] == 1)    // Success
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [alert show];
            
     
            
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
        
        else
        {
            [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }
    
    
    /*
     
 
    else  if ([WebHelper sharedHelper].tag == S_GetPaymentKeyDetails)
    {
        [AppDel hideSpinner];
        if ([[response objectForKey:@"err-code"] intValue] == 1)    // Success
        {
            [AppDel hideSpinner];
            
      
            
//            {
//                StripeViewController *obj_stripeVC=[[StripeViewController alloc]initWithNibName:@"StripeViewController" bundle:[NSBundle mainBundle]];
//                obj_stripeVC.str_publishable_key=[response objectForKey:@"publishable_key"];
//                obj_stripeVC.str_payment_amount=[response objectForKey:@"payment_amount"];
//                
//                obj_stripeVC.paylabel=@"Update Details";
//                obj_stripeVC.callBackBlock=^(NSString* token, NSString * expMonth,NSString*expYear)
//                {
//                 
//                    
//                    [self serviceUpdatePaymentDetailsWith:token];
//                    
//                };
//               [self.navigationController pushViewController:obj_stripeVC animated:YES];
//            }
            
            
            
            
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
     
    else  if ([WebHelper sharedHelper].tag == S_Update_payment_details)
    {
        [AppDel hideSpinner];
        if ([[response objectForKey:@"err-code"] intValue] == 1)    // Success
        {
            [AppDel hideSpinner];
            
        

            [[RDCallbackAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] cancelButtonTitle:nil andCompletionHandler:^(int btnIndex)
             
             {
                 
                 
             } otherButtonTitles:@"OK", nil];
            
            
            
            
        }
        else if ([[response objectForKey:@"err-code"] intValue] == 600)    // Session expired
        { [AppDel signOutFromAppSilent];
            [[RDCallbackAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] cancelButtonTitle:nil andCompletionHandler:^(int btnIndex)
             
             {
                 
                 
             } otherButtonTitles:@"OK", nil];
        }
        
        else if ([[response objectForKey:@"err-code"] intValue] == 700)
        {
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

-(void)serviceUpdatePaymentDetailsWith:(NSString*)token{
    {    if ([AppDel appIsDisconnected])
    {
        [AppData showAlertWithTitle:nil andMessage:@"No Connection." inVC:self];
        
        return;
    }
        
        
        [AppDel showSpinnerWithText:@"Processing..."];
        
        
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              
                              @"update_payment_details", @"method",
                              
                              token,@"payment_token",
                              
                              [[NSUserDefaults standardUserDefaults] objectForKey:@"loginToken"], @"login_token",
                              
                              nil];
        
        [[WebHelper sharedHelper] setWebHelperDelegate:self];
        
        [[WebHelper sharedHelper] sendRequest:dict tag:S_Update_payment_details delegate:self];
        
    }
}



#pragma mark - Font Settings

- (void)setRequiredFont1
{
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [titleL setFont:[UIFont fontWithName:@"CentraleSansRndMedium" size:25.00]];
        
        [requestHL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:18.00]];
        
        [pSettingHL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:18.00]];
        
        [manageHL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:18.00]];

        [sSettingHL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:18.00]];

        [oSettingHL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:18.00]];
        
        [profileL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:22.00]];
        
        [personalL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:22.00]];
        
        [emailL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:22.00]];
        
        [updateCreditL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:22.00]];

        [manageSubL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:22.00]];
        
        [dMangL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:22.00]];
        
        [nMethodL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:22.00]];
        
        [securityL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:22.00]];
        
        [lastUpL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:22.00]];

        [notifySettingL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:22.00]];
        
        [pendingCountL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:22.00]];
    }
    else
    {
        [titleL setFont:[UIFont fontWithName:@"CentraleSansRndMedium" size:20.00]];
        
        [requestHL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:13.00]];
        
        [manageHL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:13.00]];
        
        [pSettingHL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:13.00]];
        
        [sSettingHL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:13.00]];
        
        [oSettingHL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:13.00]];
        
        [profileL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:17.00]];
        
        [personalL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:17.00]];
        
        [emailL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:17.00]];
        
        [manageSubL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:17.00]];

        [updateCreditL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:17.00]];
        
        [dMangL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:17.00]];
        
        [nMethodL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:17.00]];
        
        [securityL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:17.00]];
        
        [lastUpL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:17.00]];
        
        [notifySettingL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:17.00]];
        
        [pendingCountL setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:17.00]];
    }
}
#pragma mark - Mail

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    if (result == MFMailComposeResultSent)
    {
        [[[UIAlertView alloc] initWithTitle:@"Sent" message:@"Email has been sent successfully." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
         [[NSFileManager defaultManager] removeItemAtPath:[AppDel dataFilePath] error:nil];
    
        
    
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

@end

