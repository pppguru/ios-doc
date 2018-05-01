//
//  InboxMessage.m
//  IMYourDoc
//
//  Created by Harry on 11/06/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import "InboxMessage.h"
#import "ChatMessage+ClassMethod.h"
#import "XMPPRoomObject.h"
#import "XMPPUserCoreDataStorageObject.h"

#import "IMConstants.h"

@implementation InboxMessage

@dynamic status;
@dynamic dateCreation;
@dynamic jidStr;
@dynamic lastUpdated;
@dynamic messageType;
@dynamic room;
@dynamic message;
@dynamic user;
@dynamic chatMessageTypeOf;

@dynamic oldMessageCount;
@dynamic isLoadingCompleteInGroupChat;

-(NSInteger) numberOfUnReadMessages
{
    //Change the filter same as HomeViewController - By Ronald [10/25]
    return [[self.message filteredOrderedSetUsingPredicate:[NSPredicate predicateWithFormat:@"chatState=%@ and mark_deleted!='1' and outbound=0 ", [NSNumber numberWithInt:ChatStateType_deliveredByReciever]]] count];
}

-(NSInteger) numberOfMessages
{
    for (ChatMessage * message1 in self.message)
    {
        if([message1.mark_deleted boolValue]==1)
        {
            [self removeMessageObject:message1];
        }
    }
    
   return [[self.message filteredOrderedSetUsingPredicate:[NSPredicate predicateWithFormat:@"mark_deleted==0"]] count];
}

-(void)awakeFromFetch
{
    [super awakeFromFetch];
}
@end
