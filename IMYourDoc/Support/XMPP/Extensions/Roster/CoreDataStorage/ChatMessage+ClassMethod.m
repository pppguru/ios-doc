//
//  ChatMessage+ClassMethod.m
//  IMYourDoc
//
//  Created by vijayveer on 22/09/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import "ChatMessage+ClassMethod.h"
#import "AppDelegate.h"
#import "InboxMessage+ClassMethods.h"
#import "GroupChatReadbyList+ClassMethod.h"
@implementation ChatMessage (ClassMethod)


- (BOOL)isOutbound
{
    return [[self outbound] boolValue];
}

- (void)setIsOutbound:(BOOL)flag
{
    [self setOutbound:[NSNumber numberWithBool:flag]];
}

- (BOOL)hasBeenRead
{
    return [[self read] boolValue];
}

- (void)setHasBeenRead:(BOOL)flag
{
    if (flag != [self hasBeenRead])
    {
        [self setRead:[NSNumber numberWithBool:flag]];
    }
}


+(NSString*)ChatTypeToStr:(ChatStateType)formatType
{
    NSString *result = nil;
 
    switch(formatType) {
        case ChatStateType_Sending:
            result = @"ChatStateType_Sending";
            break;
        case ChatStateType_Sent:
            result = @"ChatStateType_Sent";
            break;
        case ChatStateType_Delivered:
            result = @"ChatStateType_Delivered";
            break;
        case ChatStateType_Read:
            result = @"ChatStateType_Read";
            break;
        case ChatStateType_Notification_EmailSent:
            result = @"ChatStateType_Notification_EmailSent";
            break;
        case ChatStateType_NotDelivered:
            result = @"ChatStateType_NotDelivered";
            break;
        case ChatStateType_deliveredByReciever:
            result = @"ChatStateType_deliveredByReciever";
            break;
        case ChatStateType_displayedByReciever:
            result = @"ChatStateType_displayedByReciever";
            break;
            
        default:
            [NSException raise:NSGenericException format:@"Unexpected FormatType."];
    }
    
    return result;
}


+(ChatMessage*)initMessageWithFrom:(NSString*)from
                                to:(NSString*)to
                           content:(NSString*)content
                         timestamp:(NSString*)old_timeStamp
                         messageID:(NSString*)messageID
                       withContext:(NSManagedObjectContext*)context
                             MyJid:(NSString*)selfUser
                      WithFileType:(NSString*)filetype
                      WithFilepath:(NSString*)filepath
{
    
    if(from==nil)
    {
        return nil ;
    }
    
    ChatMessage *message    = [NSEntityDescription insertNewObjectForEntityForName:@"ChatMessage" inManagedObjectContext:context];
    message.messageID       = messageID;
    
    message.chatMessageTypeOf=[NSNumber numberWithInt:ChatMessageType_Simple];
    
    if ([filetype isEqualToString:@"image"] )
    {
        message.fileMediaType=filetype;
        message.thumb= content;
        message.content         = filepath;
        message.fileTypeChat    = [NSNumber numberWithInteger:fileTypeChat_File];
        message.requestStatus    = [NSNumber numberWithInt:RequestStatusType_fileIsUploadedButMessageIsNotSent];
    }
  
    //pdf, doc, and other files are labeled "other" for filetype and not "file". The thumbnail image will appear when logging back in.
    else if ([filetype isEqualToString:@"file"] || [filetype isEqualToString:@"other"] )
    {
        message.fileMediaType = filetype;
        message.content         = filepath;
        message.fileTypeChat    = [NSNumber numberWithInt:fileTypeChat_File];
        NSString * extension=[[filepath lastPathComponent] pathExtension];
        
        if([[extension lowercaseString] isEqualToString:@"pdf"])
        {
            
            
            message.thumb=[UIImagePNGRepresentation([UIImage imageNamed:kfile_pdf]) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
            
        }
        else if([[extension lowercaseString] isEqualToString:@"doc"]||[[extension lowercaseString] isEqualToString:@"docx"])
        {
            message.thumb=[UIImagePNGRepresentation([UIImage imageNamed:kfile_word]) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
            
        }
        
        else  if([[extension lowercaseString] isEqualToString:@"xls"]||[[extension lowercaseString] isEqualToString:@"xlsx"])
        {
            message.thumb=[UIImagePNGRepresentation([UIImage imageNamed:kfile_xsl]) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
            
        }
        else if([[extension lowercaseString] isEqualToString:@"txt"])
        {
            message.thumb=[UIImagePNGRepresentation([UIImage imageNamed:kfile_text]) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
            
        }
        else  if([[extension lowercaseString] isEqualToString:@"ppt"]||[[extension lowercaseString] isEqualToString:@"pptx"])
        {
            message.thumb=[UIImagePNGRepresentation([UIImage imageNamed:kfile_ppt]) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        }
        else
        {
            message.thumb=[UIImagePNGRepresentation([UIImage imageNamed:kfile_extra]) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        }
    }
    else{
        message.content         = content;
        
        message.fileTypeChat    =[NSNumber numberWithInt:fileTypeChat_message];
        
    }
    
    
    NSString*str_old_fromIMYOURDOC;
    if ([from isEmail])
    {
        str_old_fromIMYOURDOC=from;
    }
    else
    {
        str_old_fromIMYOURDOC=[NSString stringWithFormat:@"%@@imyourdoc.com",from];
    }
    

    message.identityuri     =  selfUser;
    
    if ([str_old_fromIMYOURDOC isEqualToString:selfUser])
    {
        message.outbound        = [NSNumber numberWithBool:OutBoundType_Right];
        message.uri             =  to;
        
        message.chatState       = [NSNumber numberWithInt:ChatStateType_Read];
        message.requestStatus       = [NSNumber numberWithInt:RequestStatusType_uploaded];
    }
    else{
        message.outbound        = [NSNumber numberWithBool:OutBoundType_Left];
        message.uri             =  str_old_fromIMYOURDOC;
        
        message.chatState       = [NSNumber numberWithInt:ChatStateType_displayedByReciever];
        message.requestStatus       = [NSNumber numberWithInt:RequestStatusType_deliveredByRecieverGuest];
    }
    
    message.readReportSent_Bl=[NSNumber numberWithInt:1];
    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    NSDate * dateNotFormatted = [dateFormatter dateFromString: old_timeStamp];
    
    message.timeStamp       = dateNotFormatted;
    message.mark_deleted    = [NSNumber numberWithBool:mark_deleted_NO];
    message.displayName     = from;
    
    if (message.timeStamp == nil)
    {
        NSDateFormatter * dateFormatterw = [[NSDateFormatter alloc]init];
        [dateFormatterw setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
        NSDate * dateNotFormattedw = [dateFormatterw dateFromString: old_timeStamp];
        
        message.timeStamp       = dateNotFormattedw;
        if (message.timeStamp == nil)
        {
            
            
            NSDateFormatter * dateFormatterw = [[NSDateFormatter alloc]init];
            [dateFormatterw setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSDate * dateNotFormattedw = [dateFormatterw dateFromString: old_timeStamp];
            
            message.timeStamp       = dateNotFormattedw;
        }
        
        if (message.timeStamp == nil)
        {
            NSLog(@"%@",message.timeStamp);
        }
    }
    
    
    
    return message;
    
}




/*
 Use Message Id for Normal MessAGE 
 IF messageID == IMYOURDOC_CLOSE  IN BODY
 USE timestamp as messageID
 
 */

+(ChatMessage*)initGroupChatMessageFrom:(NSString*)from
                                     to:(NSString*)to
                                content:(NSString*)content
                            chatMessage:(ChatMessageType)chatMessageType
                              timestamp:(NSString*)timeStamp
                              messageID:(NSString*)messageID
                          ChatStateType:(ChatStateType)chatStateType
                                  MyJid:(NSString*)selfUser
                           WithFileType:(NSString*)filetype
                           WithFilepath:(NSString*)filepath
{
    if(from == nil)
    {
        return nil ;
    }
    
    BOOL isExist = [ChatMessage checkIfExistsChatMessageObjectWithMessageID:messageID];
    if (isExist)
    {
        return nil;
    }
    

    ChatMessage *message    = [NSEntityDescription insertNewObjectForEntityForName:@"ChatMessage"
                                                            inManagedObjectContext:[AppDel managedObjectContext_roster]];
    message.messageID       = messageID;
    
    
    
    
    
    if ([filetype isEqualToString:@"image"])
    {
        message.fileMediaType=filetype;
        message.thumb= content;
        message.content         = filepath;
        message.fileTypeChat    = [NSNumber numberWithInt:fileTypeChat_File];
        message.requestStatus    = [NSNumber numberWithInt:RequestStatusType_fileIsUploadedButMessageIsNotSent];
    }
    
    //pdf, doc, and other files are labeled "other" for filetype and not "file". The thumbnail image will appear when logging back in.
    else if ([filetype isEqualToString:@"file"] || [filetype isEqualToString:@"other"] )
    {
        message.fileMediaType=filetype;
        
        message.content         = filepath;
        message.fileTypeChat    = [NSNumber numberWithInt:fileTypeChat_File];
        NSString * extension=[[filepath lastPathComponent] pathExtension];
        
        if([[extension lowercaseString] isEqualToString:@"pdf"])
        {
            
            
            message.thumb=[UIImagePNGRepresentation([UIImage imageNamed:kfile_pdf]) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
            
        }
        else if([[extension lowercaseString] isEqualToString:@"doc"]||[[extension lowercaseString] isEqualToString:@"docx"])
        {
            message.thumb=[UIImagePNGRepresentation([UIImage imageNamed:kfile_word]) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
            
        }
        
        else  if([[extension lowercaseString] isEqualToString:@"xls"]||[[extension lowercaseString] isEqualToString:@"xlsx"])
        {
            message.thumb=[UIImagePNGRepresentation([UIImage imageNamed:kfile_xsl]) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
            
        }
        else if([[extension lowercaseString] isEqualToString:@"txt"])
        {
            message.thumb=[UIImagePNGRepresentation([UIImage imageNamed:kfile_text]) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
            
        }
        else  if([[extension lowercaseString] isEqualToString:@"ppt"]||[[extension lowercaseString] isEqualToString:@"pptx"])
        {
            message.thumb=[UIImagePNGRepresentation([UIImage imageNamed:kfile_ppt]) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        }
        else
        {
            message.thumb=[UIImagePNGRepresentation([UIImage imageNamed:kfile_extra]) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        }
    }
    else{
        message.content         = content;
        
        message.fileTypeChat    = [NSNumber numberWithInt:fileTypeChat_message];
        
    }
    
    
    NSString*fromMail;
    if ([from isEmail])
    {
        fromMail=from;
    }
    else
    {
        fromMail=[NSString stringWithFormat:@"%@@imyourdoc.com",from];
    }
    
    
    message.identityuri     =  selfUser;
    message.uri             =  to;
    
    if ([fromMail isEqualToString:selfUser])
    {
        message.outbound        = [NSNumber numberWithBool:OutBoundType_Right];
      
        
        message.chatState       = [NSNumber numberWithInt:ChatStateType_Read];
    }
    else{
        message.outbound        = [NSNumber numberWithBool:OutBoundType_Left];

        
        message.chatState       = [NSNumber numberWithInt:ChatStateType_displayedByReciever];
    }
    
    message.readReportSent_Bl=[NSNumber numberWithInt:1];
    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    NSDate * dateNotFormatted = [dateFormatter dateFromString: timeStamp];
    
    message.timeStamp       = dateNotFormatted;
    
    if (message.timeStamp == nil)
    {
        NSDateFormatter * dateFormatterw = [[NSDateFormatter alloc]init];
        [dateFormatterw setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
        NSDate * dateNotFormattedw = [dateFormatterw dateFromString: timeStamp];
        
        message.timeStamp       = dateNotFormattedw;
        if (message.timeStamp == nil)
        {
     
            
            NSDateFormatter * dateFormatterw = [[NSDateFormatter alloc]init];
            [dateFormatterw setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSDate * dateNotFormattedw = [dateFormatterw dateFromString: timeStamp];
            
              message.timeStamp       = dateNotFormattedw;
        }
        
        if (message.timeStamp == nil)
        {
                   NSLog(@"%@",message.timeStamp);
        }
    }
    
    
    message.mark_deleted    = [NSNumber numberWithBool:mark_deleted_NO];
    message.displayName     = from;
    message.isRoomMessage  = [NSNumber numberWithBool:YES];
    message.chatMessageTypeOf=[NSNumber numberWithInt:chatMessageType];
    
    
    return message;
    
    
}


+(ChatMessage*)initbcMessageWithFrom:(NSString*)from
                                  to:(NSString*)to
                             content:(NSString*)content
                             subject:(NSString*)subject
                         chatMessage:(ChatMessageType)chatMessageType
                           timestamp:(NSString*)timeStamp
                           messageID:(NSString*)messageID
                       withSubjectid:(NSString*)subject_id
                       ChatStateType:(ChatStateType)chatStateType
{
    
    
    
    
    
    if(from == nil)
    {
        return nil ;
    }

    
    BOOL isExist = [ChatMessage checkIfExistsChatMessageObjectWithMessageID:messageID];
    if (isExist)
    {
        return nil;
    }
    
    
    
    
    
    ChatMessage *message    =
    [NSEntityDescription insertNewObjectForEntityForName:@"ChatMessage" inManagedObjectContext:[AppDel managedObjectContext_roster]];
        message.messageID       = messageID;
    
    

    {
        message.content         = content;
        
        message.fileTypeChat    = [NSNumber numberWithInt:fileTypeChat_message];
    

        
        
    }
    
//    NSString*str_old_fromIMYOURDOdC;
//    if ([from isEmail]) {
//        str_old_fromIMYOURDOdC=from;
//    }
//    else
//    {
//        str_old_fromIMYOURDOdC=[NSString stringWithFormat:@"%@@imyourdoc.com",from];
//    }
//    
    message.identityuri     =  to;
      message.uri             =  from;
     message.outbound        = [NSNumber numberWithBool:OutBoundType_Left];
    message.chatState       =  [NSNumber numberWithInt:chatStateType];
    
     message.thumb =subject_id;
    
    message.readReportSent_Bl=[NSNumber numberWithInt:0];
    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss  Z"];
    
    NSDate * dateNotFormatted = [dateFormatter dateFromString: timeStamp];
  
    message.timeStamp       = dateNotFormatted;
    message.mark_deleted    = [NSNumber numberWithBool:mark_deleted_NO];
 
    message.displayName     = subject;
    
    message.bcSubject =subject;
    message.chatMessageTypeOf=[NSNumber numberWithInt:chatMessageType];

    
    
    return message;
}








+(NSDate*)getFirstMessageDateWithJiD:(NSString*)jid{
    
    ChatMessage * last_messages=nil;
    
    NSFetchRequest * request=[NSFetchRequest fetchRequestWithEntityName:@"ChatMessage"];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"uri=%@ and mark_deleted=%@",jid,[NSNumber numberWithBool:mark_deleted_NO]]];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"timeStamp" ascending:NO]];
    NSArray * last_chat = [[AppDel managedObjectContext_roster] executeFetchRequest:request error:nil];
    
    if (last_chat.count>0)
    {
        last_messages = [last_chat lastObject];
        return last_messages.timeStamp;
    }
    return nil;
    
}

+(NSDate*)getLastMessageDateWithJiD:(NSString*)jid;
{
    
    ChatMessage * last_messages=nil;
    
    NSFetchRequest * request=[NSFetchRequest fetchRequestWithEntityName:@"ChatMessage"];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"uri=%@ and mark_deleted=%@",jid,[NSNumber numberWithBool:mark_deleted_NO]]];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"timeStamp" ascending:NO]];
    NSArray * last_chat = [[AppDel managedObjectContext_roster] executeFetchRequest:request error:nil];
    
    
    if (last_chat.count>0)
    {
        last_messages = [last_chat firstObject];
        return last_messages.timeStamp;
    }
    return nil;
    
    
    
}
+(ChatMessage*)getfirstMessageWithjid:(NSString*)jid{
    
    ChatMessage * last_messages=nil;
    
    NSFetchRequest * request=[NSFetchRequest fetchRequestWithEntityName:@"ChatMessage"];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"uri=%@ and mark_deleted=%@ and bcSubject = nil",jid,[NSNumber numberWithBool:mark_deleted_NO]]];
     request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"timeStamp" ascending:YES]];
    NSArray * last_chat = [[AppDel managedObjectContext_roster] executeFetchRequest:request error:nil];
    
    
    if (last_chat.count>0)
    {
        last_messages = [last_chat firstObject];
        
        return last_messages;
    }
      return last_messages;
    
    
}

+(void)broadcastMessageDeliverywithBuddy:(NSString*)uri withMessageID:(NSString*)messageID
{

    
    NSDictionary *dict_broadcastList = [NSDictionary dictionaryWithObjectsAndKeys:
                                        
                                        @"mark_broadcast_message_delivery", @"method",
                                         uri, @"jid",
                                        messageID, @"message_id",
                                        [[NSUserDefaults standardUserDefaults]objectForKey:@"loginToken"], @"login_token",
                                        nil];
    
    
    
    {
        
        @try {
            
            [[WebHelper sharedHelper]servicesWebHelperWith:dict_broadcastList successBlock:^(BOOL succeeded, NSDictionary *response)
             {
                 
                 
                 
                 if ([[response objectForKey:@"err-code"] intValue] == 1)    // Success
                 {
                     
                     NSLog(@"%@",response);
         
                     
                     
                     
                 }
                 
                 else if ([[response objectForKey:@"err-code"] intValue] == 600)    // Session expired
                 { [AppDel signOutFromAppSilent];
                     

                 }
                 
                 else if ([[response objectForKey:@"err-code"] intValue] == 300)    // Unable to proceed
                 {

                 }
                 
                 
             } failureBlock:^(BOOL succeeded, NSDictionary *resultdict)
             {
                 
             }];
            
        }
        @catch (NSException * e) {
            
            
            NSLog(@"Exception: %@", e);
        }
        @finally {
            
            
            NSLog(@"finally");
        }
    }
    
    
    
    
    
    
}

+(NSArray*)getAllMessageIds{
    
    NSMutableArray * arr_messgaeIDS = [NSMutableArray new];
    
    
    NSFetchRequest *alreadyExistsRequest = [[NSFetchRequest alloc] initWithEntityName:@"ChatMessage"];
    
    NSArray *alreadyExistsArr = [[AppDel managedObjectContext_roster] executeFetchRequest:alreadyExistsRequest error:nil];
    
    for (ChatMessage * message in alreadyExistsArr )
    {
        [arr_messgaeIDS addObject:message.messageID];
        
    }
    
    
    return nil;
    
}

+(ChatMessage*)getLastMessageWithJiD:(NSString*)jid withContext:(NSManagedObjectContext*)context
{
    
    ChatMessage * last_messages=nil;
    
    NSFetchRequest * request=[NSFetchRequest fetchRequestWithEntityName:@"ChatMessage"];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"uri=%@ and mark_deleted=%@",jid,[NSNumber numberWithBool:mark_deleted_NO]]];
    
    
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"timeStamp" ascending:NO]];
    
    NSArray * last_chat = [context executeFetchRequest:request error:nil];
    
    last_messages = [last_chat firstObject];
    
    
    return last_messages;
    
    
    
}


+(BOOL)checkIfExistsChatMessageObjectWithMessageID:(NSString *) messageID
{
    return [self checkIfExistsChatMessageObjectWithMessageID:messageID withContext:[AppDel managedObjectContext_roster]];
}

+(BOOL)checkIfExistsChatMessageObjectWithMessageID:(NSString *) messageID withContext:(NSManagedObjectContext*)context
{
    NSFetchRequest *alreadyExists = [[NSFetchRequest alloc] initWithEntityName:@"ChatMessage"];
    [alreadyExists setPredicate:[NSPredicate predicateWithFormat:@"messageID=%@", messageID]];
    NSUInteger count = [context countForFetchRequest:alreadyExists error:nil];
    
    if (count != NSNotFound && count > 0)
        return YES;
    else
        return NO;
}

+(ChatMessage*)getChatMessageObjectWithMessageID:(NSString *) messageID
{
    return [self getChatMessageWithMessageID:messageID withContext:[AppDel managedObjectContext_roster]];
}

+(ChatMessage*)getChatMessageWithMessageID:(NSString*)messageId withContext:(NSManagedObjectContext*)context
{
    NSFetchRequest *alreadyExists = [[NSFetchRequest alloc] initWithEntityName:@"ChatMessage"];
    [alreadyExists setPredicate:[NSPredicate predicateWithFormat:@"messageID=%@", messageId]];
    NSArray *alreadyExistsArr = [context executeFetchRequest:alreadyExists error:nil];
    ChatMessage * last_messages=nil;
    last_messages= [alreadyExistsArr lastObject];
    return last_messages;
}


+(ChatMessage*)getFailedLastChatMessageWithContext:(NSManagedObjectContext*)context{
    
    NSFetchRequest *alreadyExistsRequest = [[NSFetchRequest alloc] initWithEntityName:@"ChatMessage"];
    
    [alreadyExistsRequest setPredicate:[NSPredicate predicateWithFormat:@"requestStatus == %@ and mark_deleted=%@", [NSNumber numberWithInt:RequestStatusType_Failed],[NSNumber numberWithBool:mark_deleted_NO]]];
    
    
    alreadyExistsRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"timeStamp" ascending:NO]];
    
    
    NSArray *alreadyExistsArr = [context executeFetchRequest:alreadyExistsRequest error:nil];
    
    ChatMessage * last_messages=nil;
    
    last_messages= [alreadyExistsArr firstObject];
    
    
    return last_messages;
}


+(ChatMessage*)getLastFailedMessageForJID:(NSString *) jid
{
    NSFetchRequest *alreadyExistsRequest = [[NSFetchRequest alloc] initWithEntityName:@"ChatMessage"];
    
    [alreadyExistsRequest setPredicate:[NSPredicate predicateWithFormat:@"mark_deleted=%@ and uri=%@ and outbound=%@ and (chatState=%@ OR chatState=%@) and ((  requestStatus!=%@) OR  fileTypeChat= null) and lastResend < %@", [NSNumber numberWithBool:mark_deleted_NO],jid,[NSNumber numberWithBool:OutBoundType_Right],[NSNumber numberWithInt:ChatStateType_Sending],[NSNumber numberWithInt:ChatStateType_NotDelivered],[NSNumber numberWithInt:RequestStatusType_uploaded], [NSDate dateWithTimeIntervalSinceNow:-60]]];
    
    
    alreadyExistsRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"timeStamp" ascending:YES]];
    
    NSArray *alreadyExistsArr = [[AppDel managedObjectContext_roster] executeFetchRequest:alreadyExistsRequest error:nil];
    
    ChatMessage * last_messages=nil;
    
    last_messages= [alreadyExistsArr firstObject];
    
    
    return last_messages;
}


+(NSString*)getSubjectofMessageWithSubjectId:(NSString*)subjectId{
    NSString *subject;
    
    
    
    NSFetchRequest *alreadyExistsRequest = [[NSFetchRequest alloc] initWithEntityName:@"ChatMessage"];
    
    [alreadyExistsRequest setPredicate:[NSPredicate predicateWithFormat:@"thumb=%@", subjectId]];
    
    
    alreadyExistsRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"timeStamp" ascending:YES]];
    
    NSArray *alreadyExistsArr = [[AppDel managedObjectContext_roster] executeFetchRequest:alreadyExistsRequest error:nil];
    
    ChatMessage * last_messages=nil;
    
    last_messages= [alreadyExistsArr firstObject];
    
    subject =last_messages.bcSubject;
    
    return subject;
    
}




#pragma mark - LoadEarliar Messages for Group

+(NSUInteger)getCountofMessagesForJid:(NSString*)jid
{
    NSFetchRequest *alreadyExistsRequest = [[NSFetchRequest alloc] initWithEntityName:@"ChatMessage"];
    
    [alreadyExistsRequest setPredicate:[NSPredicate predicateWithFormat:@"uri=%@", jid]];

    NSUInteger count = [[AppDel managedObjectContext_roster] countForFetchRequest:alreadyExistsRequest error:nil];
  
    if (count != NSNotFound)
        return count;
    else
        return 0;
    
}
+(BOOL)checkLoadingCompleteInGroupChatForJid:(NSString*)jid{
    
    NSFetchRequest *alreadyExistsRequest = [[NSFetchRequest alloc] initWithEntityName:@"InboxMessage"];
    
    [alreadyExistsRequest setPredicate:[NSPredicate predicateWithFormat:@"jidStr=%@ ",jid]];
    
    NSArray *alreadyExistsArr = [[AppDel managedObjectContext_roster] executeFetchRequest:alreadyExistsRequest error:nil];
    
    
    
    InboxMessage * inboxMessage=nil;
    
    
    inboxMessage = [alreadyExistsArr firstObject];
    
    
    
    if (inboxMessage)
    {
        return   inboxMessage.isLoadingCompleteInGroupChat ;
        
    }
    
    return NO;
    
}


+(void)deleteEmptyJIDRowFromInboxAndChatTable
{
   
    {
        NSFetchRequest *alreadyExistsRequest = [[NSFetchRequest alloc] initWithEntityName:@"InboxMessage"];
        
        [alreadyExistsRequest setPredicate:[NSPredicate predicateWithFormat:@"jidStr == nil "]];
        
        NSArray *alreadyExistsArr = [[AppDel managedObjectContext_roster] executeFetchRequest:alreadyExistsRequest error:nil];
        
        
        if (alreadyExistsArr.count>0)
        {
            for (InboxMessage *mess in alreadyExistsArr)
            {
                
                [[AppDel managedObjectContext_roster] deleteObject:mess];
            }
            [[AppDel managedObjectContext_roster] save:nil];
            
        }
        
    }
   
    {
    NSFetchRequest *alreadyExistsRequest = [[NSFetchRequest alloc] initWithEntityName:@"ChatMessage"];
    
    [alreadyExistsRequest setPredicate:[NSPredicate predicateWithFormat:@"uri == nil "]];
    
    NSArray *alreadyExistsArr = [[AppDel managedObjectContext_roster] executeFetchRequest:alreadyExistsRequest error:nil];
    
    
    if (alreadyExistsArr.count>0)
    {
        for (ChatMessage *mess in alreadyExistsArr)
        {
            
            [[AppDel managedObjectContext_roster] deleteObject:mess];
        }
        [[AppDel managedObjectContext_roster] save:nil];
        
    }
    }
    
    
   
    
    
    
}

+(void)changeCountoOfLoadEalierMessageForJid:(NSString*)jid
 {
     NSFetchRequest *alreadyExistsRequest = [[NSFetchRequest alloc] initWithEntityName:@"InboxMessage"];
     
     [alreadyExistsRequest setPredicate:[NSPredicate predicateWithFormat:@"jidStr=%@ ",jid]];
     
     NSArray *alreadyExistsArr = [[AppDel managedObjectContext_roster] executeFetchRequest:alreadyExistsRequest error:nil];
     
     
     
     InboxMessage * inboxMessage=nil;
     
     
     inboxMessage = [alreadyExistsArr firstObject];
     
     if (inboxMessage)
     {
         inboxMessage.oldMessageCount = [NSNumber numberWithInteger:5 ];
         inboxMessage.isLoadingCompleteInGroupChat = NO;
         [[AppDel managedObjectContext_roster] save:nil];
         
     }
     
    
}

+(void)resetIsLodingCompleteInGroupChatForJid:(NSString*)jid
{
    NSFetchRequest *alreadyExistsRequest = [[NSFetchRequest alloc] initWithEntityName:@"InboxMessage"];
    
    [alreadyExistsRequest setPredicate:[NSPredicate predicateWithFormat:@"jidStr=%@ ",jid]];
    
    NSArray *alreadyExistsArr = [[AppDel managedObjectContext_roster] executeFetchRequest:alreadyExistsRequest error:nil];
    
    
    
    InboxMessage * inboxMessage=nil;
    
    
    inboxMessage = [alreadyExistsArr firstObject];
    
    if (inboxMessage)
    {
        inboxMessage.oldMessageCount = [NSNumber numberWithInteger:0 ];
        inboxMessage.isLoadingCompleteInGroupChat = NO;
        [[AppDel managedObjectContext_roster] save:nil];
        
    }
    
   
}

+(void)changeValueForOldMessageCountForJid:(NSString*)jid

{
    NSFetchRequest * request=[NSFetchRequest fetchRequestWithEntityName:@"ChatMessage"];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"uri=%@ and mark_deleted=%@",jid,[NSNumber numberWithBool:mark_deleted_NO]]];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"timeStamp" ascending:NO]];
    NSUInteger count = [[AppDel managedObjectContext_roster] countForFetchRequest:request error:nil];
    
    
    
    if (count != NSNotFound)
    {
        NSFetchRequest *alreadyExistsRequest = [[NSFetchRequest alloc] initWithEntityName:@"InboxMessage"];
        
        [alreadyExistsRequest setPredicate:[NSPredicate predicateWithFormat:@"jidStr=%@ ",jid]];
        
        NSArray *alreadyExistsArr = [[AppDel managedObjectContext_roster] executeFetchRequest:alreadyExistsRequest error:nil];
        
        
        
        InboxMessage * inboxMessage=nil;
        
        
        inboxMessage = [alreadyExistsArr firstObject];
        
        if (inboxMessage)
        {
            inboxMessage.oldMessageCount = [NSNumber numberWithInteger:count ];
            inboxMessage.isLoadingCompleteInGroupChat = NO;
            [[AppDel managedObjectContext_roster] save:nil];
            
        }
    }
  
    
    
}


+(void) setMark_deletedToNoForLastTenMessagesForJid:(NSString*)jid completionBlock:(completionBlock__loadEaliarMessge)completionBlock failureBloack:(failureBlock_loadEaliarMessge)failureBlock{
    
    
    NSFetchRequest * request=[NSFetchRequest fetchRequestWithEntityName:@"ChatMessage"];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"uri=%@ and mark_deleted=%@ and fakeMessage=%@",jid,[NSNumber numberWithBool:mark_deleted_YES],[NSNumber numberWithBool:NO]]];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"timeStamp" ascending:NO]];
    NSArray * arr_big = [[AppDel managedObjectContext_roster] executeFetchRequest:request error:nil];
    
    
     if (arr_big.count>0)
     {
         NSUInteger rangemax = 1;
         
         
         if (arr_big.count>10)
         {
             rangemax = 10;
             
         }
         else{
             rangemax = arr_big.count;
         }
         
         
         if (arr_big.count>0) {
             NSArray *smallArray = [arr_big subarrayWithRange:NSMakeRange(0, rangemax)];
             if (smallArray.count>0)
             {
                 
                 for (ChatMessage *message in smallArray)
                 {
                     message.mark_deleted = [NSNumber numberWithBool:mark_deleted_NO];
                     [[AppDel managedObjectContext_roster] save:nil];
                 }
                 completionBlock(YES);
                 
                 return;
                 
             }
         }
         
      
         
     }
    
 // if there is no message in loacl database load from server
   
    failureBlock(YES);
    
    return;
    

}


+(void)groupMessageReadByListChangeStatus:(NSString*)status   ofMessage:(ChatMessage *)msg from:(XMPPJID *)fromJID
{
    if ([status isEqualToString:@"Delivered"] || [status isEqualToString:@"Read"]  || [status isEqualToString:@"Display"] || [status isEqualToString:@"Notification"]|| [status isEqualToString:@"Deliver"] || [status isEqualToString:@"Notification Sent"] )
    {
        
        GroupChatReadbyList *readUser = [[[msg readby] filteredOrderedSetUsingPredicate:[NSPredicate predicateWithFormat:@"userJID=%@", [fromJID user]]] lastObject];
        
        if (readUser == nil)
        {
            readUser = [GroupChatReadbyList insertChatReadByMessage:msg userJID:[fromJID user]];
        }
        
        readUser.status = status;
        
        
        
        
        NSError *error = nil;
        
        if([[AppDel managedObjectContext_roster]  hasChanges])
            if (![[AppDel managedObjectContext_roster] save:&error])
            {
                NSLog(@"%@", [error domain]);
            }
        
        
        
        return;
        
    }
    
    if ([fromJID resource])
    {
        GroupChatReadbyList *readUser = [[[msg readby] filteredOrderedSetUsingPredicate:[NSPredicate predicateWithFormat:@"userJID=%@", [fromJID resource]]] lastObject];
        
        if (readUser == nil)
        {
            readUser = [GroupChatReadbyList insertChatReadByMessage:msg userJID:[fromJID resource]];
        }
        
        readUser.status = status;
        
        
        
        
        NSError *error = nil;
        
        if([[AppDel managedObjectContext_roster]  hasChanges])
            if (![[AppDel managedObjectContext_roster] save:&error])
            {
                NSLog(@"%@", [error domain]);
            }
    }
    
    
    
}


@end
