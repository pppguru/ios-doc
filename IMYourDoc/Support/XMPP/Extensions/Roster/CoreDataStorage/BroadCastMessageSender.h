//
//  BroadCastMessageSender.h
//  IMYourDoc
//
//  Created by vijayveer on 23/09/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BroadCastMessageDeliveryRecipient, BroadcastSubjectSender;

@interface BroadCastMessageSender : NSManagedObject

@property (nonatomic, retain) NSString * messageId;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSString * subjectid;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * groupId;
@property (nonatomic, retain) NSSet *recipients;
@property (nonatomic, retain) BroadcastSubjectSender *ofSubject;
@end

@interface BroadCastMessageSender (CoreDataGeneratedAccessors)

- (void)addRecipientsObject:(BroadCastMessageDeliveryRecipient *)value;
- (void)removeRecipientsObject:(BroadCastMessageDeliveryRecipient *)value;
- (void)addRecipients:(NSSet *)values;
- (void)removeRecipients:(NSSet *)values;

@end
