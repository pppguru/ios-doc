//
//  AppDelegate+XmppConnectionMethods.h
//  IMYourDoc
//
//  Created by Nicholas on 6/16/16.
//  Copyright © 2016 vijayvir . All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate (XmppConnectionMethods)

-(void)getRoster;
-(void)getVcard:(XMPPJID *)jid;
-(void)update_pending_Request_count;
-(void)migrationOfChatMessageToInboxMessage;
-(void)addInboxMessage:(ChatMessage *)message;

-(NSArray *)fetchChatMessageOfNoneReceiverStatus; // fetch message for send delivery to server.

-(VCard *)fetchVCard:(XMPPJID *)jid;

-(OfflineContact *)fetchInsertExternamContact:(NSString *)streamJID phoneNo:(NSString *)phoneNo email:(NSString *)email firstName:(NSString *)firstName lastName:(NSString *)lastName;

-(InboxMessage*)addInboxMessageGroupChat:(ChatMessage *)message;
@end
