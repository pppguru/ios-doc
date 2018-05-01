//
//  GroupInfo.h
//  IMYourDoc
//
//  Created by macbook on 23/07/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface GroupInfo : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * roomName;
@property (nonatomic, retain) NSString * role;
@property (nonatomic, retain) NSString * roomNICK;
@property (nonatomic, retain) NSString * affilation;
@property (nonatomic, retain) NSString * roomOwner;
@property (nonatomic, assign) NSNumber *roomTYPE;

@property (nonatomic, retain) NSNumber * roomStatusJoined;
@property (nonatomic, retain) NSNumber * isInviteRequest;

@property (nonatomic, assign) BOOL IsRoomStatusJoined;
@property (nonatomic, assign) BOOL hasInviteRequest;

@end
