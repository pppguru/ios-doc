//
//  BroadcastSubjectSender.h
//  IMYourDoc
//
//  Created by vijayveer on 23/09/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BroadCastGroup, BroadCastMessageSender;

@interface BroadcastSubjectSender : NSManagedObject

@property (nonatomic, retain) NSDate * lastupdate;
@property (nonatomic, retain) NSString * subject;
@property (nonatomic, retain) NSString * subjectId;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * groupId;
@property (nonatomic, retain) NSSet *messages;
@property (nonatomic, retain) BroadCastGroup *ofGroup;
@end

@interface BroadcastSubjectSender (CoreDataGeneratedAccessors)

- (void)addMessagesObject:(BroadCastMessageSender *)value;
- (void)removeMessagesObject:(BroadCastMessageSender *)value;
- (void)addMessages:(NSSet *)values;
- (void)removeMessages:(NSSet *)values;

@end
