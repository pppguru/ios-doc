//
//  AppDelegate+XmppConnectionMethods.m
//  IMYourDoc
//
//  Created by admin on 6/16/16.
//  Copyright © 2016 vijayvir . All rights reserved.
//

#import "AppDelegate+XmppConnectionMethods.h"

@implementation AppDelegate (XmppMethods)

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
    
    
    
    
    NSXMLElement *xMessage = [NSXMLElement elementWithName:@"x" xmlns:@"jabber:x:event"];
    
    [xMessage addChild:[NSXMLElement elementWithName:@"offline"]];
    
    [xMessage addChild:[NSXMLElement elementWithName:@"delivered"]];
    
    [xMessage addChild:[NSXMLElement elementWithName:@"displayed"]];
    
    [xMessage addChild:[NSXMLElement elementWithName:@"composing"]];
    
    
    
    
    
    
    [message addChild:xMessage];
    
    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                      operation:@"sendElement>>Msg"
                                        Content:msgID
                                      parameter:@""];
    
    [xmppStream sendElement:message];
    
    
    double delayInSeconds = [[NSUserDefaults standardUserDefaults] doubleForKey:@"delay"] == 0 ? 30.0 : [[NSUserDefaults standardUserDefaults] doubleForKey:@"delay"];
    
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    
    
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        NSFetchRequest *fetchrequest = [[NSFetchRequest alloc] initWithEntityName:@"ChatMessage"];
        
        [fetchrequest setPredicate:[NSPredicate predicateWithFormat:@"messageID=%@", [message attributeStringValueForName:@"id"]]];
        
        
        NSArray *array = [self.managedObjectContext_roster executeFetchRequest:fetchrequest error:nil];
        
        
        ChatMessage *chatmessage = [array lastObject];
        
        
        if (chatmessage == nil)
        {
            return;
        }
        
        
        if ([chatmessage.chatState intValue] <= ChatStateType_Delivered)
        {
            
            
            [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                              operation:@"send_notification_device >> See MessageState "
                                                Content:[NSString stringWithFormat:@"%@ State %@",chatmessage.messageID ,[ChatMessage ChatTypeToStr:[chatmessage.chatState integerValue]] ]
                                              parameter:@""];
            
            //
            //            NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
            //                                  @"send_notification_device",@"method",
            //                                  [[NSUserDefaults standardUserDefaults] objectForKey:@"loginToken"], @"login_token",
            //                                  chatmessage.messageID,@"message_id",
            //                                  nil];
            
            
            //            [[WebHelper sharedHelper] setWebHelperDelegate:self];
            //
            //            [[WebHelper sharedHelper] sendRequest:dict tag:S_Send_notification_device delegate:self];
            
        }
    });
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
        {
            NSXMLElement *idElement = [NSXMLElement elementWithName:@"id"];
            
            [idElement setStringValue:msgID];
            
            
            NSXMLElement *deliveredElement = [NSXMLElement elementWithName:@"delivered"];
            
            [deliveredElement addChild:idElement];
            
            
            [xElement addChild:deliveredElement];
            
            
            [message addChild:xElement];
        }
            
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
    
    //    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__] operation:@"__XLC_XMPPStreamLifeCycle__" Content:@"" parameter:@""];
    
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
    
    [[NSNotificationCenter defaultCenter] postNotificationName:XMPPREACHABILITY object:[NSDictionary dictionaryWithObjectsAndKeys:@"Securely Connected", @"status", @"secure_icon", @"image", nil]];
    
    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                      operation:@"XMPPREACHABILITY"
                                        Content:@"Securely Connected"
                                      parameter:@""];
}


- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                      operation:@"__XLC_XMPPStreamLifeCycle__"
                                        Content:@""
                                      parameter:@""];
    
    isXmppConnected = YES;
    
    
    NSError *error = nil;
    
    
    if (![[self xmppStream] authenticateWithPassword:[[NSUserDefaults standardUserDefaults] valueForKey:@"kXMPPmyPassword"] error:&error])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:XMPPREACHABILITY object:[NSDictionary dictionaryWithObjectsAndKeys:@"Not Connected", @"status", @"unsecure_icon", @"image", nil]];
        [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                          operation:@"XMPPREACHABILITY"
                                            Content:@"Not Connected"
                                          parameter:@""];
    }
    
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:XMPPREACHABILITY object:[NSDictionary dictionaryWithObjectsAndKeys:@"Securely Connected", @"status", @"secure_icon", @"image", nil]];
        [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                          operation:@"XMPPREACHABILITY"
                                            Content:@"Securely Connected"
                                          parameter:@""];
    }
}


- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    
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
        
        [self fetchOldRooms];
    }
    
    [self fetchVCard:[sender myJID]];
    
    [self goOnline];
    
    if (self.isLoggedState == 0)
    {
        [self.loginView setUsernameAndPassWordAsEmpty];
        
        
        if (!self.homeView)
        {
            self.homeView = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
            
        }
        
        [self.navController pushViewController:self.homeView animated:YES];
        if (![self.navController.visibleViewController isKindOfClass:[DeviceRegistrationViewController class]])
        {
        }
        
        
        
        
        
        
        [self hideSpinner];
        
        
        self.isLoggedState = 2;
    }
    
    
    if (self.isLoggedState == 1)
    {
        /* if (internetRechablity)
         {
         [internetRechablity stopNotifier];
         }
         */
        
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
    
    [NSDictionary dictionaryWithObjectsAndKeys:@"Not Connected", @"status", @"unsecure_icon", @"image", nil];
}


- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    
    
    NSLog(@"didReceiveIQ.. %@....%@",[iq xmlns],iq);
    
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
        [[AppDel arr_stateTransferAccount] removeObject:[iq attributeStringValueForName:@"id"]];
        [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:[NSString stringWithFormat:@"KstateTransferArrayUpdateNotification"] object:nil  userInfo:nil];
    }
    
    
    
    
    //oldmessages
    if ([[[iq elementForName:@"list"] xmlns] isEqualToString:@"urn:xmpp:archive"])
    {
        [self leoXmppStreamReceiveIQ:sender withListUrnXmppArchive:iq];
        
        
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
    
    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                      operation:@"__XLC_XMPPStreamLifeCycle__"
                                        Content:@""
                                      parameter:@""];
    
    if(TARGET_IPHONE_SIMULATOR)
        NSLog(@"didSendMessage.... message %@",message);
    
    if ([message isMessageWithBody])
    {
        if ([message isMessageWithBody])
        {
            NSFetchRequest *alreadyExists = [[NSFetchRequest alloc] initWithEntityName:@"ChatMessage"];
            
            [alreadyExists setPredicate:[NSPredicate predicateWithFormat:@"messageID=%@", [message attributeStringValueForName:@"id"]]];
            
            
            NSArray *alreadyExistsArr = [self.managedObjectContext_roster executeFetchRequest:alreadyExists error:nil];
            
            
            ChatMessage *chat = [alreadyExistsArr lastObject];
            
            if([chat.isRoomMessage boolValue]==NO)
            {
                /*
                if (chat != nil)
                {
                    chat.chatState = [NSNumber numberWithInt:ChatStateType_Sent];
                    chat.requestStatus =[NSNumber numberWithInt: RequestStatusType_uploaded];
                    
                }
                 */
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
                        
                        
                        dispatch_queue_t que1 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
                        
                        [room addDelegate:self delegateQueue:que1];
                        
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
    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                      operation:@"__XLC_XMPPStreamLifeCycle__"
                                        Content:@""
                                      parameter:@""];
    
    NSLog(@".... message %@",message);
    pingTimeOuts=0;
    if ([message isErrorMessage])
    {
        
        if([message.errorMessage code]==401)
        {
            [self authenticate];
        }
        
        
        if ([message isMessageWithBody])
        {
            NSFetchRequest *alreadyExists = [[NSFetchRequest alloc] initWithEntityName:@"ChatMessage"];
            
            [alreadyExists setPredicate:[NSPredicate predicateWithFormat:@"messageID=%@", [message attributeStringValueForName:@"id"]]];
            
            
            NSArray *alreadyExistsArr = [self.managedObjectContext_roster executeFetchRequest:alreadyExists error:nil];
            
            
            ChatMessage *mess2age = [alreadyExistsArr lastObject];
            
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
    
    
    
    
    
    NSString *fromUSERJID = [message.from bare];
    [self managedObjectContext_roster];
    
    
    
    
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
    
    if ([message hasChatState] && ![message isErrorMessage])
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
#pragma mark code to check the offline messages dilevery on user get online
    pingTimeOuts=0;
    
    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                      operation:@"__XLC_XMPPStreamLifeCycle__"
                                        Content:@""
                                      parameter:@""];
    
    if (![[[presence from] bare] isEqualToString:sender.myJID.bare])
    {
        
        ChatMessage * lastUnsentMessage=[ChatMessage getLastFailedMessageForJID:presence.from.bare];
        
        if(lastUnsentMessage)
            [self resendMessage:lastUnsentMessage];
        
        return;
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"ChatMessage"];
        
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"displayName=%@ AND outbound=%@ AND (chatState=%@ OR chatState=%@ ) ", [presence.from bare], @"1", [NSNumber numberWithInt:ChatStateType_Sending], [NSNumber numberWithInt:ChatStateType_NotDelivered]];
        
        [request setPredicate:predicate];
        
        
        NSArray *messages = [self.managedObjectContext_roster executeFetchRequest:request error:nil];
        
        
        int i = 0;
        
        
        for (ChatMessage *chatmessage in messages)
        {
            i += 1;
            __block ChatMessage *msg=chatmessage;
            
            if ([[chatmessage chatState] intValue] == ChatStateType_Sending || [[chatmessage chatState] intValue] == ChatStateType_NotDelivered)
            {
                [que_t addOperationWithBlock:^{
                    if(chatmessage)
                        [self resendMessage:chatmessage];
                }];
            }
            continue;
            
            double delayInSeconds = i + ([[NSUserDefaults standardUserDefaults] doubleForKey:@"delay"] == 0 ? 30.0 : [[NSUserDefaults standardUserDefaults] doubleForKey:@"delay"]);
            
            
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            
            
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                
                
            });
        }
    }
    
    
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
                if ([[NSUserDefaults standardUserDefaults] objectForKey:kXMPPmyJID])
                {
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kXMPPmyJID];
                }
            }
            
            
            if ([[NSUserDefaults standardUserDefaults] objectForKey:kXMPPmyPassword])
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
            
            
            [self hideSpinnerAfterDelayWithText:@"Disconnected" andImageName:@"warning.png"];
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
    
    [[NSNotificationCenter defaultCenter] postNotificationName:XMPPREACHABILITY object:[NSDictionary dictionaryWithObjectsAndKeys:@"Not Connected", @"status", @"unsecure_icon", @"image", nil]];
    
    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                      operation:@"XMPPREACHABILITY"
                                        Content:@"Not Connected"
                                      parameter:@""];
    
    /*
     if (![AppDel appIsDisconnected])
     {
     [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__] operation:@"ForceFullyConnectOpenFire" Content:@"When net is on " parameter:@""];
     
     [AppDel connect];
     
     }*/
    
    
    
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
    // dispatch_queue_t que1 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    
    
    
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
    
    if(TARGET_IPHONE_SIMULATOR)
        NSLog(@"....didReceiveMessage fromOccupant message %@",message);
    
    
    
    
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
    NSError *error = nil;
    
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
        
        [[AppDel arr_stateTransferAccount] removeObject:[NSString stringWithFormat:@"%@" ,info.from.bare] ];
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
                    [que_t addOperationWithBlock:^{
                        
                        
                        NSLog(@"JOINING ROOM......room name  %@ ...%@",roomObj.room_jidStr,roomObj.lastMessageDate);
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
                        
                        NSLog(@"JOINING ROOM WITH ... %@....%@ ....%@",sender.roomJID,history,seconds);
                        
                        [sender joinRoomUsingNickname:self.xmppStream.myJID.user history:history];
                    }];
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
                        
                        if (![[self xmppStream] authenticateWithPassword:[[NSUserDefaults standardUserDefaults] valueForKey:@"kXMPPmyPassword"] error:&error])
                        {
                            [[NSNotificationCenter defaultCenter] postNotificationName:XMPPREACHABILITY object:[NSDictionary dictionaryWithObjectsAndKeys:@"Not Connected", @"status", @"unsecure_icon", @"image", nil]];
                            
                            [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                                              operation:@"XMPPREACHABILITY"
                                                                Content:@"Not Connected"
                                                              parameter:@""];
                        }
                        
                        else
                        {
                            [[NSNotificationCenter defaultCenter] postNotificationName:XMPPREACHABILITY object:[NSDictionary dictionaryWithObjectsAndKeys:@"Securely Connected", @"status", @"secure_icon", @"image", nil]];
                            
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
        
        dispatch_queue_t que1 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
        
        [room addDelegate:self delegateQueue:que1];
        
        NSXMLElement * history=nil;
        
        
        [room joinRoomUsingNickname:xmppStream.myJID.user history:history];
        
        [room fetchRoomInfo];
    }];
    
    
    
}


- (void)xmppMUC:(XMPPMUC *)sender roomJID:(XMPPJID *) roomJID didReceiveInvitationDecline:(XMPPMessage *)message
{
    
}




#pragma mark vCard


- (void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule
        didReceivevCardTemp:(XMPPvCardTemp *)vCardTemp
                     forJID:(XMPPJID *)jid
{
    NSLog(@".... VCard JID %@",[jid bare]);
    
    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                      operation:@"__XLC_XMPPStreamLifeCycle__"
                                        Content:@""
                                      parameter:@""];
}

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
        [[NSNotificationCenter defaultCenter] postNotificationName:XMPPREACHABILITY object:[NSDictionary dictionaryWithObjectsAndKeys:@"Securely Connected", @"status", @"secure_icon", @"image", nil]];
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
        
        [[NSNotificationCenter defaultCenter] postNotificationName:XMPPREACHABILITY object:[NSDictionary dictionaryWithObjectsAndKeys:@"Not Connected", @"status", @"unsecure_icon", @"image", nil]];
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

/*
- (void)updatevCard
{
    
}
*/

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
        
        [self getVcard:[XMPPJID jidWithString:[NSString stringWithFormat:@"%@@imyourdoc.com",[[NSUserDefaults standardUserDefaults] stringForKey:kXMPPmyJID]]]];
        
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
        
        NSLog(@".....%@",error2);
        
    }
    
    
    return  contact;
    
}


-(InboxMessage *)fetchOrInsertMessage:(NSString *)jid
{
    InboxMessage * message=nil;
    
    
    NSFetchRequest * req=[NSFetchRequest fetchRequestWithEntityName:@"InboxMessage"];
    
    req.predicate=[NSPredicate predicateWithFormat:@"jidStr=%@",jid];
    
    message=[[self.managedObjectContext_roster executeFetchRequest:req error:nil] lastObject];
    
    if(message==nil)
    {
        message=[NSEntityDescription insertNewObjectForEntityForName:@"InboxMessage" inManagedObjectContext:self.managedObjectContext_roster];
        message.jidStr=jid;
        
        message.dateCreation=[NSDate date];
        
        [self.managedObjectContext_roster save:nil];
    }
    
    
    
    
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


-(void)addInboxMessage:(ChatMessage *)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        
        [self.managedObjectContext_roster lock];
        
        InboxMessage * msg= nil;
        
        if ([message.chatMessageTypeOf integerValue ] == ChatMessageType_Broadcast)
        {
            msg= [self fetchOrInsertMessage:message.thumb];
            msg.chatMessageTypeOf=[NSNumber numberWithInt:ChatMessageType_Broadcast];
            msg.lastUpdated = message.timeStamp;
        }
        else{
            msg= [self fetchOrInsertMessage:message.uri];
            msg.lastUpdated = message.timeStamp;
        }
        
        [msg addMessageObject:message];
        
        msg.lastUpdated=message.timeStamp;
        
        msg.messageType=message.isRoomMessage;
        
        if([[message isRoomMessage] boolValue])
            msg.room=[self fetchRoom:message.uri];
        else
            msg.user=[self fetchUserForJIDString:message.uri];
        
        
        if(message.bcSubject!=nil)
        {
            msg.chatMessageTypeOf=[NSNumber numberWithInt:ChatMessageType_Broadcast];
            msg.jidStr=message.thumb;
        }
        
        
        NSError *error2=nil;
        
        if([self.managedObjectContext_roster hasChanges])
            [self.managedObjectContext_roster save:&error2];
        
        [self.managedObjectContext_roster unlock];
        NSLog(@".....%@",error2);
        
    });
    
    
    
    
}

-(InboxMessage*)addInboxMessageGroupChat:(ChatMessage *)message
{  InboxMessage * msg= nil;
    
    if (message) {
        
        [self.managedObjectContext_roster lock];
        
        
        
        
        msg= [self fetchOrInsertMessage:message.uri];
        
        [msg addMessageObject:message];
        msg.lastUpdated=message.timeStamp;
        
        msg.messageType=message.isRoomMessage;
        
        
        if([[message isRoomMessage] boolValue])
        {
            msg.room=[self fetchRoom:message.uri];
            
            if(msg.room == nil)
            {
                XMPPJID *fromJid = [XMPPJID jidWithString:message.uri];
                msg.room = [self fetchOrInsertRoom:[[XMPPRoom alloc] initWithRoomStorage:[XMPPRoomMemoryStorage sharedInstanse] jid:fromJid]];
            }
            else
            {
                if (msg.room.streamJidStr == nil)
                {
                    NSLog(@"%@",msg.room);
                    
                }
            }
            
        }
        
        
        else
            msg.user=[self fetchUserForJIDString:message.uri];
        
        
        if([[message isRoomMessage] boolValue])
        {
            //msg.room=[self fetchRoom:message.uri];
            msg.oldMessageCount =[NSNumber numberWithInt:-1];
            msg.isLoadingCompleteInGroupChat =NO;
            
        }
        
        msg.chatMessageTypeOf=[NSNumber numberWithInt:ChatMessageType_Group];
        
        
        NSError *error2=nil;
        
        if([self.managedObjectContext_roster hasChanges])
            [self.managedObjectContext_roster save:&error2];
        
        [self.managedObjectContext_roster unlock];
        NSLog(@".....%@",error2);
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
        NSLog(@".....%@",error2);
        
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

@end
