//
//  HomeViewController.m
//  IMYourDoc
//
//  Created by Sarvjeet on 17/01/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import "HomeViewController.h"
#import "UserListViewController.h"
#import "FeedbackViewController.h"
#import "OfflineChatViewController.h"
#import "MessageInboxViewController.h"
#import "OfflineNetworkViewController.h"
#import "AccountSettingViewController.h"
#import "AnnouncementWebViewController.h"
#import "DeviceRegistrationViewController.h"
#import "BroadcastContactListViewController.h"
#import "BroadcastComposeOutboxViewController.h"
#import "GroupListViewController.h"
#import "GroupProfileViewController.h"

@interface HomeViewController ()


@end


@implementation HomeViewController


#pragma mark - View LifeCycle

- (void) viewDidLoad
{
     [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__] operation:@"__CLC_ClassLifeCycle__" Content:@"" parameter:@""];
    
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
       [ChatMessage deleteEmptyJIDRowFromInboxAndChatTable];
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"broad_cast_enable"])
    {
        shareIcon.image = [UIImage imageNamed:@"bc_home"];
        
        [shareIcon setHighlightedImage:[UIImage imageNamed:@"bc_home"]];
    }
    else
    {
        shareIcon.image = [UIImage imageNamed:@"share_icon"];
        
        [shareIcon setHighlightedImage:[UIImage imageNamed:@"share_icon_h"]];
    }
        

    
    userNameLbl.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"UserFullName"];

    userProfilePic.image=[AppDel image];
    
    userProfilePic.layer.backgroundColor = [UIColor clearColor].CGColor;
    
    userProfilePic.layer.masksToBounds = YES;
    
    
    userProfilePic.layer.cornerRadius = userProfilePic.frame.size.height / 2;
    
    
   

    
    
    [self setRequiredFont1];
    
    
    if ([AppDel isConnected])
    {
        secureLbl.text = @"Securely Connected";
        
        secureImg.image = [UIImage imageNamed:@"secure_icon"];
    }
    
    else
    {
        secureLbl.text = @"Not Connected";
        
        secureImg.image = [UIImage imageNamed:@"unsecure_icon"];
    }

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateConnectivity:) name:XMPPREACHABILITY object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];

    
    [self updateMessagCount];
}


- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    userProfilePic.image=[AppDel image];
    
    [self setRequiredFont2];
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

- (void)checkInternetConnection:(BOOL)isConnected
{
    if (isConnected)
    {
        secureLbl.text = @"Securely Connected";
        secureImg.image = [UIImage imageNamed:@"secure_icon"];
    }
    
    else
    {
        secureLbl.text = @"Not Connected";
        secureImg.image = [UIImage imageNamed:@"unsecure_icon"];
    }
}


- (void)appEnterBackground: (NSNotification *)noti
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void)loadPhoneContacts
{
    
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    
    if (status == kABAuthorizationStatusDenied) {
    
        
        return;
    }
    
    CFErrorRef error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    
    if (error) {
        NSLog(@"ABAddressBookCreateWithOptions error: %@", CFBridgingRelease(error));
        if (addressBook) CFRelease(addressBook);
        return;
    }
    
    if (status == kABAuthorizationStatusNotDetermined) {
        
        // present the user the UI that requests permission to contacts ...
        
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            if (error)
            {
                NSLog(@"ABAddressBookRequestAccessWithCompletion error: %@", CFBridgingRelease(error));
            }
            
            if (granted)
            {
               
            } else {
                
                dispatch_async(dispatch_get_main_queue(),
                ^{
                    
                    [[RDCallbackAlertView alloc] initWithTitle:nil message:@"This app requires access to your contacts to function properly. Please visit to the \"Privacy\" section in the iPhone Settings app." cancelButtonTitle:nil andCompletionHandler:^(int btnIndex)
                     
                     {
                         
                         
                     } otherButtonTitles:@"OK", nil];
                    
                });
            }
            
            if (addressBook) CFRelease(addressBook);
        });
        
    } else if (status == kABAuthorizationStatusAuthorized)
    {
        
        if (addressBook) CFRelease(addressBook);
    }
}



- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration
{
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
        toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        userProfilePic.layer.cornerRadius = userProfilePic.frame.size.height / 2;
        
        [userNameLbl setFont:[UIFont fontWithName:@"CentraleSansRndBold" size:65.00]];
    }
    else
    {
        userProfilePic.layer.cornerRadius = userProfilePic.frame.size.height / 2;
        
        [userNameLbl setFont:[UIFont fontWithName:@"CentraleSansRndBold" size:80.00]];
    }
}



#pragma mark - IBAction

- (IBAction)userList
{
	UserListViewController *userListVC = [[UserListViewController alloc] initWithNibName:@"UserListViewController" bundle:nil];
    	
	[self.navigationController pushViewController:userListVC animated:YES];
}


- (IBAction)shareTap
{

    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"broad_cast_enable"])
    {
        BroadcastComposeOutboxViewController *feedVC =
        [[BroadcastComposeOutboxViewController alloc] initWithNibName:@"BroadcastComposeOutboxViewController" bundle:nil];
        
        [self.navigationController pushViewController:feedVC animated:YES];
    }
    else
    {
        NSString *textToShare = @"Hi! I want to be able to text with you securely. IM Your Doc is a free, secure app that is HIPAA compliant. Will you download it, register and then add me to your contacts? Then we can discuss PHI and share images without worrying. Let me know if you have questions. Or you can contact IM Your Doc through their website. Thanks!!";
        
        
        NSArray *objectsToShare = @[textToShare];
        
        activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
        
        activityVC.popoverPresentationController.sourceView = self.view;
        
        [self presentViewController:activityVC animated:YES completion:nil];
    }
}


- (IBAction)showMessages
{    
    MessageInboxViewController *msgInboxVC = [[MessageInboxViewController alloc] initWithNibName:@"MessageInboxViewController" bundle:nil];

    [self.navigationController pushViewController:msgInboxVC animated:YES];
}


- (IBAction)userFeedback
{
    
    

    {
        FeedbackViewController *feedVC = [[FeedbackViewController alloc] initWithNibName:@"FeedbackViewController" bundle:nil];
        [self.navigationController pushViewController:feedVC animated:YES];
        
    }
    


 
}


- (IBAction)accountSetting
{
    if ([[UIDevice currentDevice].systemVersion floatValue] < 8.0)
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"UserType"] isEqualToString:@"Patient"])
            {
                AccountSettingViewController *accountVC = [[AccountSettingViewController alloc] initWithNibName:@"AccountSettingIPadVersionSeven_patient" bundle:nil];
                
                [self.navigationController pushViewController:accountVC animated:YES];
            }
            else
            {
                AccountSettingViewController *accountVC = [[AccountSettingViewController alloc] initWithNibName:@"AccountSettingIPadVersionSeven" bundle:nil];
                
                [self.navigationController pushViewController:accountVC animated:YES];
            }
            
        }
        else
        {
            if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"UserType"] isEqualToString:@"Patient"])
            {
                AccountSettingViewController *accountVC = [[AccountSettingViewController alloc] initWithNibName:@"AccountSettingVersionSeven_patient" bundle:nil];
                
                [self.navigationController pushViewController:accountVC animated:YES];
            }
            else
            {
                AccountSettingViewController *accountVC = [[AccountSettingViewController alloc] initWithNibName:@"AccountSettingVersionSeven" bundle:nil];
                
                [self.navigationController pushViewController:accountVC animated:YES];
            }
            
        }
    }
    
    else
    {
        AccountSettingViewController *accountVC = [[AccountSettingViewController alloc] initWithNibName:@"AccountSettingViewController" bundle:nil];
        
        [self.navigationController pushViewController:accountVC animated:YES];
    }
}


- (IBAction)showOfflineMessages
{
    OfflineNetworkViewController *offMsgInbox = [[OfflineNetworkViewController alloc] initWithNibName:@"OfflineNetworkViewController" bundle:nil];
    
    [self.navigationController pushViewController:offMsgInbox animated:YES];
}


#pragma mark - Update Connectivity

- (void) updateConnectivity:(NSNotification *)note
{
    NSDictionary *dict = note.object;
    
    
    secureLbl.text = [dict objectForKey:@"status"];
    
    
    [secureImg setImage:[UIImage imageNamed:[dict objectForKey:@"image"]]];
}


- (void)updateMessagCount
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"ChatMessage"];
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"chatState=%@ and mark_deleted!='1' and uri!=%@ and identityuri=%@ and outbound=0 ", [NSNumber numberWithInt:ChatStateType_deliveredByReciever],[AppDel myJID],[AppDel myJID]];
    
    
    NSUInteger count = [[AppDel managedObjectContext_roster] countForFetchRequest:fetchRequest error:nil];
    
    
    messageCountView.hidden = YES;
    
    msgCountLbl.hidden = YES;
    
    
    if (count != NSNotFound && count > 0)
    {
        messageCountView.hidden = NO;
        
        msgCountLbl.hidden = NO;
        
        msgCountLbl.text = [NSString stringWithFormat:@"%d", (int)count];
    }
    
    userProfilePic.image=[AppDel image];
    
    accntCountView.hidden = YES;
    
    accntCountLbl.hidden = YES;
    
    
    if ([AppDel request_count] > 0)
    {
        accntCountView.hidden = NO;
        
        accntCountLbl.hidden = NO;
        
        accntCountLbl.text = [NSString stringWithFormat:@"%d", (int)[AppDel request_count]];
    }
}


#pragma mark - Font Settings

- (void)setRequiredFont2
{
    
    userProfilePic.layer.cornerRadius = userProfilePic.frame.size.height / 2;
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [welcomeLbl setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:30.00]];
        
        welcomeLbl.text = @"Welcome!";

        [msgLbl setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:30.00]];
        
        msgLbl.text = @"MESSAGES";
        
        [externalContactsLbl setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:30.00]];
        
        externalContactsLbl.text = @"EXTERNAL CONTACTS";
        
        [userListLbl setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:30.00]];
        
        userListLbl.text = @"MY CONTACTS";
        
        [accntSettingLbl setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:30.00]];
        
        accntSettingLbl.text = @"ACCOUNT SETTINGS";
        
        [feedbackLbl setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:30.00]];
        
        feedbackLbl.text = @"FEEDBACK";
    }
    
    else
    {
        [msgLbl setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
        
        [externalContactsLbl setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
        
        [userListLbl setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
        
        [accntSettingLbl setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
        
        [feedbackLbl setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
    }
}



- (void)setRequiredFont1
{
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [welcomeLbl setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:30.00]];
        
        welcomeLbl.text = @"Welcome!";

        [msgLbl setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:30.00]];
       
        [userListLbl setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:30.00]];
        
        [feedbackLbl setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:30.00]];
        
        [accntSettingLbl setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:30.00]];
        
        [externalContactsLbl setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:30.00]];
        

        
        if (([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeLeft) || ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight))
        {
            [userNameLbl setFont:[UIFont fontWithName:@"CentraleSansRndBold" size:65.00]];
        }
        else
        {
            [userNameLbl setFont:[UIFont fontWithName:@"CentraleSansRndBold" size:80.00]];
        }
    }
    else
    {
        [userNameLbl setFont:[UIFont fontWithName:@"CentraleSansRndBold" size:40.00]];
    }
}


@end

