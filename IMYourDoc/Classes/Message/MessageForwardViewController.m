//
//  MessageForwardViewController.m
//  IMYourDoc
//
//  Created by Sarvjeet on 16/03/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import "ChatViewController.h"
#import "MessageForwardViewController.h"


@interface MessageForwardViewController ()


@end


@implementation MessageForwardViewController


#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    refreshControl = [[UIRefreshControl alloc] init];
    
    refreshControl.backgroundColor = [UIColor clearColor];
    
    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    
    
    [searchTable addSubview:refreshControl];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    [self searchViewAttribute];
    
    
    if ([AppDel isConnected])
    {
        secureLabel.text = @"Securely Connected";
        
        secureIcon.image = [UIImage imageNamed:@"secure_icon"];
    }
    
    else
    {
        secureLabel.text = @"Not Connected";
        
        secureIcon.image = [UIImage imageNamed:@"unsecure_icon"];
    }
    
    
    [self setupFetchedController];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateConnectivity:) name:XMPPREACHABILITY object:nil];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    
    [refreshControl performSelector:@selector(endRefreshing) withObject:nil afterDelay:0.0f];
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:XMPPREACHABILITY object:nil];
}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - Void

- (void) refresh
{
    if ([AppDel appIsDisconnected])
    {
        [refreshControl performSelector:@selector(endRefreshing) withObject:nil afterDelay:0.0f];
        
        
        [AppData showAlertWithTitle:nil andMessage:@"No Connection." inVC:self];
        
        
        return;
    }
    
    
    GetRosterGrounp *getRoster = [[GetRosterGrounp alloc] init];
    
    getRoster.screenIndex = 1;
    
    getRoster.delegate = self;
    
    [getRoster getRosterByGroupNameAPI];
}


- (void)searchTableView
{
    [self filterContentForSearchText:[searchTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
}


- (void) searchViewAttribute
{
    searchSV.layer.cornerRadius = 5.0f;
    
    searchSV.layer.borderWidth = 0.5f;
    
    searchSV.layer.borderColor = [[UIColor colorWithRed:175.0/ 250.0 green:177.0/ 250.0 blue:180.0/ 250.0 alpha:1.0] CGColor];
    
  
    
    NSShadow *shadow = [[NSShadow alloc] init];
    
    shadow.shadowColor = [UIColor clearColor];
    
    [[UISegmentedControl appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                             [UIColor colorWithRed:156.0/255.0 green:205.0/255.0 blue:33.0/255.0 alpha:1.0], NSForegroundColorAttributeName,
                                                             shadow, NSShadowAttributeName,
                                                             [UIFont fontWithName:@"CentraleSansRndLight" size:16.0], NSFontAttributeName, nil] forState:UIControlStateNormal];
    
    
    NSShadow *shadow2 = [[NSShadow alloc] init];
    
    shadow2.shadowColor = [UIColor clearColor];
    
    shadow2.shadowOffset = CGSizeMake(0, 1);
    
    [[UISegmentedControl appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                             [UIColor whiteColor], NSForegroundColorAttributeName,
                                                             shadow2, NSShadowAttributeName,
                                                             [UIFont fontWithName:@"CentraleSansRndLight" size:16.0], NSFontAttributeName, nil] forState:UIControlStateSelected];
}


- (void) setupFetchedController
{
    NSError *er = nil;
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"XMPPUserCoreDataStorageObject"];
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"subscription LIKE[c] %@", @"both"];
    
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    
    
    self.listFetchResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[AppDel managedObjectContext_roster] sectionNameKeyPath:nil cacheName:nil];
    
    self.listFetchResultController.delegate = self;
    
    
    if (! [self.listFetchResultController performFetch:&er])
    {
        NSLog(@"Error while fetching from DB: %@", er.description);
    }
    
    
    NSFetchRequest *fetchRequest2 = [[NSFetchRequest alloc] initWithEntityName:@"XMPPRoomObject"];
    
    fetchRequest2.predicate = [NSPredicate predicateWithFormat:@"room_status!='deleted'"];
    
    fetchRequest2.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    
    
    self.roomFetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest2 managedObjectContext:[AppDel managedObjectContext_roster] sectionNameKeyPath:nil cacheName:nil];
    
    self.roomFetchController.delegate = self;
    
    
    if (![self.roomFetchController performFetch:&er])
    {
        NSLog(@"Error while fetching from DB: %@", er.description);
    }
}


- (void)filterContentForSearchText:(NSString *)searchText
{
    [self.self.userFilterArr removeAllObjects];
    
    
    if (segmentBtn.selectedSegmentIndex == 0)
    {
        NSPredicate *nickNamePredi = [NSPredicate predicateWithFormat:@"nickname CONTAINS[cd] %@", searchText];
        
        
        self.userFilterArr = [NSMutableArray arrayWithArray:[self.listFetchResultController.fetchedObjects filteredArrayUsingPredicate:nickNamePredi]];
    }
    
    else
    {
        NSPredicate *roomMemPredi = [NSPredicate predicateWithFormat:@"ANY members.memberJidStr CONTAINS[cd] %@", searchText];
        
        
        self.userFilterArr = [NSMutableArray arrayWithArray:[self.roomFetchController.fetchedObjects filteredArrayUsingPredicate:roomMemPredi]];
    }
    
    
    [searchTable reloadData];
}


- (void) imYourDocRosterGrouping: (BOOL) isRosterFinished withscreen: (NSInteger) responseForScreen
{
    if (isRosterFinished)
    {
        [refreshControl performSelector:@selector(endRefreshing) withObject:nil afterDelay:1.0f];
    }
}


#pragma mark - IBAction

- (IBAction)segmentTap:(UISegmentedControl *)sender
{
    searchTF.text = @"";
    
    [searchTF resignFirstResponder];
    
    
    if (sender.selectedSegmentIndex == 0)   // Users tap
    {
        
    }
    
    else                                    // Groups tap
    {
        
    }
    
    
    [searchTable reloadData];
}


#pragma mark - Update Connectivity

- (void) updateConnectivity:(NSNotification *)note
{
    NSDictionary *dict = note.object;
    
    
    secureLabel.text = [dict objectForKey:@"status"];
    
    
    [secureIcon setImage:[UIImage imageNamed:[dict objectForKey:@"image"]]];
}


#pragma mark - TextField

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    
    
    return YES;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [self performSelector:@selector(searchTableView) withObject:nil afterDelay:0.1f];
    
    
    return YES;
}


#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (searchTF.text.length > 0)
    {
        return self.userFilterArr.count;
    }
    
    else
    {
        if (segmentBtn.selectedSegmentIndex == 0)
        {
            return self.listFetchResultController.fetchedObjects.count;
        }
        
        else
        {
            return self.roomFetchController.fetchedObjects.count;
        }
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserListCell *tbCell = [tableView dequeueReusableCellWithIdentifier:@"LIST_TB_CELLID"];
    
    
    if (tbCell == nil)
    {
        tbCell = [[[NSBundle mainBundle] loadNibNamed:@"UserListCell" owner:self options:nil] lastObject];
        
        tbCell.userIMGV.layer.cornerRadius = 30;
        
        tbCell.userIMGV.layer.masksToBounds = YES;
    }
    
    
    if (segmentBtn.selectedSegmentIndex == 0)
    {
        if (searchTF.text.length > 0)
        {
            tbCell.userNameLB.text = [(NSManagedObject *)[self.userFilterArr objectAtIndex:indexPath.row] valueForKey:@"nickname"];
            
            
            NSData *imgData = [[AppDel xmppvCardAvatarModule] photoDataForJID:[XMPPJID jidWithString:[(NSManagedObject *)[self.userFilterArr objectAtIndex:indexPath.row] valueForKey:@"jidStr"]]];
            
            
            if (imgData)
            {
                tbCell.userIMGV.image = [UIImage imageWithData:imgData];
            }
        }
        
        else
        {
            tbCell.userNameLB.text = [(NSManagedObject *)[[self.listFetchResultController fetchedObjects] objectAtIndex:indexPath.row] valueForKey:@"nickname"];
            
            
            NSData *imgData = [[AppDel xmppvCardAvatarModule] photoDataForJID:[XMPPJID jidWithString:[(NSManagedObject *)[[self.listFetchResultController fetchedObjects] objectAtIndex:indexPath.row] valueForKey:@"jidStr"]]];
            
            
            if (imgData)
            {
                tbCell.userIMGV.image = [UIImage imageWithData:imgData];
            }
        }
    }
    
    else
    {
        if (searchTF.text.length > 0)
        {
            NSManagedObject *room = (NSManagedObject *)[self.userFilterArr objectAtIndex:indexPath.row];
            
            
            tbCell.userNameLB.text = [room valueForKey:@"name"];
            
            tbCell.userIMGV.image = [UIImage imageNamed:@"Group_profile"];
            
            
            if ([[room valueForKey:@"isPatient"] boolValue] == 1)
            {
                tbCell.userIMGV.image = [UIImage imageNamed:@"Red_group_profile"];
            }
        }
        
        else
        {
            NSManagedObject *room = [self.roomFetchController.fetchedObjects objectAtIndex:indexPath.row];
            
            
            tbCell.userNameLB.text = [(NSManagedObject *)room valueForKey:@"name"];
            
            tbCell.userIMGV.image = [UIImage imageNamed:@"Group_profile"];
            
            
            if ([[(XMPPRoomObject *)room isPatient] boolValue] == 1)
            {
                tbCell.userIMGV.image = [UIImage imageNamed:@"Red_group_profile"];
            }
        }
    }
    
    
    return tbCell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    [self.view endEditing:YES];
    
    
    ChatViewController *chatVC = [[ChatViewController alloc] initWithNibName:@"ChatViewController" bundle:nil];
    
    chatVC.forwardMessage = self.forwardMessage;
    
    chatVC.forChat = YES;
    
    chatVC.isForward = YES;
    
    
    if (segmentBtn.selectedSegmentIndex == 0)
    {
        chatVC.isGroupChat = NO;
        
        
        XMPPUserCoreDataStorageObject *user;
        
        
        if ([searchTF.text exactLength] > 0)
        {
            user = [self.userFilterArr objectAtIndex:indexPath.row];
        }
        
        else
        {
            user = [[self.listFetchResultController fetchedObjects] objectAtIndex:indexPath.row];
        }
        
        
        chatVC.user = user;
        
        chatVC.jid = user.jid;
    }
    
    else
    {
        chatVC.isGroupChat = YES;
        
        
        XMPPRoomObject *roomObj;
        
        
        if ([searchTF.text exactLength] > 0)
        {
            roomObj = [self.userFilterArr objectAtIndex:indexPath.row];
        }
        
        else
        {
            roomObj = [[self.roomFetchController fetchedObjects] objectAtIndex:indexPath.row];
        }
        
        
        chatVC.roomObj = roomObj;
        
        chatVC.jid = [XMPPJID jidWithString:roomObj.room_jidStr];
        
        
        XMPPRoomObject *alreadyJoined = [[[AppDel roomsArr] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"room_jidStr=%@", roomObj.room_jidStr]] lastObject];
        
        
        if (alreadyJoined)
        {
            chatVC.room = alreadyJoined.room;
        }
        
        else
        {
          
            
            
            chatVC.room = roomObj.room;
            
            
            [roomObj.room activate:[AppDel xmppStream]];
            
            [roomObj.room addDelegate:AppDel delegateQueue:dispatch_get_main_queue()];
            
            [roomObj.room fetchRoomInfo];
        }
    }
    
    
    [self.navigationController pushViewController:chatVC animated:YES];
}


#pragma mark - NSFetchedResultController

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{

    
    
    if ([refreshControl isRefreshing])
    {
        [refreshControl performSelector:@selector(endRefreshing) withObject:nil afterDelay:1.0f];
    }
}


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    [searchTable reloadData];
}


@end

