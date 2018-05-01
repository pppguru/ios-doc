//
//  BroadCastMessageDeliveryRecipient+ClassMethod.h
//  IMYourDoc
//
//  Created by vijayveer on 17/09/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

@class BroadCastMessageSender;

#import "BroadCastMessageDeliveryRecipient.h"



typedef enum : NSInteger
{
    BC_ResponseStatusType_Sending =0 ,
    BC_ResponseStatusType_Sent =1,
    BC_ResponseStatusType_Delivered=2,
    BC_ResponseStatusType_Read=3,
    BC_ResponseStatusType_Notification_EmailSent =4 ,
    BC_ResponseStatusType_NotDelivered  =5,
    BC_ResponseStatusType_delivered=100,
    BC_ResponseStatusType_displayed=101
}   BC_ResponseStatusType;

@interface BroadCastMessageDeliveryRecipient (ClassMethod)



+(BroadCastMessageDeliveryRecipient*)initWithRecipientJid:(NSString *)str_receiverJid messageID:(NSString *)str_messageId responseStatus:(BC_ResponseStatusType)responseStauts lastUpdate:(NSDate*)lastupdate ofMessage:(BroadCastMessageSender*)ofmessage ;



@end
