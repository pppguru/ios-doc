//
//  ReadByViewController.m
//  IMYourDoc
//
//  Created by Harminder on 02/04/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import "UserListCell.h"
#import "GroupChatReadbyList.h"
#import "ReadByWebServicesViewController.h"


@interface ReadByWebServicesViewController ()


@end


@implementation ReadByWebServicesViewController


#pragma mark - View LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    
    
    [self getMessageStatus];    
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - Web Services Methods

- (void)getMessageStatus
{
    [AppDel showSpinnerWithText:@"Fetching.."];
    
//    NSDictionary *searchDict = [NSDictionary dictionaryWithObjectsAndKeys:
//                                
//                                @"getGroupMessageDeliveryStatus", @"method",
//                                
//                                [[NSUserDefaults standardUserDefaults]objectForKey:@"loginToken"], @"login_token",
//                                
//                                self.msg.uri, @"roomjid",
//                                
//                                self.msg.messageID, @"message_id",
//                                
//                                nil];
    
    
    [[WebHelper sharedHelper] setWebHelperDelegate:self];
    
   // [[WebHelper sharedHelper] sendRequest:searchDict tag:S_GroupReadby delegate:self];

}


- (void)didReceivedresponse:(NSDictionary *)response
{
    [AppDel hideSpinner];
    
    
    if ([[response objectForKey:@"err-code"] intValue] == 1)
    {
        self.readByDic = [[NSDictionary alloc] initWithDictionary:response];
        
        [readbyTable reloadData];
    }
    else if ([[response objectForKey:@"err-code"] intValue] == 600)
    {
        [AppDel signOutFromAppSilent];
        
        [[RDCallbackAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] cancelButtonTitle:nil andCompletionHandler:^(int btnIndex)
         
         {
             
         } otherButtonTitles:@"OK", nil];
        
        return;
    }
    else
    {
        [[RDCallbackAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] cancelButtonTitle:nil andCompletionHandler:^(int btnIndex)
         
         {
             
         } otherButtonTitles:@"OK", nil];
    }
}


- (void)didFailedWithError: (NSError *) error
{
    [AppDel hideSpinner];
    
    
    NSLog(@"Error .............%@", error);
}


#pragma mark - Table

- (NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    
    return [[self.readByDic objectForKey:@"status"] count];
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
    
  
    XMPPJID * jid = [XMPPJID jidWithString:[[[self.readByDic objectForKey:@"status"] objectAtIndex:indexPath.row] objectForKey:@"userjid"]];
    
    
    cell.userNameLB.text = [jid user];
    
    cell.userIMGV.image = nil;
    
    [cell.userIMGV downloadFromURL:[NSURL URLWithString:[NSString stringWithFormat:URLBUILER(@"https://api.imyourdoc.com/profilepic.php?user_name=%@") , jid.user]]];
  
    
    
    cell.roleLB.text = @"Delivered";
    
    if ([[[[[self.readByDic objectForKey:@"status"] objectAtIndex:indexPath.row] objectForKey:@"delivery_status"] uppercaseString] isEqualToString:@"XMPP"])
    {
        GroupChatReadbyList *readby = [[self.msg.readby filteredOrderedSetUsingPredicate:[NSPredicate predicateWithFormat:@"userJID=%@",[jid bare]]] lastObject];
        
        if(readby==nil)
        {
            if([self.msg.identityuri isEqualToString:[jid bare]]&&self.msg.isOutbound)
            {
                cell.roleLB.text = @"Sender";
            }
        }
        else
        {
            cell.roleLB.text = readby.status;
            if(readby.status==nil)
                cell.roleLB.text = @"Delivered";
        }
    }
    
    else if ([[[[[self.readByDic objectForKey:@"status"] objectAtIndex:indexPath.row] objectForKey:@"delivery_status"] uppercaseString] isEqualToString:@"PUSH"])
    {
        cell.roleLB.text = @"Notification Sent";
        
        GroupChatReadbyList *readby = [[self.msg.readby filteredOrderedSetUsingPredicate:[NSPredicate predicateWithFormat:@"userJID=%@",[jid bare]]] lastObject];
        
        if(readby==nil)
        {
            if([self.msg.identityuri isEqualToString:[jid bare]]&&self.msg.isOutbound)
            {
                cell.roleLB.text = @"Sender";
            }
        }
        else
        {
           
            cell.roleLB.text = readby.status;
            if(readby.status==nil)
                cell.roleLB.text = @"Delivered";
        }
    }
    
    else if ([[[[[self.readByDic objectForKey:@"status"] objectAtIndex:indexPath.row] objectForKey:@"delivery_status"] uppercaseString] isEqualToString:@"PENDING"])
    {
        cell.roleLB.text = @"Pending";
        
        GroupChatReadbyList *readby = [[self.msg.readby filteredOrderedSetUsingPredicate:[NSPredicate predicateWithFormat:@"userJID=%@",[jid bare]]] lastObject];
        
        if(readby==nil)
        {
            if([self.msg.identityuri isEqualToString:[jid bare]]&&self.msg.isOutbound)
            {
                cell.roleLB.text = @"Sender";
            }
        }
        else
        {
            cell.roleLB.text = readby.status;
            if(readby.status==nil)
                cell.roleLB.text = @"Delivered";
        }
    }
    
    
    
    
    if ([self.msg.identityuri isEqualToString:[jid bare]]&&self.msg.isOutbound)
    {
        cell.roleLB.text = @"Sender";
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

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [readbyTable reloadData];
}


@end

