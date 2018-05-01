//
//  XMPPRoomInfo.h
//  NoMyID
//
//  Created by harry on 12/09/14.
//  Copyright (c) 2014 Emxq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class XMPPvCardTemp;
@class XMPPRoom;
@protocol XMPPStreamDelegate;

@interface XMPPRoomInfo : NSManagedObject<XMPPStreamDelegate>

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * jidStr;
@property (nonatomic, retain) NSDate * last_update;
@property (nonatomic, retain) NSString * room_subject;
@property (nonatomic, retain) NSString * last_message;
@property (nonatomic, retain) NSString * streamJidStr;
@property (nonatomic, retain) NSString * desc;
@property(nonatomic,retain) XMPPRoom * room;

-(XMPPvCardTemp *)vcard;
@end
