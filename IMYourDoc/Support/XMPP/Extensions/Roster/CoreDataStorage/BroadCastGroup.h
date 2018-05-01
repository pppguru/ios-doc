//
//  BroadCastGroup.h
//  IMYourDoc
//
//  Created by vijayveer on 23/09/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BroadCastMembers, BroadcastSubjectSender;

@interface BroadCastGroup : NSManagedObject

@property (nonatomic, retain) NSString * groupId;
@property (nonatomic, retain) NSDate * lastUpdated;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSSet *members;
@property (nonatomic, retain) NSSet *subjects;
@end

@interface BroadCastGroup (CoreDataGeneratedAccessors)

- (void)addMembersObject:(BroadCastMembers *)value;
- (void)removeMembersObject:(BroadCastMembers *)value;
- (void)addMembers:(NSSet *)values;
- (void)removeMembers:(NSSet *)values;

- (void)addSubjectsObject:(BroadcastSubjectSender *)value;
- (void)removeSubjectsObject:(BroadcastSubjectSender *)value;
- (void)addSubjects:(NSSet *)values;
- (void)removeSubjects:(NSSet *)values;

@end
