//
//  AppDelegate+XmppRosterIQMethods.m
//  IMYourDoc
//
//  Created by OSX on 06/04/16.
//  Copyright (c) 2016 vijayvir . All rights reserved.
//

#import "AppDelegate+XmppRosterIQMethods.h"
#import  "AppDelegate+ClassMethods.h"

#import "VCard.h"
#import "VCardAffilication.h"
#import "NSData+XMPP.h"


@implementation AppDelegate (XmppRosterIQMethods)


#pragma mark -  ••••• INCOMMING ••••••
- (void)leoXmppStreamReceiveIQ:(XMPPStream *)sender withJabberIqRoster:(XMPPIQ *)iq{
    NSArray *itemElements = [[iq elementForName:@"query"] elementsForName: @"item"];
    
    for (int i = 0; i < [itemElements count]; i++)
    {
        NSXMLElement * item=[[itemElements objectAtIndex:i] copy];
        
        // [self.managedObjectContext_roster lock];
        
        
        XMPPUserCoreDataStorageObject * user=[self fetchUserForJIDString:[item attributeStringValueForName:@"jid"]];
        if(user)
        {
            
            [user updateWithItem:item];
        }
        else
        {
            [XMPPUserCoreDataStorageObject insertInManagedObjectContext:self.managedObjectContext_roster withItem:item streamBareJidStr:[self myJID]];
        }
        
        
        NSString *jid = [[[itemElements objectAtIndex:i] attributeForName:@"jid"] stringValue];
        
        if([[[itemElements objectAtIndex:i] attributeStringValueForName:@"subscription"]  isEqualToString:@"both"])
        {
            NSBlockOperation *fetch_vCard = [NSBlockOperation blockOperationWithBlock:^{
                
                
                [self getVcard:[XMPPJID jidWithString:jid]];
                
            }];
            
            NSOperationQueue * que2=[NSOperationQueue currentQueue];
            [que2 addOperation:fetch_vCard];
        }
        
        
    }
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSError *error=nil;
        
        if([self.managedObjectContext_roster hasChanges])
            if ( ![self.managedObjectContext_roster save:&error]) {
                NSLog(@"  ••••••••• Error ••••• %@",error.description);
            }
    });
}
- (void)leoXmppStreamReceiveIQ:(XMPPStream *)sender withVcardTemp:(XMPPIQ *)iq{
    XMPPUserCoreDataStorageObject * userObj=[self fetchUserForJIDString:[iq fromStr]];
    
    XMPPvCardCoreDataStorageObject *vcardObj = [XMPPvCardCoreDataStorageObject fetchOrInsertvCardForJID:iq.from inManagedObjectContext:self.managedObjectContext_vCard];
    
    
    XMPPvCardTemp *temp = [XMPPvCardTemp vCardTempCopyFromIQ:iq];
    
    
    [vcardObj setVCardTemp:temp];
    
    
    NSXMLElement *VCardTmp = [iq elementForName:@"vCard"];
    
    
    VCard *card = [self fetchVCard:[iq from]];
    
    card.name = [[VCardTmp elementForName:@"FN"] stringValue];
    
    card.nickname = [[VCardTmp elementForName:@"NICKNAME"] stringValue];
    
    card.title = [[VCardTmp elementForName:@"TITLE"] stringValue];
    
    card.designation = [[VCardTmp elementForName:@"ROLE"] stringValue];
    
    card.practiceType = [[VCardTmp elementForName:@"DESC"] stringValue];
    
    card.messagingVersion=[NSNumber numberWithInt:[[[VCardTmp elementForName:@"BDAY"] stringValue] intValue]];
    
    NSString * base64image=[[[VCardTmp elementForName:@"PHOTO"] elementForName:@"BINVAL"] stringValue];
    
    userObj.photo=[UIImage imageWithData:[[base64image dataUsingEncoding:NSUTF8StringEncoding] xmpp_base64Decoded]];
    
    NSArray *affiliations = [VCardTmp elementsForName:@"ADR"];
    
    
    for (XMPPvCardTempAdr *adress in affiliations)
    {
        VCardAffilication *affliation = [[card.affilications filteredOrderedSetUsingPredicate:[NSPredicate predicateWithFormat:@"hosp_id=%@", [NSNumber numberWithInt:[[[adress elementForName:@"PCODE"] stringValue]intValue]]]] lastObject];
        
        
        if (affliation == nil)
        {
            affliation = [NSEntityDescription insertNewObjectForEntityForName:@"VCardAffilication" inManagedObjectContext:self.managedObjectContext_roster];
            
            
            [card addAffilicationsObject:affliation];
            
            
            affliation.hosp_id = [NSNumber numberWithInt:[[[adress elementForName:@"PCODE"] stringValue] intValue]];
        }
        
        
        affliation.name = [[adress elementForName:@"POBOX"] stringValue];
        
        affliation.isPrimary = [NSNumber numberWithBool:[[[adress elementForName:@"STREET"] stringValue] boolValue]];
    }
    
    
    
    if([[iq from] isEqualToJID:[XMPPJID jidWithString:[AppDel myJID]]])
    {
        
        self.image=[UIImage imageWithData:[[base64image dataUsingEncoding:NSUTF8StringEncoding] xmpp_base64Decoded]];
        
    }
    NSError *error2 = nil;
    
    if([self.managedObjectContext_roster hasChanges])
        [self.managedObjectContext_roster save:&error2];
    
    
    NSError *error = nil;
    
    
    [self.managedObjectContext_vCard save:&error];
    
}
- (void)leoXmppStreamReceiveIQ:(XMPPStream *)sender withChatUrnXmppArchive:(XMPPIQ *)iq{
    
    
    
    NSMutableArray *arr_from=[ NSMutableArray getChatFrom:iq];
    NSMutableArray *arr_to=[ NSMutableArray getChatTo:iq];
    
    
    
    
    NSXMLElement* chat=[iq elementForName:@"chat"] ;
    
    
    
    
    for (NSDictionary*obj_from  in arr_from)
    {
        
        
        
        ChatMessage *message=[ChatMessage getChatMessageWithMessageID:[obj_from valueForKey:@"messageID"] withContext:self.managedObjectContext_roster];
        if (message != nil)
        {
            
            if([message.mark_deleted isEqualToNumber:[NSNumber numberWithBool:mark_deleted_YES]] )
            {
                
                message.mark_deleted = [NSNumber numberWithBool:mark_deleted_NO];
                
                [[AppDel managedObjectContext_roster] save:nil];
                
                
                {
                    ChatMessage *lastMessage=[ChatMessage getLastMessageWithJiD:[chat attributeStringValueForName:@"with"] withContext:self.managedObjectContext_roster];
                    
                    if (lastMessage)
                    {
//                        [AppDel addInboxMessage:lastMessage];
                        
                        [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                                          operation:@"check Message State "
                                                            Content:lastMessage.messageID
                                                          parameter:[ChatMessage ChatTypeToStr:lastMessage.chatState.intValue]];
                    }
                    [[AppDel managedObjectContext_roster] save:nil];
                    
                }
            }
        }
        else
        {
            
            
            ChatMessage *message= [ChatMessage
                                   initMessageWithFrom:[obj_from objectForKey:@"from"]
                                   to:[obj_from objectForKey:@"to"]
                                   content:[obj_from objectForKey:@"content"]
                                   timestamp:[obj_from objectForKey:@"timestamp"]
                                   messageID:[obj_from objectForKey:@"messageID"]
                                   withContext:self.managedObjectContext_roster
                                   MyJid:[self myJID]  WithFileType:[obj_from objectForKey:@"file_type"] WithFilepath:[obj_from objectForKey:@"file_path"]];
            
            if (message)
            {
                ChatMessage *lastMessage=[ChatMessage getLastMessageWithJiD:[chat attributeStringValueForName:@"with"] withContext:self.managedObjectContext_roster];
                
                if (lastMessage)
                {
//                    [AppDel addInboxMessage:lastMessage];
                    [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                                      operation:@"check Message State "
                                                        Content:lastMessage.messageID
                                                      parameter:[ChatMessage ChatTypeToStr:lastMessage.chatState.intValue]];
                }
                [[AppDel managedObjectContext_roster] save:nil];
                
                
            }
            
            
            
        }
    }
    for (NSDictionary*obj_to  in arr_to)
    {
        
        
        
        {
            ChatMessage *message=[ChatMessage getChatMessageWithMessageID:[obj_to valueForKey:@"messageID"] withContext:self.managedObjectContext_roster];
            
            if (message != nil)
            {
                if([message.mark_deleted isEqualToNumber:[NSNumber numberWithBool:mark_deleted_YES]])
                {
                    message.mark_deleted = [NSNumber numberWithBool:mark_deleted_NO];
                    
                    [[AppDel managedObjectContext_roster] save:nil];
                }
                
                {
                    ChatMessage *lastMessage=[ChatMessage getLastMessageWithJiD:[chat attributeStringValueForName:@"with"] withContext:self.managedObjectContext_roster];
                    
                    if (lastMessage)
                    {
//                        [AppDel addInboxMessage:lastMessage];
                        [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                                          operation:@"check Message State "
                                                            Content:lastMessage.messageID
                                                          parameter:[ChatMessage ChatTypeToStr:lastMessage.chatState.intValue]];
                    }
                    [[AppDel managedObjectContext_roster] save:nil];
                    
                }
                
                
            }
            else
            {
                ChatMessage *message= [ChatMessage
                                       initMessageWithFrom:[obj_to objectForKey:@"from"]
                                       to:[obj_to objectForKey:@"to"]
                                       content:[obj_to objectForKey:@"content"]
                                       timestamp:[obj_to objectForKey:@"timestamp"]
                                       messageID:[obj_to objectForKey:@"messageID"]
                                       withContext:self.managedObjectContext_roster
                                       MyJid:[self myJID]  WithFileType:[obj_to objectForKey:@"file_type"] WithFilepath:[obj_to objectForKey:@"file_path"]];
                
                
                if (message)
                {
                    
                    ChatMessage *lastMessage=[ChatMessage getLastMessageWithJiD:[chat attributeStringValueForName:@"with"] withContext:self.managedObjectContext_roster];
                    
                    if (lastMessage)
                    {
//                        [AppDel addInboxMessage:lastMessage];
                        [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__]
                                                          operation:@"check Message State "
                                                            Content:lastMessage.messageID
                                                          parameter:[ChatMessage ChatTypeToStr:lastMessage.chatState.intValue]];
                    }
                    
                    [[AppDel managedObjectContext_roster] save:nil];
                }
            }
        }
    }
    
    if (arr_from.count>0||arr_to.count>0)
    {
        
        dispatch_async(dispatch_get_main_queue(), ^
                       {
                           
                           [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:@"KLoadOlderMessagesNotification" object:nil userInfo:nil];
                       }
                       );
        
    }
    
    if (arr_from.count==0&&arr_to.count==0)
    {
        
        dispatch_async(dispatch_get_main_queue(), ^
                       {
                           
                           
                           //
                           [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:@"KLoadOlderMessagesWithIncreaseCountNotification" object:nil userInfo:nil];
                       }
                       );
        
        
    }
    
    
    
    {
        
        
        
        [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:[NSString stringWithFormat:@"KStateTransferReceiveNotificationStep3%@" ,[chat attributeStringValueForName:@"with"] ]object:[chat attributeStringValueForName:@"with"]  userInfo:nil];
        //
        
    }
    
    
}

- (void)leoXmppStreamReceiveIQ:(XMPPStream *)sender withListUrnXmppArchive:(XMPPIQ *)iq{
    NSArray * listElements = [[[iq elementForName:@"list"] elementsForName: @"chat"] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings)
                                                                                                                  {
                                                                                                                      NSXMLElement *  element=(NSXMLElement*)evaluatedObject;
                                                                                                                      
                                                                                                                      if([[element attributeStringValueForName:@"with"] rangeOfString:@"@newconversation.imyourdoc.com"].location!=NSNotFound)
                                                                                                                          return false;
                                                                                                                      
                                                                                                                      return true;
                                                                                                                      
                                                                                                                  }]];
    
    
    
    
    
    for (int i = 0; i < [listElements count]; i++)
    {
        NSXMLElement * chat=[[listElements objectAtIndex:i] copy];
        
        
        
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                       ^{
                           
                           ConversationLog *message = [ConversationLog getIfObjectExistMyJID:[self myJID]  WithJID:[chat attributeStringValueForName:@"with"] lastSynDate:nil startDate:[chat attributeStringValueForName:@"start"] withContext:self.managedObjectContext_roster];
                           
                           if(message==nil)
                           {
                               dispatch_async(dispatch_get_main_queue(), ^
                                              {
                                                  
                                                  @autoreleasepool {
                                                      
                                                      
                                                      ConversationLog * conversationlog=[ConversationLog initMyJID:[self myJID] WithJID:[chat attributeStringValueForName:@"with"] lastSynDate:nil startDate:[chat attributeStringValueForName:@"start"] withContext:self.managedObjectContext_roster];
                                                      [[AppDel managedObjectContext_roster] save:nil];
                                                      
                                                      
                                                      (void)conversationlog;
                                                  }
                                                  
                                                  if (i==[listElements count]-1)
                                                  {
                                                      dispatch_async(dispatch_get_main_queue(), ^
                                                                     {
                                                                         [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:[NSString stringWithFormat:@"KStateTransferReceiveActiveConversationLastNotificationStep2%@" ,[chat attributeStringValueForName:@"with"] ]object:[chat attributeStringValueForName:@"with"]  userInfo:nil];
                                                                     }
                                                                     );
                                                      
                                                  }
                                                  
                                              });
                           }
                           else
                           {
                               
                           }
                       });
    }
}

- (void)leoXmppStreamReceiveIQ:(XMPPStream *)sender withPing:(XMPPIQ *)iq{
    NSXMLElement *pong = [NSXMLElement elementWithName:@"iq"];
    
    [pong addAttributeWithName:@"type" stringValue:@"result"];
    
    [pong addAttributeWithName:@"from" stringValue:[[iq to] bare]];
    
    [pong addAttributeWithName:@"to" stringValue:[[iq from] bare]];
    
    [pong addAttributeWithName:@"id" stringValue:[iq attributeStringValueForName:@"id"]];
    
    
    [[self xmppStream] sendElement:pong];
}
- (void)leoXmppStreamReceiveIQ:(XMPPStream *)sender withNewConversationImyourdocCom:(XMPPIQ *)iq{
    if([iq elementForName:@"query" xmlns:@"http://jabber.org/protocol/disco#items"])
    {
        NSXMLElement * query=[iq elementForName:@"query"];
        NSArray * itemArray=[query elementsForName:@"item"];
        for (NSXMLElement * item in itemArray)
        {
            
            XMPPRoom * room=[[XMPPRoom alloc] initWithRoomStorage:[XMPPRoomMemoryStorage sharedInstanse] jid:[XMPPJID jidWithString:[item attributeStringValueForName:@"jid"]]];
            XMPPRoomObject * roomObj=[self fetchOrInsertRoom:room];
            roomObj.subject=[item attributeStringValueForName:@"name"];
            roomObj.name=[item attributeStringValueForName:@"name"];
            roomObj.streamJidStr=[AppDel myJID];
            roomObj.room_status=@"Active";
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error=nil;
            
            if([self.managedObjectContext_roster hasChanges])
                if ( ![self.managedObjectContext_roster save:&error]) {
                    NSLog(@"  ••••••••• Error ••••• %@",error.description);
                }
        });
    }
}

@end


