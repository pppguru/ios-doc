//
//  AppData.m
//  IMYourDoc
//
//  Created by Ronald Wang on 11/13/16.
//  Copyright © 2016 IMYourDoc Inc. All rights reserved.
//


#import "AppData.h"
#import "APIManager.h"
#import "Reachability.h"

#import "AccountConfigViewController.h"
#import "DeviceRegistrationViewController.h"
#import "IMConstants.h"

static AppData * instance;

/*------------------------------    API calls  ----------------------------------*/

static NSString * const API_KEY       = @"15U1U29p42mG0914h7148376qdlV8n1j";
static NSString * const BASEURL_PROD  = @"https://s.imyourdoc.com";
static NSString * const BASEURL_DEVEL = @"https://s-qa.imyourdoc.com";
static const BOOL DEVEL_SERVER  = NO;

static const int MAX_LOGIN_FETCH_INFORMATION_COUNT = 4;


@implementation AppData
{
    NSUserDefaults * _userDefaults;
    Reachability *_reachability;
    
    int firstLoginFetchInformationCount;
    BOOL isLoadingFirstFetchMessages;
}


#pragma mark - SingleTon Initializer
+ (AppData *)appData{
    static AppData *sharedMyAppData = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyAppData = [[self alloc] init];
    });
    return sharedMyAppData;
}

- (id)init{
    self = [super init];
    if (self){
        _userDefaults = [NSUserDefaults standardUserDefaults];
        
        _reachability = [Reachability reachabilityWithHostname:[self getBaseUrl]];
        [_reachability startNotifier];
        
        firstLoginFetchInformationCount = -1;
        isLoadingFirstFetchMessages = NO;
    }
    return self;
}


#pragma mark - globa preferences

- (NSString *)username{
    return [_userDefaults objectForKey:@"username"];
}
- (void)setUsername:(NSString *)username{
    [_userDefaults setObject:username forKey:@"username"];
    [_userDefaults synchronize];
}

- (NSString *)firstname{
    return [_userDefaults objectForKey:@"firstname"];
}
- (void)setFirstname:(NSString *)firstname{
    [_userDefaults setObject:firstname forKey:@"firstname"];
    [_userDefaults synchronize];
}

- (NSString *)lastname{
    return [_userDefaults objectForKey:@"lastname"];
}
- (void)setLastname:(NSString *)lastname{
    [_userDefaults setObject:lastname forKey:@"lastname"];
    [_userDefaults synchronize];
}

- (NSString *)userAccessToken{
    return [_userDefaults objectForKey:@"userAccessToken"];
}

- (void)setUserAccessToken:(NSString*)userAccessToken{
    [_userDefaults setObject:userAccessToken forKey:@"userAccessToken"];
    [_userDefaults synchronize];
}

#pragma mark - User PIN
- (void)setUserPIN:(NSString *)userPIN
{
    [[NSUserDefaults standardUserDefaults] setObject:userPIN forKey:@"userPIN"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)userPIN
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"userPIN"];
}


#pragma mark - User Login Credentials

- (NSString*)getMyJID{
    return [NSString stringWithFormat:@"%@@imyourdoc.com", [AppData appData].XMPPmyJID];
}

- (NSString*)XMPPmyJID{
    return [_userDefaults objectForKey:kXMPPmyJID];
}

- (void)setXMPPmyJID:(NSString*)strJID{
    NSString *cleanedStrJID = [[strJID stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
    [_userDefaults setObject:cleanedStrJID forKey:kXMPPmyJID];
    [_userDefaults synchronize];
}

- (NSString*)XMPPmyJIDPassword{
    return [_userDefaults objectForKey:kXMPPmyPassword];
}

- (void)setXMPPmyJIDPassword:(NSString*)strPW{
    [_userDefaults setObject:strPW forKey:kXMPPmyPassword];
    [_userDefaults synchronize];
}


#pragma mark - XMPP Server connection

+ (void)connectXMPPServer{
    [AppDel setSpinnerText:@"Connecting to Server"];
    [AppDel resetXMPPCoreDataStorage];
    [AppDel connect];
}


#pragma mark - User Info Management

+ (void)fetchUserInfoFromLoginResponse:(NSDictionary*)response{
//    NSMutableArray *arr_activeConversation = [response objectForKey:@"active_conversations"];
    
    if ([response objectForKey:@"broad_cast_enable"])
        [[NSUserDefaults standardUserDefaults] setBool:[[response objectForKey:@"broad_cast_enable"] boolValue] forKey:@"broad_cast_enable"];
    
    if ([response objectForKey:@"login_token"])
        [[NSUserDefaults standardUserDefaults] setObject:[response objectForKey:@"login_token"] forKey:@"loginToken"];
    
    if ([response objectForKey:@"name"])
        [[NSUserDefaults standardUserDefaults] setObject:[response objectForKey:@"name"] forKey:@"UserFullName"];
    
    if ([response objectForKey:@"seq_question"])
        [[NSUserDefaults standardUserDefaults] setObject:[response objectForKey:@"seq_question"] forKey:@"QuestionString"];
    
    if ([response objectForKey:@"seq_answer"])
        [[NSUserDefaults standardUserDefaults] setObject:[response objectForKey:@"seq_answer"] forKey:@"AnswerString"];
    
    if ([response objectForKey:@"user_pin"])
        [[AppData appData] setUserPIN:[NSString stringWithFormat:@"%@", [response objectForKey:@"user_pin"]]];
    
    if ([response objectForKey:@"required_config"])
        [[NSUserDefaults standardUserDefaults] setObject:[response objectForKey:@"required_config"] forKey:@"required_config"];
    
    NSString *strUserType;
    if ((strUserType = [response objectForKey:@"user_type"])){
        
        [[NSUserDefaults standardUserDefaults] setObject:strUserType forKey:@"UserType"];
        
        if ([strUserType isEqualToString:@"Physician"])
            [AppDel setUserType:0];
        else if([strUserType isEqualToString:@"Patient"])
            [AppDel setUserType:1];
        else if([strUserType isEqualToString:@"Staff"])
            [AppDel setUserType:2];
    }

    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Local Notification

- (void)showLocalNotification:(NSString*)message withBadgeNumber:(int)badgeNum{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UILocalNotification *localNotif = [[UILocalNotification alloc] init];
        
        localNotif.alertBody = message;
        
        localNotif.alertAction = NSLocalizedString(@"View IM", nil);
        
        //Get the currently set audio for notification
        NSString *musicFilename;
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"Sound"])
        {
            musicFilename = [NSString stringWithFormat:@"%@.caf", [[NSUserDefaults standardUserDefaults] objectForKey:@"Sound"]];
        }
        
        else
        {
            musicFilename = @"Ripple.caf";
        }
        
        localNotif.soundName = musicFilename;
        
        if (badgeNum >= 0)
            localNotif.applicationIconBadgeNumber = badgeNum;
        
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];
    });
}

+ (void)sendLocalNotificationForNotInternetConnection {
    [[NSNotificationCenter defaultCenter] postNotificationName:XMPPREACHABILITY
                                                        object:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                @"No Internet connection", @"status"
                                                                , @"unsecure_icon", @"image", nil]];
}

+ (void)sendLocalNotificationForNotConnected{
    [[NSNotificationCenter defaultCenter] postNotificationName:XMPPREACHABILITY
                                                        object:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                @"Not Connected", @"status"
                                                                , @"unsecure_icon", @"image", nil]];
}

+ (void)sendLocalNotificationForConnecting {
    [[NSNotificationCenter defaultCenter] postNotificationName:XMPPREACHABILITY
                                                        object:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                @"Connecting", @"status"
                                                                , @"secure_icon", @"image", nil]];
}

+ (void)sendLocalNotificationForSecurelyConnected{
    [[NSNotificationCenter defaultCenter] postNotificationName:XMPPREACHABILITY
                                                        object:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                @"Securely Connected", @"status"
                                                                , @"secure_icon", @"image", nil]];
}

#pragma mark - Apply the auth token to API mananger
- (void)addAuthTokenIntoHeaderOfAPIManager:(NSString*)authToken withHeaderName:(NSString*)headerName{
    
    NSString *token = authToken;
    NSString *header = headerName;
    
    if (authToken == nil || authToken.length == 0) {
        if (self.userAccessToken && self.userAccessToken.length > 0) {
            token = self.userAccessToken;
        }
        
    }
    
    if (headerName == nil || headerName.length == 0) {
        header = @"x-auth-token";
    }
    
    [[[APIManager sharedJSONManager] requestSerializer] setValue:token forHTTPHeaderField:header];
    [[[APIManager sharedFileManager] requestSerializer] setValue:token forHTTPHeaderField:header];
    
    
}

#pragma mark - Fetch the information from server

- (BOOL)isAllInboxMessagesFetched{
    return isLoadingFirstFetchMessages;
}

- (BOOL)isAllLoginInfoFetched{
    if (firstLoginFetchInformationCount == -1 || firstLoginFetchInformationCount == MAX_LOGIN_FETCH_INFORMATION_COUNT){
        firstLoginFetchInformationCount = -1;
        return YES;
    }
    
    return NO;
}

- (void)fetchInformationAfterLogin:(UINavigationController*)navController{
    
    isLoadingFirstFetchMessages = YES;
    firstLoginFetchInformationCount = 0;
    
    NSOperationQueue *opQueue = [NSOperationQueue new];
    
    NSBlockOperation *profileBlock = [NSBlockOperation new];
    
    profileBlock = [NSBlockOperation blockOperationWithBlock:^{
        
        [[APIManager sharedJSONManager] profileRequest:^(ProfileResponseModel *responseModel)
         {
             [[NSUserDefaults standardUserDefaults] setObject:responseModel.firstName forKey:@"UserFullName"];
             
             if ([responseModel.userType isEqualToString:@"PHYSICIAN"])
             {
                 [[NSUserDefaults standardUserDefaults] setObject:@"Physician" forKey:@"UserType"];
                 [AppDel setUserType:0];
             }
             
             else if([responseModel.userType isEqualToString:@"STAFF"])
             {
                 [[NSUserDefaults standardUserDefaults] setObject:@"Staff" forKey:@"UserType"];
                 [AppDel setUserType:2];
             }
             
             else
             {
                 [[NSUserDefaults standardUserDefaults] setObject:@"Patient" forKey:@"UserType"];
                 [AppDel setUserType:1];
             }
             
             [[NSUserDefaults standardUserDefaults] synchronize];
             
             firstLoginFetchInformationCount ++;
         }
                                           failure:^(NSError *error)
         {
             NSLog(@"Error: %@ %@", error, [error userInfo]);
             
             firstLoginFetchInformationCount ++;
         }];
    }];
    
    NSBlockOperation *contactsBlock = [NSBlockOperation new];
    
    contactsBlock = [NSBlockOperation blockOperationWithBlock:^{
        
        [[APIManager sharedJSONManager] contactsRequest:^(NSArray<ProfileResponseModel *> *responseModel)
         {
             
             firstLoginFetchInformationCount ++;
             
             
             ProfileResponseModel *contact;
             
             for (contact in responseModel)
             {
                 XMPPUserCoreDataStorageObject *user = [AppDel fetchUserForJIDString:[NSString stringWithFormat:@"%@@imyourdoc.com", contact.username]];
                 
                 if(!user)
                 {
                     user = [XMPPUserCoreDataStorageObject insertInManagedObjectContext:[AppDel managedObjectContext_roster]
                                                                                withJID:[XMPPJID jidWithString:[NSString stringWithFormat:@"%@@imyourdoc.com", contact.username]]
                                                                       streamBareJidStr:[NSString stringWithFormat:@"%@@imyourdoc.com",[AppData appData].XMPPmyJID]];
                     
                     [user updateWithModel:contact];
                     
                      [[APIManager sharedFileManager] contactPhotosRequest:contact.username
                      success:^(UIImage *image)
                      {
                          
                          if (image){
                              user.photo = image;
                              
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  
                                  [[AppDel managedObjectContext_roster] save:nil];
                              });
                          }
                      }
                      failure:^(NSError *error)
                      {
                          if (error) {
                              NSLog(@"Error: %@ %@", error, [error userInfo]);
                          }
                          
                      }];
                     
                     dispatch_async(dispatch_get_main_queue(), ^{
                         
                         [[AppDel managedObjectContext_roster] save:nil];
                     });
                 }
                 
             }
         }
         failure:^(NSError *error)
         {
             firstLoginFetchInformationCount ++;
             
             NSLog(@"Error: %@ %@", error, [error userInfo]);
         }];
    }];
    
    NSBlockOperation *flagsBlock = [NSBlockOperation new];
    
    flagsBlock = [NSBlockOperation blockOperationWithBlock:^{
        
        [[APIManager sharedJSONManager] flagsRequest:^(NSArray<FlagResponseModel *> *responseModel)
         {
             firstLoginFetchInformationCount ++;
             
             
             [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"required_config"];
             
             BOOL isConfigured = YES;
             
             for (int i = 0; i < responseModel.count; i++)
             {
                 if ([responseModel[i].flagType isEqual:@"CONFIG_REQUIRED"])
                 {
                     isConfigured = !responseModel[i].value;
                     [[NSUserDefaults standardUserDefaults] setBool:responseModel[i].value forKey:@"required_config"];
                 }
             }
             
             [[NSUserDefaults standardUserDefaults] synchronize];
             
             if (!isConfigured)  //Configure account
             {
                 [AppDel hideSpinner];
                 [AppData goToAccountConfig:navController];
             }
             
             else
             {
                 
             }
         }
         failure:^(NSError *error)
         {
             firstLoginFetchInformationCount ++;
             NSLog(@"Error: %@ %@", error, [error userInfo]);
         }];
    }];
    
    NSBlockOperation *messageBlock = [NSBlockOperation new];
    
    messageBlock = [NSBlockOperation blockOperationWithBlock:^{
        
        [[APIManager sharedJSONManager] threadRequest:^(ThreadResponseModel *responseModel)
         {
             
             
             if (responseModel.content.count < 10)
             {
                 NSString *temp = [[NSUserDefaults standardUserDefaults] objectForKey:@"page"];
                 [[NSUserDefaults standardUserDefaults] setObject:[temp stringByAppendingString:@"end"] forKey:@"page"];
             }
             
             NSOperationQueue *opQueue2 = [NSOperationQueue new];
             NSMutableArray *ops = [NSMutableArray new];
             
             firstLoginFetchInformationCount ++;
             
             NSInteger __block nMessages = responseModel.content.count;
             
             //Load the messages for each Inbox Messages
             for (ThreadContentModel *content in responseModel.content)
             {
                 //Add Inbox Object
                 InboxMessage *inboxMsg = [AppDel addInboxMessageWithThreadModel:content];
                 
                 if (inboxMsg == nil)
                     continue;
                 
                 //----------------------------  One to One Private Chat Handling --------------------------------------
                 NSBlockOperation *block2 = [NSBlockOperation new];
                 
                 if ([content.type isEqualToString:@"ONE_TO_ONE"])
                 {
                     block2 = [NSBlockOperation blockOperationWithBlock:^{
                         
                         [[APIManager sharedJSONManager] oneToOneMessagesRequest:content.users[0].username
                                                             beforeMessageID:nil
                                                                     success:^(MessageResponseModel *responseModel2)
                          {
                              LastMessageModel *messageModel;
                              NSString *myUsername = [AppData appData].XMPPmyJID;
                              
                              for (messageModel in responseModel2.content)
                              {
                                  ChatMessage *message = [ChatMessage initMessageWithFrom:[NSString stringWithFormat:@"%@@imyourdoc.com", messageModel.sender.username]
                                                                                       to:[NSString stringWithFormat:@"%@@imyourdoc.com", content.users[0].username]
                                                                                  content:messageModel.text
                                                                                timestamp:nil
                                                                                messageID:messageModel.messageId
                                                                              withContext:[AppDel managedObjectContext_roster]
                                                                                    MyJid:[NSString stringWithFormat:@"%@@imyourdoc.com", myUsername]
                                                                             WithFileType:messageModel.fileType
                                                                             WithFilepath:messageModel.filePath];
                                  
                                  message.timeStamp = messageModel.timestamp;
                                  
                                  message.chatState = [NSNumber numberWithInt:ChatStateType_Sending];
                                  
                                  message.readReportSent_Bl = [NSNumber numberWithBool:false];
                                  
                                  if (![myUsername isEqualToString:messageModel.sender.username])
                                  {
                                      message.chatState = [NSNumber numberWithInt:ChatStateType_NoneByReciever];
                                  }
                                  
                                  if (messageModel.delivery.acknowledged)
                                  {
                                      message.chatState = [NSNumber numberWithInt:ChatStateType_NoneByReciever];
                                      
                                      if ([myUsername isEqualToString:messageModel.sender.username])
                                      {
                                          message.chatState = [NSNumber numberWithInt:ChatStateType_Sent];
                                      }
                                  }
                                  
                                  if (messageModel.delivery.notified || messageModel.delivery.emailed)
                                  {
                                      message.chatState = [NSNumber numberWithInt:ChatStateType_Notification_EmailSent];
                                  }
                                  
                                  if (messageModel.delivery.delivered)
                                  {
                                      message.chatState = [NSNumber numberWithInt:ChatStateType_deliveredByReciever];
                                      
                                      if ([myUsername isEqualToString:messageModel.sender.username])
                                      {
                                          message.chatState = [NSNumber numberWithInt:ChatStateType_Delivered];
                                      }
                                  }
                                  
                                  if (messageModel.delivery.displayed)
                                  {
                                      message.readReportSent_Bl = [NSNumber numberWithBool:true];
                                      
                                      message.chatState = [NSNumber numberWithInt:ChatStateType_displayedByReciever];
                                      
                                      if ([myUsername isEqualToString:messageModel.sender.username])
                                      {
                                          message.chatState = [NSNumber numberWithInt:ChatStateType_Read];
                                      }
                                  }
                                  
                                  [AppDel addChatMessage:message toInboxMessage:inboxMsg];
                                  if (nMessages-- == 0) isLoadingFirstFetchMessages = NO;
                              }
                          }
                          failure:^(NSError *error)
                          {
                              NSLog(@"Error: %@ %@", error, [error userInfo]);
                              if (nMessages-- == 0) isLoadingFirstFetchMessages = NO;
                          }];
                     }];
                     
                     [ops addObject:block2];
                 }
                 
                 else
                 {
                     
                     //----------------------------  Group Chat Handling --------------------------------------
                     
                     block2 = [NSBlockOperation blockOperationWithBlock:^{
                         
                         [[APIManager sharedJSONManager] roomMessagesRequest:content.name
                                                         beforeMessageID:nil
                                                                 success:^(MessageResponseModel *mesModel)
                          {
                              LastMessageModel *messageModel;
                              NSString *myUsername = [AppData appData].XMPPmyJID;
                              
                              for (messageModel in mesModel.content)
                              {
                                  
                                  ChatMessage *message = [ChatMessage initGroupChatMessageFrom:[NSString stringWithFormat:@"%@@imyourdoc.com", messageModel.sender.username]
                                                                                            to:[NSString stringWithFormat:@"%@@newconversation.imyourdoc.com", content.name]
                                                                                       content:messageModel.text
                                                                                   chatMessage:ChatMessageType_Group
                                                                                     timestamp:nil
                                                                                     messageID:messageModel.messageId
                                                                                 ChatStateType:ChatStateType_NotDelivered
                                                                                         MyJid:[NSString stringWithFormat:@"%@@imyourdoc.com", myUsername]
                                                                                  WithFileType:messageModel.fileType
                                                                                  WithFilepath:messageModel.filePath];
                                  
                                  message.timeStamp = messageModel.timestamp;
                                  
                                  message.readReportSent_Bl = [NSNumber numberWithBool:false];
                                  
                                  message.chatState = [NSNumber numberWithInt:ChatStateType_Sending];
                                  
                                  if (![myUsername isEqualToString:messageModel.sender.username])
                                  {
                                      message.chatState = [NSNumber numberWithInt:ChatStateType_NoneByReciever];
                                  }
                                  
                                  if (messageModel.delivery.acknowledged)
                                  {
                                      message.chatState = [NSNumber numberWithInt:ChatStateType_NoneByReciever];
                                      
                                      if ([myUsername isEqualToString:messageModel.sender.username])
                                      {
                                          message.chatState = [NSNumber numberWithInt:ChatStateType_Sent];
                                      }
                                  }
                                  
                                  message.roomRead = 0;
                                  
                                  StatInfoModel *displayed;
                                  for (displayed in messageModel.delivery.displayed)
                                  {
                                      message.roomRead = [NSNumber numberWithInt:[message.roomRead intValue] + 1];
                                      
                                      if ([myUsername isEqualToString:displayed.username])
                                      {
                                          message.readReportSent_Bl = [NSNumber numberWithBool:true];
                                          
                                          message.chatState = [NSNumber numberWithInt:ChatStateType_displayedByReciever];
                                      }
                                  }
                                  
                                  if (messageModel.delivery.displayed.count >= (content.users.count - 1)
                                      && [myUsername isEqualToString:messageModel.sender.username])
                                  {
                                      message.chatState = [NSNumber numberWithInt:ChatStateType_Read];
                                  }
                                  
                                  [AppDel addChatMessage:message toInboxMessage:inboxMsg];
                                  
                                  if (nMessages-- == 0) isLoadingFirstFetchMessages = NO;
                              }
                          }
                          failure:^(NSError *error)
                          {
                              NSLog(@"Error: %@ %@", error, [error userInfo]);
                              
                              if (nMessages-- == 0) isLoadingFirstFetchMessages = NO;
                          }];
                         
                     }];
                     
                     [ops addObject:block2];
                 }
             }
             
             opQueue2.maxConcurrentOperationCount = 5;
             [opQueue2 addOperations:ops waitUntilFinished:false];
             
         }
         failure:^(NSError *error)
         {
             isLoadingFirstFetchMessages = NO;
             firstLoginFetchInformationCount ++;
             
             NSLog(@"Error: %@ %@", error, [error userInfo]);
         }];
    }];
    
    [opQueue addOperations:@[profileBlock, contactsBlock, flagsBlock, messageBlock] waitUntilFinished:false];
    
}

- (void)fetchMessageThreadsWithConversationIDName:(NSString*)jConversationID
                                andFirstMessageID:(NSString*)strFirstMessageID
                                      isOneORRoom:(BOOL)isOneORRoom
                                          success:(void (^)(BOOL isThereNew))success
                                          failure:(void (^)(NSError *error))failure

{
    
    if (isOneORRoom)  //----------------------   OneToOne Conversation Case ---------------------------------------//
    {
        [[APIManager sharedJSONManager] oneToOneMessagesRequest:jConversationID
                                            beforeMessageID:strFirstMessageID
                                                    success:^(MessageResponseModel *responseModel2)
        {
            BOOL isMore = NO;
            
            LastMessageModel *messageModel;
            NSString *myUsername = [AppData appData].XMPPmyJID;

            for (messageModel in responseModel2.content)
            {
                ChatMessage *message = [ChatMessage initMessageWithFrom:[NSString stringWithFormat:@"%@@imyourdoc.com", messageModel.sender.username]
                                                                   to:[NSString stringWithFormat:@"%@@imyourdoc.com", jConversationID]
                                                              content:messageModel.text
                                                            timestamp:nil
                                                            messageID:messageModel.messageId
                                                          withContext:[AppDel managedObjectContext_roster]
                                                                MyJid:[NSString stringWithFormat:@"%@@imyourdoc.com", myUsername]
                                                         WithFileType:messageModel.fileType
                                                         WithFilepath:messageModel.filePath];
                if (message == nil)
                    continue;
                
                isMore = YES;

                message.timeStamp = messageModel.timestamp;

                message.chatState = [NSNumber numberWithInt:ChatStateType_Sending];

                message.readReportSent_Bl = [NSNumber numberWithBool:false];

                if (![myUsername isEqualToString:messageModel.sender.username])
                {
                    message.chatState = [NSNumber numberWithInt:ChatStateType_NoneByReciever];
                }

                if (messageModel.delivery.acknowledged)
                {
                    message.chatState = [NSNumber numberWithInt:ChatStateType_NoneByReciever];

                    if ([myUsername isEqualToString:messageModel.sender.username])
                    {
                        message.chatState = [NSNumber numberWithInt:ChatStateType_Sent];
                    }
                }

                if (messageModel.delivery.notified || messageModel.delivery.emailed)
                {
                    message.chatState = [NSNumber numberWithInt:ChatStateType_Notification_EmailSent];
                }

                if (messageModel.delivery.delivered)
                {
                    message.chatState = [NSNumber numberWithInt:ChatStateType_deliveredByReciever];
                  
                    if ([myUsername isEqualToString:messageModel.sender.username])
                    {
                        message.chatState = [NSNumber numberWithInt:ChatStateType_Delivered];
                    }
                }

                if (messageModel.delivery.displayed)
                {
                    message.readReportSent_Bl = [NSNumber numberWithBool:true];
                  
                    message.chatState = [NSNumber numberWithInt:ChatStateType_displayedByReciever];
                  
                    if ([myUsername isEqualToString:messageModel.sender.username])
                    {
                        message.chatState = [NSNumber numberWithInt:ChatStateType_Read];
                    }
                }

                
                [AppDel addInboxMessage:message];
            }
            
            
            success(isMore);
        }
        failure:^(NSError *error)
        {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            
            failure(error);
        }];
    }
    else{   //----------------------   Room Conversation Case ---------------------------------------//
        
        
        [[APIManager sharedJSONManager] roomMessagesRequest:jConversationID
                                        beforeMessageID:strFirstMessageID
                                                success:^(MessageResponseModel *mesModel)
         {
             
             BOOL isMore = NO;
             
             LastMessageModel *messageModel;
             NSString *myUsername = [AppData appData].XMPPmyJID;
             
             for (messageModel in mesModel.content)
             {
                 
                 ChatMessage *message = [ChatMessage initGroupChatMessageFrom:[NSString stringWithFormat:@"%@@imyourdoc.com", messageModel.sender.username]
                                                                           to:[NSString stringWithFormat:@"%@@newconversation.imyourdoc.com", jConversationID]
                                                                      content:messageModel.text
                                                                  chatMessage:ChatMessageType_Group
                                                                    timestamp:nil
                                                                    messageID:messageModel.messageId
                                                                ChatStateType:ChatStateType_NotDelivered
                                                                        MyJid:[NSString stringWithFormat:@"%@@imyourdoc.com", myUsername]
                                                                 WithFileType:messageModel.fileType
                                                                 WithFilepath:messageModel.filePath];
                 
                 if (message == nil)
                     continue;
                 
                 isMore = YES;
                 
                 message.timeStamp = messageModel.timestamp;
                 
                 message.readReportSent_Bl = [NSNumber numberWithBool:false];
                 
                 message.chatState = [NSNumber numberWithInt:ChatStateType_Sending];
                 
                 if (![myUsername isEqualToString:messageModel.sender.username])
                 {
                     message.chatState = [NSNumber numberWithInt:ChatStateType_NoneByReciever];
                 }
                 
                 if (messageModel.delivery.acknowledged)
                 {
                     message.chatState = [NSNumber numberWithInt:ChatStateType_NoneByReciever];
                     
                     if ([myUsername isEqualToString:messageModel.sender.username])
                     {
                         message.chatState = [NSNumber numberWithInt:ChatStateType_Sent];
                     }
                 }
                 
                 message.roomRead = 0;
                 
                 StatInfoModel *displayed;
                 for (displayed in messageModel.delivery.displayed)
                 {
                     message.roomRead = [NSNumber numberWithInt:[message.roomRead intValue] + 1];
                     
                     if ([myUsername isEqualToString:displayed.username])
                     {
                         message.readReportSent_Bl = [NSNumber numberWithBool:true];
                         
                         message.chatState = [NSNumber numberWithInt:ChatStateType_displayedByReciever];
                     }
                 }
                 
                 
//                 if (messageModel.delivery.displayed.count >= (content.users.count - 1)
//                     && [myUsername isEqualToString:messageModel.sender.username])
//                 {
//                     message.chatState = [NSNumber numberWithInt:ChatStateType_Read];
//                 }
                 
                 [AppDel addInboxMessageGroupChat:message];
             }
             
             
             
             success(isMore);
             
         }
         failure:^(NSError *error)
         {
             NSLog(@"Error: %@ %@", error, [error userInfo]);
             
             failure(error);
             
         }];
    }
}


#pragma mark - Version Management
- (BOOL)isNewAppVersion{
    NSString *strCurrentAppBuildVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey: @"CFBundleShortVersionString"];
    NSString *installAppVersion = [self appVersion];
    
    if (installAppVersion && [installAppVersion isEqualToString:strCurrentAppBuildVersion]){
        return NO;
    }
    
    return YES;
}

- (void)saveCurrentAppVersion{
    NSString *strCurrentAppBuildVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey: @"CFBundleShortVersionString"];
    [self setAppVersion:strCurrentAppBuildVersion];
}

- (NSString*)appVersion{
    return [_userDefaults objectForKey:@"AppVersion"];
}

- (void)setAppVersion:(NSString*)strAppVersion{
    [_userDefaults setObject:strAppVersion forKey:@"AppVersion"];
    [_userDefaults synchronize];
}


#pragma mark - Clear Login Session

- (void)clearPreviousLoginSession{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"required_config"])
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"required_config"];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"loginToken"])
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"loginToken"];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"QuestionString"])
        [[NSUserDefaults standardUserDefaults] removeObjectForKey: @"QuestionString"];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"AnswerString"])
        [[NSUserDefaults standardUserDefaults] removeObjectForKey: @"AnswerString"];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"UserType"])
        [[NSUserDefaults standardUserDefaults] removeObjectForKey: @"UserType"];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"UserFullName"])
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserFullName"];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"rememberMe"])
    {
        if ([AppData appData].XMPPmyJID)
        {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kXMPPmyJID];
        }
    }
    
    if ([AppData appData].XMPPmyJIDPassword)
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kXMPPmyPassword];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"page"])
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"page"];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"userLoggedIn"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark - globa function

-(NSString *)apiKey{
    return API_KEY;
}

- (NSString *)getBaseUrl{
    if (DEVEL_SERVER){
        return BASEURL_DEVEL;
    }
    else{
        return BASEURL_PROD;
    }
}

- (BOOL)wifiAvaiable{
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    NetworkStatus status = [reachability currentReachabilityStatus];
    
    if(status == NotReachable)
    {
        //No internet
        return NO;
    }
    else if (status == ReachableViaWiFi)
    {
        //WiFi
        return YES;
    }
    else if (status == ReachableViaWWAN)
    {
        //3G
        return YES;
    }
    
    return NO;
}

#pragma mark - Alert View

+ (void)showAlertWithTitle:(NSString*)strTitle andMessage:(NSString*)strMsg inVC:(UIViewController*)containerVC{
    
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:strTitle
                                                                   message:strMsg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [sheet addAction:[UIAlertAction actionWithTitle:@"OK"
                                              style:UIAlertActionStyleCancel
                                            handler:nil]];
    
    [containerVC presentViewController:sheet animated:YES completion:nil];
}

#pragma mark - TextField Text Validation

+ (BOOL)isFieldEmpty:(UITextField *)field{
    if ([field.text exactLength] > 0){
        return NO;
    }
    else{
        return YES;
    }
}


+ (BOOL)isFieldEmail:(UITextField *)field{
    NSString * mail = field.text;
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
    NSPredicate *emailText = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailText evaluateWithObject:mail];
}


#pragma mark - UI Navigation

+ (void)logOut {
    
}

+ (void)loginWithResponseJSON:(NSDictionary*)strResponse withNavController:(UINavigationController*)navCurrent{
    [AppData fetchUserInfoFromLoginResponse:strResponse];
    
    NSInteger requiredConfigFlag = [[[NSUserDefaults standardUserDefaults] objectForKey:@"required_config"] integerValue];
    NSInteger requiredRegisterDeviceFlag = [[[NSUserDefaults standardUserDefaults] objectForKey:@"required_register_device"] integerValue];
    [AppData loginActionWithRequiredConfig:requiredConfigFlag andRegisterDevice:requiredRegisterDeviceFlag andNavVC:navCurrent];
}

+ (void)goToAccountConfig:(UINavigationController*)navController{
    AccountConfigViewController *acVC = [[AccountConfigViewController alloc] initWithNibName:@"AccountConfigViewController" bundle:nil];
    [navController pushViewController:acVC animated:YES];
}

+ (void)loginActionWithRequiredConfig:(NSInteger)requiredConfigFlag andRegisterDevice:(NSInteger)registerDeviceFlag andNavVC:(UINavigationController*)navController{

    if (requiredConfigFlag == 0)
    {
        if (registerDeviceFlag == 1)   // Device registration Required
        {
            [AppDel hideSpinner];
            
            DeviceRegistrationViewController *deviceReg = [[DeviceRegistrationViewController alloc] initWithNibName:@"DeviceRegistrationViewController" bundle:nil];
            [navController pushViewController:deviceReg animated:YES];
        }
        else
        {
            [AppData connectXMPPServer];  //----------- Connect to the XMPP server ---------- //
        }
    }
    
    
    else  //Configure account is required
    {
        [AppDel hideSpinner];
        
        [AppData goToAccountConfig:navController];
    }
}


@end
