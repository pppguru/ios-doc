//
//  AppDelegate+XmppMethods.h
//  IMYourDoc
//
//  Created by OSX on 11/03/16.
//  Copyright (c) 2016 vijayvir . All rights reserved.
//

#import "AppDelegate.h"




@interface AppDelegate (XmppMethods)


#pragma mark -  ••••• OutGoing  ••••••

#pragma mark Global

#pragma mark Simple

#pragma mark - broadcast 

-(void)leoXmppStreamSendMessageToOpenFireWithChatMessage:(ChatMessage*)chatmessage;
- (void)leoResendInQueueWithChatMessage:(NSString *)messageID;

- (void)sendbroadcastMessageToOpenFire:(BroadCastMessageSender*)bcmessage;
-(void)broadcastDidnotReceivedMessage:(NSString*)messageid;
-(void)broadcastMessagedidSendWithID:(NSString*)messageid;
#pragma mark  GROUPCHAT

#pragma mark  Broadcast
#pragma mark -  ••••• INCOMMING ••••••

#pragma mark Global

- (void)leoXmppStreamReceive:(XMPPStream *)sender didServerAcknowlgement:(XMPPMessage *)message;
- (void)LeoXmppStreamReceive:(XMPPStream *)sender didServerSentNotification:(XMPPMessage *)message;

-(void)leoXmppStreamReceive:(XMPPStream *)sender hasDeliveredChatStateWithBody:(XMPPMessage *)message;
-(void)leoXmppStreamReceive:(XMPPStream *)sender hasDisPlayedChatStateWithBody:(XMPPMessage *)message;


#pragma mark Simple
-(void)leoXmppStreamReceive:(XMPPStream *)sender isChatMessageWithBody:(XMPPMessage *)message;
#pragma mark  GROUPCHAT

-(void)leoXmppStreamReceive:(XMPPStream *)sender IsGroupChatwithBody:(XMPPMessage *)message;
#pragma mark  Broadcast
-(void)leoXmppStreamReceive:(XMPPStream *)sender isBroadcastMessage:(XMPPMessage *)xMPPmessage;

@end
