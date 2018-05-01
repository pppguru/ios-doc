//
//  BroadCastMessageDeliveryRecipient.h
//  IMYourDoc
//
//  Created by vijayveer on 17/09/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BroadCastMessageSender;

@interface BroadCastMessageDeliveryRecipient : NSManagedObject

@property (nonatomic, retain) NSString *  messgeID;
@property (nonatomic, retain) NSString *  receiverJid;
@property (nonatomic, retain) NSNumber *  responseStatus;
@property (nonatomic, retain) NSNumber * responseStatusRead;

@property (nonatomic, retain) NSDate *    lastUpdate;
@property (nonatomic, retain) NSDate *     date;
@property (nonatomic, retain) BroadCastMessageSender *ofMessage;

@end
