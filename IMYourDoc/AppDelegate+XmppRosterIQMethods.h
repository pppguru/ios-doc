//
//  AppDelegate+XmppRosterIQMethods.h
//  IMYourDoc
//
//  Created by OSX on 06/04/16.
//  Copyright (c) 2016 vijayvir . All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate (XmppRosterIQMethods)

#pragma mark -  ••••• INCOMMING ••••••

- (void)leoXmppStreamReceiveIQ:(XMPPStream *)sender withJabberIqRoster:(XMPPIQ *)iq;
- (void)leoXmppStreamReceiveIQ:(XMPPStream *)sender withVcardTemp:(XMPPIQ *)iq;
- (void)leoXmppStreamReceiveIQ:(XMPPStream *)sender withChatUrnXmppArchive:(XMPPIQ *)iq;
- (void)leoXmppStreamReceiveIQ:(XMPPStream *)sender withListUrnXmppArchive:(XMPPIQ *)iq;
- (void)leoXmppStreamReceiveIQ:(XMPPStream *)sender withPing:(XMPPIQ *)iq;
- (void)leoXmppStreamReceiveIQ:(XMPPStream *)sender withNewConversationImyourdocCom:(XMPPIQ *)iq;

@end
