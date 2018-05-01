//
//  GroupMembersViewController.m
//  IMYourDoc
//
//  Created by Nipun on 20/01/15.
//
//


#import "UserListCell.h"
#import "GroupMemberCell.h"
#import "GroupMembersViewController.h"


@interface GroupMembersViewController () <XMPPRoomDelegate>


@property (nonatomic, strong) NSMutableArray *users;


@end


@implementation GroupMembersViewController


#pragma mark - View LifeCycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    
    if (self)
    {
        
    }
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    
    self.navigationController.navigationBarHidden = YES;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    [self setRequiredFont2];
    
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
    
    
    [self.xmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
    

    
    
    if ([[self.roomObj roleForJid:[[AppDel xmppStream] myJID]] isEqualToString:@"owner"] == NO)
    {
      
    
        addSrchBarBtn.hidden=YES;
    }
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.xmppRoom fetchModeratorsList];
    
    });
    
    
    [self.userTableView reloadData];
    

    {
        NSDictionary *searchDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                    
                                    @"getRoomMembers", @"method",
                                    
                                    [[NSUserDefaults standardUserDefaults]objectForKey:@"loginToken"], @"login_token",
                                    
                                    _roomObj.room_jidStr, @"roomJID",
                                    
                                    nil];
        [[WebHelper sharedHelper] setWebHelperDelegate:self];
        
        [[WebHelper sharedHelper] sendRequest:searchDict tag:S_GetRoomMembers delegate:self];
    }
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    
    [self.xmppRoom removeDelegate:self delegateQueue:dispatch_get_main_queue()];
}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - Fetched Results

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


#pragma mark - Table

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView != self.userTableView)
    {
        return 1;
    }
    
    
    return self.fetchController.sections.count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView != self.userTableView)
    {
        return self.users.count;
    }
    
    
    id<NSFetchedResultsSectionInfo> sectionInfo = [self.fetchController.sections objectAtIndex:section];
    
    
    return [sectionInfo numberOfObjects];
}


- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView != self.userTableView)
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
           
            
            
            tbCell.userNameLB.text = [(NSManagedObject *)user valueForKey:@"nickname"];
            
            
            NSData *imgData = [[AppDel xmppvCardAvatarModule] photoDataForJID:[XMPPJID jidWithString:[(NSManagedObject *)user valueForKey:@"jidStr"]]];
            
            
            if (imgData)
            {
                tbCell.userIMGV.image = [UIImage imageWithData:imgData];
            }
        }
        
        UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeContactAdd];
        
        UIImage *img = [addBtn imageForState:UIControlStateNormal];
        
        tbCell.accessoryView = [[UIImageView alloc] initWithImage:img];
        
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
    

    
    
    return cell;
}


- (CGFloat )tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    if (tableView != self.userTableView)
    {
        NSMutableArray *users = [[self.roomObj.members filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"role='member'"]] mutableCopy];
        
        [users addObject:[self.users objectAtIndex:indexPath.row]];
        
        
        XMPPRoomAffaliations *newUser = [NSEntityDescription insertNewObjectForEntityForName:@"XMPPRoomAffaliations" inManagedObjectContext:[AppDel managedObjectContext_roster]];
        
        newUser.roomJidStr = self.roomObj.room_jidStr;
        
        newUser.memberJidStr = [[[self.users objectAtIndex:indexPath.row] jid] bare];
        
        newUser.role = @"member";
        
        
        [self.roomObj addMembersObject:newUser];
        
        
        [[AppDel managedObjectContext_roster] save:nil];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
           [self.xmppRoom addMembers:[[self.roomObj.members filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"role='member'"]] allObjects]];
       
        });
        
        
      
        
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
    if (tableView != self.userTableView)
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
    if (tableView != self.userTableView)
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
                
                [query addChild:item];
            }
            
            
            [iq addChild:query];
            
            
            [[AppDel xmppStream] sendElement:iq];
            
            
            user.role = @"none";
            
            
            [[AppDel managedObjectContext_roster] save:nil];
        }
    }
}


#pragma mark - Fetch Results

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.userTableView reloadData];
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


- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    self.searchbar.hidden = YES;
    
    [self.view layoutIfNeeded];
}


#pragma mark - IBAction

- (IBAction)addSearchBar
{
    addSrchBarBtn.selected = !addSrchBarBtn.selected;
    
    
    if (addSrchBarBtn.selected)
    {
        [self.view bringSubviewToFront:self.searchDisplayController.searchBar];
        
        
        self.searchDisplayController.searchBar.hidden = NO;
        
        [self.searchDisplayController.searchBar becomeFirstResponder];
        
        
        addIcon.highlighted = YES;
        
        
        TBVertSpaceConstraint.constant = 44;
        
        
        [self.view layoutIfNeeded];
        
        
        [self.searchDisplayController setActive:YES animated:YES];
    }
    
    else
    {
        self.searchbar.hidden = YES;
        
        
        addIcon.highlighted = NO;
        
        [self.searchDisplayController.searchBar resignFirstResponder];
        
        [self.searchDisplayController setActive:NO animated:YES];
        
        
        [self.view layoutIfNeeded];
    }
}


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


#pragma mark - update Connectivity

- (void) updateConnectivity:(NSNotification *)note
{
    NSDictionary *dict = note.object;
    
    
    secureL.text = [dict objectForKey:@"status"];
    
    
    [secureIcon setImage:[UIImage imageNamed:[dict objectForKey:@"image"]]];
}



#pragma mark - Set Required Font


- (void)setRequiredFont2
{
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [titleL setFont:[UIFont fontWithName:@"CentraleSansRndMedium" size:25.00]];
     }
    else
    {
        [titleL setFont:[UIFont fontWithName:@"CentraleSansRndMedium" size:20.00]];        
    }
}


#pragma mark -

-(void)didFailedWithError:(NSError *)error{
    
}

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
           
                     
                     if (owner == nil)
                     {
                         owner = [NSEntityDescription insertNewObjectForEntityForName:@"XMPPRoomAffaliations" inManagedObjectContext:[AppDel managedObjectContext_roster ] ];
                         
                         owner.memberJidStr = [obj objectForKey:@"jid"];;
                     }
                     
                     
                     owner.roomJidStr = _xmppRoom.roomJID.bare;
                     
                     owner.role = [obj objectForKey:@"membership"];
                     
                     
                     [_roomObj addMembersObject:owner];
                     [[AppDel managedObjectContext_roster] save:nil];
                     
                 }
             }];
            
            

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



@end

