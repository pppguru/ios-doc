//
//  BroadCastMessageSender+ClassMetod.h
//  IMYourDoc
//
//  Created by vijayveer on 17/09/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import "BroadCastMessageSender.h"
@class BroadCastGroup;


typedef enum : NSInteger
{
    BCMessageType_Sending =0 ,
    BCMessageType_Sent =1,
    BCMessageType_Delivered=2,
    BCMessageType_Read=3,
    BCMessageType_Notification_EmailSent =4 ,
    BCMessageType_NotDelivered  =5,
    BCMessageType_delivered=100,
    BCMessageType_displayed=101
}BCMessageType;


@interface BroadCastMessageSender (ClassMetod)


@property (nonatomic, retain) NSArray *recipientjids;
/**
 *  <br>
 * This method adds Message to database and also append following things
 * -> Link this message to every recipient i.e  create recipient and link to message
 * @see BCMessageType:  <br>
 * @see +(BroadCastMessageDeliveryRecipient*)initWithRecipientJid:(NSString *)str_receiverJid messageID:(NSString *)str_messageId responseStatus:(BC_ResponseStatusType)responseStauts lastUpdate:(NSDate*)lastupdate ofMessage:(BroadCastMessageSender*)ofmessage  <br>
 */

+(BroadCastMessageSender*)initMessage:(NSString*)str_message  ofsubject:(BroadcastSubjectSender*)subject status:(BCMessageType )status  withSubjectId:(NSString*)str_subjectid;

+(BroadCastMessageSender*)initStatTransferMessage:(NSString*)str_message  ofsubject:(BroadcastSubjectSender*)subject status:(BCMessageType )status  withSubjectId:(NSString*)str_subjectid date:(NSString*)sent_timestamp messageID:(NSString*)messageId;


+(NSString*)getDelievedToWithMessage:(BroadCastMessageSender*)message;
+(NSString*)getReadByWithMessage:(BroadCastMessageSender*)message;

+(void)setStatusofMessageWhenDelievedWithMessahgId:(NSString*)message withRecipitId:(NSString*)recipitent;
+(void)setStatusofMessageWhenReadWithMessahgId:(NSString*)message   withRecipitId:(NSString*)recipitent;
+(void)broadcastStateTransferMessages:(NSMutableArray*)arr_messages group:(BroadCastGroup*)group;




@end
