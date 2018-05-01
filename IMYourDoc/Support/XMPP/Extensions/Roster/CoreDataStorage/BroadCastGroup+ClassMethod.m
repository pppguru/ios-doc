//
//  BroadCastGroup+ClassMethod.m
//  IMYourDoc
//
//  Created by vijayveer on 14/09/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import "BroadCastGroup+ClassMethod.h"
#import "BroadCastMembers+ClassMethod.h"

#import "AppDelegate.h"

@implementation BroadCastGroup (ClassMethod)





-(BOOL)isPatientRoom;
{
  
    NSNumber *tmp = nil;
    if (tmp == nil)
    {
        
        NSFetchRequest * request=[NSFetchRequest  fetchRequestWithEntityName:@"XMPPUserCoreDataStorageObject"];
        
        request.predicate=[NSPredicate predicateWithFormat:@"jidStr IN %@ ",[self.members valueForKey:@"streamId"]];
        
        NSArray * users=[self.managedObjectContext executeFetchRequest:request error:nil];
        
        for (XMPPUserCoreDataStorageObject * user in users) {
            
            if([[[[user.groups anyObject] name] uppercaseString]isEqualToString:@"PATIENT"])
                return YES;
        }
    }
    return NO;
    
    
}

+(BroadCastGroup*)initWithGroupName:(NSString*)str_groupName withgroupId:(id )str_groupId  withGroupMembersArray:(NSArray *)arr_members

{
    
    
    NSFetchRequest *alreadyExists = [[NSFetchRequest alloc] initWithEntityName:@"BroadCastGroup"];
    [alreadyExists  setPredicate:[NSPredicate predicateWithFormat:@"groupId = %@ ",str_groupId  ]];
    NSError *er = nil;
    NSArray *alreadyExistsArr = (NSArray*)[[AppDel managedObjectContext_roster] executeFetchRequest:alreadyExists error:&er];
    
    if([alreadyExistsArr count]!=0)
    {
        return (BroadCastGroup*)[alreadyExistsArr firstObject];
    }
    
    else
    {
        BroadCastGroup *obj_ActiveConverstion    = [NSEntityDescription insertNewObjectForEntityForName:@"BroadCastGroup" inManagedObjectContext:[AppDel managedObjectContext_roster]];
     
        obj_ActiveConverstion.name=str_groupName;
        obj_ActiveConverstion.groupId=str_groupId ;
        obj_ActiveConverstion.date = [NSDate date];
        obj_ActiveConverstion.lastUpdated = obj_ActiveConverstion.date;
        for (id memberName in arr_members)
        {
        
            BroadCastMembers *member=[BroadCastMembers initWithStreamId:memberName ];
            [obj_ActiveConverstion addMembersObject:member];
            
        }
        
        
        NSError *er = nil;
        if([[AppDel managedObjectContext_roster]  hasChanges])
            [[AppDel managedObjectContext_roster] save:&er];
        
            return obj_ActiveConverstion;
    }
    
}

@end
