//
//  ConversationLog.h
//  IMYourDoc
//
//  Created by OSX on 24/07/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ConversationLog : NSManagedObject

@property (nonatomic, retain) NSString * str_start;
@property (nonatomic, retain) NSDate * lastSynDate;
@property (nonatomic, retain) NSString * jid;
@property (nonatomic, retain) NSString * withJid;
@property (nonatomic, retain) NSNumber * read;
@property (nonatomic, retain) NSDate * start;

@end
