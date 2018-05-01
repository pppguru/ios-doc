//
//  GroupChatReadbyList.h
//  IMYourDoc
//
//  Created by Harminder on 02/04/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface GroupChatReadbyList : NSManagedObject

@property (nonatomic, retain) NSString * userJID;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSDate * timeStamp;

@end
