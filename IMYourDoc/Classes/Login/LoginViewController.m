//
//  ViewController.m
//  IMYourDoc
//
//  Created by Sarvjeet on 15/01/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import <AddressBook/AddressBook.h>


#import "HomeViewController.h"
#import "HelpViewController.h"
#import "LoginViewController.h"
#import "SignupTypesViewController.h"
#import "AccountConfigViewController.h"
#import "ForgotPswdStepOneViewController.h"
#import "AttachmentWebViewController.h"
#import "OfflineChatViewController.h"

#import "BroadCastGroup.h"
#import "BroadCastMessageSender+ClassMetod.h"
#import "ChatMessage+ClassMethod.h"


#import "APIManager.h"


@interface LoginViewController ()
{
    BOOL bool_LoginRetry, bool_LoginFirstTime;
}

@end

@implementation LoginViewController

#pragma mark - View LifeCycle

- (void) viewDidLoad
{
    [super viewDidLoad];

    [self setRequiredFont1];
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setRequiredFont1];
    
    passwordTF.text=@"";
    
    // Device orientation handling...
    
    if ([[UIDevice currentDevice] orientation] == UIInterfaceOrientationLandscapeLeft || [[UIDevice currentDevice] orientation] == UIInterfaceOrientationLandscapeRight)
    {
        profileHeight.constant = - 0.1 * self.view.frame.size.height;
        
        [scrollView layoutIfNeeded];
    }
    else
    {
        profileHeight.constant = 0.0 * scrollView.frame.size.height;
        
        [scrollView layoutIfNeeded];
    }
    
    
    // 6Plus device UI handling...
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        if ([[UIScreen mainScreen] bounds].size.height > 700.00 )
        {
            userNameTopSpaceConst.constant = 40.00;
            rememberTopSpaceConst.constant = 40.00;
            logionTopSpaceConst.constant = 20.00;
            needHelpTopConst.constant = 10.00;
            
            [scrollView layoutIfNeeded];
        }
        
        else if ([[UIScreen mainScreen] bounds].size.height > 600.00 && [[UIScreen mainScreen] bounds].size.height < 700.00)
        {
            userNameTopSpaceConst.constant = 30.00;
            rememberTopSpaceConst.constant = 30.00;
            logionTopSpaceConst.constant = 10.00;
            needHelpTopConst.constant = 10.00;
            
            [scrollView layoutIfNeeded];
        }
        
        else if ([[UIScreen mainScreen] bounds].size.height > 500.00 && [[UIScreen mainScreen] bounds].size.height < 600.00)
        {
            userNameTopSpaceConst.constant = 20.00;
            rememberTopSpaceConst.constant = 30.00;
            logionTopSpaceConst.constant = 10.00;
            needHelpTopConst.constant = 10.00;
            
            [scrollView layoutIfNeeded];
        }
        
        else
        {
            userNameTopSpaceConst.constant = 20.00;
            rememberTopSpaceConst.constant = 10.00;
            logionTopSpaceConst.constant = 10.00;
            needHelpTopConst.constant = 2.00;
            
            [scrollView layoutIfNeeded];
        }
    }
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"rememberMe"])
    {
        userNameTF.text = [AppData appData].XMPPmyJID;
        rememberBtn.selected = YES;
    }
    else{
        userNameTF.text =@"";
    }
    
    
    // Notifications...
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(typingStarted:) name:UITextFieldTextDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}


- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self setRequiredFont2];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"required_config"])
        [AppData goToAccountConfig:self.navigationController];
}

- (void) viewWillDisappear:(BOOL)animated
{
       [super viewWillDisappear:animated];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - Web Service Call & Delegate

- (void) loginReqest
{
    if ([AppDel appIsDisconnected] && bool_LoginFirstTime)
    {
        [self noConnectionAlert];
    }
    else
    {
        if (bool_LoginRetry && !bool_LoginFirstTime)
        {
            [AppDel showSpinnerWithText:@"Retrying..."];
            bool_LoginRetry = NO;
        }
        else
        {
            [AppDel showSpinnerWithText:@"Verifying User..."];
            bool_LoginRetry = YES;
            bool_LoginFirstTime = NO;
        }
        
        [[AppData appData] setXMPPmyJID:userNameTF.text];
        [[AppData appData] setXMPPmyJIDPassword:passwordTF.text];
        
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"page"];
        [[NSUserDefaults standardUserDefaults] synchronize];

        dispatch_async(dispatch_get_main_queue(), ^{
            LoginRequestModel *requestModel = [LoginRequestModel new];
            requestModel.user_name = userNameTF.text;
            requestModel.password = passwordTF.text;
            
            [[APIManager sharedHTTPManager] loginWithRequestModel:requestModel
                                                          success:^()
                                                          {
                                                              bool_LoginRetry=NO;
                                                             
                                                              [self successfulResponse];
                                                          }
                                                          failure:^(NSError *error)
                                                          {
                                                              if (error){
                                                                 
                                                              }
                                                          }];
        });
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *dict =[[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:@"login", [[userNameTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString], passwordTF.text, [[NSUserDefaults standardUserDefaults] stringForKey:@"openUUID"], @"IOS", [[NSUserDefaults standardUserDefaults] stringForKey:@"deviceToken"], @"false", @"false",nil] forKeys:[NSArray arrayWithObjects:@"method", @"user_name", @"password", @"device_id", @"device_type", @"device_token",@"fetch_messages",@"isNew", nil]];
            
            [[WebHelper sharedHelper] setWebHelperDelegate:self];
            [[WebHelper sharedHelper] sendRequest:dict tag:S_Login delegate:self];
        });
    }
}

- (void)successfulResponse
{
    [[AppData appData] fetchInformationAfterLogin:self.navigationController];
}



#pragma mark - Device Rotation Handler

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration
{
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
        toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        profileHeight.constant = - 0.1 * self.view.frame.size.height;
        
        [scrollView layoutIfNeeded];
    }
    else
    {
        profileHeight.constant = 0.0 * scrollView.frame.size.height;
        
        [scrollView layoutIfNeeded];
    }
}

#pragma mark - No Connection Alert

- (void)noConnectionAlert
{
    [AppData showAlertWithTitle:@"No Connection." andMessage:nil inVC:self];
}


#pragma mark - Web Service Call - Block User

- (void)blockUser
{
    if ([AppDel appIsDisconnected])
    {
        [self noConnectionAlert];
    }
    
    else
    {
        NSDictionary *dict =  [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:@"blockUser", [[userNameTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString], nil] forKeys:[NSArray arrayWithObjects:@"method", @"user_name", nil]];
        
        [[WebHelper sharedHelper] setWebHelperDelegate:self];
        
        [[WebHelper sharedHelper] sendRequest:dict tag:S_BlockUser delegate:self];
        
    }
}

#pragma mark - Device Registration

- (void)showDeviceRegistrationStatus
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Device Registration Successful" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    alert.tag = 3;
    
    [alert show];
}

#pragma mark - UI Handler

- (void)setUsernameAndPassWordAsEmpty
{
    userNameTF.text = @"";
    passwordTF.text = @"";
}


#pragma mark - Local Notification Handler

- (void)typingStarted:(NSNotification *)aNotification
{
    [userNameTF.text lowercaseString];
}


#pragma  mark - IBAction

- (IBAction)userHelp
{
    HelpViewController *hVC = [[HelpViewController alloc] initWithNibName:@"HelpViewController" bundle:nil];
    
    [self.navigationController pushViewController:hVC animated:YES];
}


- (IBAction)userLogin
{
    [self.view endEditing:YES];
    
    bool_LoginFirstTime = YES;
    
    
    //Check username field is empty
    if ([AppData isFieldEmpty:userNameTF])
    {
        [userNameTF becomeFirstResponder];
        
        [AppData showAlertWithTitle:nil
                         andMessage:@"Please enter the Username first."
                               inVC:self];
        
        return;
    }
    
    //Check password field is empty
    if ([AppData isFieldEmpty:passwordTF])
    {
        [passwordTF becomeFirstResponder];
        
        [AppData showAlertWithTitle:nil
                         andMessage:@"Please enter the Password."
                               inVC:self];
        
        return;
    }

    //Send the login request to API
    [self sendLoginRequest];
}


- (IBAction)userSignUp
{
    SignupTypesViewController *sutVC = [[SignupTypesViewController alloc] initWithNibName:@"SignupTypesViewController" bundle:nil];
    
    [self.navigationController pushViewController:sutVC animated:YES];
}


- (IBAction)rememberTap
{
    rememberBtn.selected = !rememberBtn.selected;
    
    [[NSUserDefaults standardUserDefaults] setBool:rememberBtn.selected forKey:@"rememberMe"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (IBAction)forgotPassword
{
   ForgotPswdStepOneViewController *stepOneVC = [[ForgotPswdStepOneViewController alloc] initWithNibName:@"ForgotPswdStepOneViewController" bundle:nil];

    [self.navigationController pushViewController:stepOneVC animated:YES];
}


#pragma mark - Request

/**
 * This will trigger in Xmpp did authenticate
 *
 * @param :  notify  nil
 *
 * @see hideHUDForView:animated:
 * @
 */


- (void)receiveActiveConversationNotificationStep1:(NSNotification *)notify
{
    [[ActiveConverstion getAllObjectsWithContext:[AppDel managedObjectContext_roster]] enumerateObjectsUsingBlock:^(ActiveConverstion* obj_con, NSUInteger idx, BOOL *stop)
    {
        if (obj_con)
        {
            XMPPJID*obj_jid= [XMPPJID jidWithString:obj_con.jid];
            
            if (![[obj_jid domain] isEqualToString:@"newconversation.imyourdoc.com"])
            {
                NSLog(@"receiveActiveConversationNotificationStep1 %@",obj_jid.bare);
                
                [[NSNotificationCenter defaultCenter] addObserver:self
                                                         selector:@selector(receiveActiveConversationLastNotificationStep2:)
                                                             name:[NSString stringWithFormat:@"KStateTransferReceiveActiveConversationLastNotificationStep2%@",obj_jid.bare]
                                                           object:nil];
            }
        }
    }];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"KStateTransferReceiveActiveConversationNotificationStep1" object:nil];
}

/**
 * This will trigger in Did Recieve IQ in list Method
 *
 * @param :  notify  XMPPJID
 *
 * @see
 * @
 */

-(void)receiveActiveConversationLastNotificationStep2:(NSNotification *)notify
{
    XMPPJID*obj_jid = [XMPPJID jidWithString:[notify object]];
    NSLog(@"ªªªªªªªªªªªª ªªªªªªªª %@ ",obj_jid.bare);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[NSString stringWithFormat:@"KStateTransferReceiveActiveConversationLastNotificationStep2%@" ,obj_jid.bare]object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveStateTransferReceiveNotificationStep3:) name:  [NSString stringWithFormat:@"KStateTransferReceiveNotificationStep3%@" ,obj_jid.bare] object:nil];
}

-(void)receiveStateTransferReceiveNotificationStep3:(NSNotification *)notify
{
    XMPPJID*obj_jid= [XMPPJID jidWithString:[notify object]];
    
    NSDate* date_stateTransferDate = [ActiveConverstion getStr_LastAciveDateOfJid:obj_jid.bare withContext:[AppDel managedObjectContext_roster]];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[NSString stringWithFormat:@"KStateTransferReceiveNotificationStep3%@" ,obj_jid.bare]
                                                  object:nil];
    
    NSLog(@"%@",date_stateTransferDate);
    
    NSDate* date_rightFromDBOfChatTB = [ChatMessage  getFirstMessageDateWithJiD:obj_jid.bare];
    
    if (date_rightFromDBOfChatTB && date_stateTransferDate)
    {
        NSComparisonResult result = [date_stateTransferDate compare:date_rightFromDBOfChatTB];
        
        switch (result)
        {
            case NSOrderedAscending:
            {
                break;
            }
            case NSOrderedDescending:
            {
                [[NSNotificationCenter defaultCenter] addObserver:self
                                                         selector:@selector(receiveStateTransferReceiveNotificationStep3:) name:[NSString stringWithFormat:@"KStateTransferReceiveNotificationStep3%@" ,obj_jid.bare]
                                                           object:nil];
                break;
            }
            case NSOrderedSame:
            {               
                [[NSNotificationCenter defaultCenter] addObserver:self
                                                         selector:@selector(receiveStateTransferReceiveNotificationStep3:) name:[NSString stringWithFormat:@"KStateTransferReceiveNotificationStep3%@",obj_jid.bare]
                                                           object:nil];
                     break;
            }
            default:
            {
                
            }
        }
    }
}


- (void)didReceivedresponse:(NSDictionary *)response
{
    if ([WebHelper sharedHelper].tag == S_Login) // --------------------------------  Login ------------------------------- //
    {
        bool_LoginRetry=NO;
        
        if ([[response objectForKey:@"err-code"] intValue] == 1)    // Login
        {
            
            [[AppData appData] setXMPPmyJID:userNameTF.text];
            
            // This will trigger in XmppDidAuthenticate
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveActiveConversationNotificationStep1:) name:@"KStateTransferReceiveActiveConversationNotificationStep1" object:nil];
            
            
            
            /*
             *  TODO: Add this back in when Broadcast Message feature is enabled (VH)
             *
            [self fetchBroadcastListFromServer];
            [self broadcastStateTransfer:(NSMutableArray*)[response objectForKey:@"broadcast_messages"]];
             *
             */
            
            //Try to login
            [AppData loginWithResponseJSON:response withNavController:self.navigationController];
            
        }
        
        else if ([[response objectForKey:@"err-code"] intValue] == 300)     // Device Blocked
        {
            [AppDel hideSpinner];
            [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        
        else if ([[response objectForKey:@"err-code"] intValue] == 700)       // Login Failed
        {
            [AppDel hideSpinner];

            if (!(AppDel).loginUserName)
            {
                (AppDel).loginFailCount++;
                
                
                (AppDel).loginUserName = [userNameTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                
                
                [AppDel hideSpinner];
                
                
                [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                
                
                return;
            }
            
            else if ([[userNameTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:(AppDel).loginUserName])
            {
                (AppDel).loginFailCount++;
            }
            
            else
            {
                (AppDel).loginFailCount = 1;
                
                (AppDel).loginUserName = [userNameTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            }
            
            
            
            if ((AppDel).loginFailCount == 2)
            {
                [AppDel hideSpinner];
                
                [[[UIAlertView alloc] initWithTitle:nil message:@"You have the last login chance, Please fill correct credentials else your device will get blocked." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                
                return;
            }
            
            else if ((AppDel).loginFailCount == 3)
            {
                [self blockUser];
                
                return;
            }
            
            [AppDel hideSpinner];
            
            [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        
        else if ([[response objectForKey:@"err-code"] intValue] == 400)    // User blocked
        {
            [AppDel hideSpinner];
            
            
            [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        
        else if ([[response objectForKey:@"err-code"] intValue] == 404)    // User name not found
        {
            [AppDel hideSpinner];
            
            
            [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        
        else
        {
            [AppDel hideSpinner];
            
            [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        
    }
    
    else if ([WebHelper sharedHelper].tag == S_BlockUser)  // --------------------------------  Block User ------------------------------- //
    {
        [AppDel hideSpinner];

         if ([[response objectForKey:@"err-code"] intValue] == 1)    // User Blocked
         {
             [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
         }
        
        else
        {
            [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
             
        }
    }
}

- (void)didFailedWithError: (NSError *) error
{
    [AppDel hideSpinner];

     if ([WebHelper sharedHelper].tag == S_Login)
    {
        if (bool_LoginRetry)
        {
            [self performSelector:@selector(loginReqest) withObject:nil afterDelay:0.9];
        }
        else
        {
            [[RDCallbackAlertView alloc] initWithTitle:nil message:error.userInfo[NSLocalizedDescriptionKey] cancelButtonTitle:nil andCompletionHandler:^(int btnIDX)
             {
                 
                 if (btnIDX==0)
                 {
                     bool_LoginRetry = YES;
                     
                     [self loginReqest];
                     
                 }
                 if (btnIDX==1)
                 {
                     bool_LoginRetry = NO;
                 }
                 
             } otherButtonTitles:@"Retry" ,@"Try Later", nil];
            
        }
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Unable to connect to the server, Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    
 
}

#pragma mark- Active conversation


#pragma mark - AlertView

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 3)
    {
        [AppData connectXMPPServer];
    }
}

#pragma mark - Webservice API call - Login Request
- (void)sendLoginRequest{
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    
    if (networkStatus != NotReachable)
    {
        [self loginReqest];
    }
    
    else
    {
        [self noConnectionAlert];
    }
}


#pragma mark - TextField Delegation

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == userNameTF)
    {
        [passwordTF becomeFirstResponder];
    }
    
    else if (textField == passwordTF)
    {
        [passwordTF resignFirstResponder];
    }
	
    
    return YES;
}


#pragma mark - Keyboard

- (void)keyboardWillAppear: (NSNotification *)noti
{
    NSDictionary *info = [noti userInfo];
    
    
    keyBRect = [info[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    
    UIEdgeInsets insets = UIEdgeInsetsMake(scrollV.contentInset.top, 0, keyBRect.size.height, 0);
    
    
    scrollV.contentInset = insets;
    
    scrollV.scrollIndicatorInsets = insets;
    
    
    float btnOffset = 0  ;
    
   
    if (userNameTF.isEditing)
    {
        btnOffset = scrollV.frame.origin.y + rememberBtn.frame.origin.y + rememberBtn.frame.size.height;
    }
    
    else if (passwordTF.isEditing)
    {
        btnOffset = scrollV.frame.origin.y + loginBtn.frame.origin.y + loginBtn.frame.size.height;
    }
    
    
    if ((keyBRect.origin.y - btnOffset) < 0)
    {
        CGFloat y = (btnOffset - keyBRect.origin.y);
        
        scrollV.contentOffset = CGPointMake(scrollV.frame.origin.x, y);
    }
}


- (void)keyboardWillHide: (NSNotification *)noti
{
    UIEdgeInsets insets = UIEdgeInsetsMake(scrollV.contentInset.top, 0, 0, 0);
    
    
    scrollV.contentInset = insets;
    
    scrollV.scrollIndicatorInsets = insets;
    
    scrollV.contentOffset = CGPointMake(scrollV.frame.origin.x, -20.0);  // -20.0
}

#pragma mark - Font Settings

- (void)setRequiredFont2
{
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [userNameTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:25.00]];
        
        [passwordTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:25.00]];
        
        
        forgotBtn.titleLabel.font = [UIFont fontWithName:@"CentraleSansRndLight" size:18.00];
        
        helpBtn.titleLabel.font = [UIFont fontWithName:@"CentraleSansRndLight" size:18.00];
        
        rememberBtn.titleLabel.font = [UIFont fontWithName:@"CentraleSansRndLight" size:20.00];
    }
    
    else
    {
        [userNameTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
        
        [passwordTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
        
        
        forgotBtn.titleLabel.font = [UIFont fontWithName:@"CentraleSansRndLight" size:15.00];
        
        helpBtn.titleLabel.font = [UIFont fontWithName:@"CentraleSansRndLight" size:15.00];
        
        rememberBtn.titleLabel.font = [UIFont fontWithName:@"CentraleSansRndLight" size:18.00];
    }
}

- (void)setRequiredFont1
{
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        
        [userNameTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:25.00]];
        
        [passwordTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:25.00]];
        
        
        forgotBtn.titleLabel.font = [UIFont fontWithName:@"CentraleSansRndLight" size:18.00];
        
        helpBtn.titleLabel.font = [UIFont fontWithName:@"CentraleSansRndLight" size:18.00];
        
        rememberBtn.titleLabel.font = [UIFont fontWithName:@"CentraleSansRndLight" size:20.00];
    }
    else
    {
        [userNameTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
        
        [passwordTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
        
        
        forgotBtn.titleLabel.font = [UIFont fontWithName:@"CentraleSansRndLight" size:15.00];
        
        helpBtn.titleLabel.font = [UIFont fontWithName:@"CentraleSansRndLight" size:15.00];

        rememberBtn.titleLabel.font = [UIFont fontWithName:@"CentraleSansRndLight" size:18.00];
        
    }
}

#pragma mark - Broadcast State Transfer Funtionality

-(void)broadcastStateTransfer:(NSMutableArray*)arr_messages
{
    if (arr_messages.count<=0)
        return;
    
    
    for (id messageObj in arr_messages) {
        
        @autoreleasepool {
            
            ChatMessage *message =[ChatMessage initbcMessageWithFrom:[messageObj objectForKey:@"from"] to: [[[AppDel xmppStream] myJID] bare] content:[messageObj objectForKey:@"content"] subject:[messageObj objectForKey:@"subject"] chatMessage:ChatMessageType_Broadcast timestamp:[messageObj objectForKey:@"sent_timestamp"] messageID:[messageObj objectForKey:@"message_id"] withSubjectid:[messageObj objectForKey:@"subject_id"] ChatStateType:ChatStateType_Read];
            
            
            
            
            [[AppDel managedObjectContext_roster] save:nil];
            
            
            (void)message;
        }

    }
    
}


-(void)fetchBroadcastListFromServer
{
    NSDictionary *dict_broadcastList = [NSDictionary dictionaryWithObjectsAndKeys:
                                        
                                        @"get_broadcast_lists", @"method",
                                        [[NSUserDefaults standardUserDefaults]objectForKey:@"loginToken"], @"login_token",
                                        nil];
    {
        
        
        @try {
            
            [[WebHelper sharedHelper]servicesWebHelperWith:dict_broadcastList successBlock:^(BOOL succeeded, NSDictionary *response)
             {
                 if ([[response objectForKey:@"err-code"] intValue] == 1)    // Success
                 {
                     
                     NSLog(@"%@",response);
                     
                     for (id group in (NSArray*)[response objectForKey:@"broadcast_list"])
                     {
                         
                     BroadCastGroup*temp_group= [BroadCastGroup initWithGroupName:[group objectForKey:@"group_name"] withgroupId:[group objectForKey:@"group_id"] withGroupMembersArray:[(NSArray*)[group objectForKey:@"members"] valueForKey:@"member_jid"]];
                         
                         if(temp_group){
                             
                             
                              [BroadCastMessageSender broadcastStateTransferMessages:[(NSArray*)[group objectForKey:@"messages"] mutableCopy] group:temp_group];
                         }
                         
                     }
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
                 
                 
             } failureBlock:^(BOOL succeeded, NSDictionary *resultdict)
             {
                 
             }];
            
        }
        @catch (NSException * e) {
            
            
            NSLog(@"Exception: %@", e);
        }
        @finally {
            
            
            NSLog(@"finally");
        }
    }
}

@end

