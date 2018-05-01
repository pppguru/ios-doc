//
//  RoomMember.h
//  IMYourDoc
//
//  Created by macbook on 30/07/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface RoomMember : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * roomName;
@property (nonatomic, retain) NSString * roomMemberName;
@property (nonatomic, retain) NSString * affilation;
@property (nonatomic, retain) NSNumber *roomPresence;



@end
