//
//  OfflineMessages.h
//  IMYourDoc
//
//  Created by Sarvjeet on 14/05/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class OfflineContact;

@interface OfflineMessages : NSManagedObject

@property (nonatomic, retain) NSString * streamJID;
@property (nonatomic, retain) NSDate * sentDate;
@property (nonatomic, retain) NSString * messageStatus;
@property (nonatomic, retain) NSString * messageContent;
@property (nonatomic, retain) NSString * messageID;
@property(nonatomic,retain )NSString * message_identity;
@property (nonatomic, retain) OfflineContact *contact;

@end
