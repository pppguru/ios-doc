//
//  GroupProfileViewController.m
//  IMYourDoc
//
//  Created by OSX on 27/08/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import "GroupProfileViewController.h"
#import "GroupMembersViewController.h"
#import "UserListCell.h"
#import "GroupMemberCell.h"
#import "ChatViewController.h"


@interface GroupProfileViewController ()<UITextFieldDelegate>
{
    
}
@property (nonatomic, strong) NSMutableArray *users;
@end

@implementation GroupProfileViewController
#pragma mark - SDLC

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    
    // Do any additional setup after loading the view from its nib.
    
//      [tableMIA registerNib:[UINib nibWithNibName:@"MIAHeaderCell" bundle:nil] forHeaderFooterViewReuseIdentifier:@"MIACellHeaderID”];
    //MembersHeaderCell.xib
    
//    [_table_members registerNib:[UINib nibWithNibName:@"MembersHeaderCell" bundle:nil] forHeaderFooterViewReuseIdentifier:@"MembersHeaderCellId"];
//
    

    
   
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    _txt_GroupName.text=_roomObj.subject;
    
    
    if ([_roomObj isPatientRoom] == 0)
         _imageView_GroupImage.image = [UIImage imageNamed:@"group_green"];
    else
    {
          _imageView_GroupImage.image  = [UIImage imageNamed:@"group_red"];
    }
    

    if (_roomObj.members.count<=0)
    {
        NSDictionary *searchDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                    
                                    @"getRoomMembers", @"method",
                                    
                                    [[NSUserDefaults standardUserDefaults]objectForKey:@"loginToken"], @"login_token",
                                    
                                    _roomObj.room_jidStr, @"roomJID",
                                    
                                    nil];
        [[WebHelper sharedHelper] setWebHelperDelegate:self];
        
        [[WebHelper sharedHelper] sendRequest:searchDict tag:S_GetRoomMembers delegate:self];
    }

    
        [self changeGrupName];
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - HelperMethod
-(void)changeGrupName{
    
    if (_roomObj  &&  [[_roomObj roleForJid:[XMPPJID jidWithString:[AppDel myJID]]] isEqualToString:@"owner"])
    {
        //  [self addSubview:adminEditModeSubView toSuperView:subViewContainer];
        
        _txt_GroupName.userInteractionEnabled=YES;
        _btn_EditGroupName.userInteractionEnabled=YES;
        _btn_EditGroupName.hidden=NO;
        _btn_addMembers.hidden=NO;
        [_btn_LeaveOrDelete setImage:[UIImage imageNamed:@"Delete_icon"] forState:UIControlStateNormal];
        [_btn_LeaveOrDelete setTitle:@"Delete Group" forState:UIControlStateNormal];
        
        
        
        
    }
    
    else
    {
        
        _txt_GroupName.userInteractionEnabled=NO;
        _btn_EditGroupName.userInteractionEnabled=NO;
        _btn_EditGroupName.hidden=YES;
         _btn_addMembers.hidden=YES;
        [_btn_LeaveOrDelete setImage:[UIImage imageNamed:@"Leave_grp_icon"] forState:UIControlStateNormal];
        [_btn_LeaveOrDelete setTitle:@"Leave Group" forState:UIControlStateNormal];
        
    }
}
#pragma  mark - Actions

- (IBAction)action_addMembers:(id)sender
{
    GroupMembersViewController *groupMember = [[GroupMembersViewController alloc] initWithNibName:@"GroupMembersViewController" bundle:nil];
    
    groupMember.roomObj = _roomObj;
    
    groupMember.xmppRoom =_xmppRoom;
    
    [self.navigationController pushViewController:groupMember animated:YES];
    
}
- (IBAction)action_LeaveORDeleteGroup:(id)sender
{
    
    if (_roomObj  &&  [[_roomObj roleForJid:[XMPPJID jidWithString:[AppDel myJID]]] isEqualToString:@"owner"])
    {
        // Delete Group 
        
        
        {
            [[RDCallbackAlertView alloc] initWithTitle:nil message:@"Are you sure you want to delete this group?" cancelButtonTitle:@"YES" andCompletionHandler:^(int button) {
                
                if (button == 0)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        XMPPMessage *message = [XMPPMessage message];
                        
                        [message addAttributeWithName:@"id" stringValue:@"IMYOURDOC_DELETE"];
                        
                        [message addAttributeWithName:@"from" stringValue:[[[AppDel xmppStream] myJID] bare]];
                        
                        [message addAttributeWithName:@"to" stringValue:[self.xmppRoom.roomJID bare]];
                        
                        [message addAttributeWithName:@"type" stringValue:@"groupchat"];
                        
                        //[message addChild:[NSXMLElement elementWithName:@"body" stringValue:@"DELETE ROOM"]];
                        
                        
                        
                        
                        
                        
                        //*************qwerty********************
                        
                        @autoreleasepool {
                            VCard    *vcared=[AppDel
                                              fetchVCard:[XMPPJID jidWithString:self.xmppRoom.roomJID.bare]];
                            
                            (void)vcared;
                        }
                        
                     
                        
                        
                        //                    if([vcard.messagingVersion boolValue]==YES)
                        //
                        {
                            NSDictionary * dictionary=[NSDictionary  dictionaryWithObjectsAndKeys:@"DELETE ROOM",@"content",[NSString stringWithFormat:@"%@",[NSDate date]],@"timestamp",[[[AppDel xmppStream] myJID] bare],@"from",self.xmppRoom.roomJID.bare,@"to",@"IMYOURDOC_DELETE",@"messageID", nil];
                            
                            NSXMLElement *body = [NSXMLElement elementWithName:@"body" stringValue:[dictionary JSONString]];
                            
                            [message addChild:body];
                            
                            [message addProperty:@"message_version" value:@"2.0" type:@"string"];
                        }
                        
                        //                    else{
                        //
                        //
                        //                        NSXMLElement *body = [NSXMLElement elementWithName:@"body" stringValue:@"DELETE ROOM"];
                        //
                        //                        [message addChild:body];
                        //
                        //
                        //                    }
                        //
                        //*********************************
                        
                        
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            [[AppDel xmppStream] sendElement:message];
                            
                            
                            [self.xmppRoom destroyRoom];
                            
                            
                            [self.navigationController popViewControllerAnimated:YES];
                        });
                        
                        
                        self.roomObj.room_status = @"deleted";
                        
                        
                        [[AppDel managedObjectContext_roster] save:nil];
                    });
                }
                
            } otherButtonTitles:@"NO", nil];
        }
     
        
    }
    
    else
    {  // Leave Group
        {
        [[RDCallbackAlertView alloc] initWithTitle:nil message:@"Are you sure you want to leave this group?" cancelButtonTitle:@"YES" andCompletionHandler:^(int button) {
            
            if (button == 0)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
                    
                    [message addAttributeWithName:@"type" stringValue:@"groupchat"];
                    
                    [message addAttributeWithName:@"id" stringValue:@"REMOVE_REQUEST"];
                    
                    [message addAttributeWithName:@"from" stringValue:[[[AppDel xmppStream] myJID] bare]];
                    
                    [message addAttributeWithName:@"to" stringValue:[[self.xmppRoom roomJID] bare]];
                    
                    //[message addChild:[NSXMLElement elementWithName:@"body" stringValue:@"left the room"]];
                    
                    //****************qwerty*********************
                    
                    @autoreleasepool {
                        VCard * vcard=[AppDel
                                       fetchVCard:[XMPPJID jidWithString:[self.xmppRoom.roomJID bare]]];
                        (void)vcard;
                    }
                    
                  
                    
                    //  if([vcard.messagingVersion boolValue]==YES)
                    
                    {
                        NSDictionary * dictionary=[NSDictionary  dictionaryWithObjectsAndKeys:@"left the room",@"content",[NSString stringWithFormat:@"%@",[NSDate date]],@"timestamp",[[[AppDel xmppStream] myJID] bare],@"from",[self.xmppRoom.roomJID bare],@"to",@"REMOVE_REQUEST",@"messageID", nil];
                        
                        
                        
                        NSXMLElement *body = [NSXMLElement elementWithName:@"body" stringValue:[dictionary JSONString]];
                        
                        [message addChild:body];
                        
                        [message addProperty:@"message_version" value:@"2.0" type:@"string"];
                    }
                    
                    //                    else{
                    //
                    //
                    //                        NSXMLElement *body = [NSXMLElement elementWithName:@"body" stringValue:@"left the room"];
                    //
                    //                        [message addChild:body];
                    //
                    //
                    //                    }
                    
                    
                    //****************************************
                    
                    [[AppDel xmppStream] sendElement:message];
                    
                    
                    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ChatMessage"];
                    
                    request.predicate = [NSPredicate predicateWithFormat:@"uri=%@",[self.xmppRoom.roomJID bare]];
                    
                    
                    NSArray *messagesForRoom = [[AppDel managedObjectContext_roster] executeFetchRequest:request error:nil];
                    
                    
                    for (ChatMessage *message in messagesForRoom)
                    {
                        message.mark_deleted = [NSNumber numberWithBool:mark_deleted_YES];
                    }
                    
                    
                    [self.navigationController popToViewController:[AppDel homeView] animated:YES];
                    
                    
                    self.roomObj.room_status = @"deleted";
                    
                    
                    [self.xmppRoom leaveRoom];
                    
                    
                    [[AppDel managedObjectContext_roster] save:nil];
                });
            }
            
        } otherButtonTitles:@"NO", nil];
        }
        
    }
}

- (IBAction)action_EditGroupName:(id)sender
{
    
    [self titleChanged:nil];
    
}


- (void)composeAction:(id)sender
{
    {
        [_txt_GroupName resignFirstResponder];
        
        XMPPRoomObject *room  = _roomObj;
        
        ChatViewController *messageVC = [[ChatViewController alloc] initWithNibName:@"ChatViewController" bundle:nil];
        
      messageVC.forChat = YES;
   
            messageVC.isGroupChat = YES;
        
            messageVC.roomObj = room;
        
        
        XMPPRoomObject *alreadyJoined = [[[AppDel roomsArr] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"room_jidStr=%@", room.room_jidStr]] lastObject];
        


        if (alreadyJoined)
        {
              messageVC.room = alreadyJoined.room;
            //Obj_groupProfileViewController.xmppRoom = alreadyJoined.room;
            
        }
        
        else
        {
            /*if ([room.room_status isEqualToString:@"deleted"])
             {
             return;
             }*/
            
            
                 messageVC.room = room.room;
           
            [room.room activate:[AppDel xmppStream]];
            
            [room.room addDelegate:AppDel delegateQueue:[AppDel xmppDelegateQueue] ];
            
            [room.room joinRoomUsingNickname:[[XMPPJID jidWithString:[AppDel myJID]] user] history:nil];
        }
        
        
        
        
        
        
        
        
        
        
        
        
        [self.navigationController pushViewController:messageVC animated:YES];
    }
    
}


#pragma mark - TextField

- (IBAction)titleChanged:(id)sender
{
    
    [_txt_GroupName becomeFirstResponder];
    
    if ([_txt_GroupName.text exactLength] > 3)
    {
        
        
        [self.xmppRoom fetchConfigurationForm];
        
        
        XMPPMessage *message = [XMPPMessage message];
        
        
        NSString *messageID =  [[AppDel xmppStream] generateUUID];
        
        
        [message addAttributeWithName:@"id" stringValue:messageID];
        
        [message addAttributeWithName:@"from" stringValue:[[[AppDel xmppStream] myJID] bare]];
        
        [message addAttributeWithName:@"to" stringValue:self.roomObj.room_jidStr];
        
        [message addAttributeWithName:@"type" stringValue:@"groupchat"];
        
        
        NSXMLElement *subject = [NSXMLElement elementWithName:@"subject" stringValue:_txt_GroupName.text];
        
        
        [message addChild:subject];
        
        
        [[AppDel xmppStream] sendElement:message];
    }
    
    
   
    
    

    

    
    
    // code to update it on server.
}



#pragma mark - Table

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView != _table_members)
    {
        return 1;
    }
    
    
    return self.fetchController.sections.count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView != _table_members)
    {
        return self.users.count;
    }
    
    
    id<NSFetchedResultsSectionInfo> sectionInfo = [self.fetchController.sections objectAtIndex:section];
    
    
    return [sectionInfo numberOfObjects];
}


- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView != _table_members)
    {
        static NSString *listTBID = @"LIST_TB_CELLID";
        
        
        UserListCell *tbCell = [tableView dequeueReusableCellWithIdentifier:listTBID];
        
        if (tbCell == nil)
        {
            tbCell = [[[NSBundle mainBundle] loadNibNamed:@"UserListCell" owner:self options:nil] lastObject];
            
            tbCell.userIMGV.layer.cornerRadius = 30;
            
            tbCell.userIMGV.layer.masksToBounds = YES;
        }
        
        
        NSManagedObject *user = [self.users objectAtIndex:indexPath.row];
        
        
        if ([user isKindOfClass:[XMPPUserCoreDataStorageObject class]])
        {
            //tbCell.userIMGV.image = [UIImage imageWithData:imgData];
            
            
            tbCell.userNameLB.text = [(NSManagedObject *)user valueForKey:@"nickname"];
            
            
            NSData *imgData = [[AppDel xmppvCardAvatarModule] photoDataForJID:[XMPPJID jidWithString:[(NSManagedObject *)user valueForKey:@"jidStr"]]];
            
            
            if (imgData)
            {
                tbCell.userIMGV.image = [UIImage imageWithData:imgData];
            }
        }
        
        
        tbCell.accessoryView = [UIButton buttonWithType:UIButtonTypeContactAdd];
        
        
        return tbCell;
    }
    
    
    static NSString *listTBID = @"MemberCell";
    
    
    GroupMemberCell *cell = [tableView dequeueReusableCellWithIdentifier:listTBID];
    
    
    if (cell == nil)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"GroupMemberCell" owner:self options:nil] lastObject];
        
        cell.userImg.layer.cornerRadius = 22.5f;
        
        cell.userImg.layer.masksToBounds = YES;
    }
    
    
    XMPPRoomAffaliations *user = [self.fetchController objectAtIndexPath:indexPath];
    
    
    cell.userNameL.text = [[XMPPJID jidWithString:user.memberJidStr] user];
    
    cell.user = user;
    
    [cell.crossBtn removeTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.crossBtn.hidden = YES;
    
    cell.adminL.hidden = YES;
    
    
    if ([user.role isEqualToString:@"owner"])
    {
        cell.crossBtn.hidden = YES;
        
        cell.adminL.hidden = NO;
    }
    
    else if ([[self.roomObj roleForJid:[XMPPJID jidWithString:[AppDel myJID]]]isEqualToString:@"owner"])
    {
        cell.crossBtn.hidden = NO;
        
        [cell.crossBtn addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    
    NSData *imgData = [[AppDel xmppvCardAvatarModule] photoDataForJID:user.jid];
    
    
    if (imgData)
    {
        cell.userImg.image = [UIImage imageWithData:imgData];
    }
    
    else
    {
        cell.userImg.image = [UIImage imageNamed:@"Profile"];
    }
    
    
    /*cell.imageView.frame = CGRectMake(0, 0, 80, 80);
     
     cell.imageView.layer.cornerRadius = 12;
     
     cell.imageView.layer.masksToBounds = YES;*/
    
    
    return cell;
}


- (CGFloat )tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    if (tableView != _table_members)
    {
        NSMutableArray *users = [[self.roomObj.members filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"role='member'"]] mutableCopy];
        
        [users addObject:[self.users objectAtIndex:indexPath.row]];
        
        
        XMPPRoomAffaliations *newUser = [NSEntityDescription insertNewObjectForEntityForName:@"XMPPRoomAffaliations" inManagedObjectContext:[AppDel managedObjectContext_roster]];
        
        newUser.roomJidStr = self.roomObj.room_jidStr;
        
        newUser.memberJidStr = [ (XMPPJID*)[[self.users objectAtIndex:indexPath.row] jid] bare];
        
        newUser.role = @"member";
        
        
        [self.roomObj addMembersObject:newUser];
        
        
        [[AppDel managedObjectContext_roster] save:nil];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.xmppRoom addMembers:[[self.roomObj.members filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"role='member'"]] allObjects]];
            
        });
        
        
        //return;
        
        
        XMPPIQ *iq = [XMPPIQ iqWithType:@"set"];
        
        [iq addAttributeWithName:@"from" stringValue:[[[AppDel xmppStream] myJID] bare]];
        
        [iq addAttributeWithName:@"to" stringValue:[self.xmppRoom.roomJID bare]];
        
        
        NSString *iqID = [NSString stringWithFormat:@"%@", [self.xmppRoom.roomJID bare]];
        
        
        [iq addAttributeWithName:@"id" stringValue:iqID];
        
        
        NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"http://jabber.org/protocol/muc#admin"];
        
        
        for (XMPPRoomAffaliations *members in users)
        {
            NSXMLElement *item = [NSXMLElement elementWithName:@"item"];
            
            
            if ([[members.jid bare] length] == 0)
            {
                continue;
            }
            
            
            [item addAttributeWithName:@"jid" stringValue:[members.jid bare]];
            
            [item addAttributeWithName:@"affiliation" stringValue:@"member"];
            
            //[item addAttributeWithName:@"nick" stringValue:user.nickname];
            
            
            [query addChild:item];
        }
        
        
        [iq addChild:query];
        
        
        [[AppDel xmppStream] sendElement:iq];
        
        [[AppDel managedObjectContext_roster] save:nil];
        
        
        [self.searchDisplayController setActive:NO animated:YES];
    }
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView != _table_members)
    {
        
    }
    
    else
    {
        if ([[self.roomObj roleForJid:[[AppDel xmppStream] myJID]] isEqualToString:@"owner"] == NO)
        {
            return NO;
        }
        
        
        XMPPRoomAffaliations *user = [self.fetchController objectAtIndexPath:indexPath];
        
        
        if ([user.role isEqualToString:@"owner"])
        {
            return NO;
        }
        
        else
        {
            return YES;
        }
    }
    
    
    return NO;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView !=_table_members)
    {
        
    }
    
    else
    {
        if (editingStyle == UITableViewCellEditingStyleDelete)
        {
            XMPPRoomAffaliations *user = [self.fetchController objectAtIndexPath:indexPath];
            
            
            NSArray *users = [[self.roomObj.members filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"role='member'", user.memberJidStr]] allObjects];
            
            
            XMPPIQ *iq = [XMPPIQ iqWithType:@"set"];
            
            [iq addAttributeWithName:@"from" stringValue:[[[AppDel xmppStream] myJID] bare]];
            
            [iq addAttributeWithName:@"to" stringValue:[self.xmppRoom.roomJID bare]];
            
            
            NSString *iqID = [NSString stringWithFormat:@"%@", [self.xmppRoom.roomJID bare]];
            
            
            [iq addAttributeWithName:@"id" stringValue:iqID];
            
            
            NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"http://jabber.org/protocol/muc#admin"];
            
            
            for (XMPPRoomAffaliations *members in users)
            {
                NSXMLElement *item = [NSXMLElement elementWithName:@"item"];
                
                
                if ([[members.jid bare] length] == 0)
                {
                    continue;
                }
                
                
                [item addAttributeWithName:@"jid" stringValue:[members.jid bare]];
                
                
                if ([members isEqual:user])
                {
                    [item addAttributeWithName:@"affiliation" stringValue:@"none"];
                }
                
                else
                {
                    [item addAttributeWithName:@"affiliation" stringValue:@"member"];
                }
                
                
                //[item addAttributeWithName:@"nick" stringValue:user.nickname];
                
                
                [query addChild:item];
            }
            
            
            [iq addChild:query];
            
            
            [[AppDel xmppStream] sendElement:iq];
            
            
            user.role = @"none";
            
            
            [[AppDel managedObjectContext_roster] save:nil];
        }
    }
}


#pragma mark - Delete user
- (void)deleteCell: (XMPPRoomAffaliations *)user
{
    if (user == nil)
    {
        return;
    }
    
    
    NSArray *users = [[self.roomObj.members filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"role='member'", user.memberJidStr]] allObjects];
    
    
    XMPPIQ *iq = [XMPPIQ iqWithType:@"set"];
    
    [iq addAttributeWithName:@"from" stringValue:[[[AppDel xmppStream] myJID] bare]];
    
    [iq addAttributeWithName:@"to" stringValue:[self.xmppRoom.roomJID bare]];
    
    
    NSString *iqID = [NSString stringWithFormat:@"%@",[self.xmppRoom.roomJID bare]];
    
    
    [iq addAttributeWithName:@"id" stringValue:iqID];
    
    
    NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"http://jabber.org/protocol/muc#admin"];
    
    
    for (XMPPRoomAffaliations * members in users)
    {
        NSXMLElement *item = [NSXMLElement elementWithName:@"item"];
        
        
        if ([[members.jid bare] length] == 0)
        {
            continue;
        }
        
        
        [item addAttributeWithName:@"jid" stringValue:[members.jid bare]];
        
        
        if ([members isEqual:user])
        {
            [item addAttributeWithName:@"affiliation" stringValue:@"none"];
        }
        
        else
        {
            [item addAttributeWithName:@"affiliation" stringValue:@"member"];
        }
        
        
        //[item addAttributeWithName:@"nick" stringValue:user.nickname];
        
        
        [query addChild:item];
    }
    
    
    [iq addChild:query];
    
    
    [[AppDel xmppStream] sendElement:iq];
    
    
    user.role = @"none";
    
    
    [[AppDel managedObjectContext_roster] save:nil];
}


- (void)deleteAction:(UIButton *)sender
{
    UIView *tmp = sender.superview;
    
    
    while (![tmp isKindOfClass:[GroupMemberCell class]])
    {
        tmp = tmp.superview;
        
        
        if (tmp == nil)
        {
            break;
        }
    }
    
    
    [self deleteCell:[(GroupMemberCell *)tmp user]];;
}



#pragma mark - Fetch Results



- (NSFetchedResultsController * )fetchController
{
    if (_fetchController)
    {
        return _fetchController;
    }
    
    
    if (self.xmppRoom == nil)
    {
        return nil;
    }
    
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPRoomAffaliations"];
    
    request.predicate = [NSPredicate predicateWithFormat:@"roomJidStr=%@ AND role!='none' ", self.xmppRoom.roomJID.bare];
    
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"memberJidStr" ascending:YES]];
    
    _fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:[AppDel managedObjectContext_roster] sectionNameKeyPath:nil cacheName:nil];
    
    _fetchController.delegate = self;
    
    
    NSError *error = nil;
    
    
    if ([_fetchController performFetch:&error] == NO)
    {
        NSLog(@"...%@", error);
    }
    
    
    return _fetchController;
}
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [_table_members reloadData];
    
    
 
    
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(nickname beginswith[cd] %@ or jidStr beginswith[cd]  %@  ) AND NOT ( jidStr IN %@ )", searchString, searchString, [[self.roomObj.members filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"role='member' OR role='owner'"]] valueForKey:@"memberJidStr"]];
    
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPUserCoreDataStorageObject"];
    
    request.predicate = predicate;
    
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"nickname" ascending:YES]];
    
    
    self.users = [[[AppDel managedObjectContext_roster] executeFetchRequest:request error:nil] mutableCopy];
    
    
    return TRUE;
}











#pragma mark -  Webservice



- (void)didReceivedresponse:(NSDictionary *)response
{
    [AppDel hideSpinner];
    
    
    if ([WebHelper sharedHelper].tag == S_GetRoomMembers)
    {
        if ([[response objectForKey:@"err-code"] intValue] == 1)
        {
            
            

            
            
            [(NSMutableArray*)[response objectForKey:@"members"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
            
            {
                {
                    XMPPRoomAffaliations *owner = [[_roomObj.members filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"memberJidStr=%@", [obj objectForKey:@"jid"] ]] anyObject];
//                    memberJidStr;
//                    roomJidStr;
//                    role;
//                    jid;
//                    roomJid;

                    
                    if (owner == nil)
                    {
                        owner = [NSEntityDescription insertNewObjectForEntityForName:@"XMPPRoomAffaliations" inManagedObjectContext:[AppDel managedObjectContext_roster ] ];
                        
                        owner.memberJidStr = [obj objectForKey:@"jid"]; //[[XMPPJID jidWithString:[[field elementForName:@"value"] stringValue]] bare];
                    }
                    
                    
                    owner.roomJidStr = _xmppRoom.roomJID.bare;
                    
                    owner.role = [obj objectForKey:@"membership"];
                    
                    
                    [_roomObj addMembersObject:owner];
                }
            }];
            
            
               [self changeGrupName];
            
            
//            [[RDCallbackAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] cancelButtonTitle:nil andCompletionHandler:^(int btnIDX) {
//                
//                [self.navigationController popViewControllerAnimated:YES];
//                
//            } otherButtonTitles:@"OK", nil];
            
//            members =     (
//                           {
//                               jid = "harmsing3@imyourdoc.com";
//                               membership = owner;
//                           },
//                           {
//                               jid = "kiranprovider@imyourdoc.com";
//                               membership = member;
//                           },
//                           {
//                               jid = "kiranstaff@imyourdoc.com
            
//            
        }
        else if ([[response objectForKey:@"err-code"] intValue] == 600)
        {
            [AppDel signOutFromAppSilent];
            
            [[RDCallbackAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] cancelButtonTitle:nil andCompletionHandler:^(int btnIndex)
             
             {
                 
                 
             } otherButtonTitles:@"OK", nil];
            
            return;
            
        }
        else if ([[response objectForKey:@"err-code"] intValue] == 300)
        {
            [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"]  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
            
            return;
            
        }
    }
}


- (void)didFailedWithError: (NSError *) error
{
    [AppDel hideSpinner];
    
    
//    if (boolService_feedbackRetry)
//    {
//        [self performSelector:@selector(submitFeedbackMethod) withObject:nil afterDelay:.9];
//    }
//    else
//    {
//        [[RDCallbackAlertView alloc] initWithTitle:nil message:@"Cannot detect Internet connection" cancelButtonTitle:nil andCompletionHandler:^(int btnIDX)
//         {
//             
//             if (btnIDX==0)
//             {
//                 boolService_feedbackRetry=YES;
//                 
//                 [self submitFeedback];
//             }
//             if (btnIDX==1)
//             {
//                 boolService_feedbackRetry=NO;
//                 
//                 [self.navigationController popViewControllerAnimated:YES];
//             }
//             
//         } otherButtonTitles:@"Retry" ,@"Try Later", nil];
//    }
}



@end
