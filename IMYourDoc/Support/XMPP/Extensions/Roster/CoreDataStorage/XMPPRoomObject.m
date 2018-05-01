
//
//  XMPPRoomObject.m
//  IMYourDoc
//
//  Created by Nipun on 20/01/15.
//
//

#import "XMPPRoomObject.h"
#import "XMPPRoomAffaliations.h"
#import "XMPPRoomMemoryStorage.h"
#import "XMPPUserCoreDataStorageObject.h"
#import "AppDelegate.h"

@implementation XMPPRoomObject

@dynamic room_status;
@dynamic room_jidStr;
@dynamic subject;
@dynamic streamJidStr;
@dynamic name,lastMessageDate;
@dynamic isPatient;
@dynamic members;
@dynamic creationDate;

@synthesize primitiveisPatient;
@synthesize room=_room;
-(XMPPRoom *)room
{
    if (_room)
    {
        return _room;
    }
    
    _room=[[XMPPRoom alloc] initWithRoomStorage:[XMPPRoomMemoryStorage sharedInstanse] jid:[XMPPJID jidWithString:self.room_jidStr]];
    
    [_room activate:[AppDel xmppStream]];
    
    [[AppDel managedObjectContext_roster] lock];
    NSMutableSet * members=[self.members mutableCopy];
    
    for (XMPPRoomAffaliations * member in members)
    {
     if([member.role isEqualToString:@"member"])
     {
         RoomMembers * mem=[RoomMembers roomMembers:member.jid];
         mem.role=member.role;
         [_room.members addObject:mem];
     }
    }
    [[AppDel managedObjectContext_roster] unlock];
    return _room;
    
}

-(NSString *)roleForJid:(XMPPJID *)jid
{
    NSString * str;
    str=[[[self.members filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"memberJidStr=%@",jid.bare]] anyObject] role];
    return str;
}

-(BOOL)isPatientRoom
{
 
    NSNumber *tmp = nil;
    if (tmp == nil) {
        //tmp = [XMPPJID jidWithString:[self jidStr]];
        
        
        NSFetchRequest * request=[NSFetchRequest  fetchRequestWithEntityName:@"XMPPUserCoreDataStorageObject"];
        
        request.predicate=[NSPredicate predicateWithFormat:@"jidStr IN %@ ",[[self.members filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"role!='none'"]]valueForKey:@"memberJidStr"]];
       
        NSArray * users=[self.managedObjectContext executeFetchRequest:request error:nil];
        
        for (XMPPUserCoreDataStorageObject * user in users) {
            
            if([[[[user.groups anyObject] name] uppercaseString]isEqualToString:@"PATIENT"])
                return YES;
        }
    }
    return NO;
    
  
}


@end
