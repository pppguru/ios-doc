//
//  InboxMessage.h
//  IMYourDoc
//
//  Created by Harry on 11/06/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ChatMessage, XMPPRoomObject, XMPPUserCoreDataStorageObject;

@interface InboxMessage : NSManagedObject

@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSDate * dateCreation;
@property (nonatomic, retain) NSString * jidStr;
@property (nonatomic, retain) NSDate * lastUpdated;
@property (nonatomic, retain) NSNumber * messageType;
@property (nonatomic, retain) XMPPRoomObject *room;
@property (nonatomic, retain) NSOrderedSet *message;
@property (nonatomic, retain) XMPPUserCoreDataStorageObject *user;



@property (nonatomic, retain) NSNumber * oldMessageCount;
@property (nonatomic, assign) BOOL isLoadingCompleteInGroupChat;

-(NSInteger) numberOfUnReadMessages;
-(NSInteger) numberOfMessages;



// For Group ChatoldMessageCount



@property (nonatomic, retain) NSNumber *chatMessageTypeOf;

@end

@interface InboxMessage (CoreDataGeneratedAccessors)

- (void)insertObject:(ChatMessage *)value inMessageAtIndex:(NSUInteger)idx;
- (void)removeObjectFromMessageAtIndex:(NSUInteger)idx;
- (void)insertMessage:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeMessageAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInMessageAtIndex:(NSUInteger)idx withObject:(ChatMessage *)value;
- (void)replaceMessageAtIndexes:(NSIndexSet *)indexes withMessage:(NSArray *)values;
- (void)addMessageObject:(ChatMessage *)value;
- (void)removeMessageObject:(ChatMessage *)value;
- (void)addMessage:(NSOrderedSet *)values;
- (void)removeMessage:(NSOrderedSet *)values;
@end
