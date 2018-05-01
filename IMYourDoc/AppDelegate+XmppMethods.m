//
//  AppDelegate+XmppMethods.m
//  IMYourDoc
//
//  Created by OSX on Friday  11/03/16. After Build 5.5
//  Copyright (c) 2016 vijayvir . All rights reserved.
//

#import "AppDelegate+XmppMethods.h"

#import  "AppDelegate+ClassMethods.h"

#import "ChatViewController.h"
#import "HomeViewController.h"
#import "LoginViewController.h"
#import "GroupChatReadbyList+ClassMethod.h"

#import "BroadCastMessageSender+ClassMetod.h"
@implementation AppDelegate (XmppMethods)







#pragma mark -  ••••• OutGoing  ••••••

#pragma mark Global

#pragma mark Simple


-(void)leoResendInQueueWithChatMessage:(NSString *)messageID
{
    
    double delayInSeconds = 10.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void)
                   {
                       ChatMessage * chatmessage =[ ChatMessage getChatMessageObjectWithMessageID:messageID];
                       
                       if (chatmessage)
                       {
                           if ([chatmessage.chatState intValue] == ChatStateType_Sending)
                           {
                               if (![chatmessage.retryState isEqualToNumber:@(RetryStatusType_three)])
                               {
                                   
                                   if ([chatmessage.retryState isEqualToNumber:@(RetryStatusType_one)])
                                   {
                                       chatmessage.retryState = @(RetryStatusType_two);
                                       //     chatmessage.content = @"RetryStatusType_two";
                                       
                                       
                                   }
                                   else  if ([chatmessage.retryState isEqualToNumber:@(RetryStatusType_two)])
                                   {
                                       
                                       chatmessage.retryState = @(RetryStatusType_three);
                                       //  chatmessage.content = @"RetryStatusType_three";
                                   }
                                   
                                   
                                   chatmessage.isResending = [NSNumber numberWithBool:YES];
                                   
                                   if([self.managedObjectContext_roster hasChanges])
                                   {
                                       [self.managedObjectContext_roster save:nil];
                                   }
                                   [self leoXmppStreamSendMessageToOpenFireWithChatMessage:chatmessage];
                                   
                                   [self leoResendInQueueWithChatMessage:chatmessage.messageID];
                                   
                                   
                               }
                           }
                           
                       }
                       
                   });
    
}
-(void)leoXmppStreamSendMessageToOpenFireWithChatMessage:(ChatMessage*)chatmessage{
    
    {
        
        
        if([chatmessage.chatState intValue]!= ChatStateType_Delivered &&[chatmessage.chatState intValue]!= ChatStateType_Read)
        {
            chatmessage.chatState = [NSNumber numberWithInt:ChatStateType_Sending];
            
            
            [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                              operation:@"Resend"
                                                Content:chatmessage.messageID
                                              parameter:[ChatMessage ChatTypeToStr:chatmessage.chatState.intValue]];
            
            
            chatmessage.isResending=[NSNumber numberWithBool:YES];
            
            chatmessage.lastResend=[NSDate date];
            
            
            if([self.managedObjectContext_roster hasChanges])
            {
                [self.managedObjectContext_roster save:nil];
            }
        }
        
        if ([chatmessage.fileTypeChat intValue] == fileTypeChat_File )
        {
            
            if([chatmessage.requestStatus intValue]!= RequestStatusType_uploaded && [chatmessage.requestStatus intValue]!= RequestStatusType_fileIsUploadedButMessageIsNotSent )
                return;
            
            
            NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
            
            [message addAttributeWithName:@"type" stringValue:@"chat"];
            
            
            NSString *jidString = [[xmppStream myJID] bare];
            
            
            [message addAttributeWithName:@"from" stringValue:jidString];
            
            [message addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@", chatmessage.displayName]];
            
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
            
            [message addAttributeWithName:@"type" stringValue:@"chat"];
            
            
            NSString *jidString = [[xmppStream myJID] user];
            
            
            [message addAttributeWithName:@"from" stringValue:[NSString stringWithFormat:@"%@@imyourdoc.com", jidString]];
            
            [message addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@", chatmessage.displayName]];
            
            
            @autoreleasepool {
                VCard * vcard=[self fetchVCard:[XMPPJID jidWithString:chatmessage.uri]];
                (void)vcard;
            }
            
            
            
            
            
            {
                NSDictionary * dictionary=[NSDictionary  dictionaryWithObjectsAndKeys:chatmessage.content,@"content",[NSString stringWithFormat:@"%@",[NSDate date]],@"timestamp",chatmessage.identityuri,@"from",chatmessage.uri,@"to",chatmessage.messageID,@"messageID", nil];
                
                NSXMLElement *body = [NSXMLElement elementWithName:@"body" stringValue:[dictionary JSONString]];
                
                [message addChild:body];
                
                [message addProperty:@"message_version" value:@"2.0" type:@"string"];
            }
            
            
            NSXMLElement *xMessage = [NSXMLElement elementWithName:@"x" xmlns:@"jabber:x:event"];
            
            [xMessage addChild:[NSXMLElement elementWithName:@"offline"]];
            
            [xMessage addChild:[NSXMLElement elementWithName:@"delivered"]];
            
            [xMessage addChild:[NSXMLElement elementWithName:@"displayed"]];
            
//            [xMessage addChild:[NSXMLElement elementWithName:@"composing"]];
            
            
            [message addChild:xMessage];
            
            
            [xmppStream sendElement:message];
        }
        
        
        
    }
    
}

#pragma mark  GROUPCHAT

#pragma mark  Broadcast
-(void)broadcastMessagedidSendWithID:(NSString*)messageid{
    // Broadcast
    
    {
        
        {
            NSFetchRequest *alreadyExists = [[NSFetchRequest alloc] initWithEntityName:@"BroadCastMessageSender"];
            [alreadyExists setPredicate:[NSPredicate predicateWithFormat:@"messageId=%@", messageid]];
            NSArray *alreadyExistsArr = [self.managedObjectContext_roster executeFetchRequest:alreadyExists error:nil];
            
            
            BroadCastMessageSender *messagebc = [alreadyExistsArr lastObject];
            
            if (messagebc != nil)
            {
                messagebc.status = [NSNumber numberWithInt:BCMessageType_Sent];
                
                [[self managedObjectContext_roster] save:nil];
                
            }
        }
    }
}
- (void)sendbroadcastMessageToOpenFire:(BroadCastMessageSender*)bcmessage
{
    NSXMLElement *addressElement = [NSXMLElement elementWithName: @"addresses" xmlns: @"http://jabber.org/protocol/address"];
    
    NSXMLElement *message = [NSXMLElement elementWithName: @"message"];
    
    for (id user in bcmessage.recipientjids)
    {
        NSXMLElement *address = [NSXMLElement elementWithName: @"address"];
        
        [address addAttributeWithName: @"type" stringValue: @"to"];
        
        [address addAttributeWithName: @"jid" stringValue: (NSString *)user];
        
        [addressElement addChild:address];
    }
    
    
    
    NSXMLElement *propertiesElement = [NSXMLElement elementWithName: @"properties" xmlns: @"http://www.jivesoftware.com/xmlns/xmpp/properties"];
    
    
    NSXMLElement *property = [NSXMLElement elementWithName: @"property"];
    
    [property addAttributeWithName: @"message_type" stringValue: @"Broadcast_Message"];
    
    [propertiesElement addChild:property];
    
    [message addProperty: @"message_type" value:@"Broadcast_Message" type:@"string"];
    
    [message addAttributeWithName: @"from" stringValue: [[self.xmppStream myJID] bare]];
    
    [message addAttributeWithName: @"id" stringValue: bcmessage.messageId];
    
    [message addAttributeWithName: @"to" stringValue: @"imyourdoc.com"];
    
    
    
    [message addChild:[NSXMLElement elementWithName:@"subject" objectValue:bcmessage.ofSubject.subject]];
    
    NSDictionary * dictionary=[NSDictionary  dictionaryWithObjectsAndKeys:
                               bcmessage.message,@"content",
                               [NSString stringWithFormat:@"%@",bcmessage.date],@"timestamp",
                               [[self.xmppStream myJID] bare],@"from",
                               bcmessage.ofSubject.subject,@"subject",
                               @"headline",@"type",
                               bcmessage.groupId,@"group_id",
                               bcmessage.ofSubject.subjectId,@"subject_id",
                               
                               bcmessage.messageId,@"messageID", nil];
    
    
    
    NSXMLElement *body = [NSXMLElement elementWithName:@"body" stringValue:[dictionary JSONString]];
    
    [message addChild:body];
    
    
    [message addChild: addressElement];
    
    
    NSLog(@"......%@",message);
    
    [self.xmppStream sendElement: message];
}

#pragma mark -  ••••• INCOMMING ••••••
#pragma mark Global

/**
 * Introduce in 5.5
 *  When this method is called ? \n \n
 *
 * When our message has been recieved by SERVER. Server will give us aknowldgement.
 *
 * What this will do ?
 *
 * It will modify our view and database . change message object status to ChatStateType_Sent
 **/

- (void)leoXmppStreamReceive:(XMPPStream *)sender didServerAcknowlgement:(XMPPMessage *)message
{
    NSString* messageID = [[message elementForName:@"x"] stringValue];
    ChatMessage *chat = [ChatMessage getChatMessageObjectWithMessageID:messageID];
    if (chat)
    {
        
        [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                          operation:@"checkState"
                                            Content:chat.messageID
                                          parameter:[ChatMessage ChatTypeToStr:chat.chatState.intValue]];
        
        chat.chatState=[NSNumber numberWithInt:ChatStateType_Sent];
        chat.requestStatus=[NSNumber numberWithInt:RequestStatusType_uploaded];
        
        [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                          operation:@"checkState"
                                            Content:chat.messageID
                                          parameter:[ChatMessage ChatTypeToStr:chat.chatState.intValue]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[AppDel managedObjectContext_roster] save:nil];
        });
        
    }
    else
    {
        NSLog(@" not exist " );
        
    }
}

/**
 * Introduce in 5.5
 *  When this method is called ? \n \n
 *
 * When  other user is offline . and server sent notification to other user and tell us that Serber hase notification to that user .
 *
 * What this will do ?
 *
 * It will modify our view and database . change message object status to ChatStateType_Notification_EmailSent
 *
 * @More:  it removed our web services
 **/
- (void)LeoXmppStreamReceive:(XMPPStream *)sender didServerSentNotification:(XMPPMessage *)message
{
    
    
    
    
    NSManagedObjectContext *childObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [childObjectContext setParentContext:[AppDel managedObjectContext_roster]];
    [childObjectContext performBlock:^{
        
    }];
    
    NSString *messageID = [[message elementForName:@"x"] stringValue];
    ChatMessage *chat = [ChatMessage getChatMessageObjectWithMessageID:messageID];
    
    if (chat)
    {
        if ([chat.chatState intValue] <= ChatStateType_Delivered)
        {
            if ([chat.chatState intValue] != ChatStateType_Delivered && [chat.chatState intValue] != ChatStateType_Read )
            {
                if (!chat.isRoomMessage)
                    chat.chatState = [NSNumber numberWithInt:ChatStateType_Notification_EmailSent];
                
                chat.requestStatus=[NSNumber numberWithInt:RequestStatusType_uploaded];
                [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                                  operation:@"to >> S_Send_notification_device"
                                                    Content:chat.messageID
                                                  parameter: [ChatMessage ChatTypeToStr:[chat.chatState intValue]]];
                
                if([self.managedObjectContext_roster hasChanges])
                    [self.managedObjectContext_roster save:nil];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [[AppDel managedObjectContext_roster] save:nil];
                });
                
            }
            
            [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__] operation:@"checkState" Content:chat.messageID parameter:[ChatMessage ChatTypeToStr:chat.chatState.intValue]];
        }
        
        [self groupMessageReadByListChangeStatus:@"Notification sent" ofMessage: chat from:[message from] ];
        
        
    }
    
    else
    {
        NSLog(@" not exist " );
        
    }
    
    
    
}

-(void)leoXmppStreamReceive:(XMPPStream *)sender hasDeliveredChatStateWithBody:(XMPPMessage *)message
{
    [self broadcastDidReceiveDelivedMessageOfSender:message];
    
    ChatMessage * nextMessage=[ChatMessage getLastFailedMessageForJID:[message.from bare]];
    
    if(nextMessage)
    {
        [self resendMessage:nextMessage];
    }
    
    
    NSXMLElement *messageEvent = [message elementForName:@"x" xmlns:@"jabber:x:event"];
    
    NSXMLElement *deliveredEvent = [messageEvent elementForName:@"delivered"];
    
    
    NSPredicate *pred;
    
    
    if ([messageEvent elementForName:@"id"])
    {
        pred = [NSPredicate predicateWithFormat:@"messageID like %@", [[messageEvent elementForName:@"id"] stringValue]];
    }
    
    else if ([deliveredEvent elementForName:@"id"])
    {
        pred = [NSPredicate predicateWithFormat:@"messageID like %@", [[deliveredEvent elementForName:@"id"] stringValue]];
    }
    
    
    NSArray *temp = [[CoreDataHelper searchObjectsInContext:@"ChatMessage" : pred : nil : NO : self.managedObjectContext_roster] mutableCopy];
    
    
    if (temp != nil && [temp count] > 0)
    {
        ChatMessage *msg = [temp lastObject];
        
        
        if (msg.isOutbound == OutBoundType_Right)
        {
            if ([msg.chatState intValue] != ChatStateType_Read)
            {
                
                [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                                  operation:@"MassageStatus>>From>>To"
                                                    Content:[NSString stringWithFormat:@"%@ %@",msg.messageID, [ChatMessage ChatTypeToStr:msg.chatState.intValue]]
                                                  parameter:[ChatMessage ChatTypeToStr:ChatStateType_Delivered]];
                
                if (!msg.isRoomMessage)
                    msg.chatState = [NSNumber numberWithInt:ChatStateType_Delivered];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [[AppDel managedObjectContext_roster] save:nil];
                });
                
            }

            [self groupMessageReadByListChangeStatus:@"Delivered"
                                           ofMessage:msg
                                                from:[message from]];
        }
    }
}


-(void)leoXmppStreamReceive:(XMPPStream *)sender hasDisPlayedChatStateWithBody:(XMPPMessage *)message{
    [self broadcastDidReceiveReadMessageOfSender:message];
    
    NSXMLElement *messageEvent = [message elementForName:@"x" xmlns:@"jabber:x:event"];
    NSXMLElement *displayElement = [messageEvent elementForName:@"displayed"];
    NSPredicate *pred;
    
    if ([messageEvent elementForName:@"id"])
    {
        pred = [NSPredicate predicateWithFormat:@"messageID like %@", [[messageEvent elementForName:@"id"] stringValue]];
    }
    
    else if ([displayElement elementForName:@"id"])
    {
        pred = [NSPredicate predicateWithFormat:@"messageID like %@", [[displayElement elementForName:@"id"] stringValue]];
    }
    
    
    NSArray *temp = [[CoreDataHelper searchObjectsInContext:@"ChatMessage" : pred : nil : NO : self.managedObjectContext_roster] mutableCopy];
    
    
    if ([temp count] > 0)
    {
        ChatMessage *msg = [temp lastObject];
        
        ////-change received message to read only when on the ChatViewController or sending
        //No for above - It should display the status in any time. (Ronald)
        if(msg.isOutbound)// && [self.navController.visibleViewController isKindOfClass:[ChatViewController class]])
        {
            [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                              operation:@"MassageStatus>>From>>To"
                                                Content:[NSString stringWithFormat:@"%@ %@",msg.messageID, [ChatMessage ChatTypeToStr:msg.chatState.intValue]]
                                              parameter:[ChatMessage ChatTypeToStr:ChatStateType_Read]];
            
            NSFetchRequest *alreadyExists = [[NSFetchRequest alloc] initWithEntityName:@"XMPPRoomObject"];
            
            [alreadyExists setPredicate:[NSPredicate predicateWithFormat:@"room_jidStr=%@", msg.uri]];
            
            
            NSArray *alreadyExistsArr = [self.managedObjectContext_roster executeFetchRequest:alreadyExists error:nil];
            
            
            XMPPRoomObject *room = [alreadyExistsArr lastObject];
            
            if (!msg.roomRead)
                msg.roomRead = 0;
            
            msg.roomRead = [NSNumber numberWithInt:[msg.roomRead intValue] + 1];
            
            if (!msg.isRoomMessage || [msg.roomRead intValue] >= (room.members.count - 1))
                msg.chatState = [NSNumber numberWithInt:ChatStateType_Read];
            
            [self groupMessageReadByListChangeStatus:@"Read" ofMessage: msg from:[message from]];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[AppDel managedObjectContext_roster] save:nil];
        });
        
  
    }
}

#pragma mark  broadcast 
-(void)broadcastDidReceiveReadMessageOfSender:(XMPPMessage *)xMPPmessage
{
    
    
    
    
    
    NSString* str= [[xMPPmessage attributeForName:@"from"] stringValue];
    // Search from back to get the last space character
    NSRange range= [str rangeOfString: @"/" options: NSBackwardsSearch];
    // Take the first substring: from 0 to the space character
    NSString* finalStr = [str substringToIndex: range.location];
    
    
    
    
    
    if ([[[[xMPPmessage elementForName:@"x" xmlns:@"jabber:x:event"]elementForName:@"displayed" ]elementForName:@"id" ] stringValue])
    {
        [BroadCastMessageSender setStatusofMessageWhenReadWithMessahgId:[[[[xMPPmessage elementForName:@"x" xmlns:@"jabber:x:event"]elementForName:@"displayed" ]elementForName:@"id" ] stringValue] withRecipitId:finalStr];
        
    }
    else if ([[[xMPPmessage elementForName:@"x" xmlns:@"jabber:x:event"] elementForName:@"id"] stringValue])
    {
        [BroadCastMessageSender setStatusofMessageWhenReadWithMessahgId:[[[xMPPmessage elementForName:@"x" xmlns:@"jabber:x:event"] elementForName:@"id"] stringValue] withRecipitId:finalStr];
        
    }
    
    
    
    
    
    
}

-(void)broadcastDidReceiveDelivedMessageOfSender:(XMPPMessage *)xMPPmessage
{
    
    //
    NSString* str= [[xMPPmessage attributeForName:@"from"] stringValue];
    // Search from back to get the last space character
    NSRange range= [str rangeOfString: @"/" options: NSBackwardsSearch];
    // Take the first substring: from 0 to the space character
    NSString* finalStr = [str substringToIndex: range.location];
    
    
    if ([[[[xMPPmessage elementForName:@"x" xmlns:@"jabber:x:event"]elementForName:@"delivered" ]elementForName:@"id" ] stringValue])
    {
        [BroadCastMessageSender setStatusofMessageWhenDelievedWithMessahgId:[[[[xMPPmessage elementForName:@"x" xmlns:@"jabber:x:event"]elementForName:@"delivered" ]elementForName:@"id" ] stringValue] withRecipitId:finalStr];
        
    }
    else if ([[[xMPPmessage elementForName:@"x" xmlns:@"jabber:x:event"] elementForName:@"id"] stringValue])
    {
        [BroadCastMessageSender setStatusofMessageWhenDelievedWithMessahgId:[[[xMPPmessage elementForName:@"x" xmlns:@"jabber:x:event"] elementForName:@"id"] stringValue] withRecipitId:finalStr];
        
    }
    
}

- (void)broadcastDidnotReceivedMessage:(NSString *)messageid
{
    
}



#pragma mark Simple
/**
 * Introduce in 5.5 \n
 *
 *  When this method is called ? \n \n
 *
 *  When our message is send to server , we check state of message after 30 sec . If it is in sending state , app resend
 *   message to Server with increment  count of retryState  and  recall this method till retryState is RetryStatusType_three
 **/

-(void)leoXmppStreamReceive:(XMPPStream *)sender isChatMessageWithBody:(XMPPMessage *)message{
    {
        NSString *fromUSERJID = [message.from bare];
        
        ChatMessage * nextMessage=[ChatMessage getLastFailedMessageForJID:[message.from bare]];
        
        if(nextMessage)
        {
            [self resendMessage:nextMessage];
        }
        NSXMLElement *subjectXMPP = [message elementForName:@"subject"];
        
        
        isAppInBackgroundMsg = TRUE;
        
        
        NSXMLElement * messageVersion=[message getPropertyForName:@"message_version"];
        
        if(messageVersion==nil)
        {
            
            NSString *body1 = [[message elementForName:@"body"] stringValue];
            
            
            if ([body1 rangeOfString:@"~$^^xxx*xxx~$^^"].location != NSNotFound)
            {
                static NSDateFormatter *date = nil;
                
                
                if (date == nil)
                {
                    date = [[NSDateFormatter alloc] init];
                    
                    [date setTimeStyle:NSDateFormatterShortStyle];
                }
                
                
                
                
                
                [self service_ReportCloseConversationWithjid:[[message from]bare]];
                
                [ConversationLog resetConversationLogMYJiD:[AppDel myJID] WithJID:[[message from] bare]withContext:[AppDel managedObjectContext_roster]];
                
                
                
                NSPredicate *predicateForIM;
                
                predicateForIM = [NSPredicate predicateWithFormat:@"uri like %@ and mark_deleted=%@", fromUSERJID,[NSNumber numberWithBool:mark_deleted_NO]];
                
                
                NSMutableArray *itemsIM = [[CoreDataHelper searchObjectsInContext:@"ChatMessage" :predicateForIM :@"timeStamp" :NO :[self managedObjectContext_roster]] mutableCopy];
                
                
                NSString *tempURIDisplayName = @"";
                
                
                
                
                
                if(itemsIM.count>0)
                {
                    [[[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"This conversation was closed by %@. Please go to new conversation section to start conversation again.", [[message from] user]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
                    
                    if([self.navController.visibleViewController isKindOfClass:[ChatViewController class]])
                    {
                        if([[[(ChatViewController *) self.navController.visibleViewController jid] bare] isEqualToString:[message.from bare]])
                            [self.loginView.navigationController popToViewController:self.homeView animated:YES];
                    }
                }
                
                for (ChatMessage *message in itemsIM)
                {
                    if ([message isOutbound])
                    {
                        tempURIDisplayName = message.displayName;
                    }
                    
                    
                    message.mark_deleted = [NSNumber numberWithBool:mark_deleted_YES];
                    
                    
                    
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        NSError *error = nil;
                        
                        if([self.managedObjectContext_roster hasChanges])
                            if (![managedObjectContext_roster save:&error])
                            {
                                NSLog(@"%@", [error domain]);
                            }
                    });
                }
                
                
                if ([self.openConversationArray containsObject:tempURIDisplayName])
                {
                    [self.openConversationArray removeObject:tempURIDisplayName];
                }
            }
            
            else if (subjectXMPP != nil)
            {
                NSRange range = [[subjectXMPP stringValue] rangeOfString:URLBUILER(@"https://api.imyourdoc.com/uploads") ];
                
                
                if (range.location != NSNotFound)
                {
                    NSString *messageID = [message attributeStringValueForName:@"id"];
                    BOOL isExist = [ChatMessage checkIfExistsChatMessageObjectWithMessageID:messageID];
                    if (isExist)
                    {
                        [self sendChatState:SendChatStateType_delivered withBuddy:message.from.bare withMessageID:[message attributeStringValueForName:@"id"] isGroupChat:NO];
                        return;
                    }
                    
                    
                    NSXMLElement *deleayElement = [message elementForName:@"delay" xmlns:@"urn:xmpp:delay"];
                    
                 
                    
                    
                    ChatMessage *msg    =  [self insertChatMessage:[message attributeStringValueForName:@"id"]];
                    
                    
                    
                    NSXMLElement * timeelement=[message elementForName:@"properties" xmlns:@"http://www.jivesoftware.com/xmlns/xmpp/properties"];
                    
                    NSArray * elements=[timeelement elementsForName:@"property"];
                    
                    
                    for(  NSXMLElement * property in elements)
                    {
                        
                        if([[[property elementForName:@"name"] stringValue] isEqualToString:@"file_type"])
                        {
                            NSString * value=[[property elementForName:@"value"] stringValue];
                            
                            msg.fileMediaType=value;
                            
                        }
                        
                        
                    }
                    msg.identityuri     = [AppDel myJID];
                    
                    msg.content         = [subjectXMPP stringValue];
                    
                    msg.isOutbound      = OutBoundType_Left;
                    
                    msg.fileTypeChat    = [NSNumber numberWithInt:fileTypeChat_File];
                    
                    msg.hasBeenRead     = NO;
                    
                    
                    if([msg.fileMediaType isEqualToString :@"image"]==YES )
                    {
                        msg.thumb           = body1;
                    }
                    else
                    {
                        NSString * extension=[[msg.content lastPathComponent] pathExtension];
                        
                        if([[extension lowercaseString] isEqualToString:@"pdf"])
                        {
                            
                            
                            
                            msg.thumb=[UIImagePNGRepresentation([UIImage imageNamed:kfile_pdf]) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
                            
                        }
                        else if([[extension lowercaseString] isEqualToString:@"doc"]||[[extension lowercaseString] isEqualToString:@"docx"])
                        {
                            msg.thumb=[UIImagePNGRepresentation([UIImage imageNamed:kfile_word]) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
                            
                        }
                        
                        else  if([[extension lowercaseString] isEqualToString:@"xls"]||[[extension lowercaseString] isEqualToString:@"xlsx"])
                        {
                            msg.thumb=[UIImagePNGRepresentation([UIImage imageNamed:kfile_xsl]) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
                            
                        }
                        else if([[extension lowercaseString] isEqualToString:@"txt"])
                        {
                            msg.thumb=[UIImagePNGRepresentation([UIImage imageNamed:kfile_text]) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
                            
                        }
                        else  if([[extension lowercaseString] isEqualToString:@"ppt"]||[[extension lowercaseString] isEqualToString:@"pptx"])
                        {
                            msg.thumb=[UIImagePNGRepresentation([UIImage imageNamed:kfile_ppt]) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
                        }
                        else  if([[extension lowercaseString] isEqualToString:@"jpg"]||[[extension lowercaseString] isEqualToString:@"jpeg"]||[[extension lowercaseString] isEqualToString:@"png"])
                        {
                            msg.thumb      = body1;
                        }
                        
                        else
                        {
                            msg.thumb=[UIImagePNGRepresentation([UIImage imageNamed:kfile_extra]) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
                        }
                        
                        
                        
                    }
                    
                    
                    
                    
                    msg.messageID       = [message attributeStringValueForName:@"id"];
                    
                    if (!msg.isRoomMessage)
                        msg.chatState   = [NSNumber numberWithInt:ChatStateType_deliveredByReciever];
                    
                    
                    
                    
                    
                    if (deleayElement != nil)
                    {
                        msg.timeStamp = [XMPPDateTimeProfiles parseDateTime:[deleayElement attributeStringValueForName:@"stamp"]];
                    }
                    
                    else
                    {
                        msg.timeStamp   = [NSDate date];
                    }
                    
                    msg.uri             = [message.from bare];
                    
                    msg.displayName     = [message.from bare];
                    
                    msg.requestStatus   = [NSNumber numberWithInt:RequestStatusType_deliveredByRecieverGroup];
                    
                    msg.mark_deleted    = [NSNumber numberWithBool:mark_deleted_NO];
                    
                    
                    
                    
                    [self addInboxMessage:msg];
                    
                    
                    
                    
                    
                    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                                      operation:@"check Message State "
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
                    
                    
                    
                    {
                        [self sendChatState:SendChatStateType_delivered withBuddy:[[message from] bare] withMessageID:[message attributeStringValueForName:@"id"] isGroupChat:NO];
                    }
                    
                    
                    [self updateOpenConversationArray:[[message from] bare]];
                    
                    
                    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"Alerts"])
                    {
                        
                    }
                    
                    
                    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"Vibrate"])
                    {
                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                    }
                    
                    
                    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"Sounds"])
                    {
                        [self playSoundForKey];
                    }
                }
            }
            
            else
            {
                if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive)
                {
                    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"Alerts"])
                    {
                        [self backgroundNotification:message.from.user withxMPPmessage:message];
                    }
                }
                
                
                [[NSUserDefaults standardUserDefaults] setObject:message.from.user forKey:@"fromJID"];
                
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                
                ChatMessage *msg    =
                
                [self insertChatMessage:[message attributeStringValueForName:@"id"]];
                
                msg.identityuri     = [AppDel myJID];
                
                msg.content         = body1;
                
                msg.isOutbound      = OutBoundType_Left;
                
                msg.messageID       = [message attributeStringValueForName:@"id"];
                
                msg.hasBeenRead     = NO;
                
                msg.chatState       = [NSNumber numberWithInt:ChatStateType_deliveredByReciever];
                
                
                NSXMLElement *deleayElement = [message elementForName:@"delay" xmlns:@"urn:xmpp:delay"];
                
                
                if (deleayElement != nil)
                {
                    msg.timeStamp = [XMPPDateTimeProfiles parseDateTime:[deleayElement attributeStringValueForName:@"stamp"]];
                }
                
                else
                {
                    static NSDateFormatter *dateFormatter = nil;
                    
                    
                    if (dateFormatter == nil)
                    {
                        dateFormatter = [[NSDateFormatter alloc] init];
                        
                        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
                    }
                    
                    
                    msg.timeStamp   = [NSDate date];
                }
                
                
                msg.uri             = message.from.bare;
                
                msg.fileTypeChat    = [NSNumber numberWithInt:fileTypeChat_message];
                
                msg.requestStatus   = [NSNumber numberWithInt:RequestStatusType_deliveredByRecieverGuest];
                
                msg.displayName     = message.from.bare;
                
                msg.mark_deleted    = [NSNumber numberWithBool:mark_deleted_NO];
                
                
                
                if (![AppDel appIsDisconnected])
                {
                    
                    
//                    __block  NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys
//                                                   :@"updateMessageReceivers", @"method",
//                                                   msg.uri, @"sender_jid",
//                                                   msg.messageID,@"message_id",
//                                                   [AppDel myJID], @"roomjid",
//                                                   [[NSUserDefaults standardUserDefaults] objectForKey:@"loginToken"], @"login_token",
//                                                   nil];
                    
                    //                    [que_t addOperationWithBlock:^{
                    //
                    //                        [[WebHelper sharedHelper] setWebHelperDelegate:self];
                    //
                    //                        [[WebHelper sharedHelper] sendRequest:dict tag:S_UpdateMessageReceivers delegate:self];
                    //                    }];
                    
                    
                }
                
                
                [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                                  operation:@"check Message State "
                                                    Content:msg.messageID
                                                  parameter:[ChatMessage ChatTypeToStr:msg.chatState.intValue]];
                [self addInboxMessage:msg];
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSError *error = nil;
                    
                    if([self.managedObjectContext_roster hasChanges])
                        if (![self.managedObjectContext_roster save:&error])
                        {
                            NSLog(@"%@", [error domain]);
                        }
                });
                
                
                
                {
                    [self sendChatState:SendChatStateType_delivered withBuddy:message.from.bare withMessageID:[message attributeStringValueForName:@"id"] isGroupChat:NO];
                }
                
                
                [self updateOpenConversationArray:message.from.bare];
                
                
                if ([[NSUserDefaults standardUserDefaults] boolForKey:@"Alerts"])
                {
                    
                }
                
                
                if ([[NSUserDefaults standardUserDefaults] boolForKey:@"Vibrate"])
                {
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                }
                
                
                if ([[NSUserDefaults standardUserDefaults] boolForKey:@"Sounds"])
                {
                    [self playSoundForKey];
                }
            }
            
            [self.homeView updateMessagCount];
        }
        else if([[[messageVersion elementForName:@"value"] stringValue] isEqualToString:@"2.0"])
        {
            
            
            NSString *bodyContent = [[message elementForName:@"body"] stringValue];
            
            NSDictionary * jsonBody=[[NSJSONSerialization JSONObjectWithData:[bodyContent dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil] copy];
            
            
            NSString * file_path=[jsonBody objectForKey:@"file_path"];
            
            NSString *body=[jsonBody objectForKey:@"content"];
            
            if ([body rangeOfString:@"~$^^xxx*xxx~$^^"].location != NSNotFound)
            {
                static NSDateFormatter *date = nil;
                
                
                if (date == nil)
                {
                    date = [[NSDateFormatter alloc] init];
                    
                    [date setTimeStyle:NSDateFormatterShortStyle];
                }
                
                [self service_ReportCloseConversationWithjid:[[message from]bare]];
                [ConversationLog resetConversationLogMYJiD:[AppDel myJID] WithJID:[[message from] bare]withContext:[AppDel managedObjectContext_roster]];
                
                [[[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"This conversation was closed by %@. Please go to new conversation section to start conversation again.", [[message from] user]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
                
                
                [self.loginView.navigationController popToViewController:self.homeView animated:YES];
                
                
                NSPredicate *predicateForIM;
                
                predicateForIM = [NSPredicate predicateWithFormat:@"uri like %@", fromUSERJID];
                
                
                NSMutableArray *itemsIM = [[CoreDataHelper searchObjectsInContext:@"ChatMessage" :predicateForIM :@"timeStamp" :NO :[self managedObjectContext_roster]] mutableCopy];
                
                
                NSString *tempURIDisplayName = @"";
                
                
                
                
                
                for (ChatMessage *message in itemsIM)
                {
                    if ([message isOutbound])
                    {
                        tempURIDisplayName = message.displayName;
                    }
                    
                    
                    message.mark_deleted = [NSNumber numberWithBool:mark_deleted_YES];
                    
                    
                    
                    
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        NSError *error = nil;
                        
                        if([self.managedObjectContext_roster hasChanges])
                            if (![managedObjectContext_roster save:&error])
                            {
                                NSLog(@"%@", [error domain]);
                            }
                    });
                }
                
                
                if ([self.openConversationArray containsObject:tempURIDisplayName])
                {
                    [self.openConversationArray removeObject:tempURIDisplayName];
                }
            }
            
            else if (file_path != nil)
            {
                NSRange range = [file_path rangeOfString:URLBUILER(@"https://api.imyourdoc.com/uploads")];
                
                
                if (range.location != NSNotFound)
                {
                    NSString *messageID = [message attributeStringValueForName:@"id"];
                    BOOL isExist = [ChatMessage checkIfExistsChatMessageObjectWithMessageID:messageID];
                    if (isExist)
                    {
                         // shammi : send notification of deliverd message to sender.
                        [self sendChatState:SendChatStateType_delivered withBuddy:message.from.bare withMessageID:[message attributeStringValueForName:@"id"] isGroupChat:NO];
                        return;
                    }
                    
                    ChatMessage *msg    = [self insertChatMessage:[jsonBody objectForKey:@"messageID"]];
                    
                    msg.fileMediaType=(NSString*)[jsonBody objectForKey:@"file_type"];
                    
                    msg.identityuri     = [AppDel myJID];
                    
                    msg.content         = file_path;
                    
                    msg.isOutbound      = OutBoundType_Left;
                    
                    msg.fileTypeChat    = [NSNumber numberWithInt:fileTypeChat_File];
                    
                    msg.hasBeenRead     = NO;
                    
                    
                    if([msg.fileMediaType isEqualToString:@"image"]==YES)
                    {
                        msg.thumb           = body;
                    }
                    else
                    {
                        NSString * extension=[[msg.content lastPathComponent] pathExtension];
                        
                        if([[extension lowercaseString] isEqualToString:@"pdf"])
                        {
                            
                            
                            
                            
                            msg.thumb=[UIImagePNGRepresentation([UIImage imageNamed:kfile_pdf]) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
                            
                        }
                        else if([[extension lowercaseString] isEqualToString:@"doc"]||[[extension lowercaseString] isEqualToString:@"docx"])
                        {
                            msg.thumb=[UIImagePNGRepresentation([UIImage imageNamed:kfile_word]) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
                            
                        }
                        
                        else  if([[extension lowercaseString] isEqualToString:@"xls"]||[[extension lowercaseString] isEqualToString:@"xlsx"])
                        {
                            msg.thumb=[UIImagePNGRepresentation([UIImage imageNamed:kfile_xsl]) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
                            
                        }
                        else if([[extension lowercaseString] isEqualToString:@"txt"])
                        {
                            msg.thumb=[UIImagePNGRepresentation([UIImage imageNamed:kfile_text]) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
                            
                        }
                        else  if([[extension lowercaseString] isEqualToString:@"ppt"]||[[extension lowercaseString] isEqualToString:@"pptx"])
                        {
                            msg.thumb=[UIImagePNGRepresentation([UIImage imageNamed:kfile_ppt]) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
                        }
                        else  if([[extension lowercaseString] isEqualToString:@"jpg"]||[[extension lowercaseString] isEqualToString:@"jpeg"]||[[extension lowercaseString] isEqualToString:@"png"])
                        {
                            msg.thumb      = body;
                        }
                        else
                        {
                            msg.thumb=[UIImagePNGRepresentation([UIImage imageNamed:kfile_extra]) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
                        }
                        
                        
                        
                    }
                    
                    
                    
                    
                    
                    
                    msg.chatState       = [NSNumber numberWithInt:ChatStateType_deliveredByReciever];
                    
                    
                    NSXMLElement *deleayElement = [message elementForName:@"delay" xmlns:@"urn:xmpp:delay"];
                    
                    
                    if (deleayElement != nil)
                    {
                        msg.timeStamp = [XMPPDateTimeProfiles parseDateTime:[deleayElement attributeStringValueForName:@"stamp"]];
                    }
                    
                    else
                    {
                        msg.timeStamp   = [NSDate date];
                    }
                    
                    
                    msg.uri             = [message.from bare];
                    
                    msg.displayName     = [message.from bare];
                    
                    msg.requestStatus   = [NSNumber numberWithInt:RequestStatusType_deliveredByRecieverGroup];
                    
                    msg.mark_deleted    = [NSNumber numberWithBool:mark_deleted_NO];
                    
                    
                    
                    
                    [self addInboxMessage:msg];
                    
                    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__] operation:@"check Message State " Content:msg.messageID parameter:[ChatMessage ChatTypeToStr:msg.chatState.intValue]];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        NSError *error = nil;
                        
                        
                        if (![self.managedObjectContext_roster save:&error])
                        {
                            NSLog(@"%@", [error domain]);
                        }
                    });
                    
                    
                    
                    {
                        [self sendChatState:SendChatStateType_delivered withBuddy:[[message from] bare] withMessageID:[message attributeStringValueForName:@"id"] isGroupChat:NO];
                    }
                    
                    
                    [self updateOpenConversationArray:[[message from] bare]];
                    
                    
                    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"Alerts"])
                    {
                         if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive)
                            [self backgroundNotification:message.from.user withxMPPmessage:message];
                    }
                    
                    
                    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"Vibrate"])
                    {
                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                    }
                    
                    
                    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"Sounds"])
                    {
                        [self playSoundForKey];
                    }
                }
            }
            
            else
            {
               
             
                
                
                [[NSUserDefaults standardUserDefaults] setObject:message.from.user forKey:@"fromJID"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                NSString *messageID = [message attributeStringValueForName:@"id"];
                BOOL isExist = [ChatMessage checkIfExistsChatMessageObjectWithMessageID:messageID];
                if (isExist)
                {
                    // shammi : send notification of deliverd message to sender.
//                    {
//                        [self sendChatState:SendChatStateType_delivered withBuddy:message.from.bare withMessageID:[message attributeStringValueForName:@"id"] isGroupChat:NO];
//                    }
                    
                    return;
                }
                
                
                ChatMessage *msg    =
                [self insertChatMessage:[jsonBody objectForKey:@"messageID"]];
                
                msg.identityuri     = [AppDel myJID];
                
                msg.content         = body;
                
                msg.isOutbound      = OutBoundType_Left;
                
                msg.messageID       = [jsonBody objectForKey:@"messageID"];
                
                msg.hasBeenRead     = NO;
                
                [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                                  operation:@"MassageStatus>>From>>To"
                                                    Content:[NSString stringWithFormat:@"%@ %@",msg.messageID, [ChatMessage ChatTypeToStr:msg.chatState.intValue]]
                                                  parameter:[ChatMessage ChatTypeToStr:ChatStateType_deliveredByReciever]];
                
                if (!msg.isRoomMessage)
                    msg.chatState   = [NSNumber numberWithInt:ChatStateType_deliveredByReciever];
                
                
                NSXMLElement *deleayElement = [message elementForName:@"delay" xmlns:@"urn:xmpp:delay"];
                
                
                if (deleayElement != nil)
                {
                    msg.timeStamp = [XMPPDateTimeProfiles parseDateTime:[deleayElement attributeStringValueForName:@"stamp"]];
                }
                
                else
                {
                    static NSDateFormatter *dateFormatter = nil;
                    
                    
                    if (dateFormatter == nil)
                    {
                        dateFormatter = [[NSDateFormatter alloc] init];
                        
                        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
                    }
                    
                    
                    msg.timeStamp   = [NSDate date];
                }
                
                
                msg.uri             = message.from.bare;
                
                msg.fileTypeChat    = [NSNumber numberWithInt:fileTypeChat_message];
                
                msg.requestStatus   = [NSNumber numberWithInt:RequestStatusType_deliveredByRecieverGuest];
                
                msg.displayName     = message.from.bare;
                
                msg.mark_deleted    = [NSNumber numberWithBool:mark_deleted_NO];
                
                
                
                
                [self addInboxMessage:msg];
                
                [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                                  operation:@"check Message State"
                                                    Content:msg.messageID
                                                  parameter:[ChatMessage ChatTypeToStr:msg.chatState.intValue]];
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSError *error = nil;
                    
                    
                    if (![self.managedObjectContext_roster save:&error])
                    {
                        NSLog(@"%@", [error domain]);
                    }
                });
                
                
                
                {
                    [self sendChatState:SendChatStateType_delivered withBuddy:message.from.bare withMessageID:[message attributeStringValueForName:@"id"] isGroupChat:NO];
                }
                
                
                [self updateOpenConversationArray:message.from.bare];
                
                
                if ([[NSUserDefaults standardUserDefaults] boolForKey:@"Alerts"])
                {
                    if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive)
                        [self backgroundNotification:message.from.user withxMPPmessage:message];
                }
                
                
                if ([[NSUserDefaults standardUserDefaults] boolForKey:@"Vibrate"])
                {
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                }
                
                
                if ([[NSUserDefaults standardUserDefaults] boolForKey:@"Sounds"])
                {
                    // backGround // ForeGround
                    [self playSoundForKey];
                }
            }
            
            [self.homeView updateMessagCount];
        }
        
    }
}

#pragma mark  GROUPCHAT

-(void)leoXmppStreamReceive:(XMPPStream *)sender IsGroupChatwithBody:(XMPPMessage *)message;

{
    {
        [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:[NSString stringWithFormat:@"KstateTransferArrayUpdateNotification"] object:nil  userInfo:nil];
        
        if ([message isMessageWithBody])
        {
            NSXMLElement * messageVersion=[message getPropertyForName:@"message_version"];
            
            if(messageVersion==nil)
            {
                if ([[message attributeStringValueForName:@"id"] isEqualToString:@"REMOVE_REQUEST"])
                {
                    XMPPJID *user_id = [XMPPJID jidWithString:[[[message from] resource] stringByAppendingString:@"@imyourdoc.com"]];
                    
                    
                    XMPPRoomObject *room = nil;
                    
                    room = [[self.roomsArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"room_jidStr=%@", [message.from bare]]] lastObject];
                    
                    
                    XMPPRoomAffaliations *user = [[room.members filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"memberJidStr=%@", user_id.bare]] anyObject];
                    
                    
                    if ([[room roleForJid:[xmppStream myJID]] isEqualToString:@"owner"])
                    {
                        
                        
                        [room.room deleteMember:[RoomMembers roomMembers:user.jid]];
                    }
                    
                    
                    user.role = @"none";
                    
                    
                    if ([[xmppStream myJID] isEqualToJID:user_id])
                    {
                        room.room_status = @"deleted";
                    }
                    
                    
                    [[AppDel managedObjectContext_roster] save:nil];
                    
                    
                    return;
                }
                
                if ([[message attributeStringValueForName:@"id"] isEqualToString:@"IMYOURDOC_CLOSE"])
                {
                    
                    if ([[[message elementForName:@"body"] stringValue] isEqualToString:@"~$^^xxx*xxx~$^^"])
                    {
                        
                        
                        
                        NSXMLElement *deleayElement = [message elementForName:@"delay" xmlns:@"urn:xmpp:delay"];
                        
                        
                        NSDate *dateOfMessage = nil;
                        
                        
                        if (deleayElement != nil)
                        {
                            dateOfMessage = [XMPPDateTimeProfiles parseDateTime:[deleayElement attributeStringValueForName:@"stamp"]];
                        }
                        
                        
                        XMPPRoomObject *room1 = [self fetchRoom:[[message from] bare]];
                        
                        
                        NSComparisonResult result;
                        
                        
                        
                        if (dateOfMessage)
                        {
                            result = [dateOfMessage compare:room1.creationDate]; // comparing two dates
                            
                            if(result==NSOrderedAscending)
                            {
                                
                                
                                
                                NSLog(@"today is less dateNotFormatted_older");
                            }
                            else if(result==NSOrderedDescending)
                            {
                                
                                room1.creationDate = dateOfMessage;
                                [[AppDel  managedObjectContext_roster] save:nil];
                                
                                
                                
                                {
                                    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ChatMessage"];
                                    
                                    request.predicate = [NSPredicate predicateWithFormat:@"uri=%@ AND timeStamp<=%@ AND mark_deleted=%@", message.from.bare, dateOfMessage, [NSNumber numberWithBool:mark_deleted_NO] ];
                                    
                                    
                                    NSArray *messagesForRoom = [[AppDel managedObjectContext_roster] executeFetchRequest:request error:nil];
                                    
                                    
                                    for (ChatMessage *message in messagesForRoom)
                                    {
                                        message.mark_deleted = [NSNumber numberWithBool:mark_deleted_YES];
                                        
                                        
                                        
                                    }
                                    
                                    
                                    [[AppDel managedObjectContext_roster] save:nil];
                                    
                                    
                                    if ([messagesForRoom count] > 0)
                                    {
                                        
                                        [self service_ReportCloseConversationWithjid:[[message from]bare]];
                                        
                                        [ConversationLog resetConversationLogMYJiD:[AppDel myJID] WithJID:[[message from] bare]withContext:[AppDel managedObjectContext_roster]];
                                        
                                        [[[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"This conversation was closed by %@. Please go to new conversation section to start conversation again.", [[message from] resource]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                                        
                                        
                                        if ([self.navController.visibleViewController isKindOfClass:[ChatViewController class]])
                                        {
                                            [self.navController popToViewController:self.homeView animated:YES];
                                        }
                                    }
                                    
                                    return;
                                }
                                
                                
                                
                            }
                        }
                        
                        
                        
                        
                        
                        
                    }
                    
                    
                    
                    
                }
                
                
                if ([[message attributeStringValueForName:@"id"] isEqualToString:@"IMYOURDOC_DELETE"])
                {
                    if ([[[message elementForName:@"body"] stringValue] isEqualToString:@"DELETE ROOM"])
                    {
                        XMPPRoomObject *room = [self fetchRoom:[[message from] bare]];
                        
                        room.room_status = @"deleted";
                        
                        
                        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ChatMessage"];
                        
                        request.predicate = [NSPredicate predicateWithFormat:@"uri=%@", message.from.bare];
                        
                        
                        NSArray *messagesForRoom = [[AppDel managedObjectContext_roster] executeFetchRequest:request error:nil];
                        
                        
                        for (NSManagedObject * message in messagesForRoom)
                        {
                            [[AppDel managedObjectContext_roster] deleteObject:message];
                        }
                        
                        
                        [[AppDel managedObjectContext_roster] save:nil];
                        
                        
                        if ([self.navController.visibleViewController isKindOfClass:[ChatViewController class]])
                        {
                            [self.navController popToViewController:self.homeView animated:YES];
                        }
                        
                        
                        return;
                    }
                }
                
                
                
                
                
                
                XMPPRoomObject *room = [self fetchRoom:[[message from] bare]];
                
                ChatMessage *chat = nil;
                
                
                {
                    
                    NSDictionary * messageBody =[message jsonMessageBody] ;
                    NSString *messageID;
                    
                    if ([messageBody.messageID isEqualToString:@"IMYOURDOC_CLOSE"])
                    {
                        messageID = messageBody.timestamp;
                    }
                    else{
                        messageID = messageBody.messageID;
                    }
                    
                    chat = [ChatMessage getChatMessageObjectWithMessageID:messageID];
                    
                    
                    if (chat == nil)
                    {
                        NSString * messId=messageBody.messageID;
                        
                        
                        
                        if ([messId isEqualToString:@"IMYOURDOC_CLOSE"])
                        {
                            chat =[ChatMessage initGroupChatMessageFrom:messageBody.from to:messageBody.to content:messageBody.content chatMessage:ChatMessageType_Group timestamp:messageBody.timestamp messageID:messageBody.timestamp ChatStateType:ChatStateType_Read MyJid:[self myJID] WithFileType:messageBody.file_type WithFilepath:messageBody.file_path];
                            
                            
                        }
                        else{
                            chat =[ChatMessage initGroupChatMessageFrom:messageBody.from to:messageBody.to content:messageBody.content chatMessage:ChatMessageType_Group timestamp:messageBody.timestamp messageID:messageBody.messageID ChatStateType:ChatStateType_Read MyJid:[self myJID] WithFileType:messageBody.file_type WithFilepath:messageBody.file_path];
                            
                            
                        }
                        
                        
                        
                    }
                    
                    else
                    {
                        
                        if ([chat.displayName isEqualToString:self.xmppStream.myJID.bare])
                        {
                            
                            [que_t addOperationWithBlock:^{
                                if([chat.reportedtoAPI boolValue]==NO)
                                    [self sendGroupMessageToServer:chat.messageID roomJID:chat.uri];
                            }];
                            
                            
                            if([chat.chatState intValue]==ChatStateType_Sending)
                            {
                                chat.chatState=[NSNumber numberWithInt:ChatStateType_Sent];
                                
                                [[self managedObjectContext_roster] save:nil];
                            }
                        }
                        
                        return;
                    }
                    
                    
                    
                    
                    if (chat != nil)
                    {
                        [self addInboxMessage:chat];
                        
                        [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__] operation:@"check Message State" Content:chat.messageID parameter:[ChatMessage ChatTypeToStr:chat.chatState.intValue]];
                        
                        if([chat.timeStamp compare:room.creationDate]==NSOrderedAscending)
                        {
                            chat.chatState      = [NSNumber numberWithInt:ChatStateType_displayedByReciever];
                        }
                        
                        
                        [self.managedObjectContext_roster save:nil];
                        
                        if(chat.isOutbound==OutBoundType_Left)
                        {
                            [self sendChatState:SendChatStateType_delivered withBuddy:[chat displayName] withMessageID:[message attributeStringValueForName:@"id"] isGroupChat:YES];
                            
                            room.lastMessageDate=chat.timeStamp;
                        }
                        
                        if (chat.isOutbound == OutBoundType_Left &&[chat.chatState intValue]!= ChatStateType_displayedByReciever  && [chat.reportedtoAPI boolValue]==NO)
                        {
                            if (![AppDel appIsDisconnected])
                                chat.reportedtoAPI=[NSNumber numberWithBool:YES];
                            
                            
                            if([chat.chatState intValue]!= ChatStateType_displayedByReciever )
                            {
                                if ([[NSUserDefaults standardUserDefaults] boolForKey:@"Vibrate"])
                                {
                                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                                }
                                
                                
                                if ([[NSUserDefaults standardUserDefaults] boolForKey:@"Sounds"])
                                {
                                    [self playSoundForKey];
                                }
                            }
                            
                            
                            {
                                if ([[NSUserDefaults standardUserDefaults] boolForKey:@"Alerts"])
                                {
                                    // shammi
                                    [self backgroundNotification:message.from.resource withxMPPmessage:message];
                                }
                            }
                        }
                        
                        
                        
                    }
                    
                    
                    
                }
                
                
                
                
                
                
            }
            
            
            else if([[[messageVersion elementForName:@"value"] stringValue] isEqualToString:@"2.0"])
            {
                
                NSDictionary * jsonBody=[NSJSONSerialization JSONObjectWithData:[[message body] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                
                
                NSXMLElement *deleayElement = [message elementForName:@"delay" xmlns:@"urn:xmpp:delay"];
                
                
                NSDate *dateOfMessage = nil;
                
                
                if (deleayElement != nil)
                {
                    dateOfMessage = [XMPPDateTimeProfiles parseDateTime:[deleayElement attributeStringValueForName:@"stamp"]];
                }
                
                
                if (dateOfMessage == nil)
                {
                    dateOfMessage = [NSDate date];
                }
                
                
                if ([[message attributeStringValueForName:@"id"] isEqualToString:@"REMOVE_REQUEST"])
                {
                    XMPPJID *user_id = [XMPPJID jidWithString:[[[message from] resource] stringByAppendingString:@"@imyourdoc.com"]];
                    
                    
                    XMPPRoomObject *room = nil;
                    
                    room = [[self.roomsArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"room_jidStr=%@", [message.from bare]]] lastObject];
                    
                    
                    XMPPRoomAffaliations *user = [[room.members filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"memberJidStr=%@", user_id.bare]] anyObject];
                    
                    
                    if ([[room roleForJid:[xmppStream myJID]] isEqualToString:@"owner"])
                    {
                        
                        
                        [room.room deleteMember:[RoomMembers roomMembers:user.jid]];
                    }
                    
                    
                    user.role = @"none";
                    
                    
                    if ([[xmppStream myJID] isEqualToJID:user_id])
                    {
                        room.room_status = @"deleted";
                    }
                    
                    
                    [[AppDel managedObjectContext_roster] save:nil];
                    
                    
                    return;
                }
                
                
                if ([[message attributeStringValueForName:@"id"] isEqualToString:@"IMYOURDOC_CLOSE"])
                {
                    
                    
                    if ([[jsonBody objectForKey:@"content"] isEqualToString:@"~$^^xxx*xxx~$^^"])
                    {
                        
                        
                        NSDateFormatter * dateFormatter = [[NSDateFormatter alloc]init];
                        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
                        NSDate * dateNotFormatted_older = [dateFormatter dateFromString: [jsonBody objectForKey:@"timestamp"]];
                        
                        
                        
                        XMPPRoomObject *room1 = [self fetchRoom:[[message from] bare]];
                        
                        
                        NSComparisonResult result;
                        
                        
                        result = [dateNotFormatted_older compare:room1.creationDate];
                        
                        
                        if(result==NSOrderedAscending)
                        {
                            NSLog(@"today is less dateNotFormatted_older");
                        }
                        else if(result==NSOrderedDescending)
                        { NSLog(@"newDate is less");
                            
                            room1.creationDate = dateOfMessage;
                            [[AppDel  managedObjectContext_roster] save:nil];
                            
                            
                            {
                                NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ChatMessage"];
                                
                                request.predicate = [NSPredicate predicateWithFormat:@"uri=%@ AND timeStamp<=%@ AND mark_deleted=%@", message.from.bare, dateOfMessage, [NSNumber numberWithBool:mark_deleted_NO] ];
                                
                                
                                NSArray *messagesForRoom = [[AppDel managedObjectContext_roster] executeFetchRequest:request error:nil];
                                
                                
                                for (ChatMessage *message in messagesForRoom)
                                {
                                    message.mark_deleted = [NSNumber numberWithBool:mark_deleted_YES];
                                    
                                    
                                    
                                }
                                
                                
                                [[AppDel managedObjectContext_roster] save:nil];
                                
                                
                                if ([messagesForRoom count] > 0)
                                {
                                    
                                    
                                    [self service_ReportCloseConversationWithjid:[[message from]bare]];
                                    [ConversationLog resetConversationLogMYJiD:[AppDel myJID] WithJID:[[message from] bare]withContext:[AppDel managedObjectContext_roster]];
                                    
                                    [[[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"This conversation was closed by %@. Please go to new conversation section to start conversation again.", [[message from] resource]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                                    
                                    
                                    if ([self.navController.visibleViewController isKindOfClass:[ChatViewController class]])
                                    {
                                        [self.navController popToViewController:self.homeView animated:YES];
                                    }
                                }
                                
                                return;
                            }}
                    }
                    else
                    {  NSLog(@"Both dates are same");
                    }
                    
                    
                    
                    
                    
                    
                }
                
                
                if ([[message attributeStringValueForName:@"id"] isEqualToString:@"IMYOURDOC_DELETE"])
                {
                    if ([[jsonBody objectForKey:@"content"] isEqualToString:@"DELETE ROOM"])
                    {
                        XMPPRoomObject *room = [self fetchRoom:[[message from] bare]];
                        
                        room.room_status = @"deleted";
                        
                        
                        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ChatMessage"];
                        
                        request.predicate = [NSPredicate predicateWithFormat:@"uri=%@", message.from.bare];
                        
                        
                        NSArray *messagesForRoom = [[AppDel managedObjectContext_roster] executeFetchRequest:request error:nil];
                        
                        
                        for (NSManagedObject * message in messagesForRoom)
                        {
                            [[AppDel managedObjectContext_roster] deleteObject:message];
                        }
                        
                        
                        [[AppDel managedObjectContext_roster] save:nil];
                        
                        
                        if ([self.navController.visibleViewController isKindOfClass:[ChatViewController class]])
                        {
                            [self.navController popToViewController:self.homeView animated:YES];
                        }
                        
                        //[self.navigationController popViewControllerAnimated:YES];
                        
                        return;
                    }
                }
                
                XMPPRoomObject *room = [self fetchRoom:[[message from] bare]];
                
                NSString *messageID = [message attributeStringValueForName:@"id"];
                if ([[message attributeStringValueForName:@"id"] isEqualToString:@"IMYOURDOC_CLOSE"])
                    messageID = [NSString stringWithFormat:@"%@%@", [message attributeStringValueForName:@"id"],[jsonBody objectForKey:@"timestamp"]];
                
                
                
                //---------- Check If the Message is already there --------------------//
                
                ChatMessage *chat = [ChatMessage getChatMessageObjectWithMessageID:messageID];
                if (chat == nil)  // If new, add new message in db
                {
                    if ([[message attributeStringValueForName:@"id"] isEqualToString:@"IMYOURDOC_CLOSE"])
                    {
                        
                        chat =[self insertChatMessage:[NSString stringWithFormat:@"%@%@",[message attributeStringValueForName:@"id"],[jsonBody objectForKey:@"timestamp"]]];
                    }
                    else
                    {
                        chat = [self insertChatMessage:[message attributeStringValueForName:@"id"]];
                    }
                }
                else //If not new
                {
                    if ([chat.displayName isEqualToString:self.xmppStream.myJID.bare])
                    {
                        
                        if([chat.chatState intValue]== ChatStateType_Sending)
                            
                        {
                            chat.chatState=[NSNumber numberWithInt:ChatStateType_Sent];
                            chat.requestStatus=[NSNumber numberWithInt:RequestStatusType_uploaded];
                            
                            [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                                              operation:@"checkState"
                                                                Content:chat.messageID
                                                              parameter:[ChatMessage ChatTypeToStr:chat.chatState.intValue]];
                            
                            
                            [[self managedObjectContext_roster] save:nil];
                        }
                        [que_t addOperationWithBlock:^{
                            
                            if([chat.reportedtoAPI boolValue]==NO)
                                [self sendGroupMessageToServer:chat.messageID roomJID:chat.uri];
                            
                            
                        }];
                        
                    }
                    
                    
                    
                    return;
                }
                
                
                
                chat.uri            = [[message from] bare];
                
                chat.displayName    = [[[message from] resource] stringByAppendingString:@"@imyourdoc.com"];
                
                chat.identityuri    = [[message to] bare];
                
                chat.mark_deleted   = [NSNumber numberWithBool:mark_deleted_NO];
                
                chat.content        = [jsonBody objectForKey:@"content"];
                
                
                chat.fileMediaType=(NSString*)[jsonBody objectForKey:@"file_type"];
                
                if ([chat.displayName isEqualToString:self.xmppStream.myJID.bare])
                {
                    chat.isOutbound = OutBoundType_Right;
                    
                }
                else{
                    chat.isOutbound = OutBoundType_Left;
                }
                
                if ([jsonBody objectForKey:@"file_path"])
                {
                    chat.content        = [jsonBody objectForKey:@"file_path"];
                    
                    chat.fileTypeChat   = [NSNumber numberWithInt:fileTypeChat_File];
                    
                    chat.hasBeenRead    = NO;
                    
                    
                    if([chat.fileMediaType isEqualToString:@"image"]==YES)
                    {
                        chat.thumb          = [jsonBody objectForKey:@"content"];
                    }
                    else
                    {
                        NSString * extension=[[chat.content lastPathComponent] pathExtension];
                        
                        
                        
                        if([[extension lowercaseString] isEqualToString:@"pdf"])
                        {
                            chat.thumb=[UIImagePNGRepresentation([UIImage imageNamed:kfile_pdf]) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
                            
                        }
                        else if([[extension lowercaseString] isEqualToString:@"doc"]||[[extension lowercaseString] isEqualToString:@"docx"])
                        {
                            chat.thumb=[UIImagePNGRepresentation([UIImage imageNamed:kfile_word]) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
                            
                        }
                        
                        else  if([[extension lowercaseString] isEqualToString:@"xls"]||[[extension lowercaseString] isEqualToString:@"xlsx"])
                        {
                            chat.thumb=[UIImagePNGRepresentation([UIImage imageNamed:kfile_xsl]) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
                            
                        }
                        else if([[extension lowercaseString] isEqualToString:@"txt"])
                        {
                            chat.thumb=[UIImagePNGRepresentation([UIImage imageNamed:kfile_text]) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
                            
                        }
                        else  if([[extension lowercaseString] isEqualToString:@"ppt"]||[[extension lowercaseString] isEqualToString:@"pptx"])
                        {
                            chat.thumb=[UIImagePNGRepresentation([UIImage imageNamed:kfile_ppt]) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
                        }
                        
                        else  if([[extension lowercaseString] isEqualToString:@"jpg"]||[[extension lowercaseString] isEqualToString:@"jpeg"]||[[extension lowercaseString] isEqualToString:@"png"])
                        {
                            chat.thumb          = [jsonBody objectForKey:@"content"];
                        }
                        else
                        {
                            chat.thumb=[UIImagePNGRepresentation([UIImage imageNamed:kfile_extra]) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
                        }
                        
                        
                    }
                }
                
                
                chat.timeStamp      = dateOfMessage;
                
                chat.isRoomMessage  = [NSNumber numberWithBool:YES];
                
                chat.requestStatus  = [NSNumber numberWithInt:RequestStatusType_deliveredByRecieverGroup];
                
                chat.chatState  = [NSNumber numberWithInt:ChatStateType_deliveredByReciever];
                
                room.lastMessageDate=chat.timeStamp;
                
                
                [self addInboxMessageGroupChat:chat];
                
                
                [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__] operation:@"check Message State" Content:chat.messageID parameter:[ChatMessage ChatTypeToStr:chat.chatState.intValue]];
                
                BOOL is_OldMessage=NO;
                
                if([chat.timeStamp compare:room.creationDate]==NSOrderedAscending)
                {
                    is_OldMessage=YES;
                    chat.chatState      = [NSNumber numberWithInt:ChatStateType_displayedByReciever];
                    if(chat.isOutbound )
                    {
                        chat.chatState      = [NSNumber numberWithInt:ChatStateType_Read];
                    }
                }
                
                [self.managedObjectContext_roster save:nil];
                
                if(chat.isOutbound==OutBoundType_Left&&is_OldMessage==NO)
                {
                    [self sendChatState:SendChatStateType_delivered withBuddy:[chat displayName] withMessageID:[message attributeStringValueForName:@"id"] isGroupChat:YES];
                    
                    room.lastMessageDate=chat.timeStamp;
                }
                
                
                if (chat.isOutbound == OutBoundType_Left&&!is_OldMessage&&[chat.reportedtoAPI boolValue]==NO)
                {
                    
                    if([chat.chatState intValue]!=ChatStateType_displayedByReciever &&chat.isOutbound==OutBoundType_Left)
                    {
                        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"Vibrate"])
                        {
                            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                        }
                        
                        
                        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"Sounds"])
                        {
                            [self playSoundForKey];
                        }
                    }
                    
                    
                    {
                        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"Alerts"])
                        {
                            [self backgroundNotification:message.from.resource withxMPPmessage:message];
                        }
                    }
                }
            }
            
        }
        
        
        [self.homeView updateMessagCount];
        
        
    }
}


-(void)groupMessageReadByListChangeStatus:(NSString*)status   ofMessage:(ChatMessage *)msg from:(XMPPJID *)fromJID
{
    if ([status isEqualToString:@"Delivered"] || [status isEqualToString:@"Read"])
    {
        
        GroupChatReadbyList *readUser = [[[msg readby] filteredOrderedSetUsingPredicate:[NSPredicate predicateWithFormat:@"userJID=%@", [fromJID user]]] lastObject];
        
        if (readUser == nil)
        {
            readUser = [GroupChatReadbyList insertChatReadByMessage:msg userJID:[fromJID user]];
        }
        
        readUser.status = status;
        
        
        
        
        NSError *error = nil;
        
        if([[AppDel managedObjectContext_roster]  hasChanges])
            if (![[AppDel managedObjectContext_roster] save:&error])
            {
                NSLog(@"%@", [error domain]);
            }

        
        
        return;
        
    }
    
    if ([fromJID resource])
    {
        GroupChatReadbyList *readUser = [[[msg readby] filteredOrderedSetUsingPredicate:[NSPredicate predicateWithFormat:@"userJID=%@", [fromJID resource]]] lastObject];
        
        if (readUser == nil)
        {
            readUser = [GroupChatReadbyList insertChatReadByMessage:msg userJID:[fromJID resource]];
        }
        
        readUser.status = status;
        
        
        
        
        NSError *error = nil;
        
        if([[AppDel managedObjectContext_roster]  hasChanges])
            if (![[AppDel managedObjectContext_roster] save:&error])
            {
                NSLog(@"%@", [error domain]);
            }
    }
    
    
  
}
  #pragma mark  Broadcast
-(void)leoXmppStreamReceive:(XMPPStream *)sender isBroadcastMessage:(XMPPMessage *)xMPPmessage
{
    
    NSDictionary * jsonBody=[NSJSONSerialization JSONObjectWithData:[[[xMPPmessage elementForName:@"body"] stringValue] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    
    
    
    
    
    ChatMessage *isTheremessage=[ChatMessage getChatMessageWithMessageID:[jsonBody valueForKey:@"messageID"] withContext:self.managedObjectContext_roster];
    
    if (isTheremessage!=nil)
    {
        
    }
    else{
        
        
        
        ChatMessage *message = [ChatMessage  initbcMessageWithFrom:[jsonBody objectForKey:@"from"] to:[xMPPmessage attributeStringValueForName:@"to"] content:[jsonBody objectForKey:@"content"] subject:[jsonBody objectForKey:@"subject"] chatMessage:ChatMessageType_Broadcast timestamp:[jsonBody objectForKey:@"timestamp"] messageID:[jsonBody objectForKey:@"messageID" ] withSubjectid:[jsonBody objectForKey:@"subject_id"] ChatStateType:ChatStateType_deliveredByReciever];
        
        
        
        
        if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive)
        {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"Alerts"])
            {
                [self backgroundNotification:xMPPmessage.from.user withxMPPmessage:xMPPmessage];
            }
        }
        
        
        
        
        
        if (message)
        {
            ChatMessage *lastMessage=[ChatMessage getLastMessageWithJiD:[jsonBody objectForKey:@"subject_id"] withContext:self.managedObjectContext_roster];
            
            if (lastMessage)
            {
                
            }
            
            [AppDel addBcInboxMessage:message];
            
            
            [ChatMessage broadcastMessageDeliverywithBuddy:message.identityuri withMessageID:message.messageID];
            
            
            [self sendChatState:SendChatStateType_delivered withBuddy:message.uri withMessageID:message.messageID isGroupChat:false];
            
        }
        
        
        
        
    }
}



@end
