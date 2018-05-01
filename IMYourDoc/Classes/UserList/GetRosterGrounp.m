//
//  GetRosterGrounp.m
//  IMYourDoc
//
//  Created by macbook on 28/08/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//


#import "AppDelegate.h"
#import "ASIHTTPRequest.h"
#import "CoreDataHelper.h"
#import "GetRosterGrounp.h"
#import "IMYourDocAPIGeneratorClass.h"



@implementation GetRosterGrounp


@synthesize screenIndex, responseData, gpConnection;


#pragma mark - Void

- (void) cancelDownload
{
    [self.gpConnection cancel];
	
	self.gpConnection = nil;
    
	self.responseData = nil;
}


- (void) getRosterByGroupNameAPI
{
    self.responseData = nil;
    
	self.responseData = [[NSMutableData alloc] init];
    
	
    NSURL *url = [NSURL URLWithString:[IMYourDocAPIGeneratorClass getRosterByGroup]];
    
	
    NSString *postContentString = [IMYourDocAPIGeneratorClass selfStringGeneratorGETROSTERBYGROUPNAME:[AppData appData].XMPPmyJID];
    
    
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
	[request setHTTPMethod:@"POST"];
    
    [request setHTTPBody:[postContentString dataUsingEncoding:NSUTF8StringEncoding]];
    
	
	NSURLConnection *con = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
	
    self.gpConnection = con;
    
    
	[gpConnection start];
}


#pragma mark - GetVCard

- (void)getVcard:(XMPPJID *)jid
{
    NSXMLElement *queryElement = [NSXMLElement elementWithName: @"query" xmlns: @"jabber:iq:roster"];
    
    
	NSXMLElement *iq = [NSXMLElement elementWithName: @"iq"];
    
	
    NSXMLElement *vcard = [NSXMLElement elementWithName:@"vCard"];
    
    [vcard addAttributeWithName:@"xmlns" stringValue:@"vcard-temp"];
	
	
    [iq addChild:vcard];
    
	[iq addAttributeWithName: @"type" stringValue: @"get"];
    
    [iq addAttributeWithName:@"id" stringValue:[NSString stringWithFormat:@"vc%d",(int)[[NSDate date]timeIntervalSince1970]]];
    
    [iq addAttributeWithName:@"from" stringValue:jid.bare];
    
    [iq addAttributeWithName:@"to" stringValue:jid.bare];
	
    [iq addChild: queryElement];
    
	
    [[AppDel xmppStream] sendElement:iq];
}


#pragma mark - Request

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.responseData appendData:data];
}

    
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.gpConnection = nil;
	
    
    [self.delegate imYourDocRosterGrouping:FALSE withscreen:screenIndex];
}

    
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *responseString = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
   
    
    NSString *trimmedString = [responseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
    
    NSMutableArray *rosterName = [NSMutableArray array];
    
    NSMutableArray *userDataArray = [NSMutableArray array];
	
    
	DDXMLElement *rosterDetails = [[DDXMLElement alloc] initWithXMLString:trimmedString error:nil];
	
    
    NSArray *elements = [rosterDetails elementsForName:@"Roster"];
	
    
    int p = 0;
	
    
    for (DDXMLElement *element in elements)
	{
        if ([element elementForName:@"GroupName"] == nil)
        {
            continue;
        }
        
		
        [rosterName addObject:[[element elementForName:@"RosterJID"] stringValue]];
        
        
        NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:[[element elementForName:@"GroupName"] stringValue], @"gpName", [[element elementForName:@"RosterJID"] stringValue], @"rosterName", [element elementForName:@"full_name"] == nil ? [[element elementForName:@"RosterJID"] stringValue] : [[element elementForName:@"full_name"] stringValue], @"rosterNickName", nil];
        
        
        [userDataArray addObject:infoDict];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self getVcard:[XMPPJID jidWithString:[[element elementForName:@"RosterJID"] stringValue]]];
            
        });
        
        
		p++;
    }
	
    
	NSManagedObjectContext *context = [AppDel managedObjectContext_roster];
    
    
	NSArray *tempArr = [CoreDataHelper searchObjectsInContext:@"XMPPUserCoreDataStorageObject":nil :nil :YES :context];
    
    
    for (NSDictionary *dataDict in userDataArray)
    {
        NSPredicate *searchPredi = [NSPredicate predicateWithFormat:@"jidStr = %@", [dataDict objectForKey:@"rosterName"]];
        
        
        XMPPUserCoreDataStorageObject *user = [[tempArr filteredArrayUsingPredicate:searchPredi] lastObject];
        
        
        if (user)
        {
            if ([[[dataDict objectForKey:@"gpName"] uppercaseString] isEqualToString:@"STAFF"])
            {
                user.unreadMessages = [NSNumber numberWithInt:2];
            }

			else if ([[[dataDict objectForKey:@"gpName"] uppercaseString] isEqualToString:@"PHYSICIAN"])
            {
                user.unreadMessages = [NSNumber numberWithInt:0];
            }

			else if ([[[dataDict objectForKey:@"gpName"] uppercaseString] isEqualToString:@"PATIENT"])
            {
                user.unreadMessages = [NSNumber numberWithInt:1];
            }
            
            
            user.nickname = [dataDict objectForKey:@"rosterNickName"];
        }
    }
    
    
    [context save:nil];
	
    
    self.responseData = nil;
    
    
    self.gpConnection = nil;
    
    
	[self.delegate imYourDocRosterGrouping:TRUE withscreen:screenIndex];
}


@end

