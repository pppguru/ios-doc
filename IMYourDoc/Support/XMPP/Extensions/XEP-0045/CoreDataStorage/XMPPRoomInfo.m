//
//  XMPPRoomInfo.m
//  NoMyID
//
//  Created by harry on 12/09/14.
//  Copyright (c) 2014 Emxq. All rights reserved.
//

#import "XMPPRoomInfo.h"
#import "XMPPvCardCoreDataStorageObject.h"
#import "XMPP.h"
#import "AppDelegate.h"

@implementation XMPPRoomInfo

@dynamic name;

@dynamic jidStr;

@dynamic last_update;

@dynamic room_subject;

@dynamic last_message;

@dynamic streamJidStr;

@synthesize room=_room;

@dynamic desc;

-(XMPPvCardTemp *)vcard
{
    XMPPvCardCoreDataStorageObject * vcard=[XMPPvCardCoreDataStorageObject fetchOrInsertvCardForJID:[XMPPJID jidWithString:self.jidStr] inManagedObjectContext:AppDel.managedObjectContext_vCard];
    return vcard.vCardTemp;
}

-(XMPPRoom *) room
{
    if(_room==nil)
    {
        
    
    _room=[[XMPPRoom alloc] initWithRoomStorage:[XMPPRoomCoreDataStorage sharedInstance] jid:[XMPPJID jidWithString:self.jidStr]];
        
    [_room activate:AppDel.rdXMPPWrapper.xStream];
        
    [_room addDelegate:AppDel.rdXMPPWrapper delegateQueue:dispatch_get_main_queue()];
     
    [_room joinRoomUsingNickname:AppDel.rdXMPPWrapper.xStream.myJID.user history:nil];
        
    }
    
    
    return _room;

}

-(void)setRoom:(XMPPRoom *)room
{
    _room=room;
    
    NSXMLElement *query = [NSXMLElement elementWithName:@"query"];
    
    XMPPIQ *iq = [XMPPIQ iqWithType:@"get" to:room.roomJID];
    
    [iq addAttributeWithName:@"from" stringValue:self.streamJidStr];
    
    [iq addAttributeWithName:@"id" stringValue:[NSString stringWithFormat:@"%@",room.roomJID.user]];
    
    [query  addAttributeWithName:@"xmlns" stringValue:@"http://jabber.org/protocol/disco#info"];
    
    [iq addChild:query];
    
    XMPPElementReceipt * recepient=nil;
    
    [AppDel.rdXMPPWrapper.xStream sendElement:iq];
    
    [AppDel.rdXMPPWrapper.xStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    NSLog(@"...%@",recepient);

   
    
}

-(void)update_room
{
    NSXMLElement *query = [NSXMLElement elementWithName:@"query"];
    
    XMPPIQ *iq = [XMPPIQ iqWithType:@"get" to:[XMPPJID jidWithString:self.jidStr]];

    [iq addAttributeWithName:@"from" stringValue:self.streamJidStr];
    
    [iq addAttributeWithName:@"id" stringValue:[NSString stringWithFormat:@"%@",[[XMPPJID jidWithString:self.jidStr] user]]];
    
    [query  addAttributeWithName:@"xmlns" stringValue:@"http://jabber.org/protocol/disco#info"];
    
    [iq addChild:query];
    
    
    [AppDel.rdXMPPWrapper.xStream sendElement:iq];
    
    [AppDel.rdXMPPWrapper.xStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
}



- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq;
{
    
    NSLog(@"..x...%@",iq);
    
    if([iq.from.bare isEqualToString:self.jidStr])
    {
        
        NSXMLElement * fields=[[iq  elementForName:@"query"] elementForName:@"x"];
        
        NSXMLElement * identity=[[iq elementForName:@"query"] elementForName:@"identity"];
        
        self.name=[identity attributeStringValueForName:@"name"];
        for (NSXMLElement * e in [fields children]) {
            
            NSLog(@"...%@,%i",[e name],[[e attributeStringValueForName:@"var"] isEqual:@"muc#roominfo_description"]);
            
          
            if([[e attributeStringValueForName:@"var"] isEqual:@"muc#roominfo_subject"])
            {
                self.room_subject=[[e elementForName:@"value"] stringValue];
            }
            if([[e attributeStringValueForName:@"var"] isEqual:@"muc#roominfo_description"])
            {
                self.desc=[[e elementForName:@"value"] stringValue];
            }
            
        }
        
        
        self.last_update=[NSDate date];
        
      //  self.streamJidStr=AppDel.rdXMPPWrapper.xStream.myJID.bare;
      
        [AppDel.managedObjectContext_room save:nil];
    }
    return NO;
}


@end
