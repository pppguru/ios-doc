
//
//  AppDelegate.m
//  IMYourDoc
//
//  Created by Sarvjeet on 15/01/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import <Appsee/Appsee.h>
#import <AddressBook/AddressBook.h>

#import "AppDelegate.h"
#import "AppDelegate+XmppMethods.h"
#import "AppDelegate+ClassMethods.h"
#import "AppDelegate+XmppRosterIQMethods.h"

#import "XMPPAutoPing.h"
#import "OfflineContact.h"
#import "OfflineMessages.h"
#import "HomeViewController.h"
#import "ChatViewController.h"
#import "GroupChatReadbyList.h"
#import "LoginViewController.h"

#import "UserListViewController.h"
#import "PendingRequestViewController.h"
#import "AnnouncementWebViewController.h"

#import "VCard.h"
#import "APIManager.h"
#import "VCardAffilication.h"
#import "NSData+XMPP.h"

#import "InboxMessage+ClassMethods.h"
#import "BroadCastMessageSender+ClassMetod.h"

#import "PhysicianProfileViewController.h"
#import "StaffProfileViewController.h"
#import "PatientProfileViewController.h"
#import "SignupStepTwoViewController.h"

#import "UIAlertController+Window.h"


#import <objc/runtime.h>

@import Firebase;

@implementation NSDictionary (IMYourDOC_JSON)

-(NSString *)JSONString{
    
    NSData * data=[NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:nil];
    
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
}

@end


@interface AppDelegate ()<UITextFieldDelegate>
{
    XMPPMUC *mucmodule;
    
    NSOperationQueue * joinRoomQue;
    
    
    BOOL bool_migrateChatMessage;
    
    
    UITextField *plainTextField ;
    
    int pairsOfAllContacts, pairsOfAllMails, contactsOffset, mailsOffset, contactsSyncIteration, totalMailPairs, totalContactsPairs, mailsSyncIteration;
    
    NSArray *phoneArray, *mailArray, *demoMails;
    
    
    UIVisualEffectView *effectView;
    UIVisualEffectView *vibrantView;
    
    
    
    NSTimer* timerInbackGround;
    NSInteger int_timeInBackGround ;
    
    BOOL bool_connectRetry;
    
    int pingTimeOuts;
    
    BOOL bool_pincodeInputPresented;
    
    NSTimer *timerForLogin;
    
}


@property (nonatomic, strong) XMPPAutoPing *autoPing;

@property (nonatomic, retain) XMPPRoomObject *roomfromPush;



@end




@implementation AppDelegate

@synthesize alertController2CheckSessionPin, alertController2AuthenticaionFailed;

@synthesize xmppStream, xmppReconnect, xmppCapabilities, mucmodule, xmppRosterStorage, xmppvCardTempModule, xmppvCardAvatarModule, xmppCapabilitiesStorage, xmppRoster, autoPing = _autoPing;

@synthesize failedFileQueue;

@synthesize secureDelegate;

@synthesize   internetRechablity, networkReachability_internet ,reachability_HostAddress_ApiServer , reachanlity_HostAddress_OpenFire;

@synthesize arr_LogOfPushIDs;

@synthesize manualRosterFetchBool;
#pragma mark - Application LifeCycle

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                      operation:@"__ALC_applicationLifeCycle__"
                                        Content:@""
                                      parameter:@""];
    
    if (launchOptions)
    {
        NSLog(@"Will Push Info .................................. %@", launchOptions);
    }
    
    
    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    
    rosterQueue = dispatch_queue_create("com.imyourdoc.rosterQueue", NULL);
    
    xmppDelegateQueue = dispatch_queue_create("com.imyourdoc.xmppDelegateQueue", NULL);
    
    return true;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Use Firebase library to configure APIs
    [FIRApp configure];
    
    
    //Check the version and clear the previous login session if it is the new version
    if ([[AppData appData] isNewAppVersion]) {
        [[AppData appData] clearPreviousLoginSession];
        
        //Set the current version
        [[AppData appData] saveCurrentAppVersion];
    }
    
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                      operation:@"__ALC_applicationLifeCycle__"
                                        Content:@""
                                      parameter:@""];
    
    
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateBackground) {
        [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"¶¶¶¶¶¶ %s %d",__PRETTY_FUNCTION__,__LINE__]
                                          operation:@"__ALC_applicationLifeCycle__"
                                            Content:@"UIApplicationStateBackground"
                                          parameter:@"UIApplicationStateBackground"];
    }
    
    failedFileQueue = [NSOperationQueue new];
    failedFileQueue.name = @"Files failed in uploading";
    failedFileQueue.maxConcurrentOperationCount = 1;
    
    if(TARGET_IPHONE_SIMULATOR)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"SIMU" forKey:@"deviceToken"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    if(self.image == nil)
        self.image = [UIImage imageNamed:@"Profile"];
    
    
    if(self.xmppStream == nil)
    {
        que_t = [[NSOperationQueue alloc] init];
        
        joinRoomQue=[[NSOperationQueue alloc] init];
        
        joinRoomQue.maxConcurrentOperationCount=1;
        
        
        if (!([[UIDevice currentDevice].systemVersion floatValue] < 8.0) )
            [joinRoomQue setQualityOfService:NSQualityOfServiceBackground];
        
        [que_t setMaxConcurrentOperationCount:2];
        
        if (!([[UIDevice currentDevice].systemVersion floatValue] < 8.0) )
            [que_t setQualityOfService:NSQualityOfServiceDefault];
        
        isAppInBackgroundMsg = NO;
        self.isLoggedState = NO;
        self.isManuallyDisconnect = NO;
        self.keyforPendingUser = [[NSString alloc] init];
        self.keyforDeclinedUser = [[NSString alloc] init];
        
        self.fileQue = [NSMutableArray array];
        self.fromJid = [[NSMutableArray alloc] init];
        self.roomsArr = [[NSMutableArray alloc] init];
        
        self.pendingUserArr = [[NSMutableArray alloc] init];
        self.declinedUserArr = [[NSMutableArray alloc] init];
        
        self.notifyArrayForChat = [[NSMutableArray alloc] init];
        self.openConversationArray = [[NSMutableArray alloc] init];
        self.arr_LogOfPushIDs = [[NSMutableArray alloc] init];
        
        [self setupStream];
        
        NSString *openUUID = [OpenUDID value];
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"openUUID"])
        {
            if ([openUUID isEqualToString:[[NSUserDefaults standardUserDefaults] stringForKey:@"openUUID"]])
            {
                NSLog(@"My openUUID is %@", [[NSUserDefaults standardUserDefaults] stringForKey:@"openUUID"]);
            }
        }
        
        else    //First Launch
        {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"Alerts"];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"Sounds"];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"Vibrate"];
            [[NSUserDefaults standardUserDefaults] setObject:openUUID forKey:@"openUUID"];
            [[NSUserDefaults standardUserDefaults] setFloat:30.0f forKey:@"delay"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"oldVersion"])
        {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"oldVersion"];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"Alerts"];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"Sounds"];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"Vibrate"];
            [[NSUserDefaults standardUserDefaults] setFloat:30.0f forKey:@"delay"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        {
            [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
            
            [[UIApplication sharedApplication] registerForRemoteNotifications];
        }
        
        else
        {
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes: ( UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
        }
        
        [[Reachability reachabilityForInternetConnection] startNotifier];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkChange:) name:kReachabilityChangedNotification object:nil];
        
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        self.homeView = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
        self.loginView = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        self.navController = [[IMYOURDOCNavigationController alloc] initWithRootViewController:self.loginView];
        self.navController.navigationBarHidden = YES;
        
        NSString *strAuthToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"loginToken"];
        if (strAuthToken && ([[NSUserDefaults standardUserDefaults] boolForKey:@"required_config"] == NO)) //1948
        {
            self.isLoggedState = 1;
            
            
            //Set the auth token for API calls.
            [[AppData appData] addAuthTokenIntoHeaderOfAPIManager:strAuthToken withHeaderName:@"x-auth-token"];
            
            //Go to the HomeView automatically
            [self.loginView.navigationController pushViewController:self.homeView animated:YES];
            
            
            if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"UserType"] isEqualToString:@"Physician"])
            {
                self.isFromPhysician = isPhysician;
            }
            
            
            else if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"UserType"] isEqualToString:@"Patient"])
            {
                self.isFromPhysician = isPatient;
            }
            
            
            else
            {
                self.isFromPhysician = isStaff;
            }
            
            
            [AppData connectXMPPServer];
        }
        
        
        [self.window setRootViewController:self.navController];
        
        [self.window makeKeyAndVisible];
        
        
        NSDictionary *remoteNotificationDictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        
        
        if (remoteNotificationDictionary)
        {
            if ([[[[remoteNotificationDictionary objectForKey:@"aps"] objectForKey:@"alert"] objectForKey:@"extra"] objectForKey:@"jid"])
            {
                self.jidFromPushToStartChat = [[[[remoteNotificationDictionary objectForKey:@"aps"] objectForKey:@"alert"] objectForKey:@"extra"] objectForKey:@"jid"];
            }
            
            else
            {
                
            }
        }
        
        
        self.composeButton = [[UIButton alloc] initWithFrame:CGRectMake(self.window.frame.size.width - 70, self.window.frame.size.height - 70, 50, 50)];
        
        
        
        [self.composeButton setImage:[UIImage imageNamed:@"Compose_on"] forState:UIControlStateNormal];
        
        [self.composeButton addTarget:self action:@selector(openComposeScreen) forControlEvents:UIControlEventTouchUpInside];
        
        [Appsee start:@"6d9b048632364d96bbe4ba9e704d00fb"];
        
        [que_t addOperation:[NSBlockOperation blockOperationWithBlock:^{
            [self update_pending_Request_count];
        }]];
        
        
        [NSTimer scheduledTimerWithTimeInterval:100 target:self selector:@selector(update_pending_Request_count) userInfo:nil repeats:YES];
        
        
        if (bool_migrateChatMessage==NO)
        {
            bool_migrateChatMessage=YES;
            
            [self migrationOfChatMessageToInboxMessage];
        }
        
        
        
        
        {
            //@"www.apple.com"
            //XMPPSERVER
            
            reachanlity_HostAddress_OpenFire = [Reachability reachabilityWithHostname:@"www.apple.com"];
            [reachanlity_HostAddress_OpenFire startNotifier];
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkChange:) name:kReachabilityChangedNotification object:nil];
            
            
            
        }
    }
    else
    {
        if (state == UIApplicationStateBackground)
        {
            
            
            [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"¶¶¶¶¶¶ %s %d",__PRETTY_FUNCTION__,__LINE__]
                                              operation:@"__ALC_applicationLifeCycle__"
                                                Content:@"UIApplicationStateBackground+elf.xmppStream is not nil"
                                              parameter:@"UIApplicationStateBackground_+elf.xmppStream is not nil"];
        }
        else{
            [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"🇺🇸🇺🇺🇺🇺🇺 %s %d",__PRETTY_FUNCTION__,__LINE__]
                                              operation:@"__ALC_applicationLifeCycle__"
                                                Content:@"elf.xmppStream is not nil "
                                              parameter:@"elf.xmppStream is not nil"];
        }
        
        
        
    }
    
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    
    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                      operation:@"__ALC_applicationLifeCycle__"
                                        Content:@""
                                      parameter:@""];
    
    
    [self.arr_LogOfPushIDs removeAllObjects];
    self.jidFromPushToStartChat = nil;
    
    
    isAppInBackgroundMsg = NO;
    
    
    bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler: ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if([[self xmppStream] isConnected])
            {
                XMPPPresence *presence = [XMPPPresence presence];
                
                
                NSXMLElement *status = [NSXMLElement elementWithName:@"status"];
                
                [status setStringValue:@"Available"];
                
                
                [presence addChild:status];
                
                
                [[self xmppStream] sendElement:presence];
                
            }
            [[UIApplication sharedApplication] endBackgroundTask:self->bgTask];
            
            self->bgTask = UIBackgroundTaskInvalid;
        });
    }];
    
    //Save the last active time, if the pincode input is not presented
    
    NSLog(@"--------------------- Did Enter Background -----------------------");
    if (bool_pincodeInputPresented == NO) {
        NSLog(@"--Setuping InActiveTime---");
        [self setInActiveTime:[NSDate date]];
    }
}




- (void)applicationWillEnterForeground:(UIApplication *)application
{
    
    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                      operation:@"__ALC_applicationLifeCycle__"
                                        Content:@""
                                      parameter:@""];
    
    
    
    LoginRequestModel *requestModel = [LoginRequestModel new];
    requestModel.user_name = [AppData appData].XMPPmyJID;
    requestModel.password = [AppData appData].XMPPmyJIDPassword;
    
    [[APIManager sharedHTTPManager] loginWithRequestModel:requestModel
                                                  success:^(){}
                                                  failure:^(NSError *error)
     {
         
         if (error) {
             NSLog(@"Error: %@ %@", error, [error userInfo]);
         }
         
     }];
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    
    if (self.myJID != nil)
    {
        if ([[self xmppStream] isConnected] == NO)
        {
            if ([[NSUserDefaults standardUserDefaults] objectForKey:@"loginToken"])
            {
                
                if([[NSUserDefaults standardUserDefaults] boolForKey:@"required_config"]==NO)
                    [AppData connectXMPPServer];
            }
            
            
        }
    }
    
    
    
    NSLog(@"------------------- Will Enter Foreground ------------------------");
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    
    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                      operation:@"__ALC_applicationLifeCycle__"
                                        Content:@""
                                      parameter:@""];
    
    [self.secureDelegate show:@":"];
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    NSLog(@"------------------- Did Become Active ------------------------");
    [self checkIfUserVerificationNeeded];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                      operation:@"__ALC_applicationLifeCycle__"
                                        Content:@""
                                      parameter:@""];
    
    [application ignoreSnapshotOnNextApplicationLaunch];
    
    [self.secureDelegate hide:@"applicationWillResignActive:"];
    
    [application setApplicationIconBadgeNumber:[self unreadMessages]];
    
    //Save the last active time, if the pincode input is not presented
    NSLog(@"--------------------- Will Resign Active -----------------------");
    if (bool_pincodeInputPresented == NO) {
        NSLog(@"--Setuping InActiveTime---");
        [self setInActiveTime:[NSDate date]];
    }
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                      operation:@"__ALC_applicationLifeCycle__"
                                        Content:@""
                                      parameter:@""];
    
    self.jidFromPushToStartChat = nil;
    [self.arr_LogOfPushIDs removeAllObjects];
    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                      operation:@"__ALC_applicationLifeCycle__"
                                        Content:@""
                                      parameter:@""];
    
    
    
}


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSString *urlStr = [url absoluteString];
    
    
    if ([urlStr rangeOfString:@"imyourdoc://?"].location != NSNotFound)
    {
        urlStr = [urlStr stringByReplacingOccurrencesOfString:@"imyourdoc://?" withString:@""];
        
        
        NSArray *step1 = [urlStr componentsSeparatedByString:@"&"];
        
        NSString *userName, *userType;
        
        for (NSString *str in step1)
        {
            NSArray *step2 = [str componentsSeparatedByString:@"="];
            
            if ([step2 containsObject:@"username"])
            {
                NSLog(@"USERNAME: %@", [step2 lastObject]);
                
                userName = [step2 lastObject];
            }
            else if ([step2 containsObject:@"user_type"])
            {
                NSLog(@"USERTYPE: %@", [step2 lastObject]);
                
                userType = [step2 lastObject];
            }
        }
        
        
        
        if ([[userType uppercaseString] isEqualToString:@"PHYSICIAN"])
        {
            PhysicianProfileViewController *phy = [[PhysicianProfileViewController alloc] initWithNibName:@"PhysicianProfileViewController" bundle:nil];
            
            phy.toUserName = userName;
            
            [self.navController pushViewController:phy animated:YES];
        }
        
        else if ([[userType uppercaseString] isEqualToString:@"STAFF"])
        {
            StaffProfileViewController *staff = [[StaffProfileViewController alloc] initWithNibName:@"StaffProfileViewController" bundle:nil];
            
            staff.toUserName = userName;
            
            [self.navController pushViewController:staff animated:YES];
        }
        
        else if ([[userType uppercaseString] isEqualToString:@"PATIENT"])
        {
            PatientProfileViewController *pat = [[PatientProfileViewController alloc] initWithNibName:@"PatientProfileViewController" bundle:nil];
            
            pat.toUserName = userName;
            
            [self.navController pushViewController:pat animated:YES];
        }
        
        
        return YES;
    }
    
    
    return NO;
}


- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                      operation:@"iOS initiated a check for more content"
                                        Content:@""
                                      parameter:@""];
    
    if (self.myJID != nil)
    {
        if ([[self xmppStream] isConnected] == NO)
        {
            if ([[NSUserDefaults standardUserDefaults] objectForKey:@"loginToken"])
            {
                
                if([[NSUserDefaults standardUserDefaults] boolForKey:@"required_config"]==NO)
                    [AppData connectXMPPServer];
            }
            
            
        }
    }

    completionHandler(UIBackgroundFetchResultNewData);
}


- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler
{
    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                      operation:@"__ALC_applicationLifeCycle__"
                                        Content:@""
                                      parameter:@""];
    
    
    completionHandler(UIBackgroundFetchResultNewData);
}


#pragma mark - PIN code / Touch ID Lock
- (void)checkIfUserVerificationNeeded{
    
    NSDate *lastActiveTime = self.inActiveTime;
    
    //Check the idle time for pin code entry
    if (lastActiveTime == nil
        || [[NSDate date] timeIntervalSinceDate:self.inActiveTime] > Timer_BackGround )
    {
        if ([AppData appData].XMPPmyJID && [AppData appData].XMPPmyJIDPassword
            && ([[NSUserDefaults standardUserDefaults] boolForKey:@"required_config"] == NO)
            && [[NSUserDefaults standardUserDefaults] valueForKey:@"loginToken"])
        {
            
            NSLog(@"-------- Show PIN Alert ---------");
            [self performSelector:@selector(enterPinAlert) withObject:nil afterDelay:0.6f];
        }
    }
    else
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadAppDelegateTable" object:nil];
        });
    }
}

- (void) enterPinAlert
{
    bool_pincodeInputPresented = YES;
    
    if (alertController2CheckSessionPin)
    {
        [alertController2CheckSessionPin dismissViewControllerAnimated:YES completion:nil];
        
        alertController2CheckSessionPin = nil;
    }
    
    if ([AppData appData].XMPPmyJID && [AppData appData].XMPPmyJIDPassword
        && ([[NSUserDefaults standardUserDefaults] boolForKey:@"required_config"] == NO)
        && [[NSUserDefaults standardUserDefaults] valueForKey:@"loginToken"])
    {
        LAContext *localAuthenticationContext = [[LAContext alloc] init];
        
        
        __autoreleasing NSError *authenticationError;
        
        if ([localAuthenticationContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authenticationError])
        {
            
            
            [localAuthenticationContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:@"Please authenticate to continue" reply:^(BOOL success, NSError *error)
             {
                 
                 if (success)
                 {
                     bool_pincodeInputPresented = NO;
                     [self setInActiveTime:[NSDate date]];  //This should be here, because Touch ID verification would call the foreground state in the app
                     
                     dispatch_async(dispatch_get_main_queue(), ^{
                         
                         [effectView removeFromSuperview];
                         [vibrantView removeFromSuperview];
                         
                         [self showSpinnerWithText:@""];
                         
                         [self hideSpinnerAfterDelayWithText:@"Verified" andImageName:@"ProcessCompleted.png"];
                         
                         [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(verifiedAuthentication) userInfo:nil repeats:NO];
                     });
                 }
                 
                 else
                 {
                     if ((error.code == kLAErrorAuthenticationFailed) || (error.code == kLAErrorUserFallback) || (error.code == kLAErrorUserCancel))
                     {
                         [self pinAlertController:NO];
                     }
                     
                     else
                     {
                         bool_pincodeInputPresented = NO;
                         NSLog(@" ....................................................... %@", error.description);
                     }
                 }
             }];
        }
        
        else
        {
            [self pinAlertController:NO];
        }
    }
}

- (void)pinAlertController:(BOOL)isTimedOut
{
    bool_pincodeInputPresented = YES;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (![self.window.subviews containsObject:effectView])
        {
            UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
            UIVibrancyEffect *vibrancy = [UIVibrancyEffect effectForBlurEffect:blur];
            
            effectView = [[UIVisualEffectView alloc]initWithEffect:blur];
            effectView.frame = self.window.frame;
            
            vibrantView = [[UIVisualEffectView alloc]initWithEffect:vibrancy];
            vibrantView.frame = self.window.frame;
            
            [self.window addSubview:effectView];
            [self.window addSubview:vibrantView];
        }
        
        
        alertController2CheckSessionPin = [UIAlertController alertControllerWithTitle:nil message:@"Please enter your PIN to continue" preferredStyle:UIAlertControllerStyleAlert];
        
        if (isTimedOut)
            alertController2CheckSessionPin = [UIAlertController alertControllerWithTitle:@"Session Timed out" message:@"Your application has timed out. Please enter your PIN to continue." preferredStyle:UIAlertControllerStyleAlert];
        
        __weak AppDelegate *weakSelf = self;
        [alertController2CheckSessionPin addTextFieldWithConfigurationHandler:^(UITextField *textField)
         {
             
             textField.keyboardType = UIKeyboardTypeNumberPad;
             textField.placeholder = @"Password";
             textField.secureTextEntry = YES;
             textField.tag = TAG_PIN_Grobal;
             [textField setDelegate:weakSelf];
         }];
        
        [alertController2CheckSessionPin addAction:[UIAlertAction actionWithTitle:@"Logout" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull_action) {
            bool_pincodeInputPresented = NO;
            
            [self setLoginType:0];
            [self signOutFromApp];
        }]];
        
        [alertController2CheckSessionPin show];
    });
    
}


#pragma mark - Push Notification Delegates

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSString *uStr = [NSString stringWithFormat:@"%@", deviceToken];

    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                      operation:@"__ALC_applicationLifeCycle__"
                                        Content:@"deviceToken"
                                      parameter:uStr];

    uStr = [uStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    uStr = [uStr stringByReplacingOccurrencesOfString:@">" withString:@""];
    uStr = [uStr stringByReplacingOccurrencesOfString:@"<" withString:@""];
    uStr = [uStr stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    
    [[NSUserDefaults standardUserDefaults] setObject:uStr forKey:@"deviceToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSLog(@"------------ PUSH NOTIFICATION : Device Token has been registered--------------------------------------");
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                      operation:@"__ALC_applicationLifeCycle__"
                                        Content:@""
                                      parameter:@""];
    
    NSLog(@"-----------PUSH NOTIFICATION Failed--------------------------------------");
    
    [[NSUserDefaults standardUserDefaults] setObject:@"SIMU" forKey:@"deviceToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[[UIAlertView alloc] initWithTitle:nil message:@"Unable to register the device for getting push notification." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo


{
    NSLog(@"Push notification userinfo : %@",userInfo);

    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                      operation:@"__ALC_applicationLifeCycle__"
                                        Content:@""
                                      parameter:@""];
    
    
    [self handlePushMessage:userInfo];
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                      operation:@"Remote Notfication received with userInfo:"
                                        Content:[userInfo description]
                                      parameter:@""];
    
    if([userInfo[@"aps"][@"content-available"] intValue]== 1) //it's the silent notification
    {
        NSLog(@"didReceiveRemoteNotification inside avneet %@",userInfo);
        
        
        if (![self.arr_LogOfPushIDs containsObject:[[[[userInfo objectForKey:@"aps"] objectForKey:@"alert"] objectForKey:@"extra"] objectForKey:@"id"]]&&[[[[userInfo objectForKey:@"aps"] objectForKey:@"alert"] objectForKey:@"extra"] objectForKey:@"id"])
        {
            
            if ([[[[userInfo objectForKey:@"aps"] objectForKey:@"alert"] objectForKey:@"extra"] objectForKey:@"id"])
            {
                [self.arr_LogOfPushIDs addObject:[[[[userInfo objectForKey:@"aps"] objectForKey:@"alert"] objectForKey:@"extra"] objectForKey:@"id"]];
            }
            
        }
        else if ([[[[[userInfo objectForKey:@"aps"] objectForKey:@"alert"] objectForKey:@"extra"] objectForKey:@"action"] isEqualToString:@"app_force_update"])
        {
            NSLog(@"didReceiveRemoteNotification inside Upneet %@",userInfo);
            [self checkIfUpdateIsRequired];
            
            return;
            
        }
        
        
        [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                          operation:@"‡‡‡‡‡notification‡‡‡‡‡‡ 1 true"
                                            Content:[NSString stringWithFormat:@"content-available %@",userInfo]
                                          parameter:@"See "];
        
        
        if ([self xmppStream] == nil)
        {
            dispatch_queue_t queue = dispatch_get_main_queue();
            dispatch_group_t group = dispatch_group_create();
            
            //code to setup stream and call the connect method.
            dispatch_group_async(group, queue, ^{
                [self setupStream];
            });
            
            dispatch_group_notify(group, queue, ^{
                [AppData connectXMPPServer];
                [xmppReconnect manualStart];
            });
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if ([[self xmppStream] isConnected] == YES)
                {
                    completionHandler(UIBackgroundFetchResultNoData);
                }
                else{
                    completionHandler(UIBackgroundFetchResultNewData);
                }
            });
            
        }
        else if ([[self xmppStream] isConnected] == YES)
        {
            
            NSLog(@"* isConnected] == YES • %@", userInfo);
            
            [self authenticate];
            
            XMPPPresence *presence = [XMPPPresence presence];
            
            NSXMLElement *status = [NSXMLElement elementWithName:@"status"];
            
            [status setStringValue:@"Available"];
            
            
            [presence addChild:status];
            
            
            [[self xmppStream] sendElement:presence];
            
            
            completionHandler(UIBackgroundFetchResultNoData);
            
        }
        else
        {
            NSLog(@"* isConnected] == NO • %@", userInfo);
            
            [AppData connectXMPPServer];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if ([[self xmppStream] isConnected] == YES)
                {
                    NSLog(@"* isConnected] == NO  NoData • %@", userInfo);
                    completionHandler(UIBackgroundFetchResultNoData);
                }
                else{
                    NSLog(@"* isConnected] == NO  NewData • %@", userInfo);
                    completionHandler(UIBackgroundFetchResultNewData);
                }
            });
            
        }
        
    }
    
    else
    {
        
        NSLog(@" value od content-available   %@",userInfo[@"aps"][@"content-available"]);
        NSLog(@" class od content-available   %d",[userInfo[@"aps"][@"content-available"] intValue]);
        
        NSLog(@"vifetch CompletionHandler =0 jayvie %@",userInfo);
        [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                          operation:@"‡‡‡‡‡notification‡‡‡‡‡‡ 2 false"
                                            Content:[NSString stringWithFormat:@"content-available %@",userInfo]
                                          parameter:@"See "];
        
        [self application:application didReceiveRemoteNotification:userInfo];
        completionHandler(UIBackgroundFetchResultFailed);
    }
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    
    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                      operation:@"__ALC_applicationLifeCycle__"
                                        Content:@""
                                      parameter:@""];
}

- (void) handlePushMessage: (NSDictionary *) pushDictionary
{
    
    NSLog(@"---------------PUSH NOTIFICATION Received ----------------  : %@", pushDictionary);
    
    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                      operation:@"Remote  Notification"
                                        Content:[pushDictionary JSONRepresentation]
                                      parameter:@""];
    
    if ([[[pushDictionary objectForKey:@"aps"] objectForKey:@"alert"] isKindOfClass:[NSDictionary class]])
    {
        if ([[[[[pushDictionary objectForKey:@"aps"] objectForKey:@"alert"] objectForKey:@"extra"] objectForKey:@"action"] isEqualToString:@"add_invitation"])
        {
            [[RDCallbackAlertView alloc] initWithTitle:@"Invitation Request" message:[[[pushDictionary objectForKey:@"aps"] objectForKey:@"alert"] objectForKey:@"body"] cancelButtonTitle:nil andCompletionHandler:^(int btnIDX) {
                
                if (btnIDX == 0)
                {
                    PendingRequestViewController *prVC = [[PendingRequestViewController alloc] initWithNibName:@"PendingRequestViewController" bundle:nil];
                    
                    [self.navController pushViewController:prVC animated:YES];
                }
                
            } otherButtonTitles:@"Check", @"Cancel", nil];
        }
        
        else if ([[[[[pushDictionary objectForKey:@"aps"] objectForKey:@"alert"] objectForKey:@"extra"] objectForKey:@"action"] isEqualToString:@"open_roster"])
        {
            [[RDCallbackAlertView alloc] initWithTitle:@"Request accepted" message:[[[pushDictionary objectForKey:@"aps"] objectForKey:@"alert"] objectForKey:@"body"] cancelButtonTitle:nil andCompletionHandler:^(int btnIDX) {
                
                if (btnIDX == 0)
                {
                    UserListViewController *ulVC = [[UserListViewController alloc] initWithNibName:@"UserListViewController" bundle:nil];
                    
                    
                    if ([[[[[pushDictionary objectForKey:@"aps"] objectForKey:@"alert"] objectForKey:@"extra"] objectForKey:@"user_type"] isEqualToString:@"Physician"])
                    {
                        ulVC.listType = LIST_PHYSICIAN;
                    }
                    
                    else if ([[[[[pushDictionary objectForKey:@"aps"] objectForKey:@"alert"] objectForKey:@"extra"] objectForKey:@"user_type"] isEqualToString:@"Patient"])
                    {
                        ulVC.listType = LIST_PATIENT;
                    }
                    
                    else if ([[[[[pushDictionary objectForKey:@"aps"] objectForKey:@"alert"] objectForKey:@"extra"] objectForKey:@"user_type"] isEqualToString:@"Staff"])
                    {
                        ulVC.listType = LIST_STAFF;
                    }
                    
                    
                    [self.navController pushViewController:ulVC animated:YES];
                    
                    
                    [ulVC refresh];
                }
                
            } otherButtonTitles:@"Check", @"Cancel", nil];
        }
        
        
        
        else if ([[[[[pushDictionary objectForKey:@"aps"] objectForKey:@"alert"] objectForKey:@"extra"] objectForKey:@"action"] isEqualToString:@"open_announcement"])
        {
            AnnouncementWebViewController *sVC = [[AnnouncementWebViewController alloc] initWithNibName:@"AnnouncementWebViewController" bundle:nil];
            sVC.str_ann_id = [[[[pushDictionary objectForKey:@"aps"] objectForKey:@"alert"] objectForKey:@"extra"] objectForKey:@"ann_id"] ;
            
            
            
            UIApplicationState state = [UIApplication sharedApplication].applicationState;
            
            
            if (state==UIApplicationStateActive||state==UIApplicationStateInactive)
            {
                [[RDCallbackAlertView alloc] initWithTitle:[[[pushDictionary objectForKey:@"aps"] objectForKey:@"alert"] objectForKey:@"body"]  message:nil cancelButtonTitle:nil andCompletionHandler:^(int btnIndex)
                 
                 {
                     if (btnIndex==0)
                     {
                         [self.navController pushViewController:sVC animated:YES];
                     }
                     
                     
                 } otherButtonTitles:@"View",@"Cancel",  nil];
            }
            else if (state==UIApplicationStateBackground)
            {
                [self.navController pushViewController:sVC animated:YES];
            }
            
            
            
        }
        
        else if ([[[[[pushDictionary objectForKey:@"aps"] objectForKey:@"alert"] objectForKey:@"extra"] objectForKey:@"action"] isEqualToString:@"open_room"])
        {
            if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground || [[UIApplication sharedApplication] applicationState] == UIApplicationStateInactive)
            {
                if ([self.xmppStream isConnected])
                {
                    XMPPJID *roomJid = [XMPPJID jidWithString:[[[[pushDictionary objectForKey:@"aps"] objectForKey:@"alert"] objectForKey:@"extra"] objectForKey:@"roomJID"]];
                    
                    
                    XMPPRoomObject *liveRoom = [[self.roomsArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"room_jidStr=%@", [roomJid bare]]] lastObject];
                    
                    
                    if (liveRoom != nil)
                    {
                        ChatViewController *chatController = [[ChatViewController alloc] initWithNibName:@"ChatViewController" bundle:nil];
                        
                        chatController.roomObj      = liveRoom ;
                        
                        chatController.room         = liveRoom.room;
                        
                        chatController.jid          = roomJid;
                        
                        chatController.forChat      = YES;
                        
                        chatController.isGroupChat  = YES;
                        
                        [self.navController pushViewController:chatController animated:YES];
                    }
                    
                    else
                    {
                        self.roomfromPush = [self fetchOrInsertRoom:[[XMPPRoom alloc] initWithRoomStorage:[XMPPRoomMemoryStorage sharedInstanse] jid:roomJid]];
                        
                        self.roomfromPush.streamJidStr=[AppDel myJID];
                        
                        self.roomfromPush.room_status=@"Active";
                        
                        if(self.roomfromPush.lastMessageDate==nil)
                        {
                            self.roomfromPush.lastMessageDate=[NSDate dateWithTimeIntervalSinceNow:-210];
                            self.roomfromPush.creationDate=self.roomfromPush.lastMessageDate;
                        }
                        
                        [self.roomfromPush.room activate:xmppStream];
                        
                        
                        [self.roomfromPush.room addDelegate:self delegateQueue:xmppDelegateQueue];
                        
                        
                        [self.roomfromPush.room fetchRoomInfo];
                    }
                }
                
                else
                {
                    
                    if(self.xmppStream==nil)
                    {
                        [self setupStream];
                        [AppData connectXMPPServer];
                    }
                    else
                    {
                        if(![self.xmppStream isConnected])
                        {
                            [AppData connectXMPPServer];
                        }
                        else
                        {
                            [self authenticate];
                        }
                    }
                    
                    self.roomfromPush = [self fetchOrInsertRoom:[[XMPPRoom alloc] initWithRoomStorage:[XMPPRoomMemoryStorage sharedInstanse] jid:[XMPPJID jidWithString:[[[[pushDictionary objectForKey:@"aps"] objectForKey:@"alert"] objectForKey:@"extra"] objectForKey:@"roomJID"]]]];
                }
            }
            
            else
            {
                NSLog(@"<><><>App was not in bg so not storing jid. Current App state is %ld", (long)[[UIApplication sharedApplication] applicationState]);
                
                XMPPJID *roomJid = [XMPPJID jidWithString:[[[[pushDictionary objectForKey:@"aps"] objectForKey:@"alert"] objectForKey:@"extra"] objectForKey:@"roomJID"]];
                
                
                XMPPRoomObject *liveRoom = [[self.roomsArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"room_jidStr=%@", [roomJid bare]]] lastObject];
                
                if(liveRoom==nil)
                {
                    liveRoom = [self fetchOrInsertRoom:[[XMPPRoom alloc] initWithRoomStorage:[XMPPRoomMemoryStorage sharedInstanse] jid:roomJid]];
                    
                    liveRoom.streamJidStr=[AppDel myJID];
                    
                    liveRoom.room_status=@"Active";
                    
                    if(liveRoom.lastMessageDate==nil)
                    {
                        liveRoom.lastMessageDate=[NSDate dateWithTimeIntervalSinceNow:-500];
                        
                        liveRoom.creationDate=liveRoom.lastMessageDate;
                    }
                    [liveRoom.room activate:xmppStream];
                    
                    
                    [liveRoom.room addDelegate:self delegateQueue:xmppDelegateQueue];
                    
                    
                    [liveRoom.room fetchRoomInfo];
                }
                
                
            }
        }
        // Handle Logout Notification
        else if ([[[[[pushDictionary objectForKey:@"aps"] objectForKey:@"alert"] objectForKey:@"extra"] objectForKey:@"action"] isEqualToString:@"app_force_logout"])
        {
            [self locationUpdate];
            
            [self checkIfUpdateIsRequired];
            //  [AppDel signOutFromAppSilent];
            
        }
        else if ([[[[[pushDictionary objectForKey:@"aps"] objectForKey:@"alert"] objectForKey:@"extra"] objectForKey:@"action"] isEqualToString:@"app_force_update"])
        {
            
            [self checkIfUpdateIsRequired];
        }
        
        
        else if ([[[[pushDictionary objectForKey:@"aps"] objectForKey:@"alert"] objectForKey:@"extra"] objectForKey:@"jid"])
        {
            if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground || [[UIApplication sharedApplication] applicationState] == UIApplicationStateInactive)
            {
                XMPPJID *toJID = [XMPPJID jidWithString:[[[[pushDictionary objectForKey:@"aps"] objectForKey:@"alert"] objectForKey:@"extra"] objectForKey:@"jid"]];
                
                
                ChatViewController *chatController = [[ChatViewController alloc] initWithNibName:@"ChatViewController" bundle:nil];
                
                chatController.user = [self fetchUserForJIDString:toJID.bare];
                
                chatController.jid = chatController.user.jid;
                
                chatController.forChat = YES;
                
                [self.navController pushViewController:chatController animated:YES];
            }
            
            else
            {
                NSLog(@"<><><>App was not in bg so not storing jid. Current App state is %ld", (long)[[UIApplication sharedApplication] applicationState]);
            }
        }
        
    }
}

- (void)registerForPushNotification
{
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"loginToken"] )
    {
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              
                              @"generateDeviceToken", @"method",
                              
                              [[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"], @"device_token",
                              
                              [[NSUserDefaults standardUserDefaults] objectForKey:@"loginToken"], @"login_token",
                              @"IOS",@"device",
                              nil];
        
        [[WebHelper sharedHelper] setWebHelperDelegate:self];
        [[WebHelper sharedHelper]sendRequest:dict tag:S_GenerateDeviceToken delegate:self];
    }
}



#pragma mark - Reachability

- (void)tryReconnectChatServer
{
    if (!internetRechablity)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
        
        
        internetRechablity = [Reachability reachabilityForInternetConnection];
        
        
        [self hideSpinnerAfterDelayWithText:@"Disconnected" andImageName:@"warning.png"];
    }
}




- (void)checkNetworkStatus:(NSNotification *)notice
{
    NetworkStatus internetStatus = [internetRechablity currentReachabilityStatus];
    
    switch (internetStatus)
    {
        case ReachableViaWiFi:
        {
            if ([[AppData appData].userPIN isEqualToString:@"" ])
            {
                [self startLoginWithUserName];
            }
            
            else
            {
                [AppData connectXMPPServer];
            }
            
            break;
        }
            
        case ReachableViaWWAN:
        {
            if ([AppData appData].userPIN == nil)
            {
                [self startLoginWithUserName];
            }
            
            else
            {
                [AppData connectXMPPServer];
            }
            
            break;
        }
            
        case NotReachable:
        {
            [AppData sendLocalNotificationForNotConnected];
            
            [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                              operation:@"XMPPREACHABILITY>>NotReachable"
                                                Content:@"Not Connected"
                                              parameter:@""];
            
            break;
        }
    }
}


- (void)networkChange:(NSNotification *)notification
{
    Reachability *rechability = [notification object];
    
    
    NSLog(@"...%@ ,%@",rechability.currentReachabilityString,rechability.currentReachabilityFlags);
    
    
    
    if(rechability==reachanlity_HostAddress_OpenFire)
    {
        NSLog(@"....HOST reachability");
    }
    
    
    if ([rechability currentReachabilityStatus] == NotReachable)
    {
        [AppData sendLocalNotificationForNotConnected];
        self.appIsDisconnected=YES;
    }
    
    else
    {
        
        if([[rechability currentReachabilityFlags] isEqualToString:@"-R -------"])
        {
            
            //Internet and host is avaialable
            if ([[AppDel xmppStream] isConnected])
            {
                [AppData sendLocalNotificationForSecurelyConnected];
                
            }
            
            
            self.appIsDisconnected=NO;
        }
        else if([[rechability currentReachabilityFlags] isEqualToString:@"-R -----l-"])
        {
            
            //Internet Not avaialable
            
            self.appIsDisconnected=YES;
            
            [AppData sendLocalNotificationForNotInternetConnection];
        }
        
        
        else
        {
            //exeption cases
            
            if ([[AppDel xmppStream] isConnected])
            {
                [AppData sendLocalNotificationForSecurelyConnected];
                
            }
            else
            {
                [AppData sendLocalNotificationForNotConnected];
                
                
                /* if(self.xmppStream!=nil)
                 {
                 [self.xmppReconnect manualStart];
                 }*/
            }
        }
    }
}


#pragma mark - Core Data

- (NSManagedObjectContext *)managedObjectContext_roster
{
    if (managedObjectContext_roster == nil)
    {
        if ( [NSThread isMainThread] )
            managedObjectContext_roster = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        else
            managedObjectContext_roster = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        
        
        NSPersistentStoreCoordinator *psc = [xmppRosterStorage persistentStoreCoordinator];
        
        
        [managedObjectContext_roster setPersistentStoreCoordinator:psc];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextDidSave:) name:NSManagedObjectContextDidSaveNotification object:nil];
    }
    
    if ( [NSThread isMainThread] ) {
        [managedObjectContext_roster setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
        
    } else {
        [managedObjectContext_roster setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];
    }
    

    
    
    return managedObjectContext_roster;
}


- (NSManagedObjectContext *)managedObjectContext_capabilities
{
    if (managedObjectContext_capabilities == nil)
    {
        managedObjectContext_capabilities = [[NSManagedObjectContext alloc] init];
        
        
        NSPersistentStoreCoordinator *psc = [xmppCapabilitiesStorage persistentStoreCoordinator];
        
        
        [managedObjectContext_capabilities setPersistentStoreCoordinator:psc];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextDidSave:) name:NSManagedObjectContextDidSaveNotification object:nil];
    }
    
    
    return managedObjectContext_capabilities;
}


- (NSManagedObjectContext *)managedObjectContext_vCard
{
    if (managedObjectContext_vCard == nil)
    {
        managedObjectContext_vCard = [[NSManagedObjectContext alloc] init];
        
        
        XMPPvCardCoreDataStorage *xmppVcardStorage = [XMPPvCardCoreDataStorage sharedInstance];
        
        
        NSPersistentStoreCoordinator *psc = [xmppVcardStorage persistentStoreCoordinator];
        
        
        [managedObjectContext_vCard setPersistentStoreCoordinator:psc];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextDidSave:) name:NSManagedObjectContextDidSaveNotification object:nil];
    }
    
    
    return managedObjectContext_vCard;
}


- (void)contextDidSave:(NSNotification *)notification
{
    NSManagedObjectContext *sender = (NSManagedObjectContext *)[notification object];
    
    
    if (sender != managedObjectContext_roster && [sender persistentStoreCoordinator] == [managedObjectContext_roster persistentStoreCoordinator])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [managedObjectContext_roster mergeChangesFromContextDidSaveNotification:notification];
        });
    }
    
    else if (sender != managedObjectContext_capabilities && [sender persistentStoreCoordinator] == [managedObjectContext_capabilities persistentStoreCoordinator])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [managedObjectContext_capabilities mergeChangesFromContextDidSaveNotification:notification];
        });
    }
    
    else if (sender != managedObjectContext_vCard && [sender persistentStoreCoordinator] == [managedObjectContext_vCard persistentStoreCoordinator])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [managedObjectContext_vCard mergeChangesFromContextDidSaveNotification:notification];
        });
    }
}


#pragma mark - Sound

- (void)playSoundForKey
{
    NSString *const resourceDir = [[NSBundle mainBundle] resourcePath];
    
    
    NSString *musicFilename;
    
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"Sound"])
    {
        musicFilename = [NSString stringWithFormat:@"%@.caf", [[NSUserDefaults standardUserDefaults] objectForKey:@"Sound"]];
    }
    
    else
    {
        musicFilename = @"Ripple.caf";
    }
    
    
    NSString *const fullPath = [resourceDir stringByAppendingPathComponent:musicFilename];
    
    
    NSURL *const url = [NSURL fileURLWithPath:fullPath];
    
    
    if (!url)
    {
        return;
    }
    
    
    if (url != nil)
    {
        SystemSoundID aSoundID;
        
        
        OSStatus error = AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &aSoundID);
        
        
        if (error != kAudioServicesNoError)
        {
            return;
        }
        
        UIApplicationState state = [[UIApplication sharedApplication] applicationState];
        if ( state != UIApplicationStateBackground )
        {
            AudioServicesPlaySystemSound(aSoundID);
        }
        
        
    }
}


#pragma mark - Application Activities




- (void)setMyJID:(NSString *)myJID
{
    [[NSUserDefaults standardUserDefaults] setObject:myJID forKey:@"myJID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (NSString *)myJID
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"myJID"];
}


- (void)signOutFromAppSilent
{
    [self hideSpinner];
    
    if (alertController2CheckSessionPin)
    {
        bool_pincodeInputPresented = NO;
        
        [alertController2CheckSessionPin dismissViewControllerAnimated:YES completion:nil];
        
        alertController2CheckSessionPin = nil;
    }
    
    if (self.isFromPhysician == isPhysician)
    {
        if ([self.pendingUserArr count] > 0)
        {
            [[NSUserDefaults standardUserDefaults] setObject:self.pendingUserArr forKey:self.keyforPendingUser];
            
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        else if ([self.declinedUserArr count] > 0)
        {
            [[NSUserDefaults standardUserDefaults] setObject:self.declinedUserArr forKey:self.keyforDeclinedUser];
            
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    
    
    if (isXmppConnected)
    {
        [self showSpinnerWithText:@"Disconnecting from Server"];
        
        
        if (isXmppConnected)
        {
            self.isManuallyDisconnect = TRUE;
            
            [self disconnect];
        }
    }
    else
    {
        [self clearDataOnSignOut];
    }
    
    [effectView removeFromSuperview];
    [vibrantView removeFromSuperview];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navController popToRootViewControllerAnimated:YES];
    });
    
}

-(void)signOutFromAppVJ{
    [self stopSessionCheckTimer];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"rememberMe"])
    {
        if ([AppData appData].XMPPmyJID)
        {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kXMPPmyJID];
        }
    }
    
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kXMPPmyPassword];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserType"];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"required_config"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self clearDataOnSignOut];
    
    [self.loginView.navigationController popToRootViewControllerAnimated:NO];
    
}
- (void) signOutFromApp
{
    
    if (![self.navController.visibleViewController isKindOfClass:[DeviceRegistrationViewController class]])
    {

        {
            if (self.isFromPhysician == isPhysician)
            {
                if ([self.pendingUserArr count] > 0)
                {
                    [[NSUserDefaults standardUserDefaults] setObject:self.pendingUserArr forKey:self.keyforPendingUser];
                    
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                
                else if ([self.declinedUserArr count] > 0)
                {
                    [[NSUserDefaults standardUserDefaults] setObject:self.declinedUserArr forKey:self.keyforDeclinedUser];
                    
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
            }
            
            [self showSpinnerWithText:@"Disconnecting from Server"];
            
            if (isXmppConnected)
            {
                self.isManuallyDisconnect = TRUE;
                
                [self disconnect];
            }
        }
        
    }
    
    [self signOutRequest];
    
    [self.navController popToRootViewControllerAnimated:YES];
    
    [effectView removeFromSuperview];
    [vibrantView removeFromSuperview];
    
}


-( void)clearDataOnSignOut{
    
    [self setLoginType:0];
    manualRosterFetchBool= NO;

    //Clear the previous login session from NSUserDefaults
    [[AppData appData] clearPreviousLoginSession];
    
    [[NSFileManager defaultManager] removeItemAtPath:[AppDel dataFilePath] error:nil];
}

- (void) signOutRequest
{
    
    
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"loginToken"])
    {
        NSDictionary *dict = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:@"logout", [[NSUserDefaults standardUserDefaults] objectForKey:@"loginToken"], nil] forKeys:[NSArray arrayWithObjects:@"method", @"login_token", nil]];
        
        
        
        if (![AppDel appIsDisconnected])
        {
            [[WebHelper sharedHelper] setWebHelperDelegate:self];
            
            [[WebHelper sharedHelper] sendRequest:dict tag:S_Logout delegate:self];
        }
    }
}


- (void)failWithError:(NSError *)theError
{
    
}


- (void) startLoginWithUserName
{
    NSURL *url = [NSURL URLWithString:[IMYourDocAPIGeneratorClass loginURL]];
    
    
    ASIHTTPRequest *loginRequest = [ASIHTTPRequest requestWithURL:url];
    
    loginRequest.tag = 2;
    
    [loginRequest setRequestMethod:@"POST"];
    
    [loginRequest addRequestHeader:@"Connection" value:@"close"];
    
    [loginRequest addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
    
    
    NSString *postContentString = [IMYourDocAPIGeneratorClass selfStringGeneratorLOGIN:[AppData appData].XMPPmyJID
                                                                          withPassword:[AppData appData].XMPPmyJIDPassword
                                                                    withDeviceUniqueId:[[NSUserDefaults standardUserDefaults] stringForKey:@"openUUID"]];
    
    
    NSMutableData *postContentData = [NSMutableData dataWithBytes:[postContentString UTF8String] length:[postContentString length]];
    
    
    [loginRequest setPostBody:postContentData];
    
    [loginRequest setValidatesSecureCertificate:NO];
    
    [loginRequest setDelegate:self];
    
    [loginRequest startAsynchronous];
}


- (void)setLoginType:(NSInteger)isLogged
{
    self.isLoggedState = isLogged;
}


- (void)setUserType:(NSInteger)isPhysician
{
    self.isFromPhysician = isPhysician;
    
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:(int)isPhysician] forKey:@"isFromPhysician"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)processAfterDeviceRegistration
{
    [self.navController popViewControllerAnimated:YES];
    
    
    [self.loginView showDeviceRegistrationStatus];
}

- (NSInteger )isFromPhysician
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"isFromPhysician"] intValue];
}


#pragma mark - Private

- (void)setupStream
{
    NSAssert(xmppStream == nil, @"Method setupStream invoked multiple times");
    
    managedObjectContext_roster=nil;
    managedObjectContext_vCard=nil;
    managedObjectContext_capabilities=nil;
    
    
    self.xmppStream = [[XMPPStream alloc] init];
    
    
#if !TARGET_IPHONE_SIMULATOR
    {
        xmppStream.enableBackgroundingOnSocket = YES;
    }
    
#endif
    
    
    self.xmppReconnect = [[XMPPReconnect alloc] init];
    
    xmppReconnect.reconnectTimerInterval = 5;
    
    xmppReconnect.usesOldSchoolSecureConnect=YES;
    
    self.mucmodule = [[XMPPMUC alloc] init];
    
    
    self.xmppRosterStorage = [XMPPRosterCoreDataStorage sharedInstance];
    
    self.xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:xmppRosterStorage];
    
    xmppRoster.autoFetchRoster = NO;
    
    xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;
    
    xmppRoster.autoClearAllUsersAndResources=NO;
    
    self.xmppRosterStorage.autoRemovePreviousDatabaseFile=![[NSUserDefaults standardUserDefaults] boolForKey:@"userLoggedIn"];
    
    xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
    
    
    self.xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:xmppvCardStorage];
    
    
    self.xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:xmppvCardTempModule];
    
    
    
    xmppCapabilitiesStorage = [XMPPCapabilitiesCoreDataStorage sharedInstance];
    
    
    self.xmppCapabilities = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:xmppCapabilitiesStorage];
    
    xmppCapabilities.autoFetchHashedCapabilities = YES;
    
    xmppCapabilities.autoFetchNonHashedCapabilities = NO;
    
    
    _autoPing = [[XMPPAutoPing alloc] init];
    
    _autoPing.pingInterval=3;
    
    _autoPing.pingTimeout=7;
    
    pingTimeOuts=0;
    
    [xmppReconnect         activate:xmppStream];
    
    [xmppRoster            activate:xmppStream];
    
    [xmppvCardTempModule   activate:xmppStream];
    
    [xmppvCardAvatarModule activate:xmppStream];
    
    [xmppCapabilities      activate:xmppStream];
    
    
    [self.mucmodule activate:self.xmppStream];
    
    
    [_autoPing activate:xmppStream];
    
    
    [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    [xmppRoster addDelegate:self delegateQueue:rosterQueue];
    
    [xmppReconnect addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    
    [self.xmppvCardTempModule addDelegate:self delegateQueue:rosterQueue];
    
    [self.mucmodule addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    
    [self.autoPing addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    
    allowSelfSignedCertificates = YES;
    
    allowSSLHostNameMismatch = YES;
    
    
    customCertEvaluation = YES;
}


- (void)teardownStream
{
    
    [self.roomsArr removeAllObjects];
    
    
    [xmppStream     removeDelegate:self];
    
    [xmppRoster     removeDelegate:self];
    
    [mucmodule      removeDelegate:self];
    
    [_autoPing      removeDelegate:self];
    
    
    [xmppReconnect          deactivate];
    
    [xmppRoster             deactivate];
    
    [xmppvCardTempModule    deactivate];
    
    [xmppvCardAvatarModule  deactivate];
    
    [xmppCapabilities       deactivate];
    
    [mucmodule              deactivate];
    
    [_autoPing              deactivate];
    
    
    [xmppStream disconnect];
    
    
    xmppStream              = nil;
    
    xmppReconnect           = nil;
    
    xmppRoster              = nil;
    
    xmppRosterStorage       = nil;
    
    xmppvCardStorage        = nil;
    
    xmppvCardTempModule     = nil;
    
    xmppvCardAvatarModule   = nil;
    
    xmppCapabilities        = nil;
    
    xmppCapabilitiesStorage = nil;
    
    
    self.mucmodule = nil;
}


- (void)goOnline
{
    
    
//    NSLog(@"goOnlinegoOnlinegoOnlineg•••••••••••••••••••••••••8oOnlinegoOnlinegoOnlinegoOnlinegoOnline");
    
    XMPPPresence *presence = [XMPPPresence presence];
    
    
    NSXMLElement *status = [NSXMLElement elementWithName:@"status"];
    
    [status setStringValue:@"Available"];
    
    
    [presence addChild:status];
    
    
    [[self xmppStream] sendElement:presence];
    
    
    [AppData sendLocalNotificationForSecurelyConnected];
    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                      operation:@"XMPPREACHABILITY"
                                        Content:@"Securely Connected"
                                      parameter:@""];
    
    
    
 
    
    
    if (![AppDel appIsDisconnected])
    {
        {
            ChatMessage *obj=  [ChatMessage getFailedLastChatMessageWithContext:self.managedObjectContext_roster];
            
            
            if (obj)
            {
                [failedFileQueue addOperationWithBlock:^{
                    dispatch_async(dispatch_get_main_queue(),^{
                        [FileUplader createRequestWithChatMessage:obj WithManagedObjectContext:self.managedObjectContext_roster];
                        
                        
                    });
                }];
                
            }
        }
    }
    
    
    // update the chat status of New message after login.
    NSArray *fetchNoneReceiverStatusMessages = [AppDel fetchChatMessageOfNoneReceiverStatus];
    
    for (ChatMessage *msg in fetchNoneReceiverStatusMessages)
    {
        [AppDel sendChatState:SendChatStateType_delivered withBuddy:msg.displayName withMessageID:msg.messageID isGroupChat:[[msg isRoomMessage] boolValue]];
        
        msg.chatState = [NSNumber numberWithInt:ChatStateType_Delivered];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[AppDel managedObjectContext_roster] save:nil];
        });
    }
}



- (void)goOffline
{
    
    NSLog(@"goOfflinegoOfflinegoOfflinego••••••••••••••••••••••OfflinegoOfflinegoOfflinegoOffline");
    
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    
    
    NSXMLElement *status = [NSXMLElement elementWithName:@"status"];
    
    [status setStringValue:@"Unavailable"];
    
    
    [presence addChild:status];
    
    
    [[self xmppStream] sendElement:presence];
}


- (void)resetXMPPCoreDataStorage
{
    NSManagedObjectContext *moc = [self managedObjectContext_roster];
    
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject" inManagedObjectContext:moc];
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    [fetchRequest setEntity:entity];
    
    [fetchRequest setIncludesPropertyValues:NO];
    
    
    NSError *error = nil;
    
    
    NSArray *users = [moc executeFetchRequest:fetchRequest error:&error];
    
    
    for (NSManagedObject *user in users)
    {
        [moc deleteObject:user];
    }
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSError *saveError = nil;
        
        
        if (![moc save:&saveError])
        {
            NSLog(@"%@", [saveError domain]);
        }
    });
}






#pragma mark - Connect/disconnect

- (BOOL)connect
{
    [self.pendingUserArr removeAllObjects];
    [self.declinedUserArr removeAllObjects];
    
    self.keyforPendingUser = [NSString stringWithFormat:@"%@_pendingList", [AppData appData].XMPPmyJID];
    self.keyforDeclinedUser = [NSString stringWithFormat:@"%@_ApprovedList", [AppData appData].XMPPmyJID];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:self.keyforPendingUser])
        self.pendingUserArr = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:self.keyforPendingUser]];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:self.keyforDeclinedUser])
        self.declinedUserArr = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:self.keyforPendingUser]];
    
    //----- Check the current state of the xmppStream -------
    if (![xmppStream isDisconnected])
    {
        NSLog(@"isDisconnected false");
        if([xmppStream isConnected]==NO)
        {
            NSLog(@"isConnected false");
        }
        else if(xmppStream.isAuthenticated==NO)
        {
            NSLog(@"isAuthenticated false");
            [self authenticate];
            return YES;
        }
        else
        {
            [self goOnline];
            return YES;
        }
        
    }
    
    NSLog(@"---------------XMPPStream Starts to Connect---------------!!!");
    // ----  Start new connect to XMPP Stream --------- //
    NSString *myJID = [AppData appData].getMyJID;
    NSString *myPassword = [AppData appData].XMPPmyJIDPassword;
    
    self.myJID = myJID;
    password = myPassword;
    
    if (myJID == nil || myPassword == nil)
        return NO;
    
    if(![[NSUserDefaults standardUserDefaults] stringForKey:@"loginToken"])
        return NO;
    
    //Add the resource string for auto-group (changed by Ronald)
    [xmppStream setMyJID:[XMPPJID jidWithString:myJID resource:@"_New_Version"]];
    [[self xmppStream] setHostName:XMPPSERVER];
    [[self xmppStream] setHostPort:XMPPSERVERPORT];
    
    NSError *error = nil;
    if (![xmppStream oldSchoolSecureConnectWithTimeout:DEFAULT_KEEPALIVE_INTERVAL error:&error])
    {
        if (bool_connectRetry == NO)
        {
            bool_connectRetry = YES ;
            [AppData connectXMPPServer];
        }
        else
        {
            
            if([[UIApplication sharedApplication] applicationState]==UIApplicationStateBackground
               ||[[UIApplication sharedApplication] applicationState]==UIApplicationStateInactive)
            {
                
            }
            else
            {
                [[RDCallbackAlertView alloc] initWithTitle:@"Error connecting" message:@"Cannot detect Internet connection" cancelButtonTitle:nil andCompletionHandler:^(int btnIndex)
                 
                 {
                     if (btnIndex == 0)  //Retry button is clicked
                     {
                         [AppData connectXMPPServer];  //Retry to connect XMPP server
                         bool_connectRetry = YES ;
                     }
                     else if (btnIndex== 1)  // Try Later button is clicked
                     {
                         bool_connectRetry = NO;
                     }
                     
                 } otherButtonTitles: @"Retry" ,@"Try Later", nil];
            }
            
        }
        
        return NO;
    }
    
    if (error)
        NSLog(@"....Stream %@ Error %@",xmppStream,error);
    
    [AppData sendLocalNotificationForConnecting];
    
    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                      operation:@"XMPPREACHABILITY"
                                        Content:@"Connecting to open Fire "
                                      parameter:@"connecting"];
    return YES;
}


- (void)disconnect
{
    [self goOffline];
    [xmppStream disconnect];
    
    [self clearChatDataOnLogout];
}


-(void)authenticate
{
    
    if(self.xmppStream.isAuthenticated==NO&&self.xmppStream.isAuthenticating==NO&&self.xmppStream.isConnected==YES)
    {
        NSError *error=nil;
        
        
        if (![[self xmppStream] authenticateWithPassword:[AppData appData].XMPPmyJIDPassword error:&error])
        {
            [AppData sendLocalNotificationForNotConnected];
            
            [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                              operation:@"XMPPREACHABILITY"
                                                Content:@"Not Connected"
                                              parameter:@""];
        }
        
        else
        {
            [AppData sendLocalNotificationForSecurelyConnected];
            [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                              operation:@"XMPPREACHABILITY"
                                                Content:@"Securely Connected"
                                              parameter:@""];
        }
    }
    
    
}

- (void) clearChatDataOnLogout
{
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"image"];
    
    
    [ConversationLog deleteAllObjectsWithContext:self.managedObjectContext_roster inTable:@"InboxMessage"  ];
    [ConversationLog deleteAllObjectsWithContext:self.managedObjectContext_roster inTable:@"ChatMessage"  ];
    
    [ConversationLog deleteAllObjectsWithContext:self.managedObjectContext_roster inTable:@"OfflineContact"  ];
    
    [ConversationLog deleteAllObjectsWithContext:self.managedObjectContext_roster inTable:@"XMPPRoomObject"  ];
    [ConversationLog deleteAllObjectsWithContext:self.managedObjectContext_roster inTable:@"XMPPRoomAffaliations"  ];
    [ConversationLog deleteAllObjectsWithContext:self.managedObjectContext_roster inTable:@"OfflineMessages"  ];
    [ConversationLog deleteAllObjectsWithContext:self.managedObjectContext_roster inTable:@"ConversationLog"  ];
    [ConversationLog deleteAllObjectsWithContext:self.managedObjectContext_roster inTable:@"ActiveConverstion"  ];
    
    
    [ConversationLog deleteAllObjectsWithContext:self.managedObjectContext_roster inTable:@"BroadCastGroup"  ];
    [ConversationLog deleteAllObjectsWithContext:self.managedObjectContext_roster inTable:@"BroadCastMembers"  ];
    
    
    
    [ConversationLog deleteAllObjectsWithContext:self.managedObjectContext_roster inTable:@"BroadcastSubjectSender"  ];
    [ConversationLog deleteAllObjectsWithContext:self.managedObjectContext_roster inTable:@"BroadCastMessageSender"  ];
    [ConversationLog deleteAllObjectsWithContext:self.managedObjectContext_roster inTable:@"BroadCastMessageDeliveryRecipient"  ];
    
    
    
    
    NSError *er = nil;
    if([self.managedObjectContext_roster hasChanges])
        [self.managedObjectContext_roster save:&er];
    
    managedObjectContext_roster=nil;
    managedObjectContext_vCard=nil;
    managedObjectContext_capabilities=nil;

    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"userLoggedIn"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    //Code to delete the file
    [self teardownStream];
    [self setupStream];
    
}


#pragma mark - HTTP Delegate

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self hideSpinnerAfterDelayWithText:@"Connected" andImageName:@"ProcessCompleted.png"];
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [self.notificationreqData setLength:0];
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.notificationreqData appendData:data];
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self hideSpinnerAfterDelayWithText:@"Connected" andImageName:@"ProcessCompleted.png"];
}


#pragma mark - WebHelper Delegate

-(void)didFailedWithError:(NSError *)error{
    
    NSLog(@"WebHelper Request Failed With Error : %@", error.description);
    
    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                      operation:@"__WebHelper_Delegate_didFailedWithError__"
                                        Content:error.description
                                      parameter:@""];
    
}

-(void)didReceivedresponse:(NSDictionary *)response{
    
    if ([WebHelper sharedHelper].tag == S_Logout)
    {
        
        [self.loginView.navigationController popToRootViewControllerAnimated:NO];
        
        
        if ([[response objectForKey:@"err-code"] intValue] == 1)  // Logout Successfully
        {
            [self hideSpinnerAfterDelayWithText:@"Logged out successfully" andImageName:@"ProcessCompleted.png"];
        }
        
        else
        {
            [self hideSpinner];
        }
        
        [self stopSessionCheckTimer];
        
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"rememberMe"])
        {
            if ([AppData appData].XMPPmyJID)
            {
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:kXMPPmyJID];
            }
        }
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kXMPPmyPassword];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserType"];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"required_config"];//1948
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self clearDataOnSignOut];
        
        [self.loginView.navigationController popToRootViewControllerAnimated:NO];
        
        self.homeView = nil;

    }
    else if ([WebHelper sharedHelper].tag == S_CheckAppVersion)
    {
        if ([[response objectForKey:@"err-code"] intValue] == 800)  // Session already expired
        {
            
            
            
            if (![[response objectForKey:@"url"]isEqualToString:@""])
            {
                [[RDCallbackAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] cancelButtonTitle:nil andCompletionHandler:^(int btnIndex)
                 {
                     
                     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[response objectForKey:@"url"]]];
                     
                 } otherButtonTitles:@"Update", nil];
            }
            else{
                [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
            
            
            
            
        }
    }
    
    else if ([WebHelper sharedHelper].tag == S_Send_notification_device)
    {
        NSLog(@"..........Send Notification Response    %@", response);
        
        if ([[response objectForKey:@"err-code"] intValue] == 600)
        { [AppDel signOutFromAppSilent];
            [[RDCallbackAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] cancelButtonTitle:nil andCompletionHandler:^(int btnIndex)
             
             {
                 
                 
             } otherButtonTitles:@"OK", nil];
            
        }
        if ([[response objectForKey:@"err-code"] intValue] == 5)
        {
            
            
            
            NSString *messageID = [response objectForKey:@"message_id"];
            ChatMessage *chatmessage = [ChatMessage getChatMessageObjectWithMessageID:messageID];
            
            
            if (chatmessage == nil)
            {
                return;
            }
            
            
            [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                              operation:@"From>> S_Send_notification_device"
                                                Content:chatmessage.messageID
                                              parameter: [ChatMessage ChatTypeToStr:[chatmessage.chatState intValue]]];
            
            
            if ([chatmessage.chatState intValue] != ChatStateType_Delivered && [chatmessage.chatState intValue] != ChatStateType_Read )
            {
                if ([[response objectForKey:@"notification_state"] intValue] == 1)
                {
                    chatmessage.chatState = [NSNumber numberWithInt:ChatStateType_Notification_EmailSent];
                    
                    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                                      operation:@"to >> S_Send_notification_device"
                                                        Content:chatmessage.messageID
                                                      parameter: [ChatMessage ChatTypeToStr:[chatmessage.chatState intValue]]];
                    
                    if([self.managedObjectContext_roster hasChanges])
                        [self.managedObjectContext_roster save:nil];
                }
                
                else
                {
                    chatmessage.chatState = [NSNumber numberWithInt:ChatStateType_NotDelivered];
                    
                    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                                      operation:@"to >> S_Send_notification_device"
                                                        Content:chatmessage.messageID
                                                      parameter: [ChatMessage ChatTypeToStr:[chatmessage.chatState intValue]]];
                    
                    
                    if([self.managedObjectContext_roster hasChanges])
                        [self.managedObjectContext_roster save:nil];
                    
                    
                }
            }
            
        }
    }
    
    else if ([WebHelper sharedHelper].tag == S_Resend_notification_device)
    {
        NSLog(@"..........Resend Notification Response    %@", response);
        
        
        if ([[response objectForKey:@"err-code"] intValue] == 600)
        { [AppDel signOutFromAppSilent];
            [[RDCallbackAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] cancelButtonTitle:nil andCompletionHandler:^(int btnIndex)
             
             {
                 
                 
             } otherButtonTitles:@"OK", nil];
            
        }
        if ([[response objectForKey:@"err-code"] intValue] == 1)
        {
            
            
            
            NSString *messageID = [response objectForKey:@"message_id"];
            ChatMessage *chatmessage = [ChatMessage getChatMessageObjectWithMessageID:messageID];
            
            
            if (chatmessage == nil)
            {
                return;
            }
            
            
            
            
            if ([chatmessage.chatState intValue] != ChatStateType_Delivered &&[chatmessage.chatState intValue] != ChatStateType_Read)
            {
                if ([[response objectForKey:@"notification_state"] intValue] == 0)
                {
                    
                    
                    
                    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                                      operation:@"Response >> S_Resend_notification_device"
                                                        Content:chatmessage.messageID
                                                      parameter:
                     [NSString stringWithFormat:@"from>> %@ to>> %@",[ChatMessage ChatTypeToStr:[chatmessage.chatState intValue]],[ChatMessage ChatTypeToStr:ChatStateType_NotDelivered]]];
                    
                    chatmessage.chatState = [NSNumber numberWithInt:ChatStateType_NotDelivered];
                    
                    if([self.managedObjectContext_roster hasChanges])
                        [self.managedObjectContext_roster save:nil];
                }
                
                else
                {
                    [self resendMessage:chatmessage];
                }
            }
            
            
        }
    }
    
    else if ([WebHelper sharedHelper].tag==S_ReportCloseConversation)
    {
        
        if ([[response objectForKey:@"err-code"] intValue] == 1)    // Success
        {
            
            
            
            
        }
        
        
        
        else if ([[response objectForKey:@"err-code"] intValue] == 600)    // Session expired
        { [AppDel signOutFromAppSilent];
            [[RDCallbackAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] cancelButtonTitle:nil andCompletionHandler:^(int btnIndex)
             
             {
                 
                 
             } otherButtonTitles:@"OK", nil];
        }
        
        
        
        
        
    }
    
    else
        
    {
        if ([[response objectForKey:@"err-code"] intValue] == 600)
        {
            [AppDel signOutFromAppSilent];
            
            [[RDCallbackAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] cancelButtonTitle:nil andCompletionHandler:^(int btnIndex){} otherButtonTitles:@"OK", nil];
        }
    }
    
    
}

#pragma mark - ASIHTTP File upload

- (void)requestFailed:(ASIHTTPRequest *)request
{
    switch (request.tag)
    {
        case TAG_FILE_UPLOADER:
        {
            ChatMessage *message = [(FileUplader *)request message];
            
            message.requestStatus = [NSNumber numberWithInt:RequestStatusType_Failed];
            
            message.dataSent= [NSNumber numberWithLongLong:0];
            
            
            if([self.managedObjectContext_roster hasChanges])
            {
                [self.managedObjectContext_roster save:nil];
            }
            
            
            [self.fileQue removeObject:request];
            
            //This cannot detect the 100% loss status - So stop reuploading (Ronald Wang)
            /*
            if (![AppDel appIsDisconnected])
            {
                
                {
                    ChatMessage *obj=  [ChatMessage getFailedLastChatMessageWithContext:self.managedObjectContext_roster];
                    
                    
                    if (obj)
                    {
                        [failedFileQueue addOperationWithBlock:^{
                            dispatch_async(dispatch_get_main_queue(),^{
                                [FileUplader createRequestWithChatMessage:obj WithManagedObjectContext:self.managedObjectContext_roster];
                                
                                
                            });
                        }];

                    }
                }
            }
             */
        }
            
            break;
            
            
        case 1: // SignOut
        {
            [self.loginView.navigationController popToRootViewControllerAnimated:NO];
            
            
            [self hideSpinnerAfterDelayWithText:@"Logged out successfully" andImageName:@"ProcessCompleted.png"];
            
            
            if (![[NSUserDefaults standardUserDefaults] boolForKey:@"rememberMe"])
            {
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:kXMPPmyJID];
            }
            
            
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kXMPPmyPassword];
            
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserType"];
            
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            
            [self.loginView.navigationController popToRootViewControllerAnimated:NO];
            
            
            self.homeView = nil;
        }
            
            break;
            
            
        case 2: // Auto Login
        {
            
            if (self.isLoggedState == 1)
            {
                [self.homeView checkInternetConnection:NO];
                
                
                [self tryReconnectChatServer];
            }
            
            else
            {
                [self hideSpinner];
            }
        }
            
            break;
            
            
        case 3:
        {
            
        }
            
            break;
            
            
        case 4:
        {
            [self hideSpinnerAfterDelayWithText:@"Error" andImageName:@"warning.png"];
        }
            
            break;
            
            
        case 5:
        {
            [self hideSpinnerAfterDelayWithText:@"Error" andImageName:@"warning.png"];
        }
            
            break;
            
            
        case 200:
        {
            NSString *response = [[NSString alloc] initWithData:[request postBody] encoding:NSUTF8StringEncoding];
            
            
            NSDictionary *respDict = [response JSONValue];
            
            
            NSString *messageID = [respDict objectForKey:@"message_id"];
            ChatMessage *chatmessage = [ChatMessage getChatMessageObjectWithMessageID:messageID];;
            
            
            if (chatmessage == nil)
            {
                return;
            }
            
            
            if ([chatmessage.chatState intValue] == ChatStateType_Notification_EmailSent || [chatmessage.chatState intValue] == ChatStateType_Sending)
            {
                chatmessage.chatState = [NSNumber numberWithInt:ChatStateType_Notification_EmailSent];
                
                
                [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                                  operation:@"checkState"
                                                    Content:chatmessage.messageID
                                                  parameter:[ChatMessage ChatTypeToStr: chatmessage.chatState.intValue]];
                
                if([self.managedObjectContext_roster hasChanges])
                    [self.managedObjectContext_roster save:nil];
                
                
                
            }
        }
            
            break;
            
            
        case 220:
        {
            NSString *response = [[NSString alloc] initWithData:[request postBody] encoding:NSUTF8StringEncoding];
            
            
            NSDictionary *respDict = [response JSONValue];
            
            
            NSString *messageID = [respDict objectForKey:@"message_id"];
            ChatMessage *chatmessage = [ChatMessage getChatMessageObjectWithMessageID:messageID];
            
            
            if (chatmessage == nil)
            {
                return;
            }
            
            
            if ([chatmessage.chatState intValue] == ChatStateType_Notification_EmailSent || [chatmessage.chatState intValue] == ChatStateType_Sending)
            {
                [self resendMessage:chatmessage];
                
                [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                                  operation:@"resendMessage"
                                                    Content:chatmessage.messageID
                                                  parameter:[ChatMessage ChatTypeToStr:chatmessage.chatState.intValue]];
            }
        }
            
            break;
            
        default:
            
            break;
    }
}


- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSString *responseString = [request responseString];
    
    
    switch (request.tag)
    {
        case TAG_FILE_UPLOADER:
        {
            NSDictionary * response=[NSJSONSerialization JSONObjectWithData:request.responseData options:NSJSONReadingMutableContainers error:nil];
            
            if([[response objectForKey:@"err-code"] intValue]==1)
            {
                if ([response objectForKey:@"url"])
                {
                    ChatMessage *message = [(FileUplader *)request message];
                    
                    message.requestStatus = [NSNumber numberWithInt:RequestStatusType_fileIsUploadedButMessageIsNotSent];
                    
                    message.content = [response objectForKey:@"url"];
                    
                    
                    if ([message.isRoomMessage boolValue] == NO)
                    {
                        [self sendFileTransferMessagetoUser:message.uri withFileName:[response objectForKey:@"url"] withImage:message.thumb withMessageID:message.messageID type:@"image"];
                    }
                    else
                    {
                        [self sendFileTransferMessagetoGroup:message.uri withFileName:[response objectForKey:@"url"] withImage:message.thumb withMessageID:message.messageID type:@"image"];
                    }
                    
                    
                    message.dataSent= [NSNumber numberWithLongLong:0];
                    
                    
                    if([self.managedObjectContext_roster hasChanges])
                    {
                        [self.managedObjectContext_roster save:nil];
                    }
                }
                else
                {
                    ChatMessage *message = [(FileUplader *)request message];
                    
                    message.requestStatus = [NSNumber numberWithInt:RequestStatusType_Failed];
                    
                    message.dataSent= [NSNumber numberWithLongLong:0];
                    
                    
                    if([self.managedObjectContext_roster hasChanges])
                    {
                        [self.managedObjectContext_roster save:nil];
                    }
                }
            }
            else
            {
                ChatMessage *message = [(FileUplader *)request message];
                
                message.requestStatus = [NSNumber numberWithInt:RequestStatusType_Failed];
                
                message.dataSent= [NSNumber numberWithLongLong:0];
                
                if([self.managedObjectContext_roster hasChanges])
                {
                    [self.managedObjectContext_roster save:nil];
                }
            }
            
            
            [self.fileQue removeObject:request];
            
            
            
            if (![AppDel appIsDisconnected])
            {
                
                {
                    ChatMessage *obj=  [ChatMessage getFailedLastChatMessageWithContext:self.managedObjectContext_roster];
                    
                    if (obj)
                    {
                        
                        [failedFileQueue addOperationWithBlock:^
                         {
                             dispatch_async(dispatch_get_main_queue(),^
                                            {
                                                [FileUplader createRequestWithChatMessage:obj WithManagedObjectContext:self.managedObjectContext_roster];
                                            });
                         }];
                    }
                }
            }
        }
            break;
            
            
        case 1: // SignOut
        {
            [self.loginView.navigationController popToRootViewControllerAnimated:NO];
            
            
            NSString *someString = @"SUCCESS";
            
            
            NSRange range = [responseString rangeOfString:someString options:NSCaseInsensitiveSearch];
            
            
            if (range.location == NSNotFound)
            {
                [[[UIAlertView alloc] initWithTitle:nil message:@"Failed. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                
                
                [self hideSpinner];
            }
            
            else
            {
                [self hideSpinnerAfterDelayWithText:@"Logged out successfully" andImageName:@"ProcessCompleted.png"];
                
                
                [self stopSessionCheckTimer];
                
                
                if (![[NSUserDefaults standardUserDefaults] boolForKey:@"rememberMe"])
                {
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kXMPPmyJID];
                }
                
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:kXMPPmyPassword];
                
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserType"];
                
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"required_config"];//1948
                
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                
                [self.loginView.navigationController popToRootViewControllerAnimated:NO];
                
                
                self.homeView = nil;
            }
        }
            
            break;
            
            
        case 2: // Auto Login
        {
            NSString *trimmedString = [[responseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] mutableCopy];
            NSRange range = [trimmedString rangeOfString:@"Login Success" options:NSCaseInsensitiveSearch];
            
            if (range.location != NSNotFound)
            {
                NSArray *arrayOfTrimmedStr = [trimmedString componentsSeparatedByString:@"#:#"];
                NSString *separatedQuestionString = [NSString stringWithFormat:@"%@",[arrayOfTrimmedStr objectAtIndex:1]];
                
                [[NSUserDefaults standardUserDefaults] setObject:separatedQuestionString forKey:@"QuestionString"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                NSString *PINCodeStr = [arrayOfTrimmedStr objectAtIndex:2];
                if(PINCodeStr != nil && PINCodeStr.length > 0)
                    [[AppData appData] setUserPIN:PINCodeStr];
                
                [AppData connectXMPPServer];
            }
            
            else
            {
                [self hideSpinnerAfterDelayWithText:@"Server consistency error found!" andImageName:@"warning.png"];
                
                
                consistentErrorAlert  = [[UIAlertView alloc] initWithTitle:nil message:trimmedString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                
                [consistentErrorAlert show];
                
                
                if (![[NSUserDefaults standardUserDefaults] boolForKey:@"rememberMe"])
                {
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kXMPPmyJID];
                }
                
                
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:kXMPPmyPassword];
                
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserType"];
                
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"QuestionString"];
                
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                
                [self.loginView.navigationController popToRootViewControllerAnimated:NO];
            }
        }
            
            break;
            
            
        case 3:// location update
        {
            NSLog(@"succeed %@", [request responseString]);
            
            
            
        }
            
            break;
            
            
        case 200:
        {
            NSString *response = [request responseString];
            
            
            NSDictionary *respDict = [response JSONValue];
            
            
            NSString *messageID = [respDict objectForKey:@"message_id"];
            
            ChatMessage *chatmessage = [ChatMessage getChatMessageObjectWithMessageID:messageID];;
            
            
            if (chatmessage == nil)
            {
                return;
            }
            
            
            if ([chatmessage.chatState intValue] != ChatStateType_Delivered && [chatmessage.chatState intValue] != ChatStateType_Read )
            {
                if ([[respDict objectForKey:@"notification_state"] intValue] == 1)
                {
                    chatmessage.chatState = [NSNumber numberWithInt:ChatStateType_Notification_EmailSent];
                    
                    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                                      operation:@"checkState"
                                                        Content:chatmessage.messageID
                                                      parameter:[ChatMessage ChatTypeToStr: chatmessage.chatState.intValue]];
                    
                    if([self.managedObjectContext_roster hasChanges])
                        [self.managedObjectContext_roster save:nil];
                }
                
                else
                {
                    chatmessage.chatState = [NSNumber numberWithInt:ChatStateType_NotDelivered];
                    
                    if([self.managedObjectContext_roster hasChanges])
                        [self.managedObjectContext_roster save:nil];
                    
                    
                    
                }
            }
        }
            
            break;
            
            
        case 220:
        {
            NSString *response = [request responseString];
            
            
            NSDictionary *respDict = [response JSONValue];
            
            
            NSString *messageID = [respDict objectForKey:@"message_id"];
            ChatMessage *chatmessage = [ChatMessage getChatMessageObjectWithMessageID:messageID];
            
            
            if (chatmessage == nil)
            {
                return;
            }
            
            
            if ([chatmessage.chatState intValue] != ChatStateType_Delivered &&[chatmessage.chatState intValue] != ChatStateType_Read)
            {
                if ([[respDict objectForKey:@"notification_state"] intValue] == 2)
                {
                    chatmessage.chatState = [NSNumber numberWithInt:ChatStateType_NotDelivered];
                    
                    if([self.managedObjectContext_roster hasChanges])
                        [self.managedObjectContext_roster save:nil];
                }
                
                else
                {
                    [self resendMessage:chatmessage];
                }
            }
        }
            
            break;
            
            
        case TAG_REQUEST_AUDIT:
            
            break;
            
            
        case TAG_REQUEST_UPDATE:
        {
            NSDictionary *jsonDict = [responseString JSONValue];
            
            
            if ([[jsonDict objectForKey:@"update_required"] intValue] == 1)
            {
                [[RDCallbackAlertView alloc] initWithTitle:nil message:@"A whole new and improved IM Your Doc is now available. To continue using the app, please update." cancelButtonTitle:nil andCompletionHandler:^(int btnIndex) {
                    
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[jsonDict objectForKey:@"update_url"]]];
                    
                } otherButtonTitles:@"Update", nil];
            }
        }
            
            break;
            
            
        default:
            
            break;
    }
}


#pragma mark - File Transfer

- (void)sendFileTransFerNotification:(NSString *)toUser withFileName:(NSString *)fName withImage:(UIImage *)img
{
    NSString *msgIdForChatMsg   =  [[AppDel xmppStream] generateUUID];
    
    ChatMessage *msg=[self insertChatMessage:msgIdForChatMsg];
    
    msg.identityuri     = [[[self xmppStream] myJID] bare];
    
    msg.content         = fName;
    
    msg.isOutbound      = OutBoundType_Right;
    
    msg.hasBeenRead     = NO;
    
    msg.timeStamp       = [NSDate date];
    
    msg.uri             = toUser;
    
    
    NSArray *arr = [toUser componentsSeparatedByString:@"@"];
    
    
    msg.displayName     = [NSString stringWithFormat:@"%@@imyourdoc.com",[arr objectAtIndex:0]];
    
    msg.requestStatus   = [NSNumber numberWithInt:RequestStatusType_isYetToBeUpload];
    
    msg.messageID       = msgIdForChatMsg;
    
    msg.chatState       = [NSNumber numberWithInt:ChatStateType_Sending];
    
    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                      operation:@"resendMessage"
                                        Content:msg.messageID
                                      parameter:[ChatMessage ChatTypeToStr:msg.chatState.intValue]];
    
    
    NSData *imageData = UIImageJPEGRepresentation(img, .5f);
    
    
    msg.thumb           = [Base64 encode:imageData];
    
    msg.fileTypeChat    = [NSNumber numberWithInt:fileTypeChat_File];
    
    msg.mark_deleted    = [NSNumber numberWithBool:mark_deleted_NO];
    
    
    [self addInboxMessage:msg];
    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                      operation:@"check Message State"
                                        Content:msg.messageID
                                      parameter:[ChatMessage ChatTypeToStr:msg.chatState.intValue]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSError *error = nil;
        
        if([self.managedObjectContext_roster hasChanges])
            if (![self.managedObjectContext_roster save:&error])
            {
                NSLog(@"%@", [error domain]);
            }
    });
}


- (void)sendFileTransferMessagetoGroup:(NSString *)toGroup withFileName:(NSString *)fName withImage:(NSString *)img withMessageID:(NSString *)messageID type:(NSString *) type
{
    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
    
    [message addAttributeWithName:@"type" stringValue:@"groupchat"];
    
    
    NSString *JidString = [AppDel myJID];
    
    
    [message addAttributeWithName:@"from" stringValue:JidString];
    
    [message addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@", toGroup]];
    
    [message addAttributeWithName:@"id" stringValue:messageID];
    
    
    
    
    
    NSXMLElement *thumb = [NSXMLElement elementWithName:@"subject"];
    
    [thumb setStringValue:fName];
    
    [message addChild:thumb];
    
    @autoreleasepool {
        VCard * vcard=[self fetchVCard:[XMPPJID jidWithString:toGroup]];
        (void)vcard;
        
    }
    
    
    
    
    
    {
        NSDictionary * dictionary=[NSDictionary  dictionaryWithObjectsAndKeys:type,@"file_type",fName,@"file_path",img,@"content",[NSString stringWithFormat:@"%@",[NSDate date]],@"timestamp",JidString,@"from",toGroup,@"to",messageID,@"messageID", nil];
        
        
        
        NSXMLElement *body = [NSXMLElement elementWithName:@"body" stringValue:[dictionary JSONString]];
        
        [message addChild:body];
        
        [message addProperty:@"message_version" value:@"2.0" type:@"string"];
    }
    
    
    
    //****************
    
    
    
    [message addProperty:@"file_type" value:type type:@"string"];
    
    [xmppStream sendElement:message];
    
    
    [self addTimerForMessage:messageID];
    
    
    
    
    
    
}

#pragma mark- *******************************

- (void)sendFileTransferMessagetoUser:(NSString *)toUser withFileName:(NSString *)fName withImage:(NSString *)img withMessageID:(NSString *)messageID type:(NSString *) type
{
    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
    
    [message addAttributeWithName:@"type" stringValue:@"chat"];
    
    
    NSString *JidString = [AppDel myJID];
    
    
    [message addAttributeWithName:@"from" stringValue:JidString];
    
    [message addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@", toUser]];
    
    [message addAttributeWithName:@"id" stringValue:messageID];
    
    
    
    
    
    NSXMLElement *thumb = [NSXMLElement elementWithName:@"subject"];
    
    [thumb setStringValue:fName];
    
    
    [message addChild:thumb];
    //*******************
    VCard * vcard=[self fetchVCard:[XMPPJID jidWithString:toUser]];
    
    (void)vcard;
    
    {
        NSDictionary * dictionary=[NSDictionary  dictionaryWithObjectsAndKeys:type,@"file_type",fName,@"file_path",img,@"content",[NSString stringWithFormat:@"%@",[NSDate date]],@"timestamp",JidString,@"from",toUser,@"to",messageID,@"messageID", nil];
        
        
        NSXMLElement *body = [NSXMLElement elementWithName:@"body" stringValue:[dictionary JSONString]];
        
        [message addChild:body];
        
        [message addProperty:@"message_version" value:@"2.0" type:@"string"];
    }
    
    
    
    
    
    
    
    
    
    
    
    
    [message addProperty:@"file_type" value:type type:@"string"];
    
    //*******************************
    
    if (![AppDel appIsDisconnected])
    {
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:BASE_URL]];
        
        [request setValidatesSecureCertificate:NO];
        
        
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"submitChatMessages", @"method",
                                    [[NSUserDefaults standardUserDefaults] objectForKey:@"loginToken"],@"login_token",
                                    messageID,@"message_id",
                                    toUser, @"roomjid",
                                    @"message_id",@"message_id"   ,
                                    @"Single" ,@"message_type",
                                    nil];
        
        
        
        request.postBody = [[NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil] mutableCopy];
        
        
        __weak ASIHTTPRequest *req = request;
        
        
        [request setFailedBlock:^{
            
        }];
        
        [request setCompletionBlock:^{
            
            NSDictionary *respDict = [NSJSONSerialization JSONObjectWithData:req.responseData options:NSJSONReadingMutableContainers error:nil];
            
            
            NSLog(@"RespDict .... %@", respDict);
        }];
        
        
        [request startAsynchronous];
    }
    
    
    
    [xmppStream sendElement:message];
    
    
    double delayInSeconds = [[NSUserDefaults standardUserDefaults] doubleForKey:@"delay"] == 0 ? 30.0 : [[NSUserDefaults standardUserDefaults] doubleForKey:@"delay"];
    
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    
    
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        NSString *messageID = [message attributeStringValueForName:@"id"];
        ChatMessage *chatmessage = [ChatMessage getChatMessageObjectWithMessageID:messageID];
        
        
        if (chatmessage == nil)
        {
            return;
        }
        
        
        if ([chatmessage.chatState intValue] == ChatStateType_Sent)
        {
            
            //            NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
            //                                  @"send_notification_device",@"method",
            //                                  [[NSUserDefaults standardUserDefaults] objectForKey:@"loginToken"], @"login_token",
            //                                  [message attributeStringValueForName:@"id"],@"message_id",
            //                                  nil];
            
            
            //            [[WebHelper sharedHelper] setWebHelperDelegate:self];
            //
            //            [[WebHelper sharedHelper] sendRequest:dict tag:S_Send_notification_device delegate:self];
            
            
        }
    });
}


#pragma mark - MultiUserChat (MUC)

- (void)declineMucRequest:(NSString *)roomName toRoomOwner:(NSString *)roomOwner
{
    NSXMLElement *reason = [NSXMLElement elementWithName:@"reason" stringValue:@"Sorry :("];
    
    
    NSXMLElement *decline = [NSXMLElement elementWithName:@"decline"];
    
    [decline addAttributeWithName:@"to" stringValue:roomOwner];
    
    [decline addChild:reason];
    
    
    NSXMLElement *x = [NSXMLElement elementWithName:@"x" xmlns:@"http://jabber.org/protocol/muc#user"];
    
    [x addChild:decline];
    
    
    NSXMLElement *message = [XMPPMessage message];
    
    [message addAttributeWithName:@"to" stringValue:roomName];
    
    [message addChild:x];
    
    
    [xmppStream sendElement:message];
}


- (void)destroyRoom:(NSString *)deleteRoomName
{
    NSXMLElement *destroy = [NSXMLElement elementWithName:@"destroy"];
    
    
    NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"http://jabber.org/protocol/muc#owner"];
    
    [query addChild:destroy];
    
    
    XMPPIQ *iq = [XMPPIQ iqWithType:@"set" to:[XMPPJID jidWithString:deleteRoomName] elementID:@"destroyRequest" child:query];
    
    
    [xmppStream sendElement:iq];
}


- (void)joinRoom:(NSString *)roomName withNickName:(NSString *)nickName
{
    
    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                      operation:@"Leo_Room"
                                        Content:@""
                                      parameter:@""];
    
    
    NSString *to = [NSString stringWithFormat:@"%@/%@", roomName, nickName];
    
    
    XMPPPresence *presence = [XMPPPresence presence];
    
    [presence addAttributeWithName:@"to" stringValue:to];
    
    
    [xmppStream sendElement:presence];
}


- (void)inviteTORoom:(NSString *)roomName withNickName:(NSString *)nick toJID:(NSMutableArray *)toJids
{
    for (NSString *roomUser in toJids)
    {
        NSXMLElement *x = [NSXMLElement elementWithName:@"x" xmlns:@"jabber:x:conference"];
        
        [x addAttributeWithName:@"jid" stringValue:roomName];
        
        [x addAttributeWithName:@"reason" stringValue:@"Hi This is Group User.Please add me as IM Your Doc User"];
        
        
        XMPPMessage *message = [XMPPMessage message];
        
        [message addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@@imyourdoc.com", roomUser]];
        
        [message addChild:x];
        
        
        [xmppStream sendElement:message];
        
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.imyourdoc.com/IMYourDoc_Push/group_push_notification.php?sender=%@&room=%@&to=%@", nick, roomName, roomUser]];
        
        
        NSURLRequest *req = [NSURLRequest requestWithURL:url];
        
        
        [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            
//            NSLog(@".....%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            
        }];
    }
}


- (void)createRoomForPatient:(NSString *)ptName withNick:(NSString *)nick withDescription:(NSString *)roomDescription withAccess:(BOOL)isPrivate
{
    
}


- (void)xmppRoomDidEnter:(XMPPRoom *)sender
{
    XMPPRoomObject *room = [self fetchOrInsertRoom:sender];
    
    
    if ([[self.roomsArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"room_jidStr=%@", [sender.roomJID bare]]] count] == 0)
    {
        [self.roomsArr addObject:room];
    }
}


- (void)xmppRoom:(XMPPRoom *)sender didChangeOccupants:(NSDictionary *)occupants
{
    
}


- (void)fetchOccupant:(NSString *)room
{
    NSXMLElement *item = [NSXMLElement elementWithName:@"item"];
    
    [item addAttributeWithName:@"affiliation" stringValue:@"member"];
    
    
    NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"http://jabber.org/protocol/muc#admin"];
    
    [query addChild:item];
    
    
    XMPPIQ *iq = [XMPPIQ iqWithType:@"get" to:[XMPPJID jidWithString:room] elementID:@"roomOccupantSearch" child:query];
    
    [xmppStream sendElement:iq];
}




- (void)setQueryRoomRegistration:(NSString *)roomName
{
    NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:register"];
    
    
    XMPPIQ *iq = [XMPPIQ iqWithType:@"get" to:[XMPPJID jidWithString:roomName] elementID:@"iqForFillingRegistrationForm" child:query];
    
    
    [[self xmppStream]sendElement:iq];
}


- (void)requestForRegistration:(NSString *)roomName
{
    NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:register"];
    
    
    NSXMLElement *x = [NSXMLElement elementWithName:@"x" xmlns:@"jabber:x:data"];
    
    [x addAttributeWithName:@"type" stringValue:@"submit"];
    
    
    NSXMLElement *field = [NSXMLElement elementWithName:@"field"];
    
    [field addAttributeWithName:@"var" stringValue:@"FORM_TYPE"];
    
    
    NSXMLElement *value = [NSXMLElement elementWithName:@"value"];
    
    [value setStringValue:@"http://jabber.org/protocol/muc#register"];
    
    
    [field addChild:value];
    
    
    NSXMLElement *field1 = [NSXMLElement elementWithName:@"field1"];
    
    [field1 addAttributeWithName:@"var" stringValue:@"muc#register_first"];
    
    
    NSXMLElement *value1 = [NSXMLElement elementWithName:@"value"];
    
    [value1 setStringValue:@""];
    
    
    [field1 addChild:value1];
    
    
    NSXMLElement *field2 = [NSXMLElement elementWithName:@"field"];
    
    [field2 addAttributeWithName:@"var" stringValue:@"muc#register_last"];
    
    
    NSXMLElement *value2 = [NSXMLElement elementWithName:@"value"];
    
    [value2 setStringValue:@""];
    
    
    [field2 addChild:value2];
    
    
    NSXMLElement *field3 = [NSXMLElement elementWithName:@"field"];
    
    [field3 addAttributeWithName:@"var" stringValue:@"muc#register_roomnick"];
    
    
    NSXMLElement *value3 = [NSXMLElement elementWithName:@"value"];
    
    [value3 setStringValue:@""];
    
    
    [field3 addChild:value3];
    
    
    NSXMLElement *field4 = [NSXMLElement elementWithName:@"field"];
    
    [field4 addAttributeWithName:@"var" stringValue:@"'muc#register_url'"];
    
    
    NSXMLElement *value4 = [NSXMLElement elementWithName:@"value"];
    
    [value4 setStringValue:@""];
    
    
    [field4 addChild:value4];
    
    
    NSXMLElement *field5 = [NSXMLElement elementWithName:@"field"];
    
    [field5 addAttributeWithName:@"var" stringValue:@"muc#register_email"];
    
    
    NSXMLElement *value5 = [NSXMLElement elementWithName:@"value"];
    
    [value5 setStringValue:@""];
    
    
    [field5 addChild:value5];
    
    
    NSXMLElement *field6 = [NSXMLElement elementWithName:@"field"];
    
    [field6 addAttributeWithName:@"var" stringValue:@"muc#register_faqentry"];
    
    
    NSXMLElement *value6 = [NSXMLElement elementWithName:@"value"];
    
    [value6 setStringValue:@""];
    
    
    [field6 addChild:value6];
    
    
    [x addChild:field];
    
    [x addChild:field1];
    
    [x addChild:field2];
    
    [x addChild:field3];
    
    [x addChild:field4];
    
    [x addChild:field5];
    
    [x addChild:field6];
    
    
    [query addChild:x];
    
    
    XMPPIQ *iq = [XMPPIQ iqWithType:@"set" to:[XMPPJID jidWithString:roomName] elementID:@"iqForFillingRegistrationForm1" child:query];
    
    
    [[self xmppStream]sendElement:iq];
}


#pragma mark - get roster with Group Name

- (void)processToLogin
{
    [self.loginView loginReqest];
}


#pragma mark - resendMessage

- (void)resendMessage:(ChatMessage *) chatmessage
{
    
    if([chatmessage.isRoomMessage boolValue]==YES)
    {
        [self resendGroupMessage:chatmessage];
        return;
    }
    
    
    
    if ([AppDel appIsDisconnected])
    {
        [AppData showAlertWithTitle:nil andMessage:@"No Connection." inVC:self];
        
        return;
    }
    
    
    {
        
        chatmessage.retryState = @(RetryStatusType_one);
        chatmessage.isResending = [NSNumber numberWithBool:YES];
        chatmessage.chatState = [NSNumber numberWithInt:ChatStateType_Sending];
        
        if([self.managedObjectContext_roster hasChanges])
        {
            [self.managedObjectContext_roster save:nil];
        }
        [self leoXmppStreamSendMessageToOpenFireWithChatMessage:chatmessage];
        
        [AppDel leoResendInQueueWithChatMessage:chatmessage.messageID];
    }
    
    
    
    return;
    
}



- (void)resendGroupMessage:(ChatMessage *) chatmessage
{
    // return;
    
    if([chatmessage.chatState intValue]!= ChatStateType_Delivered &&[chatmessage.chatState intValue]!= ChatStateType_Read)
    {
        chatmessage.chatState = [NSNumber numberWithInt:ChatStateType_Sending];
        chatmessage.requestStatus = [NSNumber numberWithInt:RequestStatusType_isYetToBeUpload];
        
        chatmessage.isResending=[NSNumber numberWithBool:YES];
        chatmessage.retryState = @(RetryStatusType_one);
        
        chatmessage.lastResend=[NSDate date];
        
        if([self.managedObjectContext_roster hasChanges])
        {
            [self.managedObjectContext_roster save:nil];
        }
    }
    
    if ([chatmessage.fileTypeChat intValue] == fileTypeChat_File )
    {
        
        if([chatmessage.requestStatus intValue]!= RequestStatusType_uploaded )
            return;
        
        //This part need to be updated for the new version of message
        NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
        
        [message addAttributeWithName:@"type" stringValue:@"chat"];
        
        
        NSString *jidString = chatmessage.identityuri;
        
        
        [message addAttributeWithName:@"from" stringValue:jidString];
        
        [message addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@", chatmessage.uri]];
        
        [message addAttributeWithName:@"id" stringValue:chatmessage.messageID];
        
        
        /*
         
         */
        
        @autoreleasepool {
            VCard * vcard=[self fetchVCard:[XMPPJID jidWithString:chatmessage.uri]];
            (void)vcard;
        }
        
        
        
        
        {
            NSDictionary * dictionary=[NSDictionary  dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@",[NSDate date]],@"timestamp",chatmessage.identityuri,@"from",chatmessage.uri,@"to",chatmessage.messageID,@"messageID",chatmessage.fileMediaType,@"file_type",chatmessage.content,@"file_path",chatmessage.thumb,@"content", nil];
            
            NSXMLElement *body = [NSXMLElement elementWithName:@"body" stringValue:[dictionary JSONString]];
            
            [message addChild:body];
            
            
            NSXMLElement *thumb = [NSXMLElement elementWithName:@"subject"];
            
            [thumb setStringValue:chatmessage.content];
            
            [message addProperty:@"message_version" value:@"2.0" type:@"string"];
        }
        
        
        
        [xmppStream sendElement:message];
    }
    
    else
    {
        
        //This part need to be updated for the new version of message
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        
        [body setStringValue:chatmessage.content];
        
        
        NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
        
        [message addAttributeWithName:@"id" stringValue:chatmessage.messageID];
        
        [message addAttributeWithName:@"type" stringValue:@"groupchat"];
        
        NSString *jidString = chatmessage.identityuri;
        
        
        [message addAttributeWithName:@"from" stringValue:[NSString stringWithFormat:@"%@@imyourdoc.com", jidString]];
        
        [message addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@", chatmessage.uri]];
        
        
        
        
        {
            NSDictionary * dictionary=[NSDictionary  dictionaryWithObjectsAndKeys:chatmessage.content,@"content",[NSString stringWithFormat:@"%@",[NSDate date]],@"timestamp",chatmessage.identityuri,@"from",chatmessage.uri,@"to",chatmessage.messageID,@"messageID", nil];
            
            NSXMLElement *body = [NSXMLElement elementWithName:@"body" stringValue:[dictionary JSONString]];
            
            [message addChild:body];
            
            [message addProperty:@"message_version" value:@"2.0" type:@"string"];
        }
        
        
//        NSXMLElement *xMessage = [NSXMLElement elementWithName:@"x" xmlns:@"jabber:x:event"];
//        [xMessage addChild:[NSXMLElement elementWithName:@"composing"]];
//        [message addChild:xMessage];
        
        
        [xmppStream sendElement:message];
    }
    
    
    
}


#pragma mark- ••••••••••••••••••••••••••
- (void)recheckAndResendMessage:(ChatMessage *)message
{
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          @"send_notification_device",@"method",
                          [[NSUserDefaults standardUserDefaults] objectForKey:@"loginToken"], @"login_token",
                          message.messageID,@"message_id",
                          nil];
    
    
    [[WebHelper sharedHelper] setWebHelperDelegate:self];
    
    [[WebHelper sharedHelper] sendRequest:dict tag:S_Resend_notification_device delegate:self];
    
}




#pragma mark - SESSION Check and LOCATION Update

- (void) startSessionCheckTimer
{
    if (sessionCheckTimer == nil)
    {
        
    }
}
- (void) stopSessionCheckTimer
{
    if ([sessionCheckTimer isValid])
    {
        [sessionCheckTimer invalidate];
        
        sessionCheckTimer = nil;
    }
    
    
    if ([locationUpdateTimer isValid])
    {
        [locationUpdateTimer invalidate];
        
        locationUpdateTimer = nil;
    }
}

- (void) locationUpdate
{
    
    
    
}


- (void) SessionTimedOut
{
    if (alertController2CheckSessionPin)
    {
        bool_pincodeInputPresented = NO;
        
        [alertController2CheckSessionPin dismissViewControllerAnimated:YES completion:nil];
        
        alertController2CheckSessionPin = nil;
    }
    
    [self pinAlertController:YES];
}



#pragma mark - TextField Delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    NSLog(@"%ld",(long)textField.tag);
    
}
-(BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // Make sure that it is our textField that we are working on otherwise forget the whole thing.
    NSString *search = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if(search.length > 4 && range.length == 0)
    {
        return NO;
    }
    else if( search.length == 4 )
    {
        [alertController2CheckSessionPin dismissViewControllerAnimated:YES completion:nil];
        
        [self showSpinnerWithText:@"Verifying..."];
        
        
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(peformPinMatchFunction) userInfo:nil repeats:NO];
    }
    return YES;
}



#pragma mark - SESSION DEDUCTION FUNCTION

- (void)addUserForDeductionInGlobalArray:(NSString *)forIdentityURI withURI:(NSString *)forURI
{
    if (!globalArrayForPatientToDeductSession)
    {
        globalArrayForPatientToDeductSession = [[NSMutableArray alloc] init];
    }
    
    
    [globalArrayForPatientToDeductSession addObject:forURI];
}


#pragma mark - update Conversation

-(void)updateOpenConversationArray:(NSString *)forURI
{
    BOOL isExits = FALSE;
    
    
    NSString *tempStr;
    
    
    if ([self.openConversationArray count] > 0)
    {
        for (tempStr in self.openConversationArray)
        {
            if (![tempStr isEqualToString:forURI])
            {
                isExits = FALSE;
            }
            
            else
            {
                isExits = TRUE;
                
                
                break;
            }
        }
    }
    
    else
    {
        [self.openConversationArray addObject:forURI];
        
        
        isExits = TRUE;
    }
    
    
    if (!isExits)
    {
        [self.openConversationArray addObject:forURI];
    }
}


#pragma mark - AlertView

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (alertView == alertMessageForNewChat)
    {
        if (buttonIndex == 1)
        {
            
        }
    }
    
    else if (alertView == consistentErrorAlert)
    {
        [self.loginView.navigationController popToRootViewControllerAnimated:NO];
    }
    
    else if (alertView  == alertFileMessage)
    {
        NSArray *fromJid1 = [[self.fileMessageTOURL objectForKey:@"uri"] componentsSeparatedByString:@"@"];
        
        
        ChatMessage *msg    = [NSEntityDescription insertNewObjectForEntityForName:@"ChatMessage" inManagedObjectContext:self.managedObjectContext_roster];
        
        
        msg.identityuri     = [[[self xmppStream] myJID] bare];
        
        msg.content         = [self.fileMessageTOURL objectForKey:@"ImageURL"];
        
        msg.isOutbound      = OutBoundType_Left;
        
        msg.fileTypeChat    = [NSNumber numberWithInt:fileTypeChat_File];
        
        msg.hasBeenRead     = NO;
        
        msg.thumb           = [self.fileMessageTOURL objectForKey:@"thumb"];
        
        msg.timeStamp       = [NSDate date];
        
        msg.uri             = [NSString stringWithFormat:@"%@@imyourdoc.com", [fromJid1 objectAtIndex:0]];
        
        msg.displayName     = [NSString stringWithFormat:@"%@@imyourdoc.com", [fromJid1 objectAtIndex:0]];
        
        msg.mark_deleted    = [NSNumber numberWithBool:mark_deleted_NO];
        
        
        [self addInboxMessage:msg];
        [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                          operation:@"check Message State"
                                            Content:msg.messageID
                                          parameter:[ChatMessage ChatTypeToStr:msg.chatState.intValue]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSError *error = nil;
            
            if([self.managedObjectContext_roster hasChanges])
                if (![self.managedObjectContext_roster save:&error])
                {
                    NSLog(@"%@", [error domain]);
                }
        });
        
        
        [self updateOpenConversationArray:[NSString stringWithFormat:@"%@@imyourdoc.com", [fromJid1 objectAtIndex:0]]];
        
        
        [self.fileMessageTOURL removeAllObjects];
    }
    
    
    if (alertView.tag == 55)
    {
        
        
        
        if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"UserType"] isEqualToString:@"Physician"])
        {
            self.isFromPhysician = isPhysician;
        }
        
        else if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"UserType"] isEqualToString:@"Patient"])
        {
            self.isFromPhysician = isPatient;
        }
        
        else
        {
            self.isFromPhysician = isStaff;
        }
    }
    
    else if (alertView.tag == TAG_ALERT_UPDATE)
    {
        if (buttonIndex != alertView.cancelButtonIndex)
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@""]];
        }
    }
    
    else if (alertView.tag == 7 && buttonIndex == 1)
    {
        NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            
        [[UIApplication sharedApplication] openURL:settingsURL];
    }
    
    else if (alertView.tag == 3)
    {
        [self enterPinAlert];
    }
}

#pragma mark - po
- (void) peformPinMatchFunction
{
    if ([[alertController2CheckSessionPin textFields][0].text isEqualToString:[AppData appData].userPIN])
    {
        bool_pincodeInputPresented = NO;
        
        [self hideSpinnerAfterDelayWithText:@"Verified" andImageName:@"ProcessCompleted.png"];
        
        [effectView removeFromSuperview];
        [vibrantView removeFromSuperview];
        
        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(verifiedAuthentication) userInfo:nil repeats:NO];
    }
    else
    {
        [self hideSpinnerAfterDelayWithText:@"Not Verified" andImageName:@"warning.png"];
        
        if ([[NSUserDefaults standardUserDefaults] valueForKey:@"loginToken"])
            [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(enterPinAlert) userInfo:nil repeats:NO];
            //[self enterPinAlert];
    }
}

- (void) verifiedAuthentication
{
    if([self.xmppStream isConnected])
    {
        XMPPPresence *presence = [XMPPPresence presenceWithType:@"available"];
        
        NSXMLElement *status = [NSXMLElement elementWithName:@"status"];
        
        [status setStringValue:@"Available"];
        
        
        [presence addChild:status];
        
        
        [[self xmppStream] sendElement:presence];
    }
    
    //Reload the table in Chat View
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadAppDelegateTable" object:nil];
}





#pragma mark - Background Notifications

- (void) backgroundNotification:(NSString *)message withxMPPmessage:(XMPPMessage *)xMPPmessage
{
    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                      operation:@"__NLC_NotificationLifeCycle__"
                                        Content:[NSString stringWithFormat:@"%@",xMPPmessage]
                                      parameter:@""];
    
    if ([self.arr_LogOfPushIDs containsObject:[xMPPmessage attributeStringValueForName:@"id"]])
    {
        [self.arr_LogOfPushIDs removeObject:[xMPPmessage attributeStringValueForName:@"id"]];
        return;
        
    }
    
    
    
    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                      operation:@"__NLC_NotificationLifeCycle__"
                                        Content:[NSString stringWithFormat:@"%@",xMPPmessage]
                                      parameter:@""];
    
    
    NSString *strMsg = [NSString stringWithFormat:@"You have a message from %@", message];
    NSInteger badgeNum = [self unreadMessages];
    [[AppData appData] showLocalNotification:strMsg withBadgeNumber:(int)badgeNum];
    
}


#pragma mark - ConnectionStatus


- (BOOL)isConnected
{
    
    return ([self.xmppStream isConnected] && [self.xmppStream isAuthenticated]);
}

- (BOOL)isConnecting
{
    
    return ([self.xmppStream isConnecting]);
}

- (BOOL)isAuthenticating
{
    
    return ([self.xmppStream isAuthenticating]);
}

- (BOOL) appIsDisconnected
{
    //  Check Reachbility with internet.
    if (networkReachability_internet == nil)
    {
        networkReachability_internet = [Reachability reachabilityForInternetConnection];
        networkReachability_internet.reachableBlock = ^(Reachability *reachability)
        {
            
            [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                              operation:@"Network is reachable"
                                                Content:@"Reachability reachableBlock"
                                              parameter:@"Connecting To openFire"];
        };
        
        networkReachability_internet.unreachableBlock = ^(Reachability *reachability)
        {  dispatch_async(dispatch_get_main_queue(), ^{
            
            [AppData sendLocalNotificationForNotConnected];
            
            
            
            [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                              operation:@"Network is unreachable."
                                                Content:@"Reachability unreachableBlock"
                                              parameter:@""];
            
        });
            
            
        };
        [networkReachability_internet startNotifier];
    }
    
    
    NetworkStatus nwStatus = [networkReachability_internet currentReachabilityStatus];
    
    if (nwStatus == ReachableViaWiFi || nwStatus == ReachableViaWWAN)
    {
        [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                          operation:@"check is net is OFF"
                                            Content:@"ReachableViaWiFi OR ReachableViaWWAN"
                                          parameter:@"NO"];
        return NO;
    }
    
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [AppData sendLocalNotificationForNotConnected];
            
        });
        
        
        [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                          operation:@"check is net is OFF"
                                            Content:@"ReachableViaWiFi OR ReachableViaWWAN"
                                          parameter:@"YES"];
        return YES;
    }
}


#pragma mark - NetworkRequests

- (void) auditActivityRequest
{
    
    
    
    
    
    [que_t addOperationWithBlock:^{
        
        NSDictionary *searchDict = [NSDictionary dictionaryWithObjectsAndKeys
                                    :@"xmppLogin", @"method",
                                    [[NSUserDefaults standardUserDefaults] objectForKey:@"loginToken"], @"login_token",
                                    [[NSUserDefaults standardUserDefaults] stringForKey:@"openUUID"], @"device_id",
                                    @"iOS", @"device_type",
                                    
                                    nil];
        
        [[WebHelper sharedHelper] setWebHelperDelegate:self];
        
        [[WebHelper sharedHelper] sendRequest:searchDict tag:S_XmppLogin delegate:self];
    }];
}


#pragma mark - HandlePush

- (NSUInteger )unreadMessages
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"ChatMessage"];
    
    //Replace this with the same query in HomeViewController.m (Ronald)
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"chatState=%@ and mark_deleted!='1' and uri!=%@ and identityuri=%@ and outbound=0 ", [NSNumber numberWithInt:ChatStateType_deliveredByReciever],[self myJID],[self myJID]];

    
    NSUInteger count = [self.managedObjectContext_roster countForFetchRequest:fetchRequest error:nil];

    if (count != NSNotFound)
        return count;
    else
        return 0;
}




- (void) handleChatPushIfOneExists
{
    if (self.jidFromPushToStartChat != nil)
    {
        XMPPJID *toJID = [XMPPJID jidWithString:self.jidFromPushToStartChat];
        
        
        XMPPUserCoreDataStorageObject *user = [self fetchUserForJIDString:[toJID bare]];
        
        
        ChatViewController *chatController  = [[ChatViewController alloc] initWithNibName:@"ChatViewController" bundle:nil];
        
        chatController.user                 = user;
        
        chatController.forChat              = YES;
        
        chatController.jid                  = user.jid;
        
        
        
        if([self.navController.visibleViewController isKindOfClass:[ChatViewController class]])
        {
            if([[[(ChatViewController *) self.navController.visibleViewController jid] bare] isEqualToString:   [chatController.jid bare]])
            {
            }
            else
            {
                [self.navController pushViewController:chatController animated:YES];
            }
            
        }
        
        else{
            
            [self.navController pushViewController:chatController animated:YES];
        }
        
        
        
        self.jidFromPushToStartChat = nil;
        
        
        
        
    }
}


#pragma mark - CheckForVersionUpdate

- (void) checkIfUpdateIsRequired
{
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"checkAppVersion", @"method",
                          [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"], @"app_version",
                          [[NSUserDefaults standardUserDefaults] objectForKey:@"loginToken"], @"login_token",
                          @"IOS", @"app_type",
                          nil];
    
    
    [[WebHelper sharedHelper] setWebHelperDelegate:self];
    
    [[WebHelper sharedHelper] sendRequest:dict tag:S_CheckAppVersion delegate:self];
    
}


#pragma mark - New Conversation

- (void)openComposeScreen
{
    ChatViewController *messageVC = [[ChatViewController alloc] initWithNibName:@"ChatViewController" bundle:nil];
    
    [self.navController pushViewController:messageVC animated:YES];
}


- (void)bringButton
{
    self.composeButton.hidden = NO;
}


- (void)hideButton
{
    self.composeButton.hidden = YES;
}


- (XMPPUserCoreDataStorageObject *)fetchUserForJIDString: (NSString *) jid
{
    
    
    XMPPUserCoreDataStorageObject __block *user;
    NSError __block *coreDataError = nil;
    [self.managedObjectContext_roster performBlockAndWait:^{
        
        NSFetchRequest *fetchReq    = [[NSFetchRequest alloc] initWithEntityName:@"XMPPUserCoreDataStorageObject"];
        
        fetchReq.predicate          = [NSPredicate predicateWithFormat:@"jidStr = %@", jid];
        
        fetchReq.sortDescriptors    = @[];
        
        
        NSArray * users=[[self managedObjectContext_roster] executeFetchRequest:fetchReq error:&coreDataError];
        
        
        
        user = [users lastObject];
        
        if(users.count>1)
        {
            for (int i=0;i<users.count;i++) {
                
                XMPPUserCoreDataStorageObject * xusers =[users objectAtIndex:i];
                if(xusers==user)
                    continue;
                [[self managedObjectContext_roster] deleteObject:xusers];
            }
        }
        
        
        if([self.managedObjectContext_roster hasChanges])
            [self.managedObjectContext_roster save:nil];
        
        

    }];
//    [self.managedObjectContext_roster lock];
//    [self.managedObjectContext_roster unlock];
    
    if (user)
    {
        return user;
    }
    
    else
    {
        if (coreDataError)
        {
            NSLog(@"Error while fetching name from DB: %@", coreDataError.description);
        }
        
        
        return nil;
    }
    
}

- (XMPPRoomObject *)fetchOrInsertRoom:(XMPPRoom *) room
{
    XMPPRoomObject *roomObj = nil;
    [self.managedObjectContext_roster lock];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPRoomObject"];
    
    request.predicate = [NSPredicate predicateWithFormat:@"streamJidStr=%@ AND room_jidStr=%@", self.myJID, room.roomJID.bare];
    
    
    roomObj = [[self.managedObjectContext_roster executeFetchRequest:request error:nil] lastObject];
    
    
    if (roomObj == nil)
    {
        roomObj             = [NSEntityDescription insertNewObjectForEntityForName:@"XMPPRoomObject" inManagedObjectContext:self.managedObjectContext_roster];
        
        roomObj.room_jidStr = room.roomJID.bare;
        
        roomObj.room_status = @"active";
        
        roomObj.creationDate=[NSDate date];
        
        roomObj.lastMessageDate=[NSDate date];
        
        
        
        if([self.managedObjectContext_roster hasChanges])
            [self.managedObjectContext_roster save:nil];
    }
    
    roomObj.lastMessageDate=[NSDate date];
    roomObj.streamJidStr = [self.xmppStream.myJID bare];
    NSString *myJID = [AppData appData].getMyJID;
    
    roomObj.streamJidStr = myJID;
    
    NSError *error = nil;
    
    if([self.managedObjectContext_roster hasChanges])
        [self.managedObjectContext_roster save:&error];
    [self.managedObjectContext_roster unlock];
    
    
    return roomObj;
}


- (XMPPRoomObject *)fetchRoom:(NSString *) roomJID
{
    XMPPRoomObject *roomObj = nil;
    
    
    [self.managedObjectContext_roster lock];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPRoomObject"];
    
    request.predicate = [NSPredicate predicateWithFormat:@"room_jidStr=%@ AND streamJidStr=%@ ", roomJID, [AppDel myJID]];
    
    NSError * error=nil;
    NSArray * array=[self.managedObjectContext_roster executeFetchRequest:request error:&error];

    if(error)
        NSLog(@"Error after managedObjectContext_roster in fetchRoom %@..",error);

    if(error==nil)
        roomObj = [array lastObject];

    
    
    [self.managedObjectContext_roster unlock];
    
    
    return roomObj;
}


#pragma mark - Navigations
- (void)goToHomeView{
    
    //Check if all of the login necessary information is fetched.
    if (![AppData appData].isAllLoginInfoFetched){
        return;
    }
    
    //Stop Timer for login try
    [timerForLogin invalidate];
    timerForLogin = nil;
    
    //Additional check for login state
    if (self.isLoggedState == 2) {
        return;
    }
    
    
   [self.loginView setUsernameAndPassWordAsEmpty];
   
   if (!self.homeView)
   {
       self.homeView = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
   }
   
   [self.navController pushViewController:self.homeView animated:YES];

   [self hideSpinner];
   self.isLoggedState = 2;
}

#pragma mark - XMPP Activities

- (void)sendMsg:(NSString *)msg toIMYourDocUser:(NSString *)toUser withMessageID:(NSString *)msgID
{
    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
    [message addAttributeWithName:@"id" stringValue:msgID];
    [message addAttributeWithName:@"type" stringValue:@"chat"];
    
    NSString *JidString = [[xmppStream myJID] user];
    
    [message addAttributeWithName:@"from" stringValue:[NSString stringWithFormat:@"%@@imyourdoc.com",JidString]];
    [message addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@",toUser]];
    
    @autoreleasepool {
        VCard * vcard=[self fetchVCard:[XMPPJID jidWithString:toUser]];
        (void)vcard;
    }
    
    {
        NSDictionary * dictionary=[NSDictionary  dictionaryWithObjectsAndKeys:msg,@"content",[NSString stringWithFormat:@"%@",[NSDate date]],@"timestamp",JidString,@"from",toUser,@"to",msgID,@"messageID", nil];
        
        NSXMLElement *body = [NSXMLElement elementWithName:@"body" stringValue:[dictionary JSONString]];
        [message addChild:body];
        [message addProperty:@"message_version" value:@"2.0" type:@"string"];
    }

    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                      operation:@"sendElement>>Msg"
                                        Content:msgID
                                      parameter:@""];
    
    [xmppStream sendElement:message];
    
}


- (void)sendGroupMsg:(NSString *)msg toIMYourDocRoom:(NSString *)room
{
    NSXMLElement *body = [NSXMLElement elementWithName:@"body" stringValue:msg];
    
    
    XMPPMessage *message = [XMPPMessage message];
    
    [message addAttributeWithName:@"to" stringValue:room];
    
    [message addAttributeWithName:@"type" stringValue:@"groupchat"];
    
    
    NSTimeInterval today = ([[NSDate date] timeIntervalSince1970]*1000);
    
    
    NSString *intervalString = [NSString stringWithFormat:@"%f", today];
    
    
    NSArray *absoluteTime = [intervalString componentsSeparatedByString:@"."];
    
    
    [message addAttributeWithName:@"id" stringValue:[NSString stringWithFormat:@"%@%@", [absoluteTime objectAtIndex:0], [[[self xmppStream] myJID] user]]];
    
    [message addChild:body];
    
    
    [xmppStream sendElement:message];
}



- (void)sendDeliveredForMessageID:(NSString *)messageID fromJID:(NSString *)fromJID
{
    if(!fromJID || !fromJID.length                     // don't send ack to nobody
       || !messageID || !messageID.length              // don't send ack for nothing
       || [[AppDel myJID] isEqualToString:fromJID] )    // don't send ack to yourself
        return;

    NSXMLElement *ack = [NSXMLElement elementWithName:@"message" xmlns:@"jabber:client"];
    [ack addAttributeWithName:@"to" stringValue:fromJID];
    [ack addAttributeWithName:@"from" stringValue:[AppDel myJID]];
    
    NSXMLElement *idElement = [NSXMLElement elementWithName:@"id"];
    [idElement setStringValue:messageID];

    
    NSXMLElement *deliveredElement = [NSXMLElement elementWithName:@"delivered"];
    [deliveredElement addChild:idElement];
    
    NSXMLElement *xElement = [NSXMLElement elementWithName:@"x" xmlns:@"jabber:x:event"];
    [xElement addChild:deliveredElement];
        
    [ack addChild:xElement];
    
    [xmppStream sendElement:ack];
    
}



- (void)sendChatState:(SendChatStateType)chatState withBuddy:(NSString *)buddy withMessageID:(NSString *)msgID isGroupChat:(BOOL) isgpchat
{
    NSXMLElement *message = [NSXMLElement elementWithName:@"message" xmlns:@"jabber:client"];
    
    [message addAttributeWithName:@"to" stringValue:buddy];
    
    [message addAttributeWithName:@"from" stringValue:[AppDel myJID]];
    
    
    if([[AppDel myJID] isEqualToString:buddy])
    {
        return;
    }
    
    
    NSXMLElement *xElement = [NSXMLElement elementWithName:@"x" xmlns:@"jabber:x:event"];
    
    
    BOOL shouldSend;
    
    shouldSend = YES;
    
    
    
    
    
    switch (chatState)
    {
            
        case SendChatStateType_composing  : //disPlayed and dileived
        {
            
            if (isgpchat)
            {
                [message addAttributeWithName:@"type" stringValue:@"groupchat"];
            }
            NSXMLElement *idElement = [NSXMLElement elementWithName:@"id"];
            
            [idElement setStringValue:@"composingMYiPhone"];
            
            NSXMLElement *composingElement = [NSXMLElement elementWithName:@"composing"];
            
            [composingElement addChild:idElement];
            
            [xElement addChild:composingElement];
            
            [message addChild:xElement];
        }
            
            break;
            
            
        case SendChatStateType_composing1:
        {
            
            if (isgpchat)
            {
                [message addAttributeWithName:@"type" stringValue:@"groupchat"];
            }
            NSXMLElement *idElement = [NSXMLElement elementWithName:@"id"];
            
            [idElement setStringValue:@"composingMYiPhone"];
            
            
            NSXMLElement *composingElement = [NSXMLElement elementWithName:@"composing"];
            
            [composingElement addChild:idElement];
            
            
            [xElement addChild:composingElement];
            
            
            [message addChild:xElement];
        }
            
            break;
            
            
            
            
        case SendChatStateType_NO:
            
            shouldSend = NO;
            
            
            
            break;
            
            
        case SendChatStateType_gone:case SendChatStateType_gone2:
        {
            
            
            if (isgpchat)
            {
                [message addAttributeWithName:@"type" stringValue:@"groupchat"];
            }
            
            NSXMLElement *idElement = [NSXMLElement elementWithName:@"id"];
            
            [idElement setStringValue:@"composingMYiPhone"];
            
            
            NSXMLElement *composingElement = [NSXMLElement elementWithName:@"gone"];
            
            [composingElement addChild:idElement];
            
            
            [xElement addChild:composingElement];
            
            
            [message addChild:xElement];
        }
            
            break;
            
            
        case SendChatStateType_delivered:
            [self sendDeliveredForMessageID:msgID fromJID:buddy];
            break;
            
            
        case SendChatStateType_displayed:
        {
            NSXMLElement *idElement = [NSXMLElement elementWithName:@"id"];
            
            [idElement setStringValue:msgID];
            
            
            NSXMLElement *deliveredElement = [NSXMLElement elementWithName:@"displayed"];
            
            [deliveredElement addChild:idElement];
            
            
            [xElement addChild:deliveredElement];
            
            
            [message addChild:xElement];
        }
            
            break;
            
            
        default :
            
            shouldSend = NO;
            
            break;
    }
    
    
    if (shouldSend)
    {
        [xmppStream sendElement:message];
    }
}


- (void)deleteRosterwithJID:(NSString *)JID
{
    [[self xmppRoster] removeUser:[XMPPJID jidWithString:[NSString stringWithFormat:@"%@@imyourdoc.com", JID]]];
}


- (void)addUser:(NSString *)userJID
{
    [xmppRoster addUser:[XMPPJID jidWithString:userJID] withNickname:userJID];
}


- (void)addUser:(NSString *)userJID fromStaff:(BOOL )fromStaff
{
    [xmppRoster addUser:[XMPPJID jidWithString:userJID] withNickname:userJID fromStaff:fromStaff];
}


- (void)saveVcard
{
    [self hideSpinner];
}


- (void)setProfilePic:(NSString *)imageData withImage:(NSData *)imageData1
{
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(saveVcard) userInfo:nil repeats:NO];
    
    
    [self setSpinnerText:@"Updating Vcard"];
    
    
    NSXMLElement *vCardXML = [NSXMLElement elementWithName:@"vCard" xmlns:@"vcard-temp"];
    
    NSXMLElement *photoXML = [NSXMLElement elementWithName:@"PHOTO"];
    
    NSXMLElement *typeXML = [NSXMLElement elementWithName:@"TYPE" stringValue:@"image/jpeg"];
    
    NSXMLElement *binvalXML = [NSXMLElement elementWithName:@"BINVAL" stringValue:imageData];
    
    
    [photoXML addChild:typeXML];
    
    [photoXML addChild:binvalXML];
    
    [vCardXML addChild:photoXML];
    
    
    XMPPvCardTemp *myvCardTemp = [xmppvCardTempModule myvCardTemp];
    
    
    if (myvCardTemp)
    {
        [myvCardTemp setPhoto:imageData1];
        
        
        [xmppvCardTempModule updateMyvCardTemp:myvCardTemp];
    }
    
    else
    {
        XMPPvCardTemp *newvCardTemp = [XMPPvCardTemp vCardTempFromElement:vCardXML];
        
        
        [xmppvCardTempModule updateMyvCardTemp:newvCardTemp];
    }
    
    
}


#pragma mark - XMPPStream

- (void)xmppStream:(XMPPStream *)sender didSendIQ:(XMPPIQ *)iq
{
//    NSLog(@"---------------XMPPStream Did Send IQ---------------!!! %@", iq);
}

- (void)xmppStream:(XMPPStream *)sender socketWillConnect:(GCDAsyncSocket *)socket
{
    // Tell the socket to stay around if the app goes to the background (only works on apps with the VoIP background flag set)
    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                      operation:@"__XLC_XMPPStreamLifeCycle__"
                                        Content:@""
                                      parameter:@""];
    
    [socket performBlock:^{
        [socket enableBackgroundingOnSocket];
    }];
}

- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket
{
    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                      operation:@"__XLC_XMPPStreamLifeCycle__"
                                        Content:@""
                                      parameter:@""];
    
    [socket performBlock:^{
        [socket enableBackgroundingOnSocket];
    }];
}


- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings
{
    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                      operation:@"__XLC_XMPPStreamLifeCycle__"
                                        Content:@""
                                      parameter:@""];
    
    [settings setObject:xmppStream.myJID.domain forKey:(NSString *)kCFStreamSSLPeerName];
    
    /*
     * Use manual trust evaluation
     * as stated in the XMPPFramework/GCDAsyncSocket code documentation
     */
    
    if (customCertEvaluation)
    {
        [settings setObject:@(YES) forKey:GCDAsyncSocketManuallyEvaluateTrust];
    }
    
    
}

- (void)xmppStream:(XMPPStream *)sender didReceiveTrust:(SecTrustRef)trust completionHandler:(void (^)(BOOL shouldTrustPeer))completionHandler
{
    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                      operation:@"__XLC_XMPPStreamLifeCycle__"
                                        Content:@""
                                      parameter:@""];
    
    completionHandler(YES); // After this line, SSL connection will be established
}

- (void)xmppStreamDidSecure:(XMPPStream *)sender
{
    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                      operation:@"__XLC_XMPPStreamLifeCycle__"
                                        Content:@""
                                      parameter:@""];
    
    [AppData sendLocalNotificationForSecurelyConnected];
    
    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                      operation:@"XMPPREACHABILITY"
                                        Content:@"Securely Connected"
                                      parameter:@""];
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    NSLog(@"---------------XMPPStream Did Connect---------------!!!");
    
    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                      operation:@"__XLC_XMPPStreamLifeCycle__"
                                        Content:@""
                                      parameter:@""];
    
    isXmppConnected = YES;
    
    NSError *error = nil;
    
    NSLog(@"---------------XMPPStream Start Authenticate---------------!!!");
    if (![[self xmppStream] authenticateWithPassword:[AppData appData].XMPPmyJIDPassword error:&error])
    {
        [AppData sendLocalNotificationForNotConnected];
        [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                          operation:@"XMPPREACHABILITY"
                                            Content:@"Not Connected"
                                          parameter:@""];
    }
    
    else
    {
        [AppData sendLocalNotificationForSecurelyConnected];
        [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                          operation:@"XMPPREACHABILITY"
                                            Content:@"Securely Connected"
                                          parameter:@""];
    }
}


- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    NSLog(@"---------------XMPPStream Did Authenticate---------------!!!");
    
    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                      operation:@"__XLC_XMPPStreamLifeCycle__"
                                        Content:@""
                                      parameter:@""];
    
    [self registerForPushNotification];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"userLoggedIn"])
    {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"chatstates"];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"userLoggedIn"];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
    
    [self fetchVCard:[sender myJID]];
    
    [self goOnline];
    
    if (self.isLoggedState == 0)
    {
        timerForLogin = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(goToHomeView) userInfo:nil repeats:YES];
    }
    else if (self.isLoggedState == 1)
    {

        [self hideSpinner];
        self.isLoggedState = 2;
    }
    
    isXmppConnected = YES;
    [self.homeView checkInternetConnection:isXmppConnected];
    
    
    [self stopSessionCheckTimer];
    [self startSessionCheckTimer];
    
    [self auditActivityRequest];
    [self checkIfUpdateIsRequired];
    [self handleChatPushIfOneExists];
    
    if (manualRosterFetchBool!=YES)
    {
        [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                          operation:@"manualRosterFetchBool"
                                            Content:@"manualRosterFetchBool  not equal to yes "
                                          parameter:@"manualRosterFetchBool"];
        
        [self getRoster];
    }
    
    
    // reset
    bool_connectRetry = NO;
}


- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                      operation:@"__XLC_XMPPStreamLifeCycle__"
                                        Content:@""
                                      parameter:@""];

    NSLog(@"---------------XMPPStream Did NOT Authenticate---------------!!!");

    [self hideSpinner];
    
    if (self.isLoggedState != 0)
    {
        if (alertController2CheckSessionPin) {
            [alertController2CheckSessionPin dismissViewControllerAnimated:NO completion:nil];
            
            bool_pincodeInputPresented = NO;
        }
        
        alertController2AuthenticaionFailed = [UIAlertController alertControllerWithTitle:@"XMPP authentication failed.  If this error persists please contact customer support." message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController2AuthenticaionFailed addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull_action) {
            
        }]];
        
        [alertController2AuthenticaionFailed addAction:[UIAlertAction actionWithTitle:@"Retry" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull_action) {
            [self.loginView loginReqest];
        }]];
        
        [alertController2AuthenticaionFailed show];
        
        [NSDictionary dictionaryWithObjectsAndKeys:@"Not Connected", @"status", @"unsecure_icon", @"image", nil];
        
        //For some reason, the not authenticated user is already logged in. This will log them out.
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setLoginType:0];
            [self signOutFromApp];
        });
        
    }
}


- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    
    if(TARGET_IPHONE_SIMULATOR)
       NSLog(@"XMPPStream didReceiveIQ ------  %@ ------- %@", [iq xmlns],iq);
    
    pingTimeOuts=0;
    if([iq isErrorIQ])
    {
        if([[iq elementForName:@"error"] attributeIntValueForName:@"code"]==400)
        {
            [self authenticate];
        }
    }
    
    
    
    if([iq attributeStringValueForName:@"id"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:[NSString stringWithFormat:@"KstateTransferArrayUpdateNotification"] object:nil  userInfo:nil];
    }
    
    
    
    
    
    if ([[[iq elementForName:@"chat"] xmlns] isEqualToString:@"urn:xmpp:archive"])
    {
        
        [self leoXmppStreamReceiveIQ:sender withChatUrnXmppArchive:iq];
        
    }
    
    
    
    if ([[iq fromStr] isEqualToString:@"newconversation.imyourdoc.com"])
    {
        [self leoXmppStreamReceiveIQ:sender withNewConversationImyourdocCom:iq];
        
        
        
        
        
        return YES;
    }
    
    
    if ([iq elementForName:@"ping"])
    {
        
        [self leoXmppStreamReceiveIQ:sender withPing:iq];
        
        
        
        
        
        return NO;
    }
    else
        
        
        if ([[iq elementForName:@"vCard"].xmlns isEqualToString:@"vcard-temp"])
        {
            [self leoXmppStreamReceiveIQ:sender withVcardTemp:iq];
            
            if ([self.navController.visibleViewController isKindOfClass:[HomeViewController class]])
            {
                
                [self.homeView updateMessagCount];
                
            }
            
            
            return YES;
        }
    if ([[[iq elementForName:@"query"] xmlns] isEqualToString:@"jabber:iq:roster"])
    {
        
        [self leoXmppStreamReceiveIQ:sender withJabberIqRoster:iq];
        
        manualRosterFetchBool= YES;
        
        
        
        dispatch_async(dispatch_get_main_queue(), ^
                       {
                           
                           
                           
                           if([[NSUserDefaults standardUserDefaults] boolForKey:@"chatstates"]==NO)
                           {
                               [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"chatstates"];
                               [[NSUserDefaults standardUserDefaults] synchronize];
                               
                               [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:@"KStateTransferReceiveActiveConversationNotificationStep1" object:nil userInfo:nil];
                               
                           }
                       }
                       );
        
        
        
        return NO;
    }
    
    
    if ([[[iq elementForName:@"query"] xmlns] isEqualToString:@"jabber:iq:roster"])
    {
        if ([self.navController.visibleViewController isKindOfClass:[HomeViewController class]])
        {
            [self.homeView updateMessagCount];
        }
    }
    
    
    
    
    
    
    
    if ([self.navController.visibleViewController isKindOfClass:[HomeViewController class]])
    {
        [self.homeView updateMessagCount];
    }
    
    
    return NO;
}


- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message
{
    NSString *msgID = message ? [message attributeStringValueForName:@"id"] : @"";

    
    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                      operation:@"start didSendMessage"
                                        Content:@"outgoing messageID"
                                      parameter:msgID];
    
    if(TARGET_IPHONE_SIMULATOR)
        NSLog(@"XMPPStream didSendMessage ------ \nmessage %@ \n-------------------",message);
    
    if ([message isMessageWithBody])
    {
        if ([message isMessageWithBody])
        {
            ChatMessage *chat = [ChatMessage getChatMessageObjectWithMessageID:msgID];;

            if([chat.isRoomMessage boolValue]==NO)
            {
                chat.isResending=[NSNumber numberWithBool:NO];
                
                if([self.managedObjectContext_roster hasChanges])
                    [self.managedObjectContext_roster save:nil];
            }
            ChatMessage * nextMessage=[ChatMessage getLastFailedMessageForJID:chat.uri];
            
            if(nextMessage)
            {
                if([nextMessage.isRoomMessage boolValue])
                {
                    XMPPRoom * room=[[XMPPRoom alloc] initWithRoomStorage:[XMPPRoomMemoryStorage sharedInstanse] jid:[XMPPJID jidWithString:nextMessage.uri]];
                    
                    
                    
                    XMPPRoomObject *liveRoom = [[self.roomsArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"room_jidStr=%@", [room.roomJID bare]]] lastObject];
                    
                    if(liveRoom==nil)
                    {
                        
                        [room activate:self.xmppStream];
                        [room addDelegate:self delegateQueue:xmppDelegateQueue];
                        
                        [room fetchRoomInfo];
                    }
                    else
                    {
                        [self resendGroupMessage:nextMessage];
                    }
                    //
                    
                }
                else
                {
                    
                }
            }
            
            
            
            // Broadcast
            
            {
                [self broadcastMessagedidSendWithID:[message attributeStringValueForName:@"id"]];
                
                
                
            }
            
        }
    }
    
    if ([message hasChatState])
    {
        if ([message hasDisPlayedChatState])
        {
            NSXMLElement *messageEvent = [message elementForName:@"x" xmlns:@"jabber:x:event"];
            
            NSXMLElement *displayedEvent = [messageEvent elementForName:@"displayed"];
            
            
            NSPredicate *pred;
            
            
            if ([messageEvent elementForName:@"id"])
            {
                pred = [NSPredicate predicateWithFormat:@"messageID like %@", [[messageEvent elementForName:@"id"] stringValue]];
            }
            
            else if ([displayedEvent elementForName:@"id"])
            {
                pred = [NSPredicate predicateWithFormat:@"messageID like %@", [[displayedEvent elementForName:@"id"] stringValue]];
            }
            
            
            NSMutableArray * temp=[[CoreDataHelper searchObjectsInContext:@"ChatMessage" : pred : nil : NO : self.managedObjectContext_roster] mutableCopy];
            
            
            ChatMessage *chat = [temp lastObject];
            
            
            if (chat)
            {
                if(chat.isOutbound==OutBoundType_Right)
                    return;
                // code to update the status of the read message status --- to 1
                
                chat.readReportSent_Bl = [NSNumber numberWithBool:YES];
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^
                               {
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       if([self.managedObjectContext_roster hasChanges])
                                           [self.managedObjectContext_roster save:nil];
                                   });
                               } );
                
            }
        }
        
        
    }
}


- (void)xmppStream:(XMPPStream *)sender1 didReceiveMessage:(XMPPMessage *)message
{
    
    NSString *msgID = message ? [message attributeStringValueForName:@"id"] : @"";
    
    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                      operation:@""
                                        Content:@"incoming message id"
                                      parameter:msgID];
    
//    if(TARGET_IPHONE_SIMULATOR)
        NSLog(@"XMPPStream didReceiveMessage ------ \nmessage %@ \n ---------------",message);
    
    pingTimeOuts=0;
    if ([message isErrorMessage])
    {
        [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                          operation:@"It is an error message"
                                            Content:@"incoming message id"
                                          parameter:msgID];
        
        if([message.errorMessage code]==401)
        {
            [self authenticate];
        }
        
        
        if ([message isMessageWithBody])
        {
            ChatMessage *mess2age = [ChatMessage getChatMessageObjectWithMessageID:msgID];
            
            if (mess2age != nil)
            {
                mess2age.chatState = [NSNumber numberWithInt:ChatStateType_NotDelivered];
                
                [self resendMessage:mess2age];
            }
        }
        
        else if([message hasChatState])
        {
            
            
            if ([message hasDisPlayedChatState])
            {
                NSXMLElement *messageEvent = [message elementForName:@"x" xmlns:@"jabber:x:event"];
                
                NSXMLElement *displayedEvent = [messageEvent elementForName:@"displayed"];
                
                
                NSPredicate *pred;
                
                
                if ([messageEvent elementForName:@"id"])
                {
                    pred = [NSPredicate predicateWithFormat:@"messageID like %@", [[messageEvent elementForName:@"id"] stringValue]];
                }
                
                else if ([displayedEvent elementForName:@"id"])
                {
                    pred = [NSPredicate predicateWithFormat:@"messageID like %@", [[displayedEvent elementForName:@"id"] stringValue]];
                }
                
                
                NSMutableArray *temp = [[CoreDataHelper searchObjectsInContext:@"ChatMessage" : pred : nil : NO : self.managedObjectContext_roster] mutableCopy];
                
                
                ChatMessage *chat = [temp lastObject];
                
                
                if (chat)
                {
                    
                    
                    // code to update the status of the read message status --- to 0
                    
                    chat.readReportSent_Bl = [NSNumber numberWithBool:NO];
                    
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if([self.managedObjectContext_roster hasChanges])
                            [self.managedObjectContext_roster save:nil];
                    });
                }
            }
        }
        
        
    }
    
    
    
    
    //----------------------------  Generic Message Handling -----------------------------------
    
    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                      operation:@"Generic Message Handling"
                                        Content:@"incoming message id"
                                      parameter:msgID];
    
    NSString *fromUSERJID = [message.from bare];
    
    
    
    
    {
        if ([message isChatMessageWithBody])
        {
            [AppDel leoXmppStreamReceive:sender1 isChatMessageWithBody:message];
        }
        
        else if ([message isGroupChatMessageWithBody])
        {
            [AppDel leoXmppStreamReceive:sender1 IsGroupChatwithBody:message];
        }
        else if ([message isGroupChatMessageWithSubject])
        {
            XMPPRoomObject *room = [self fetchRoom:[[message from] bare]];
            
            room.subject = [[message elementForName:@"subject"] stringValue];
            
            room.name = room.subject;
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.managedObjectContext_roster save:nil];
            });
            [self.homeView updateMessagCount];
            
        }
        
        else if([message isHeadline])
        {
            
            [self leoXmppStreamReceive:sender1 isBroadcastMessage:message];
            
        }
        
        else if([message isEventTypeMemberAdd])  // --- Get the message with new member add event in group chat ---
        {
            
        }
        
        else if ([message isEventTypeMemberRemoved])  // --- Get the message with existing member removed event in group chat ---
        {
            
            [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                              operation:@"Group member removed message"
                                                Content:@"incoming message id"
                                              parameter:msgID];

            NSArray *eventItems = [message elementsForName:@"event"];
            
            if (eventItems.count == 1) {
                DDXMLElement *eventItem = eventItems.firstObject;
                
                NSString *strUserJID = [[eventItem attributeForName:@"jid"] stringValue];
                
                //Check if user jid is mine
                NSString *strMyjID = [AppData appData].getMyJID;
                if (strMyjID && [strUserJID isEqualToString:strMyjID]){
                    NSString *strRoomJID = [[eventItem attributeForName:@"roomJID"] stringValue];
                    
                    if (strUserJID && strRoomJID){
                        XMPPRoomObject *roomObj = [self fetchRoom:strRoomJID];
                        
                        if (roomObj){
                            NSString *strGroupChatName;
                            
                            if (roomObj.name.length > 0 ) strGroupChatName = roomObj.name;
                            else strGroupChatName = [[XMPPJID jidWithString:strRoomJID] user];
                            
                            NSString *alertMsg = [NSString stringWithFormat:@"You are no longer a member of the group \"%@\". Either contact the group admin to rejoin or start a new conversation.", strGroupChatName];
                            
                            [[[UIAlertView alloc] initWithTitle:nil message:alertMsg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                            
                            
                            //Show local notification
                            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"Alerts"]
                                && [[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground)
                            {
                                [[AppData appData] showLocalNotification:alertMsg withBadgeNumber:-1];
                            }
                            
                            //Remove the inbox message
                            InboxMessage *inboxMsg = [self fetchOrInsertMessage:strRoomJID];
                            if (inboxMsg){
                                [self.managedObjectContext_roster deleteObject:inboxMsg];
                                
                                NSError *error = nil;
                                if([self.managedObjectContext_roster hasChanges])
                                    [self.managedObjectContext_roster save:&error];
                            }
                            
                            [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                                              operation:@"Group member removed message HANDLED!"
                                                                Content:@"incoming message id"
                                                              parameter:msgID];
                        }
                            
                        
                    }
                }
                    
                
                
            }
        }
        
        else if ([[message elementForName:@"x"]elementForName:@"acknowledgement"])
        {
            [self leoXmppStreamReceive:sender1 didServerAcknowlgement:message];
            
            
        }
        else if ([[message elementForName:@"x"]elementForName:@"notification"])
        {
            [self LeoXmppStreamReceive:sender1 didServerSentNotification:message];
            
        }
        
        else
        {
            
            NSXMLElement * timeelement=[message elementForName:@"properties" xmlns:@"http://www.jivesoftware.com/xmlns/xmpp/properties"];
            
            NSArray * elements=[timeelement elementsForName:@"property"];
            
            
            for(  NSXMLElement * property in elements)
            {
                
                if([[[property elementForName:@"value"] stringValue] isEqualToString:@"Broadcast_Message"])
                {
                    
                    
                    [self leoXmppStreamReceive:sender1 isBroadcastMessage:message];
                    
                }
                
                
            }
            
        }
        
    }
    
    //----------------------------  According to the Chat Status, Message Handling -----------------------------------
    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                      operation:@"other message handling"
                                        Content:@"incoming message id"
                                      parameter:msgID];
    
    if ([message hasChatState] && ![message isErrorMessage] && ![self.window.subviews containsObject:effectView])
    {
        NSDictionary *userinfo;
        
        if ([message hasComposingChatState])
        {
            
            NSString *str_notifyArrayForChat = [(XMPPJID*)[self.notifyArrayForChat lastObject]bare];
            
            
            if ([fromUSERJID isEqualToString:str_notifyArrayForChat])
            {
                userinfo = [NSDictionary dictionaryWithObjectsAndKeys:[message fromStr], @"BuddyID", @"Composing...", @"chatNotificationState", nil];
                [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:@"KChatStateNotification" object:nil userInfo:userinfo];
                
            }
            
            else
            {
                if ([message isGroupchat])
                {
                    
                    userinfo = [NSDictionary dictionaryWithObjectsAndKeys:[message fromStr], @"BuddyID",[NSString  stringWithFormat:@"%@ composing...", [[message from] resource]], @"chatNotificationState", nil];
                    
                    
                    if (![[[message from] resource] isEqualToString:sender1.myJID.user])
                    {
                        
                        // this method is called in group chat when i wrote some text in textfied on other end
                        [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:@"KChatStateNotification" object:nil userInfo:userinfo];
                        
                        if (![message isGroupChatMessageWithBody])
                        {
                            return;
                        }
                        
                    }
                }
                
                
            }
        }
        
        else if ([message hasGoneChatState])
        {
            userinfo = [NSDictionary dictionaryWithObjectsAndKeys:[message fromStr], @"BuddyID", @"gone", @"chatNotificationState", nil];
            [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:@"KChatStateNotification" object:nil userInfo:userinfo];
        }
        else
        {
            userinfo = [NSDictionary dictionaryWithObjectsAndKeys:[message fromStr], @"BuddyID", @"gone", @"chatNotificationState", nil];
            
            
            // 1 this method is called in group chat after ablove  code
            [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:@"KChatStateNotification" object:nil userInfo:userinfo];
        }
        
        
        
        if ([message hasDeliveredChatState])
        {
            //code that u need to handle the delivery status
            [AppDel leoXmppStreamReceive:sender1 hasDeliveredChatStateWithBody:message];
        }
        
        if ([message hasDisPlayedChatState])
        {
            //.. code that u need to handle the display status
            
            [self leoXmppStreamReceive:sender1 hasDisPlayedChatStateWithBody:message];
        }

    }
    
}



- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
    
    NSString *from = [[presence from] bare];
    
    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                      operation:@"__XLC_XMPPStreamLifeCycle__"
                                        Content:@"presence stanza from: "
                                      parameter:(from ? from : @"EMPTY")];
    
    if(TARGET_IPHONE_SIMULATOR)
        NSLog(@"XMPPStream didReceivePresence ------ \npresence %@\n-------------------", presence);
    
    
    
    if (self.isFromPhysician == isPhysician)
    {
        if ([[presence type] isEqualToString:@"subscribe"])
        {
            NSString *presenceStr = [[presence fromStr] stringByReplacingOccurrencesOfString:@"@imyourdoc.com" withString:@""];
            
            
            if (![self.pendingUserArr containsObject:presenceStr] || ![self.declinedUserArr containsObject:presenceStr])
            {
                [self.pendingUserArr addObject:presenceStr];
                
                
                if (alertViewForSubscriptionRequest)
                {
                    alertViewForSubscriptionRequest.message = [NSString stringWithFormat:@"You have %lu Pending Requests", (unsigned long)[self.pendingUserArr count]];
                }
                
                else
                {
                    [[[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"You have new request. Please check pending request in Account setting"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                }
            }
        }
    }
    
    
    if ([[[presence elementForName:@"x"] stringValue] isEqualToString:@"vcard-temp:x:update"])
    {
        
        XMPPUserCoreDataStorageObject * user=[self fetchUserForJIDString:[presence fromStr]];
        if([[[user subscription]lowercaseString]isEqualToString:@"both"])
            [self getVcard:presence.from];
    }
    
    
}

- (void)xmppStreamDidStartNegotiation:(XMPPStream *)sender
{
    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                      operation:@"__XLC_XMPPStreamLifeCycle__"
                                        Content:@""
                                      parameter:@""];
}
- (void)xmppStream:(XMPPStream *)sender didNotRegister:(NSXMLElement *)error
{
    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                      operation:@"__XLC_XMPPStreamLifeCycle__"
                                        Content:@""
                                      parameter:@""];
}

- (void)xmppStreamConnectDidTimeout:(XMPPStream *)sender
{
    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                      operation:@"__XLC_XMPPStreamLifeCycle__"
                                        Content:@""
                                      parameter:@""];
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error
{
    NSLog(@"..... xmppStream..%@", error);
    
    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                      operation:@"__XLC_XMPPStreamLifeCycle__"
                                        Content:@""
                                      parameter:@""];
}


- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    
    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                      operation:@"__XLC_XMPPStreamLifeCycle__"
                                        Content:[NSString  stringWithFormat:@"...%@",error]
                                      parameter:[NSString  stringWithFormat:@"...%@",sender]];
    
    [NSDictionary dictionaryWithObjectsAndKeys:@"Not Connected", @"status", @"unsecure_icon", @"image", nil];
    
    
    if (self.isManuallyDisconnect)
    {
        
        
        [self signOutRequest];
        
        
        self.isManuallyDisconnect = FALSE;
    }
    
    else
    {
        if (self.isLoggedState == 0)
        {
            if (![[NSUserDefaults standardUserDefaults] boolForKey:@"rememberMe"])
            {
                if ([AppData appData].XMPPmyJID)
                {
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kXMPPmyJID];
                }
            }
            
            
            if ([AppData appData].XMPPmyJIDPassword)
            {
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:kXMPPmyPassword];
            }
            
            
            if ([[NSUserDefaults standardUserDefaults] objectForKey:@"UserType"])
            {
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserType"];
            }
            
            
            if ([[NSUserDefaults standardUserDefaults] objectForKey:@"QuestionString"])
            {
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"QuestionString"];
            }
            
            
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            
            [self hideSpinnerAfterDelayWithText:@"XMPP error - disconnected" andImageName:@"warning.png"];
        }
        
        else
        {
            if (self.homeView)
            {
                [self.homeView checkInternetConnection:NO];
            }
        }
        
        
        if (self.isLoggedState == 1)
        {
            [self tryReconnectChatServer];
        }
    }
    
    
    isXmppConnected = NO;
    
    
    if (!isXmppConnected)
    {
        
    }
}


#pragma mark - XMPP Roster Delegate


- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence
{
    
    
    
}

/**
 * Sent when a Roster Push is received as specified in Section 2.1.6 of RFC 6121.
 **/
- (void)xmppRoster:(XMPPRoster *)sender didReceiveRosterPush:(XMPPIQ *)iq
{
    
    
    [self update_pending_Request_count];
    
    NSXMLElement * item=[[iq elementForName:@"query"] elementForName:@"item"];
    XMPPUserCoreDataStorageObject * user=[self fetchUserForJIDString:[item attributeStringValueForName:@"jid"]];
    
    {
        if(user==nil)
        {
            user=[XMPPUserCoreDataStorageObject insertInManagedObjectContext:self.managedObjectContext_roster withItem:item streamBareJidStr:self.myJID];
        }
        
        [user updateWithItem:item];
        
        if([[item attributeStringValueForName:@"subscription"] isEqualToString:@"both"])
        {
            NSBlockOperation *fetch_vCard = [NSBlockOperation blockOperationWithBlock:^{
                
                [self getVcard:[user jid]];
            }];
            
            
            [que_t addOperation:fetch_vCard];
        }
        
    }
    
    [self.managedObjectContext_roster save:nil];
}

/**
 * Sent when the initial roster is received.
 **/
- (void)xmppRosterDidBeginPopulating:(XMPPRoster *)sender
{
    // NSLog(@"xmppRosterDidBeginPopulating.......%@",sender);
}

/**
 * Sent when the initial roster has been populated into storage.
 **/
- (void)xmppRosterDidEndPopulating:(XMPPRoster *)sender
{
    
    
}


- (void)xmppRoster:(XMPPRoster *)sender didReceiveRosterItem:(NSXMLElement *)item
{
    
    
    
    
}


#pragma mark - XMPP Reconnection

- (void)xmppReconnect:(XMPPReconnect *)sender didDetectAccidentalDisconnect:(SCNetworkReachabilityFlags)connectionFlags
{
    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                      operation:@"__XLC_XMPPStreamLifeCycle__"
                                        Content:@""
                                      parameter:@""];
    
    [AppData sendLocalNotificationForNotConnected];
    
    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                      operation:@"XMPPREACHABILITY"
                                        Content:@"Not Connected"
                                      parameter:@""];
}


- (BOOL)xmppReconnect:(XMPPReconnect *)sender shouldAttemptAutoReconnect:(SCNetworkReachabilityFlags)reachabilityFlags
{
    
    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                      operation:@"__XLC_XMPPStreamLifeCycle__"
                                        Content:@""
                                      parameter:@""];
    
    NSLog(@"shouldAttemptAutoReconnect %d",reachabilityFlags);
    
    return YES;
}

#pragma mark - XMPP Room

- (void)xmppRoomDidCreate:(XMPPRoom *)sender
{
    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                      operation:@"Leo_Room"
                                        Content:[NSString stringWithFormat:@"%@",sender]
                                      parameter:@""];
}


- (void)xmppRoom:(XMPPRoom *)sender didFetchConfigurationForm:(NSXMLElement *)configForm;
{
    XMPPRoomObject *room = [self fetchOrInsertRoom:sender];
    
    
    NSXMLElement *newConfig = [configForm copy];
    
    
    NSArray *fields = [newConfig elementsForName:@"field"];
    
    
    for (NSXMLElement *field in fields)
    {
        NSString *var = [field attributeStringValueForName:@"var"];
        
        
        if ([var isEqualToString:@"muc#roomconfig_roomname"])
        {
            room.name = [[field elementForName:@"value"] stringValue];
        }
        
        
        if ([var isEqualToString:@"muc#roomconfig_roomowners"])
        {
            XMPPRoomAffaliations *owner = [[room.members filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"memberJidStr=%@", [[field elementForName:@"value"] stringValue]]] anyObject];
            
            
            if (owner == nil)
            {
                owner = [NSEntityDescription insertNewObjectForEntityForName:@"XMPPRoomAffaliations" inManagedObjectContext:self.managedObjectContext_roster];
                
                owner.memberJidStr = [[XMPPJID jidWithString:[[field elementForName:@"value"] stringValue]] bare];
            }
            
            
            owner.roomJidStr = sender.roomJID.bare;
            
            owner.role = @"owner";
            
            
            [room addMembersObject:owner];
        }
    }
    
    
    [self.managedObjectContext_roster save:nil];
}


- (void)xmppRoom:(XMPPRoom *)sender willSendConfiguration:(XMPPIQ *)roomConfigForm
{
    
}


- (void)xmppRoom:(XMPPRoom *)sender didConfigure:(XMPPIQ *)iqResult
{
    
}


- (void)xmppRoom:(XMPPRoom *)sender didNotConfigure:(XMPPIQ *)iqResult
{
    
}


- (void)xmppRoomDidJoin:(XMPPRoom *)sender
{
    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                      operation:@"leo_RoomJoin"
                                        Content:[NSString stringWithFormat:@"%@",[sender.roomJID bare]]
                                      parameter:@""];
    
    [joinRoomQue addOperationWithBlock:^{
        
        
        [sender fetchModeratorsList];
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        XMPPRoomObject *room = [self fetchOrInsertRoom:sender];
        
        
        ChatMessage * lastUnsentMessage=[ChatMessage getLastFailedMessageForJID:room.room_jidStr];
        
        if(lastUnsentMessage)
        {
            [self resendGroupMessage:lastUnsentMessage];
            
        }
        
        if ([[self.roomsArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"room_jidStr=%@", [sender.roomJID bare]]] count] == 0)
        {
            [self.roomsArr addObject:room];
        }
        
        
        if (self.roomfromPush != nil)
        {
            if ([[sender.roomJID bare] isEqualToString:self.roomfromPush.room_jidStr])
            {
                if ([self.navController.visibleViewController isKindOfClass:[ChatViewController class]])
                {
                    ChatViewController *chatController  = (ChatViewController *)[self.navController visibleViewController];
                    
                    chatController.room                 = sender;
                    
                    chatController.roomObj              = room;
                    
                    chatController.isGroupChat          = YES;
                    
                    chatController.forChat              = YES;
                    
                    chatController.jid                  = room.room.roomJID;
                }
                
                else
                {
                    ChatViewController *chatController  = [[ChatViewController alloc] initWithNibName:@"ChatViewController" bundle:nil];
                    
                    chatController.room                 = sender;
                    
                    chatController.roomObj              = room;
                    
                    chatController.isGroupChat          = YES;
                    
                    chatController.forChat              = YES;
                    
                    chatController.jid                  = room.room.roomJID;
                    
                    
                    [self.navController pushViewController:chatController animated:YES];
                }
                
                
                self.jidFromPushToStartChat = nil;
                
                
                self.roomfromPush = nil;
            }
        }
    });
    
    
}


- (void)xmppRoomDidDestroy:(XMPPRoom *)sender
{
    
    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                      operation:@"Leo_RoomDestroy"
                                        Content:[NSString stringWithFormat:@"%@",[sender.roomJID bare]]
                                      parameter:@""];
    
    NSArray *left_room = [self.roomsArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"room_jidStr=%@", [sender.roomJID bare]]];
    
    
    [self.roomsArr removeObjectsInArray:left_room];
    
    
    for (XMPPRoomObject *room in left_room)
    {
        room.room_status = @"deleted";
    }
    
    
    [self.managedObjectContext_roster save:nil];
}


- (void)xmppRoomDidLeave:(XMPPRoom *)sender
{
    NSArray *left_room = [self.roomsArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"room_jidStr=%@", [sender.roomJID bare]]];

    if (left_room) {
        [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                          operation:@"leo_RoomLeave"
                                            Content:[NSString stringWithFormat:@"RoomJID %@ array Count>> %lu roomsArr >> %lu",[sender.roomJID bare],(unsigned long)left_room.count,self.roomsArr.count]
                                          parameter:@" Check Count Of array "];
        
        if (left_room.count>0 && self.roomsArr.count>0)
        {
            
            [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                              operation:@"Room•••••Left"
                                                Content:[NSString stringWithFormat:@"RoomJID %@ array Count>> %lu roomsArr >> %lu",[sender.roomJID bare],(unsigned long)left_room.count,self.roomsArr.count]
                                              parameter:@" Check Count Of array "];
            
            if([left_room lastObject]!=nil)
                [self.roomsArr removeObject:[left_room lastObject]];
            
            
        }
    }
}


- (void)xmppRoom:(XMPPRoom *)sender didReceiveMessage:(XMPPMessage *)message fromNick:(NSString *)nick
{
    
}


- (void)xmppRoom:(XMPPRoom *)sender occupantDidJoin:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence
{
    
}


- (void)xmppRoom:(XMPPRoom *)sender occupantDidLeave:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence
{
    
}


- (void)xmppRoom:(XMPPRoom *)sender occupantDidUpdate:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence
{
    
}


- (void)xmppRoom:(XMPPRoom *)sender didReceiveMessage:(XMPPMessage *)message fromOccupant:(XMPPJID *)occupantJID
{
    
//    if(TARGET_IPHONE_SIMULATOR)
//        NSLog(@"....didReceiveMessage fromOccupant message %@",message);
        
    return;
    
    
}


- (void)xmppRoom:(XMPPRoom *)sender didFetchBanList:(NSArray *)items
{
    
}


- (void)xmppRoom:(XMPPRoom *)sender didNotFetchBanList:(XMPPIQ *)iqError
{
    
}


- (void)xmppRoom:(XMPPRoom *)sender didFetchMembersList:(NSArray *)items
{
//    NSError *error = nil;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        XMPPRoomObject *roomObj = [self fetchOrInsertRoom:sender];
        
        
        for (XMPPRoomAffaliations * member in roomObj.members)
        {
            if (![member.role isEqualToString:@"owner"])
            {
                member.role = @"none";
            }
        }
        if([self.managedObjectContext_roster hasChanges])
            [self.managedObjectContext_roster save:nil];
        
        
        
        for (NSXMLElement *element in items)
        {
            
            [self.managedObjectContext_roster lock];
            
            XMPPRoomAffaliations *user = [[[roomObj.members filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"memberJidStr=%@", [[XMPPJID jidWithString:[element attributeStringValueForName:@"jid"]] bare]] ] allObjects] lastObject];
            
            
            if (user == nil)
            {
                user = [NSEntityDescription insertNewObjectForEntityForName:@"XMPPRoomAffaliations" inManagedObjectContext:self.managedObjectContext_roster];
                
                user.memberJidStr = [[XMPPJID jidWithString:[element attributeStringValueForName:@"jid"]] bare];
                
                user.roomJidStr = [[sender roomJID] bare];
                
                
                [roomObj addMembersObject:user];
                
                if([self.managedObjectContext_roster hasChanges])
                    [self.managedObjectContext_roster save:nil];
            }
            
            
            user.role = [element attributeStringValueForName:@"affiliation"];
            
            [self.managedObjectContext_roster unlock];
        }
        
        if([self.managedObjectContext_roster hasChanges])
            [self.managedObjectContext_roster save:nil];
        
        
    });
    
    
}


- (void)xmppRoom:(XMPPRoom *)sender didNotFetchMembersList:(XMPPIQ *)iqError
{
    
}


- (void)xmppRoom:(XMPPRoom *)sender didFetchModeratorsList:(NSArray *)items
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        XMPPRoomObject *roomObj = [self fetchOrInsertRoom:sender];
        
        
        for (XMPPRoomAffaliations *member in roomObj.members)
        {
            if ([member.role isEqualToString:@"owner"])
            {
                member.role = @"none";
            }
        }
        
        
        NSError *error = nil;
        
        
        
        if([self.managedObjectContext_roster hasChanges])
            [self.managedObjectContext_roster save:nil];
        
        
        for (NSXMLElement *element in items)
        {
            
            [self.managedObjectContext_roster lock];
            XMPPRoomAffaliations *user = [[[roomObj.members filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"memberJidStr=%@", [[XMPPJID jidWithString:[element attributeStringValueForName:@"jid"]] bare]] ] allObjects] lastObject];
            
            
            if (user == nil)
            {
                user = [NSEntityDescription insertNewObjectForEntityForName:@"XMPPRoomAffaliations" inManagedObjectContext:self.managedObjectContext_roster];
                
                user.memberJidStr = [[XMPPJID jidWithString:[element attributeStringValueForName:@"jid"]] bare];
                
                user.roomJidStr = [[sender roomJID] bare];
                
                
                [roomObj addMembersObject:user];
                
                if([self.managedObjectContext_roster hasChanges])
                    [self.managedObjectContext_roster save:nil];
            }
            
            
            user.role = [element attributeStringValueForName:@"affiliation"];
            
            error = nil;
            dispatch_async(dispatch_get_main_queue(), ^{
                if([self.managedObjectContext_roster hasChanges])
                    [self.managedObjectContext_roster save:nil];
            });
            [self.managedObjectContext_roster unlock];
            
        }
        
        
        [que_t addOperationWithBlock:^{
            
            [sender fetchMembersList];
        }];
        
        
        
        
    });
}


- (void)xmppRoom:(XMPPRoom *)sender didNotFetchModeratorsList:(XMPPIQ *)iqError
{
    [que_t addOperationWithBlock:^{
        
        [sender fetchMembersList];
        
        
    }];
}


- (void)xmppRoom:(XMPPRoom *)sender didEditPrivileges:(XMPPIQ *)iqResult
{
    
}


- (void)xmppRoom:(XMPPRoom *)sender didNotEditPrivileges:(XMPPIQ *)iqError
{
    
}


- (void)xmppRoom:(XMPPRoom *)sender didfetchInfo:(XMPPIQ *)info
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if(info==nil)
            return ;
        
        
        XMPPRoomObject *roomObj = [self fetchRoom:[[info from] bare]];
        
        [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:[NSString stringWithFormat:@"KstateTransferArrayUpdateNotification"] object:nil  userInfo:nil];
        
        
        NSLog(@"ROOM OBJECT......%@",roomObj);
        
        if(roomObj==nil)
            return ;
        
        
        
        if ([[info type] isEqualToString:@"error"] == NO)
        {
            NSXMLElement *query = [info elementForName:@"query"];
            
            NSString *name = [[query elementForName:@"identity"] attributeStringValueForName:@"name"];
            
            NSString *subject = @"";
            
            
            NSArray *fields = [[query elementForName:@"x"] elementsForName:@"field"] ;
            
            
            for (NSXMLElement *field in fields )
            {
                if ([[field attributeStringValueForName:@"var"] isEqualToString:@"muc#roominfo_subject"])
                {
                    subject = [[field elementForName:@"value"] stringValue];
                }
            }
            
            
            roomObj.name = name;
            
            roomObj.room_status = @"active";
            
            roomObj.subject = subject;
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if([self.managedObjectContext_roster hasChanges])
                    [self.managedObjectContext_roster save:nil];
            });
            
            
            if (![self.roomsArr containsObject:roomObj])
            {
                
                
                
                if (![roomObj.room_status isEqualToString:@"deleted"])
                {
                    
                    //Removed by Ronald for auto-room join
                    /*
                    [que_t addOperationWithBlock:^{
                        
                        
                        NSLog(@"JOINING ROOM......\nRoom Name  %@ ...%@",roomObj.room_jidStr,roomObj.lastMessageDate);
                        NSXMLElement * history=nil;//;
                        
                        
                        
                        history=[NSXMLElement elementWithName:@"history"];
                        if(roomObj.lastMessageDate==nil)
                            return ;
                        
                        NSString * seconds=[NSString stringWithFormat:@"%ld",(long)[[NSDate date] timeIntervalSinceDate:roomObj.lastMessageDate]+50];
                        
                        if([seconds intValue]<30)
                        {
                            seconds=@"30";
                        }
                        
                        [history addAttributeWithName:@"seconds" stringValue:seconds];
                        
                        NSLog(@"JOINING ROOM WITH ... \nRoom Name: %@\nHistory: %@\nSeconds : %@",sender.roomJID,history,seconds);
                        
                        [sender joinRoomUsingNickname:self.xmppStream.myJID.user history:history];
                    }];
                     */
                }
                
                
                
            }
        }
        
        else
        {
            
            if([[self xmppStream] isAuthenticated]==NO)
            {
                
                if([[self xmppStream] isAuthenticating]==NO)
                {
                    if([[self xmppStream] isConnected])
                    {
                        NSError *error=nil;
                        
                        if (![[self xmppStream] authenticateWithPassword:[AppData appData].XMPPmyJIDPassword error:&error])
                        {
                            [AppData sendLocalNotificationForNotConnected];
                            
                            [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                                              operation:@"XMPPREACHABILITY"
                                                                Content:@"Not Connected"
                                                              parameter:@""];
                        }
                        
                        else
                        {
                            [AppData sendLocalNotificationForSecurelyConnected];
                            
                            [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                                              operation:@"XMPPREACHABILITY"
                                                                Content:@"Securely Connected"
                                                              parameter:@""];
                            
                        }
                    }
                }
                return;
            }
            
            roomObj.room_status = @"deleted";
            
            
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ChatMessage"];
            
            request.predicate = [NSPredicate predicateWithFormat:@"uri=%@", [sender.roomJID bare]];
            
            
            NSArray *messagesForRoom = [[AppDel managedObjectContext_roster] executeFetchRequest:request error:nil];
            
            
            for (NSManagedObject * message in messagesForRoom)
            {
                [[AppDel managedObjectContext_roster] deleteObject:message];
            }
            
            
            [[AppDel managedObjectContext_roster] save:nil];
            
            
            [[RDCallbackAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"%@ group has been deleted by admin", roomObj.name] cancelButtonTitle:@"OK" andCompletionHandler:^(int ok) {
                
                [self.navController popToViewController:self.homeView animated:YES];
                
            } otherButtonTitles: nil];
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if([self.managedObjectContext_roster hasChanges])
                    [self.managedObjectContext_roster save:nil];
            });
        }
        
    });
    
    
    
}


- (void)xmppRoom:(XMPPRoom *)sender didAddMember:(XMPPIQ *)info
{
    if ([[info type] isEqualToString:@"error"])
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Unable to process the request due to server error." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }
    
    else
    {
        [que_t addOperationWithBlock:^{
            
            [sender fetchModeratorsList];
        }];
    }
}


- (void)xmppMUC:(XMPPMUC *)sender roomJID:(XMPPJID *) roomJID didReceiveInvitation:(XMPPMessage *)message
{
    [que_t addOperationWithBlock:^{
        
        XMPPRoom *room = [[XMPPRoom alloc] initWithRoomStorage:[XMPPRoomMemoryStorage sharedInstanse] jid:roomJID];
        
        
        XMPPRoomObject*obj_temp= [self fetchOrInsertRoom:room];
        
        obj_temp.streamJidStr=[AppDel myJID];
        obj_temp.room_status=@"Active";
        
        NSXMLElement *deleayElement = [message elementForName:@"delay" xmlns:@"urn:xmpp:delay"];
        
        
        NSDate *dateOfMessage = nil;
        
        
        if (deleayElement != nil)
        {
            dateOfMessage = [XMPPDateTimeProfiles parseDateTime:[deleayElement attributeStringValueForName:@"stamp"]];
        }
        
        
        if (dateOfMessage == nil)
        {
            //code to fetch all the messages
            dateOfMessage = [NSDate dateWithTimeIntervalSinceNow:-140];
        }
        
        
        obj_temp.lastMessageDate=dateOfMessage;
        obj_temp.creationDate=obj_temp.lastMessageDate;
        [self.managedObjectContext_roster save:nil];
        
        
        //code to updateRoxin  last date
        [room activate:[self xmppStream]];
        
        
        [room fetchConfigurationForm];
        
        [room addDelegate:self delegateQueue:xmppDelegateQueue];
        
        NSXMLElement * history=nil;
        
        [room joinRoomUsingNickname:xmppStream.myJID.user history:history];
        
        [room fetchRoomInfo];
    }];
    
    
    
}


- (void)xmppMUC:(XMPPMUC *)sender roomJID:(XMPPJID *) roomJID didReceiveInvitationDecline:(XMPPMessage *)message
{
    
}




#pragma mark vCard


- (void)xmppvCardTempModuleDidUpdateMyvCard:(XMPPvCardTempModule *)vCardTempModule
{
    
    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                      operation:@"__XLC_XMPPStreamLifeCycle__"
                                        Content:@""
                                      parameter:@""];
    
    if([self.image isEqual:[UIImage imageWithData:[[vCardTempModule myvCardTemp] photo]]]==NO)
    {
        /* NSXMLElement *x = [NSXMLElement elementWithName:@"x" stringValue:@"vcard-temp:x:update"];
         
         [x addAttributeWithName:@"xmlns" stringValue:@"vcard-temp:x:update"];
         
         XMPPPresence *myPresence = [XMPPPresence presence];
         
         [myPresence addChild:x];
         
         [self.xmppStream sendElement:myPresence];*/
        
        self.image=[UIImage imageWithData:[[vCardTempModule myvCardTemp] photo]];
    }
    
}

- (void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule failedToUpdateMyvCard:(NSXMLElement *)error
{
    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                      operation:@"__XLC_XMPPStreamLifeCycle__"
                                        Content:@""
                                      parameter:@""];
    
    
    [[[UIAlertView alloc] initWithTitle:nil message: @"Sorry ! We are unable to upload the profile picture. Try agin later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
}


#pragma mark - Autoping

- (void)xmppAutoPingDidSendPing:(XMPPAutoPing *)sender
{
    //NSLog(@" ... xmppAutoPingDidSendPing");
    
    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                      operation:@"__XLC_XMPPStreamLifeCycle__"
                                        Content:@""
                                      parameter:@""];
    
    //  self.appIsDisconnected=YES;
}


- (void)xmppAutoPingDidReceivePong:(XMPPAutoPing *)sender
{
    //NSLog(@" ... xmppAutoPingDidReceivePong");
    //    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__] operation:@"__XLC_XMPPStreamLifeCycle__" Content:@"" parameter:@""];
    
    
    self.appIsDisconnected=NO;
    if([xmppStream isAuthenticated])
    {
        [AppData sendLocalNotificationForSecurelyConnected];
    }
    
    pingTimeOuts=0;
}


- (void)xmppAutoPingDidTimeout:(XMPPAutoPing *)sender
{
    NSLog(@" ... xmppAutoPingDidTimeout");
    
    //    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__] operation:@"__XLC_XMPPStreamLifeCycle__" Content:@"" parameter:@""];
    
    
    self.appIsDisconnected=YES;
    
    pingTimeOuts++;
    
    NSLog(@"....pingTimeOuts %d",pingTimeOuts);
    
    if(pingTimeOuts>4)
    {
        //  if([self appIsDisconnected]==no)
        //  [self.xmppReconnect manualStart];
        
        [AppData sendLocalNotificationForNotConnected];
        pingTimeOuts=0;
    }
}


#pragma mark - XMPP Testing

- (void)getVcard:(XMPPJID *)jid
{
    NSXMLElement *queryElement = [NSXMLElement elementWithName: @"query" xmlns: @"jabber:iq:roster"];
    
    
    NSXMLElement *iq = [NSXMLElement elementWithName: @"iq"];
    
    
    NSXMLElement *vcard = [NSXMLElement elementWithName:@"vCard"];
    
    [vcard addAttributeWithName:@"xmlns" stringValue:@"vcard-temp"];
    
    
    [iq addChild:vcard];
    
    [iq addAttributeWithName: @"type" stringValue: @"get"];
    
    [iq addAttributeWithName:@"id" stringValue:[NSString stringWithFormat:@"vc%d", (int)[[NSDate date] timeIntervalSince1970]]];
    
    [iq addAttributeWithName:@"from" stringValue:self.xmppStream.myJID.bare];
    
    [iq addAttributeWithName:@"to" stringValue:jid.bare];
    
    [iq addChild: queryElement];
    
    
    [self.xmppStream sendElement: iq];
}




- (VCard *)fetchVCard:(XMPPJID *)jid
{
    [self.managedObjectContext_roster lock];
    
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"VCard"];
    
    request.predicate = [NSPredicate predicateWithFormat:@"userJID=%@ and streamJID=%@", [jid bare], self.myJID];
    
    
    VCard *vcard = [[self.managedObjectContext_roster executeFetchRequest:request error:nil] lastObject];
    
    
    if (vcard == nil)
    {
        vcard = [NSEntityDescription insertNewObjectForEntityForName:@"VCard" inManagedObjectContext:self.managedObjectContext_roster];
        
        vcard.userJID = [jid bare];
        
        vcard.streamJID = self.myJID;
        
        [self.managedObjectContext_roster save:nil];
    }
    
    
    [self.managedObjectContext_roster unlock];
    
    
    return  vcard;
}


- (void)setImage:(UIImage *)image
{
    if (image != nil)
    {
        
        if([image isEqual:[UIImage imageNamed:@"Profile"]])
        {
            return;
        }
        NSData *imageData = UIImageJPEGRepresentation(image, 1);
        
        
        NSString *imagePath = [self documentsPathForFileName:@"profile.jpg"];
        
        
        [imageData writeToFile:imagePath atomically:YES];
        
        
        [[NSUserDefaults standardUserDefaults] setObject:imagePath forKey:@"image"];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}


- (UIImage *)image
{
    NSString *imagePath = [[NSUserDefaults standardUserDefaults] objectForKey:@"image"];
    
    
    if (imagePath)
    {
        return [UIImage imageWithData:[NSData dataWithContentsOfFile:imagePath]];
    }
    else
    {
        return [UIImage imageNamed:@"Profile"];
    }
}


- (NSString *)documentsPathForFileName:(NSString *)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    
    NSString *documentsPath = [paths objectAtIndex:0];
    
    
    return [documentsPath stringByAppendingPathComponent:name];
}

-(void)update_pending_Request_count
{
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"loginToken"])
    {
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:BASE_URL]];
        
        [request setValidatesSecureCertificate:NO];
        
        
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"getRequestCount", @"method", [[NSUserDefaults standardUserDefaults] objectForKey:@"loginToken"], @"login_token", nil];
        
        
        request.postBody = [[NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil] mutableCopy];
        
        
        __weak ASIHTTPRequest *req = request;
        
        
        [request setFailedBlock:^{
            
        }];
        
        [request setCompletionBlock:^{
            
            NSDictionary *respDict = [NSJSONSerialization JSONObjectWithData:req.responseData options:NSJSONReadingMutableContainers error:nil];
            
            
            
            
            
            if([[respDict objectForKey:@"err-code"] intValue]==1)
            {
                self.request_count=[[respDict objectForKey:@"count"] intValue];
                
                if([self.navController.visibleViewController respondsToSelector:@selector(updateMessagCount)])
                {
                    [self.navController.visibleViewController performSelectorOnMainThread:@selector(updateMessagCount) withObject:nil waitUntilDone:YES];
                }
            }
            if([[respDict objectForKey:@"err-code"] intValue]==600)
            {
                [AppDel signOutFromAppSilent];
                [[RDCallbackAlertView alloc] initWithTitle:nil message:[respDict objectForKey:@"message"] cancelButtonTitle:nil andCompletionHandler:^(int btnIndex)
                 
                 {
                     
                     
                 } otherButtonTitles:@"OK", nil];
                
            }
            else
            {
                
            }
        }];
        
        
        [request startAsynchronous];
        
    }
    
}


-(OfflineContact *)fetchInsertExternamContact:(NSString *)streamJID phoneNo:(NSString *)phoneNo email:(NSString *)email firstName:(NSString *)firstName lastName:(NSString *)lastName
{
    if (email==nil)
    {
        email=@"";
    }
    if (phoneNo==nil) {
        phoneNo=@"";
    }
    
    
    OfflineContact * contact=nil;
    
    NSError * error=nil;
    NSFetchRequest * request=[NSFetchRequest fetchRequestWithEntityName:@"OfflineContact"];
    
    request.predicate=[NSPredicate predicateWithFormat:@"streamJID=%@ AND phoneNo=%@ AND emailID=%@",streamJID,phoneNo,email];
    NSArray * array=[self.managedObjectContext_roster executeFetchRequest:request error:&error];
    contact=[array lastObject];
    
    if(contact==nil)
    {
        contact=[NSEntityDescription insertNewObjectForEntityForName:@"OfflineContact" inManagedObjectContext:self.managedObjectContext_roster];
        contact.streamJID=(streamJID==nil?@"":streamJID);
        contact.firstName=(firstName==nil?@"":firstName);
        contact.lastName=(lastName==nil?@"":lastName);
        contact.emailID=(email==nil?@"":email);
        contact.phoneNo=(phoneNo==nil?@"":phoneNo);
        
        
        NSError *error2=nil;
        if([self.managedObjectContext_roster hasChanges])
            [self.managedObjectContext_roster save:&error2];
        
        if (error2) {
            NSLog(@"FetchInsertExternamContact ERROR.....%@",error2);
        }
        
        
    }
    
    
    return  contact;
    
}

-(InboxMessage *)fetchLastInboxMessage
{
    InboxMessage * message=nil;
    
    NSFetchRequest * req=[NSFetchRequest fetchRequestWithEntityName:@"InboxMessage"];
    
    NSSortDescriptor *lastUpdatedDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"lastUpdated"
                                                                            ascending:NO];
    req.sortDescriptors = @[lastUpdatedDescriptor];
    
    message=[[self.managedObjectContext_roster executeFetchRequest:req error:nil] firstObject];
    
    return message;
}


-(InboxMessage *)fetchInboxMessage:(NSString *)jid
{
    InboxMessage * message=nil;
    
    
    NSFetchRequest * req=[NSFetchRequest fetchRequestWithEntityName:@"InboxMessage"];
    
    req.predicate=[NSPredicate predicateWithFormat:@"jidStr=%@",jid];
    
    message=[[self.managedObjectContext_roster executeFetchRequest:req error:nil] lastObject];
    
    return message;
}

-(InboxMessage *)insertInboxMessage:(NSString *)jid
{
    InboxMessage * message=nil;
    
    message=[NSEntityDescription insertNewObjectForEntityForName:@"InboxMessage" inManagedObjectContext:self.managedObjectContext_roster];
    message.jidStr=jid;
    
    message.dateCreation=[NSDate date];
    
    [self.managedObjectContext_roster save:nil];
    
    return message;
}

-(InboxMessage *)fetchOrInsertMessage:(NSString *)jid
{
    
    InboxMessage * message=nil;
    
    message = [self fetchInboxMessage:jid];
    
    if(message == nil)
        message = [self insertInboxMessage:jid];

    return message;
}

-(void)migrationOfChatMessageToInboxMessage
{
    
    NSFetchRequest * req=[NSFetchRequest fetchRequestWithEntityName:@"ChatMessage"];
    req.predicate=[NSPredicate predicateWithFormat:@"mark_deleted=='0'"];
    req.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"timeStamp" ascending:NO]];
    
    NSArray *arr_chatMessage=[self.managedObjectContext_roster executeFetchRequest:req error:nil];
    
    NSLog(@"%@",arr_chatMessage);
    
    for (ChatMessage*message in  arr_chatMessage ) {
        [self addInboxMessage:message];
        //            [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__] operation:@"check Message State" Content:message.messageID parameter:[ChatMessage ChatTypeToStr:message.chatState.intValue]];
        
    }
}


-(NSArray *)fetchChatMessageOfNoneReceiverStatus  // fetch message for send delivery status to server.
{
    
    NSFetchRequest * req=[NSFetchRequest fetchRequestWithEntityName:@"ChatMessage"];
    req.predicate=[NSPredicate predicateWithFormat:@"chatState='99'"];
    
    
    NSArray *arr_chatMessage=[self.managedObjectContext_roster executeFetchRequest:req error:nil];
    
    NSLog(@"%@",arr_chatMessage);
    
    
    return arr_chatMessage;
}

#pragma mark - Inbox Message Handling
-(void)addInboxMessage:(ChatMessage *)message
{
    // If inbox message is still in fetching.
    if ([[AppData appData] isAllInboxMessagesFetched]){
        return;
    }
    
    // If message is group message, go to the group message handling
    if (message.isRoomMessage.boolValue) {
        [self addInboxMessageGroupChat:message];
        return;
    }
    
    if (message.chatMessageTypeOf.integerValue == ChatMessageType_Broadcast) {
        [self addBcInboxMessage:message];
        return;
    }
    
    //Handle the message add to the Inbox Message
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.managedObjectContext_roster lock];
        
        InboxMessage * msg = nil;
        NSString *strjID;
        strjID = message.uri;
        
        //Check if InboxMessage is already existing
        msg = [self fetchInboxMessage:strjID];
        if (msg == nil) { //If Inbox message is not existing...
            
            InboxMessage *lastInboxMsg = [self fetchLastInboxMessage];
            if (lastInboxMsg) {  //If old message, it should be skipped
                if (lastInboxMsg.lastUpdated && message.timeStamp
                    && [lastInboxMsg.lastUpdated compare:message.timeStamp] == NSOrderedDescending)
                    return;
            }

            msg = [self insertInboxMessage:strjID];
            
            if (msg == nil)  // Exception Error
                return;
        }
        
        [msg addMessageObject:message];
        
        msg.lastUpdated=message.timeStamp;
        msg.messageType=message.isRoomMessage;
        msg.user=[self fetchUserForJIDString:message.uri];
        
        NSError *error2=nil;
        if([self.managedObjectContext_roster hasChanges])
            [self.managedObjectContext_roster save:&error2];
        
        [self.managedObjectContext_roster unlock];
        
        if (error2)
            NSLog(@"Error after managedObjectContact_roster.....%@",error2);
        
    });
    
}

-(InboxMessage*)addInboxMessageGroupChat:(ChatMessage *)message
{
    // If inbox message is still in fetching.
    if ([[AppData appData] isAllInboxMessagesFetched]){
        return nil;
    }
    
    // If message is group message, go to the handling of one-one message
    if (!message.isRoomMessage.boolValue) {
        [self addInboxMessage:message];
        return nil;
    }
    
    InboxMessage * msg= nil;
    
    if (message) {
        
        [self.managedObjectContext_roster lock];
        
        NSString *strjID = message.uri;
        
        msg = [self fetchInboxMessage:strjID];
        if (msg == nil) { //If Inbox message is not existing...
            InboxMessage *lastInboxMsg = [self fetchLastInboxMessage];
            if (lastInboxMsg) {  //If old message, it should be skipped
                if (lastInboxMsg.lastUpdated && message.timeStamp
                    && [lastInboxMsg.lastUpdated compare:message.timeStamp] == NSOrderedDescending)
                    return nil;
            }
            
            msg = [self insertInboxMessage:strjID];
            
            if (msg == nil)  // Exception Error
                return nil;
            
            msg.lastUpdated=message.timeStamp;
            msg.messageType=message.isRoomMessage;
            
            msg.room=[self fetchRoom:message.uri];
            if(msg.room == nil)
            {
                XMPPJID *fromJid = [XMPPJID jidWithString:message.uri];
                msg.room = [self fetchOrInsertRoom:[[XMPPRoom alloc] initWithRoomStorage:[XMPPRoomMemoryStorage sharedInstanse] jid:fromJid]];
            }
            else
            {
                if (msg.room.streamJidStr == nil)
                    NSLog(@"%@",msg.room);
            }
            msg.oldMessageCount =[NSNumber numberWithInt:-1];
            msg.isLoadingCompleteInGroupChat =NO;
            msg.chatMessageTypeOf=[NSNumber numberWithInt:ChatMessageType_Group];
        }
        
        [msg addMessageObject:message];
        
        NSError *error2=nil;
        if([self.managedObjectContext_roster hasChanges])
            [self.managedObjectContext_roster save:&error2];
        
        [self.managedObjectContext_roster unlock];
        
        if(error2)
            NSLog(@"AddInboxMessageGroupChat Error.....%@",error2);
        
    }
    
    return msg;
}

- (BOOL)addChatMessage:(ChatMessage*)message toInboxMessage:(InboxMessage*)inboxMessage{
    if (message == nil)
        return NO;
    
    if (inboxMessage == nil)
        return NO;
    
    if (message.isRoomMessage.boolValue &&
        inboxMessage.chatMessageTypeOf.integerValue != ChatMessageType_Group)
        return NO;
    
    if (!message.isRoomMessage.boolValue &&
        inboxMessage.chatMessageTypeOf.integerValue != ChatMessageType_Simple)
        return NO;
    
    [self.managedObjectContext_roster lock];
    [inboxMessage addMessageObject:message];
    
    NSError *error2=nil;
    if([self.managedObjectContext_roster hasChanges])
        [self.managedObjectContext_roster save:&error2];
    
    if(error2){
        NSLog(@"AddInboxMessageGroupChat Error.....%@",error2);
        return NO;
    }
    
    [self.managedObjectContext_roster unlock];
    
    return YES;
    
}
-(InboxMessage*)addInboxMessageWithThreadModel:(ThreadContentModel*)threadContentModel
{
    //Apply the lock to the Core Data storage
    [self.managedObjectContext_roster lock];
    
    //---------------- Create the Inbox Message ----------------
    InboxMessage * msg= nil;
    
    
    NSString *jidStr;
    
    if ([threadContentModel.type isEqualToString:@"ONE_TO_ONE"]){  //-----------------  Private OneToOne Chat---------------------- //
        //Create the InboxMessage Object
        jidStr = [NSString stringWithFormat:@"%@@imyourdoc.com", threadContentModel.users.firstObject.username];
        msg= [self fetchOrInsertMessage:jidStr];
        
        msg.messageType = [NSNumber numberWithInt:0];
        msg.chatMessageTypeOf=[NSNumber numberWithInt:ChatMessageType_Simple];
        
        //Add user to the chat
        msg.user = [self fetchUserForJIDString:jidStr];
    }
    else if ([threadContentModel.type isEqualToString:@"ROOM"]){ //-----------------  Group Chat ---------------------- //
        //Create the InboxMessage Object
        jidStr = [NSString stringWithFormat:@"%@@newconversation.imyourdoc.com", threadContentModel.name];
        msg= [self fetchOrInsertMessage:jidStr];
        
        msg.messageType = [NSNumber numberWithInt:1];
        msg.chatMessageTypeOf=[NSNumber numberWithInt:ChatMessageType_Group];
        msg.isLoadingCompleteInGroupChat = NO;
        
        //Add Room Info to the InboxMessage object
        msg.room = [self fetchRoom:jidStr];
        if(msg.room == nil)
        {
            XMPPJID *fromJid = [XMPPJID jidWithString:jidStr];
            msg.room = [self fetchOrInsertRoom:[[XMPPRoom alloc] initWithRoomStorage:[XMPPRoomMemoryStorage sharedInstanse] jid:fromJid]];
        }
        
        msg.room.name = threadContentModel.naturalName;
    }
    else { //-----------------  Broadcast ---------------------- //
        return nil;
    }
    
    //Add some information to the created InboxMessage object
    msg.lastUpdated = threadContentModel.lastMessage.timestamp;
    msg.oldMessageCount =[NSNumber numberWithInt:-1];
//    [msg setNmberOfUnReadMessages:threadContentModel.unreadCount];
    
    //Save to the Core Data
    NSError *error = nil;
    if([self.managedObjectContext_roster hasChanges])
        [self.managedObjectContext_roster save:&error];
    
    //Release the lock of Core Data Storage
    [self.managedObjectContext_roster unlock];
    
    //Print out the error for core data storage saving action
    if(error) {
        NSLog(@"AddInboxMessageGroupChat Error.....%@",error);
        return nil;
    }
    
    return msg;
    
}



-(void)addBcInboxMessage:(ChatMessage *)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        
        [self.managedObjectContext_roster lock];
        
        InboxMessage * msg=[self fetchOrInsertMessage:message.thumb];
        msg.chatMessageTypeOf=message.chatMessageTypeOf;
        msg.messageType=[NSNumber numberWithBool:false];
        msg.lastUpdated=message.timeStamp;
        [msg addMessageObject:message];
        
        
        NSError *error2=nil;
        [[AppDel managedObjectContext_roster] save:nil];
        
        if([self.managedObjectContext_roster hasChanges])
            [self.managedObjectContext_roster save:&error2];
        
        [self.managedObjectContext_roster unlock];
        
        if (error2)
            NSLog(@"AddBCInboxMessage ERROR.....%@",error2);
        
    });
    
    
    
    
}

- (void) getRoster
{
    
    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                      operation:@"getRoster•••••••••••"
                                        Content:@"•••••••••••"
                                      parameter:@"SEE HOW MANY TIME IT IS CALL"];
    
    NSXMLElement *queryElement = [NSXMLElement elementWithName: @"query" xmlns: @"jabber:iq:roster"];
    
    
    NSXMLElement *iq = [NSXMLElement elementWithName: @"iq"];
    
    [iq addAttributeWithName: @"type" stringValue: @"get"];
    
    [iq addChild: queryElement];
    
    
    [self.xmppStream sendElement: iq];
}

#pragma mark- SENDER

-(void)sendGroupMessageToServer:(NSString *)messageID roomJID:(NSString *)roomJID
{
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:BASE_URL]];
    
    [request setValidatesSecureCertificate:NO];
    
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"submitChatMessages", @"method",
                                [[NSUserDefaults standardUserDefaults] objectForKey:@"loginToken"],@"login_token",
                                messageID,@"message_id",
                                roomJID, @"roomjid",
                                @"message_id",@"message_id"   ,
                                @"Group" ,@"message_type",
                                nil];
    
    
    
    request.postBody = [[NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil] mutableCopy];
    
    
    __weak ASIHTTPRequest *req = request;
    
    
    [request setFailedBlock:^{
        
    }];
    
    [request setCompletionBlock:^{
        
        NSDictionary *respDict = [NSJSONSerialization JSONObjectWithData:req.responseData options:NSJSONReadingMutableContainers error:nil];
        
        
        NSLog(@"RespDict .... %@", respDict);
        dispatch_async(dispatch_get_main_queue(), ^{
            ChatMessage *chat = [ChatMessage getChatMessageObjectWithMessageID:messageID];;
            chat.reportedtoAPI=[NSNumber numberWithBool:YES];
            
            
            if([[self managedObjectContext_roster] hasChanges])
                [[self managedObjectContext_roster] save:nil];
        });
        
        
    }];
    
    
    //  [request startAsynchronous];
    
}


-(void)addTimerForMessage:(NSString *) messageID
{
    
    double delayInSeconds = [[NSUserDefaults standardUserDefaults] doubleForKey:@"delay"] == 0 ? 30.0 : [[NSUserDefaults standardUserDefaults] doubleForKey:@"delay"];
    
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    
    
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        ChatMessage * message = [ChatMessage getChatMessageObjectWithMessageID:messageID];
        if([message.chatState intValue]== ChatStateType_Sending )
        {
            message.chatState=[NSNumber numberWithInt:ChatStateType_NotDelivered];
            
            
            [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                              operation:@"checkState"
                                                Content:message.messageID
                                              parameter:[ChatMessage ChatTypeToStr:message.chatState.intValue]];
            
            if([self.managedObjectContext_roster hasChanges])
                [self.managedObjectContext_roster save:nil];
        }
        
        
    });
}


-(ChatMessage *)insertChatMessage:(NSString *)messageID
{
    
    [self.managedObjectContext_roster lock];
    
    ChatMessage * message=[NSEntityDescription insertNewObjectForEntityForName:@"ChatMessage" inManagedObjectContext:self.managedObjectContext_roster];
    
    message.messageID=messageID;
    
    [self.managedObjectContext_roster save:nil];
    
    [self.managedObjectContext_roster unlock];
    
    return message;
}


-(GroupChatReadbyList *)insertChatReadByMessage:(ChatMessage *)message userJID:(NSString *)userJID
{
    
    __block GroupChatReadbyList * readBy=nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.managedObjectContext_roster lock];
        readBy =[NSEntityDescription insertNewObjectForEntityForName:@"GroupChatReadbyList" inManagedObjectContext:self.managedObjectContext_roster];
        
        readBy.userJID=userJID;
        
        [message addReadbyObject:readBy];
        
        if([self.managedObjectContext_roster hasChanges])
            [self.managedObjectContext_roster save:nil];
        
        [self.managedObjectContext_roster unlock];
        
        
    });
    return readBy;
}
#pragma mark - S_GetResendMessageStatus


-(void)service_GetResendMessageStatusWithTOjid:(NSString*)toJid withMessage_id:(NSString*)message_id{
    if ([AppDel appIsDisconnected])
    {
        [AppData showAlertWithTitle:nil andMessage:@"No Connection." inVC:self];
        
        return;
    }
    
    
    
    
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          
                          @"getResendMessageStatus", @"method",
                          toJid, @"toJid",
                          message_id, @"message_id",
                          [[NSUserDefaults standardUserDefaults] objectForKey:@"loginToken"], @"login_token",
                          
                          nil];
    
    [[WebHelper sharedHelper] setWebHelperDelegate:self];
    //S_ReportCloseConversation
    [[WebHelper sharedHelper] sendRequest:dict tag:S_GetResendMessageStatus delegate:self];
    
    
}


-(void)service_ReportCloseConversationWithjid:(NSString*)jid{
    if ([AppDel appIsDisconnected])
    {
        [AppData showAlertWithTitle:nil andMessage:@"No Connection." inVC:self];
        
        return;
    }
    
    
    //  [AppDel showSpinnerWithText:@"Processing User ..."];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          
                          @"reportCloseConversation", @"method",
                          jid, @"jid",
                          
                          [[NSUserDefaults standardUserDefaults] objectForKey:@"loginToken"], @"login_token",
                          
                          nil];
    
    
    
    
    [[WebHelper sharedHelper] setWebHelperDelegate:self];
    
    [[WebHelper sharedHelper] sendRequest:dict tag:S_ReportCloseConversation delegate:self];
}





#pragma mark - ActivityTime

-(void)setInActiveTime:(NSDate *)inActiveTime
{
    [[NSUserDefaults standardUserDefaults] setObject:inActiveTime forKey:@"inActiveTime"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}


-(NSDate *)inActiveTime
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"inActiveTime"];
}

@end
