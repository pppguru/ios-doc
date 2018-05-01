//
//  NSMutableArray+OlderMessages.h
//  IMYourDoc
//
//  Created by OSX on 24/07/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSXMLElement+XMPP.h"
#import "XMPPIQ.h"
@interface NSMutableArray (OlderMessages)
+(NSMutableArray* )getChatFrom:(XMPPIQ *)iq;
+(NSMutableArray* )getChatTo:(XMPPIQ *)iq;
+(NSString*)getChatWith:(XMPPIQ *)iq;
+(NSArray*)broadcastMembersList:(NSArray*)members;

@end
