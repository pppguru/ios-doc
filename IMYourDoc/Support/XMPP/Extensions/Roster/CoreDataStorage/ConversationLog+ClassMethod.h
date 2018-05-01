//
//  ConversationLog+ClassMethod.h
//  IMYourDoc
//
//  Created by OSX on 24/07/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import "ConversationLog.h"

@interface ConversationLog (ClassMethod)
+(ConversationLog*)initMyJID:(NSString*)t_MYjid WithJID:(NSString*)t_withjid   lastSynDate:(NSString*)lastdate startDate:(NSString*)t_startdate withContext:(NSManagedObjectContext*)context;
+(ConversationLog*)getLastConversationMYJiD:(NSString*)jid WithJID:(NSString*)withjid withContext:(NSManagedObjectContext*)context;
+(void)resetConversationLogMYJiD:(NSString*)jid WithJID:(NSString*)withjid withContext:(NSManagedObjectContext*)context;
+(NSUInteger)getUnreadCountConversationLogMYJiD:(NSString*)jid WithJID:(NSString*)withjid withContext:(NSManagedObjectContext*)context;
+(void) deleteAllObjectsWithContext:(NSManagedObjectContext*)context inTable:(NSString*)table;
+(ConversationLog*)getIfObjectExistMyJID:(NSString*)t_MYjid WithJID:(NSString*)t_withjid   lastSynDate:(NSString*)t_lastdate startDate:(NSString*)t_startdate withContext:(NSManagedObjectContext*)context;



@end
