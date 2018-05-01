//
//  BroadCastMembers+ClassMethod.m
//  IMYourDoc
//
//  Created by vijayveer on 14/09/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import "BroadCastMembers+ClassMethod.h"

#import "AppDelegate.h"

@implementation BroadCastMembers (ClassMethod)



+(BroadCastMembers*)initWithStreamId:(NSString *)str_streamId{
    
    
    
    NSFetchRequest *alreadyExists = [[NSFetchRequest alloc] initWithEntityName:@"BroadCastMembers"];
    [alreadyExists  setPredicate:[NSPredicate predicateWithFormat:@"streamId = %@ ",str_streamId  ]];
    NSError *er = nil;
    NSArray *alreadyExistsArr = (NSArray*)[[AppDel managedObjectContext_roster] executeFetchRequest:alreadyExists error:&er];
    
    if([alreadyExistsArr count]!=0)
    {
        return (BroadCastMembers*)[alreadyExistsArr firstObject];
    }
    
    else{
        BroadCastMembers* newFlight = [NSEntityDescription insertNewObjectForEntityForName:@"BroadCastMembers" inManagedObjectContext:[AppDel managedObjectContext_roster]];
           newFlight.streamId=str_streamId;
        
        
        return newFlight;
    }
    
    
    
    
   
    
}

@end
