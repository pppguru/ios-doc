//
//  BroadCastMembers.h
//  IMYourDoc
//
//  Created by vijayveer on 14/09/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class NSManagedObject;



@interface BroadCastMembers : NSManagedObject

@property (nonatomic, retain) NSString * streamId;
@property (nonatomic, retain) NSSet *broadcastGroups;
@end


@interface BroadCastMembers (CoreDataGeneratedAccessors)

- (void)addBroadcastGroupsObject:(NSManagedObject *)value;
- (void)removeBroadcastGroupsObject:(NSManagedObject *)value;
- (void)addBroadcastGroups:(NSSet *)values;
- (void)removeBroadcastGroups:(NSSet *)values;

@end
