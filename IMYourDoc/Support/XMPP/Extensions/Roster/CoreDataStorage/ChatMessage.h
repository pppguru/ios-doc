//
//  ChatMessage.h
//  IMYourDoc
//
//  Created by macbook on 27/05/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "NSString+Validations.h"





@class GroupChatReadbyList;

@interface ChatMessage : NSManagedObject {
@private
}

@property (nonatomic, retain) NSString *thumb;

// 
@property (nonatomic, retain) NSString * uri;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSString * identityuri;
@property (nonatomic, retain) NSString * displayName;
@property (nonatomic, retain) NSDate * timeStamp;
@property (nonatomic, retain) NSNumber * read;
@property (nonatomic, retain) NSNumber * outbound;
@property (nonatomic, retain) NSNumber *fileTypeChat;
@property (nonatomic, retain) NSString *groupMessageID;
@property (nonatomic, retain) NSNumber * roomRead;


/**
 * This property indicate that server sent error (beoz of unauthentcation or other reason) but user has sent message to user   <br>
 * this will futher use in calculation to sent message to server in background
 * @see ChatState:  <br>
 */
@property (nonatomic, retain) NSNumber * readReportSent_Bl;

@property (nonatomic, retain) NSString *messageID;
@property(nonatomic,retain)NSNumber    *isRoomMessage;
@property(nonatomic,retain)NSNumber *isResending;

    // fileTypeChat  = 0   //... send Messagge Text Chat Type  = Chat   -  YES 
    // fileTypeChat  = 1   //... send Messagge File Chat Type  = Chat   -  NO

    // fileTypeChat  = 2   //... send Messagge File Chat Type  = Group  -    
    // fileTypeChat  = 3   //... send Messagge Text Chat Type  = Group  -   

@property(nonatomic,retain)NSNumber *mark_deleted;

/**
 * Request status is for images that need to be upload  <br>
 * 0  is yet to be upload <br>
 * 1... uploading  <br>
 * 2 ... uploaded  <br>
 * 3... file is uploaded but message is not sent
 * -1  ... Failed  <br>
 * @see ChatState:  <br>
 */
@property (nonatomic,retain) NSNumber *requestStatus;


@property(nonatomic,retain) NSNumber * reportedtoAPI;

/**
 * chatState is status of message
 *      0 Sending   <br>
 *       1 .. Sent    <br>
 *       2  Delivered   <br>
 *       3  Read    <br>
 *       4 Notification / Email sent  <br>
 *       5 Not delivered  <br>
 *       100 delivered <br>
 *       101 displayed Same to read status  <br> 
 * @see ChatStateType also use *** •chatMessageType
 */
@property (nonatomic, retain) NSNumber *chatState;

@property (nonatomic, retain) NSNumber *retryState;

@property (nonatomic, assign) BOOL isOutbound;  // is Sender (Left side )
@property (nonatomic, assign) BOOL hasBeenRead;

//   @property (nonatomic, assign) BOOL isFromFileTypeChat;

@property unsigned long long  recivedsize;

@property(nonatomic, assign) NSNumber*   dataSent;
@property(nonatomic,retain)NSDate *lastResend;
// This doesn't really belong in the data model, but we use it to cache the
// size of the speech bubble for this message.
@property (nonatomic, assign) CGSize bubbleSize;
@property (nonatomic, retain) NSOrderedSet *readby;

@property (nonatomic, retain) NSString *fileMediaType; // image or file




#pragma mark - broadcast 

@property (nonatomic, retain) NSNumber *chatMessageTypeOf;
@property (nonatomic, retain) NSString * bcSubject;

@property (nonatomic, assign) BOOL fakeMessage;




@end


@interface ChatMessage (CoreDataGeneratedAccessors)

- (void)insertObject:(GroupChatReadbyList *)value inReadbyAtIndex:(NSUInteger)idx;
- (void)removeObjectFromReadbyAtIndex:(NSUInteger)idx;
- (void)insertReadby:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeReadbyAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInReadbyAtIndex:(NSUInteger)idx withObject:(GroupChatReadbyList *)value;
- (void)replaceReadbyAtIndexes:(NSIndexSet *)indexes withReadby:(NSArray *)values;
- (void)addReadbyObject:(GroupChatReadbyList *)value;
- (void)removeReadbyObject:(GroupChatReadbyList *)value;
- (void)addReadby:(NSOrderedSet *)values;
- (void)removeReadby:(NSOrderedSet *)values;
@end
