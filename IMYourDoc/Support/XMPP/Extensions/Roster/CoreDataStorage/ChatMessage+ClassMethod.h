//
//  ChatMessage+ClassMethod.h
//  IMYourDoc
//
//  Created by vijayveer on 22/09/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import "ChatMessage.h"
#import "LoginActiveConResponse.h"



typedef void (^completionBlock__loadEaliarMessge) (BOOL succeeded);
typedef void (^failureBlock_loadEaliarMessge) (BOOL succeeded);

@interface ChatMessage (ClassMethod)
/**
 * ChatStateType is chat state of message  <br>
 *
 */


typedef enum : NSUInteger
{
    ChatMessageType_Simple = 0 ,
    ChatMessageType_Group = 1,
    ChatMessageType_Broadcast = 2
   
}
ChatMessageType;


typedef enum : NSUInteger
{
    ChatStateType_Sending =0 ,
    ChatStateType_Sent =1,
    ChatStateType_Delivered=2,    // Sender side
    ChatStateType_Read=3,
    ChatStateType_Notification_EmailSent =4 ,
    ChatStateType_NotDelivered  = 5,
    ChatStateType_NoneByReciever = 99, // delivery status when delivery is not send from receiver side.
    ChatStateType_deliveredByReciever = 100,  // Reciever Side
    ChatStateType_displayedByReciever = 101    // Reciever Side
}ChatStateType;

/*
 * This is new type for chant Message that will automatically incremated  after 30 sec ,When  message  object chat status is in sending   state and by default this all message will have retryStatus type Zero
 *
 *
 */

typedef enum
{
    RetryStatusType_one,
    RetryStatusType_two,
    RetryStatusType_three,
    
} RetryStatusType;



typedef NSNumber * drawingTypes;
typedef enum : NSInteger
{
    RequestStatusType_isYetToBeUpload =0 ,
    RequestStatusType_uploading =1,
    RequestStatusType_uploaded=2,
    RequestStatusType_fileIsUploadedButMessageIsNotSent =3 ,
    RequestStatusType_Failed  =-1,
    RequestStatusType_deliveredByRecieverGuest  =12,// Reciever Side
    RequestStatusType_deliveredByRecieverGroup = 13,// Reciever Side
    RequestStatusType_UnKnown = 14
}RequestStatusType;


// fileTypeChat  = 0   //... send Messagge Text Chat Type  = Chat   -  YES
// fileTypeChat  = 1   //... send Messagge File Chat Type  = Chat   -  NO

// fileTypeChat  = 2   //... send Messagge File Chat Type  = Group  -
// fileTypeChat  = 3   //... send Messagge Text Chat Type  = Group  -

typedef enum : NSInteger
{
    FileTextType_TextInChat =0 ,
    FileTextType_FileInChat =1 ,
    FileTextType_TextInGroup=2 ,
    FileTextType_FileInGroup =3 ,
}FileTextType;



typedef enum : NSInteger
{
    fileTypeChat_message = 0 ,
    fileTypeChat_File =1

}fileTypeChat;

typedef enum : BOOL
{
    OutBoundType_Left = NO,
    OutBoundType_Right = YES
}   OutBoundType;

typedef enum : BOOL
{
    mark_deleted_NO = NO,
    
    mark_deleted_YES = YES
    
}   mark_deleted;

+(NSString*)ChatTypeToStr:(ChatStateType)formatType ;



// Simple

+(ChatMessage*)initMessageWithFrom:(NSString*)old_from to:(NSString*)old_to content:(NSString*)old_content  timestamp:(NSString*)old_timeStamp  messageID:(NSString*)old_messageID withContext:(NSManagedObjectContext*)context MyJid:(NSString*)old_myJid WithFileType:(NSString*)filetype WithFilepath:(NSString*)filepath;


// broadcast
+(ChatMessage*)initbcMessageWithFrom:(NSString*)from to:(NSString*)to content:(NSString*)content subject:(NSString*)subject chatMessage:(ChatMessageType)chatMessageType  timestamp:(NSString*)timeStamp  messageID:(NSString*)messageID withSubjectid:(NSString*)subject_id ChatStateType:(ChatStateType)chatStateType;

// GroupChat
+(ChatMessage*)initGroupChatMessageFrom:(NSString*)from to:(NSString*)toGroupFromBody content:(NSString*)content chatMessage:(ChatMessageType)chatMessageType  timestamp:(NSString*)timeStamp messageID:(NSString*)messageID ChatStateType:(ChatStateType)chatStateType   MyJid:(NSString*)myJid WithFileType:(NSString*)filetype WithFilepath:(NSString*)filepath;






+(void)deleteEmptyJIDRowFromInboxAndChatTable;


+(ChatMessage*)getLastMessageWithJiD:(NSString*)jid withContext:(NSManagedObjectContext*)context;
+(NSDate*)getFirstMessageDateWithJiD:(NSString*)jid;
+(NSDate*)getLastMessageDateWithJiD:(NSString*)jid;

+(ChatMessage*)getFailedLastChatMessageWithContext:(NSManagedObjectContext*)context;
+(ChatMessage*)getLastFailedMessageForJID:(NSString *) jid;

+(BOOL)checkIfExistsChatMessageObjectWithMessageID:(NSString *) messageID;
+(BOOL)checkIfExistsChatMessageObjectWithMessageID:(NSString *) messageID withContext:(NSManagedObjectContext*)context;

+(ChatMessage*)getChatMessageObjectWithMessageID:(NSString *) messageID;
+(ChatMessage*)getChatMessageWithMessageID:(NSString*)messageId withContext:(NSManagedObjectContext*)context;

+(ChatMessage*)getfirstMessageWithjid:(NSString*)jid;;

+(NSArray*)getAllMessageIds;



#pragma mark - LoadEarliar Messages for Group

+(NSUInteger)getCountofMessagesForJid:(NSString*)jid;
+(void) setMark_deletedToNoForLastTenMessagesForJid:(NSString*)jid completionBlock:(completionBlock__loadEaliarMessge)completionBlock failureBloack:(failureBlock_loadEaliarMessge)failureBlock;

+(void)changeValueForOldMessageCountForJid:(NSString*)jid;

+(BOOL)checkLoadingCompleteInGroupChatForJid:(NSString*)jid;

+(void)resetIsLodingCompleteInGroupChatForJid:(NSString*)jid;
+(void)changeCountoOfLoadEalierMessageForJid:(NSString*)jid;


#pragma mark broadcast 

+(NSString*)getSubjectofMessageWithSubjectId:(NSString*)subjectId;
+(void)broadcastMessageDeliverywithBuddy:(NSString*)uri withMessageID:(NSString*)messageID;

@end
