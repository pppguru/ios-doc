//
//  XMPPRoomAffaliations.h
//  IMYourDoc
//
//  Created by Nipun on 03/01/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "XMPPJID.h"

@interface XMPPRoomAffaliations : NSManagedObject

@property (nonatomic, retain) NSString * memberJidStr;
@property (nonatomic, retain) NSString * roomJidStr;
@property (nonatomic, retain) NSString * role;
@property(nonatomic,readonly)XMPPJID * jid;
@property(nonatomic,readonly)XMPPJID * roomJid;
@end
