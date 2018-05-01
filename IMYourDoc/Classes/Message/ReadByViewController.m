//
//  ReadByViewController.m
//  IMYourDoc
//
//  Created by Harminder on 02/04/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import "UserListCell.h"
#import "GroupChatReadbyList.h"
#import "ReadByViewController.h"


@interface ReadByViewController ()


@end


@implementation ReadByViewController


#pragma mark - View LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(readByViewControllerStatusChange:) name:@"KReadByViewControllerStatusChange" object:nil];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    if ([AppDel isConnected])
    {
        secureL.text = @"Securely Connected";
        
        secureIcon.image = [UIImage imageNamed:@"secure_icon"];
    }
    
    else
    {
        secureL.text = @"Not Connected";
        
        secureIcon.image = [UIImage imageNamed:@"unsecure_icon"];
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateConnectivity:) name:XMPPREACHABILITY object:nil];
    
    
    [readbyTable reloadData];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"KReadByViewControllerStatusChange" object:nil];
    
    
    
    
}


#pragma  mark -fetch request


- (NSFetchedResultsController * )fetch_request_controller
{
    if (_fetch_request_controller)
    {
        return _fetch_request_controller;
    }
    
    
    if (self.msg == nil)
    {
        return nil;
    }
    
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPRoomAffaliations"];
    
    [request setShouldRefreshRefetchedObjects:YES];
    
    GroupChatReadbyList * readBy;
    readBy.status=@"Read";
    
    request.predicate = [NSPredicate predicateWithFormat:@"( roomJidStr=%@ AND role!='none' ) OR ( roomJidStr=%@ AND memberJidStr in %@ AND role!='none')", self.msg.uri,self.msg.uri,[[self.msg.readby filteredOrderedSetUsingPredicate:[NSPredicate predicateWithFormat:@"status=%@ OR status=%@ OR status=%@",@"Read",@"Delivered",@"Display" ]]valueForKey:@"userJID"]];
    
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"memberJidStr" ascending:YES]];
    
    request.returnsDistinctResults=YES;
    
    _fetch_request_controller = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:[AppDel managedObjectContext_roster] sectionNameKeyPath:nil cacheName:nil];
    
    _fetch_request_controller.delegate = self;
    
    
    NSError *error = nil;
    
    
    if ([_fetch_request_controller performFetch:&error] == NO)
    {
        NSLog(@"...%@", error);
    }
    
    
    return _fetch_request_controller;
}

#pragma mark - Table

- (NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id<NSFetchedResultsSectionInfo> sections=[[self.fetch_request_controller sections] objectAtIndex:section];
    
    return [sections numberOfObjects];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserListCell *cell = (UserListCell *)[tableView dequeueReusableCellWithIdentifier:@"UserListCell"];
    
    
    if (cell == nil)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"UserListCell" owner:self options:nil] lastObject];
        
        cell.userIMGV.layer.cornerRadius = 30;
        
        cell.userIMGV.layer.masksToBounds = YES;
        
        cell.roleLB.hidden = NO;
    }
    
    XMPPRoomAffaliations * user=[self.fetch_request_controller objectAtIndexPath:indexPath];
    XMPPJID * jid=[XMPPJID jidWithString:user.memberJidStr];
    
    
    cell.userNameLB.text = [jid user];
    
    cell.userIMGV.image = nil;
    
    [cell.userIMGV downloadFromURL:[NSURL URLWithString:[NSString stringWithFormat:URLBUILER(@"https://api.imyourdoc.com/profilepic.php?user_name=%@") , jid.user]]];
   
    cell.roleLB.text = @"Pending";
    
    GroupChatReadbyList *readby = [[self.msg.readby filteredOrderedSetUsingPredicate:[NSPredicate predicateWithFormat:@"userJID=%@",[jid user]]] lastObject];
    
    if(readby==nil)
    {
        if([self.msg.identityuri isEqualToString:[jid bare]]&&self.msg.isOutbound)
        {
            cell.roleLB.text = @"sender";
        }
        
    }
    else
    {
        NSString *strStatus = readby.status;
        if ([strStatus isEqualToString:@"Display"]) {
            strStatus = @"Read";
        }
        cell.roleLB.text = strStatus;
    }
    
    
     return cell;
}


#pragma mark - Update Connectivity

- (void)updateConnectivity:(NSNotification *)note
{
    NSDictionary *dict = note.object;
    
    
    secureL.text = [dict objectForKey:@"status"];
    
    
    [secureIcon setImage:[UIImage imageNamed:[dict objectForKey:@"image"]]];
}


#pragma mark - Fetch Results




#pragma mark - manage v\context 


- (void)readByViewControllerStatusChange:(NSNotification *)notify
{
    [readbyTable reloadData];
     [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:@"KreceiveLoadOlderMessagesNotificationForGroup" object:nil userInfo:nil];
}


@end

