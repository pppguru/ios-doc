//
//  OfflineContact.m
//  IMYourDoc
//
//  Created by Sarvjeet on 14/05/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import "OfflineContact.h"
#import "OfflineMessages.h"


@implementation OfflineContact

@dynamic emailID;
@dynamic streamJID;
@dynamic firstName;
@dynamic lastupdate;
@dynamic phoneNo;
@dynamic messageCount;
@dynamic lastName;
@dynamic message;

@synthesize nickname;

-(NSString *)nickname
{
    return [NSString stringWithFormat:@"%@ %@",self.firstName,self.lastName];
}


@end
