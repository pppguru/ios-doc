//
//  ActiveConverstion.h
//  IMYourDoc
//
//  Created by OSX on 07/08/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ActiveConverstion : NSManagedObject

@property (nonatomic, retain) NSString * jid;
@property (nonatomic, retain) NSDate * lastActive;
@property (nonatomic, retain) NSString * str_lastActive;
@property (nonatomic, retain) NSString * str_last_active_sec;

@end
