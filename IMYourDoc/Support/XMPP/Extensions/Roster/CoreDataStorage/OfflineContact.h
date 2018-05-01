//
//  OfflineContact.h
//  IMYourDoc
//
//  Created by Sarvjeet on 14/05/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class OfflineMessages;

@interface OfflineContact : NSManagedObject

@property (nonatomic, retain) NSString * emailID;
@property (nonatomic, retain) NSString * streamJID;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSDate * lastupdate;
@property (nonatomic, retain) NSString * phoneNo;
@property (nonatomic, retain) NSNumber * messageCount;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSSet *message;
@property(nonatomic,retain) NSString  * nickname;
@end

@interface OfflineContact (CoreDataGeneratedAccessors)

- (void)addMessageObject:(OfflineMessages *)value;
- (void)removeMessageObject:(OfflineMessages *)value;
- (void)addMessage:(NSSet *)values;
- (void)removeMessage:(NSSet *)values;

@end
