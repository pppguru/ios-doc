//
//  ActiveConverstion+ClassMethod.h
//  IMYourDoc
//
//  Created by OSX on 04/08/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import "ActiveConverstion.h"

@interface ActiveConverstion (ClassMethod)


+(ActiveConverstion*)initWithJID:(NSString*)t_withjid  withLastActiveTime:(NSString *)t_LastactiveTime withLastActiveSec:(NSString*)t_last_active_sec     withContext:(NSManagedObjectContext*)context;
+(NSArray*) getAllObjectsWithContext:(NSManagedObjectContext*)context;
+(NSDate*)getStr_LastAciveDateOfJid:(NSString*)t_withjid withContext:(NSManagedObjectContext*)context;

@end
