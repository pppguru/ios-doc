//
//  Created by Björn Sållarp on 2009-06-14.
//  NO Copyright 2009 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import "CoreDataHelper.h"


@implementation CoreDataHelper


+(NSMutableArray *) searchObjectsInContext: (NSString*) entityName : (NSPredicate *) predicate : (NSString*) sortKey : (BOOL) sortAscending : (NSManagedObjectContext *) managedObjectContext
{

	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];	
	
	// If a predicate was passed, pass it to the query
	if (predicate != nil)
	{
		[request setPredicate:predicate];
	}
	
	// If a sort key was passed, use it for sorting.
	if (sortKey != nil)
	{
		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:sortAscending];
		NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
		[request setSortDescriptors:sortDescriptors];
		[sortDescriptors release];
		[sortDescriptor release];
	}
	
	NSError *error;
	
	NSMutableArray *mutableFetchResults = [[[managedObjectContext executeFetchRequest:request error:&error] mutableCopy] autorelease];
	
	[request release];
	
	return mutableFetchResults;
}

+(NSMutableArray *) searchObjectsInContext: (NSString*) entityName : (NSPredicate *) predicate : (NSString*) sortKey1 : (NSString *)sortKey2 : (BOOL) sortAscending : (NSManagedObjectContext *) managedObjectContext
{
    
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];	
	
        // If a predicate was passed, pass it to the query
	if (predicate != nil)
	{
		[request setPredicate:predicate];
	}
	
        // If a sort key was passed, use it for sorting.
	if (sortKey1 != nil)
	{
		NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:sortKey1 ascending:sortAscending];
        NSSortDescriptor *sortDescriptor2;
        NSArray *sortDescriptors=nil;
        if (sortKey2 != nil) {
            sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:sortKey2 ascending:sortAscending];
            sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor1,sortDescriptor2,nil];
            [request setSortDescriptors:sortDescriptors];
            [sortDescriptors release];
            [sortDescriptor1 release];

        }
        else
        {
            sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor1,nil];
            [request setSortDescriptors:sortDescriptors];
            [sortDescriptors release];
            [sortDescriptor1 release];
        }
        
        
	}
	
	NSError *error;
	
	NSMutableArray *mutableFetchResults = [[[managedObjectContext executeFetchRequest:request error:&error] mutableCopy] autorelease];
	
	[request release];
	
	return mutableFetchResults;
}


+(NSMutableArray *) getObjectsFromContext: (NSString*) entityName : (NSString*) sortKey : (BOOL) sortAscending : (NSManagedObjectContext *) managedObjectContext
{
	return [self searchObjectsInContext:entityName :nil :sortKey :sortAscending :managedObjectContext];
}


+(NSUInteger) getCountForObjectInContext: (NSString*) entityName : (NSPredicate *) predicate : (NSString*) sortKey : (BOOL) sortAscending : (NSManagedObjectContext *) managedObjectContext
{
    return [[self searchObjectsInContext:entityName :nil :sortKey :sortAscending :managedObjectContext] count];
}


@end
