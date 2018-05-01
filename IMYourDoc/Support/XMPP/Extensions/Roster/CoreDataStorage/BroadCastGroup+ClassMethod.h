//
//  BroadCastGroup+ClassMethod.h
//  IMYourDoc
//
//  Created by vijayveer on 14/09/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import "BroadCastGroup.h"


@interface BroadCastGroup (ClassMethod)
+(BroadCastGroup*)initWithGroupName:(NSString*)str_groupName withgroupId:(NSString *)str_groupId  withGroupMembersArray:(NSArray *)arr_members;

-(BOOL)isPatientRoom;

@end
