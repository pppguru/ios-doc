//
//  GroupInfo.m
//  IMYourDoc
//
//  Created by macbook on 23/07/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "GroupInfo.h"


@implementation GroupInfo
@dynamic roomName;
@dynamic affilation;
@dynamic role;
@dynamic roomNICK;
@dynamic roomStatusJoined;
@dynamic isInviteRequest;
@dynamic IsRoomStatusJoined;
@dynamic hasInviteRequest;
@dynamic roomOwner;
@dynamic roomTYPE;



- (BOOL)IsRoomStatusJoined
{
    return [[self roomStatusJoined] boolValue];
}

- (void)setIsRoomStatusJoined:(BOOL)flag
{
    [self setRoomStatusJoined:[NSNumber numberWithBool:flag]];
}

- (BOOL)hasInviteRequest
{
    return [[self isInviteRequest] boolValue];
}

- (void)setHasInviteRequest:(BOOL)flag
{
	if (flag != [self hasInviteRequest])
	{
            //[self.service willChangeValueForKey:@"messages"];
		[self setIsInviteRequest:[NSNumber numberWithBool:flag]];
            //[self.service didChangeValueForKey:@"messages"];
	}
}


@end

