//
//  GroupChatReadbyList+ClassMethod.h
//  IMYourDoc
//
//  Created by OSX on 01/04/16.
//  Copyright (c) 2016 vijayvir . All rights reserved.
//

#import "GroupChatReadbyList.h"
@class ChatMessage;

@interface GroupChatReadbyList (ClassMethod)
+(GroupChatReadbyList *)insertChatReadByMessage:(ChatMessage *)message userJID:(NSString *)userJID;

@end
