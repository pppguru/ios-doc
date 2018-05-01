//
//  VCard.h
//  IMYourDoc
//
//  Created by Harminder on 06/04/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VCardAffilication;

@interface VCard : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * designation;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * nickname;
@property (nonatomic, retain) NSString * practiceType;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSString * streamJID;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * userJID;
@property (nonatomic, retain) NSString * zip;
@property (nonatomic, retain) NSOrderedSet *affilications;
@property (nonatomic,retain)  NSNumber * messagingVersion;
@end

@interface VCard (CoreDataGeneratedAccessors)

- (void)insertObject:(VCardAffilication *)value inAffilicationsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromAffilicationsAtIndex:(NSUInteger)idx;
- (void)insertAffilications:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeAffilicationsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInAffilicationsAtIndex:(NSUInteger)idx withObject:(VCardAffilication *)value;
- (void)replaceAffilicationsAtIndexes:(NSIndexSet *)indexes withAffilications:(NSArray *)values;
- (void)addAffilicationsObject:(VCardAffilication *)value;
- (void)removeAffilicationsObject:(VCardAffilication *)value;
- (void)addAffilications:(NSOrderedSet *)values;
- (void)removeAffilications:(NSOrderedSet *)values;
@end
