//
//  XMPPRoomAffaliations.m
//  IMYourDoc
//
//  Created by Nipun on 03/01/15.
//
//

#import "XMPPRoomAffaliations.h"


@implementation XMPPRoomAffaliations

@dynamic memberJidStr;
@dynamic roomJidStr;
@dynamic role;
-(XMPPJID *)jid
{
    return [XMPPJID jidWithString:self.memberJidStr];
}
-(XMPPJID *)roomJid
{
    
    return [XMPPJID jidWithString:self.roomJidStr];
}

@end
