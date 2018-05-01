//
//  BroadcastSubjectSender+ClassMethod.h
//  IMYourDoc
//
//  Created by vijayveer on 23/09/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import "BroadcastSubjectSender.h"

@interface BroadcastSubjectSender (ClassMethod)
+(BroadcastSubjectSender*)initWithSubject:(NSString*)str_subject group:(BroadCastGroup *) group ;
+(BroadcastSubjectSender*)initWithSubject:(NSString*)str_subject subjectId:(NSString*)subjectId groupID:(NSString *)groupid  group:(BroadCastGroup*)group date:(NSString*)sent_timestamp;

@end
