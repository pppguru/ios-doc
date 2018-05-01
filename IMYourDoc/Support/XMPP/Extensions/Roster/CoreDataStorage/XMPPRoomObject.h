//
//  XMPPRoomObject.h
//  IMYourDoc
//
//  Created by Nipun on 20/01/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "XMPPRoom.h"

@class XMPPRoomAffaliations;

@interface XMPPRoomObject : NSManagedObject

@property (nonatomic, retain) NSString   * room_status;
@property (nonatomic, retain) NSString  * room_jidStr;
@property (nonatomic, retain) NSString   * subject;
@property (nonatomic, retain) NSString   * streamJidStr;
@property (nonatomic, retain) NSString   * name;
@property (nonatomic, retain) NSNumber * isPatient;
@property (nonatomic, retain) NSSet       *members;
@property(nonatomic,retain)NSDate *      lastMessageDate;
@property(nonatomic,retain)NSDate *      creationDate;

@property (nonatomic, strong) XMPPRoom * room;

@property(nonatomic,retain) NSNumber *primitiveisPatient;

-(NSString *)roleForJid:(XMPPJID *)jid;

-(BOOL)isPatientRoom;

@end

@interface XMPPRoomObject (CoreDataGeneratedAccessors)

- (void)addMembersObject:(XMPPRoomAffaliations *)value;
- (void)removeMembersObject:(XMPPRoomAffaliations *)value;
- (void)addMembers:(NSSet *)values;
- (void)removeMembers:(NSSet *)values;

@end
