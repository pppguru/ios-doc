//
//  UserListViewController.m
//  IMYourDoc
//
//  Created by Sarvjeet on 28/01/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "UserListViewController.h"
#import "SearchStaffViewController.h"
#import "StaffProfileViewController.h"
#import "SearchPatientViewController.h"
#import "PatientProfileViewController.h"
#import "SearchPhysicianViewController.h"
#import "PhysicianProfileViewController.h"

#import "VCard.h"
#import "VCardAffilication.h"
#import "GroupListCell.h"
#import "GroupProfileViewController.h"

@interface UserListViewController ()

@end

#define TAG_FETCHPROFILE 999

#define  colorSearchText  [UIColor blueColor];


@implementation UserListViewController


static NSString *listTBID;


#pragma mark - View LifeCycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    
    self.listType = LIST_PHYSICIAN;
    
    loadOnce = YES;
    
    refreshControl = [[UIRefreshControl alloc] init];
    
    refreshControl.backgroundColor = [UIColor clearColor];
    
    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    
    
    [listTable addSubview:refreshControl];
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    
    [self setRequiredFont2];
    
    if (loadOnce)
    {
        if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"UserType"] isEqualToString:@"Patient"])
        {
            patientB.hidden = YES;
            
            patViewCenterXConst.constant = -25;
            
            topbarOptionsWidthConst.constant = 162;
            
            grpOptionLeadingConst.constant = 0;
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                iPadGrpOptionLeadingConst.constant = 0;
            }
            
            
            [self.view layoutIfNeeded];
        }
        
        else
        {
            patientB.hidden = NO;
            
            patViewCenterXConst.constant = 0;
            
            [self.view layoutIfNeeded];
            
        }
    }
    
    
    loadOnce = NO;

    
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

    
    listTBID = @"LIST_TB_CELLID";
    
    
    [self setupFetchedController];
    
    
    [AppDel bringButton];
}


- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    [self setRequiredFont2];
}


- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    
    [refreshControl performSelector:@selector(endRefreshing) withObject:nil afterDelay:0.0f];
}


- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


- (void) didReceiveMemoryWarning
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
    
    
    [AppDel getRoster];
  /*
    GetRosterGrounp *getRoster = [[GetRosterGrounp alloc] init];
    
    getRoster.screenIndex = 1;
    
    getRoster.delegate = self;
    
    [getRoster getRosterByGroupNameAPI];*/
}


- (void)searchTableView
{
    [self filterContentForSearchText:[searchTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
}


- (void) setupFetchedController
{
    
    
    if (self.listType == LIST_GROUP)
    {
        
        {
            
            NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"XMPPRoomObject"];
            
            request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"subject" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
            
            NSPredicate *predicate= [NSPredicate predicateWithFormat:@" ( streamJidStr   like[cd] %@) && room_status != 'deleted'", [AppDel myJID] ];
            
            request.predicate=predicate;
            
             self.listFetchResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:[AppDel managedObjectContext_roster]
                                                                              sectionNameKeyPath:nil cacheName:nil];
            
             self.listFetchResultController.delegate = self;
            NSError *error = nil;
            
            
            if (![ self.listFetchResultController performFetch:&error])
            {
                NSLog(@"....%@", error);
            }
        }
    
    }
    
    else{
    
    

        
        NSError *er;
        
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"XMPPUserCoreDataStorageObject"];
        
        
        if (self.listType == LIST_PHYSICIAN)
        {
            fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(ANY groups.name LIKE[cd] %@) AND (subscription LIKE[c] %@) AND streamBareJidStr =%@",
                                      @"PHYSICIAN",
                                      @"both",
                                      [AppDel myJID]];
        }
        
        else if (self.listType == LIST_STAFF)
        {
         fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(ANY groups.name LIKE[cd] %@) AND (subscription LIKE[c] %@) AND streamBareJidStr =%@ ", @"STAFF", @"both",[AppDel myJID]];
            
            
        }
        
        else if (self.listType == LIST_PATIENT)
        {
           fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(ANY groups.name LIKE[cd] %@) AND (subscription LIKE[c] %@) AND streamBareJidStr =%@ ", @"PATIENT", @"both",[AppDel myJID]];
            
            
        }
        
        
        fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
        
        
        self.listFetchResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[AppDel managedObjectContext_roster] sectionNameKeyPath:nil cacheName:nil];
        
        self.listFetchResultController.delegate = self;
        
        
        if (! [self.listFetchResultController performFetch:&er])
        {
            NSLog(@"Error while fetching from DB: %@", er.description);
        }
    
    }
    
    
}


- (void)filterContentForSearchText:(NSString *)searchText
{
    [self.userFilterArr removeAllObjects];
    
    
    if(        self.listType == LIST_GROUP)
    {

        
        NSPredicate *predicate= [NSPredicate predicateWithFormat:@"name contains[cd] %@ OR  members.memberJidStr contains[cd] %@ OR subject contains[cd] %@  && room_status != 'deleted' ",searchText,searchText,searchText];
        

        
        self.userFilterArr = [NSMutableArray arrayWithArray:[self.listFetchResultController.fetchedObjects filteredArrayUsingPredicate:predicate]];
    }
    else{
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"VCard"];
        
        request.predicate = [NSPredicate predicateWithFormat:@"practiceType=%@ OR  name CONTAINS[cd] %@ OR nickname CONTAINS[cd] %@ OR designation  CONTAINS[cd] %@ OR title  CONTAINS[cd] %@ OR affilications.name CONTAINS[cd] %@ OR userJID CONTAINS[cd] %@ ", searchText, searchText, searchText, searchText, searchText, searchText,searchText];
        
        
        NSArray *users = [[AppDel managedObjectContext_roster] executeFetchRequest:request error:nil];
        
        
        NSArray *jid = [users valueForKey:@"userJID"];
        
        
        NSPredicate *nickNamePredi = [NSPredicate predicateWithFormat:@"nickname CONTAINS[cd] %@ OR jidStr in (%@)", searchText, jid];
        

        
        self.userFilterArr = [NSMutableArray arrayWithArray:[self.listFetchResultController.fetchedObjects filteredArrayUsingPredicate:nickNamePredi]];
    }
 
    
    
    [listTable reloadData];
}


- (void) imYourDocRosterGrouping: (BOOL) isRosterFinished withscreen: (NSInteger) responseForScreen
{
    if (isRosterFinished)
    {
        [refreshControl performSelector:@selector(endRefreshing) withObject:nil afterDelay:1.0f];
    }
}


#pragma mark - IBAction

- (IBAction)navBack
{
	[self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)addPhysician
{
    if (self.listType == LIST_PHYSICIAN)
    {
        SearchPhysicianViewController *spVC = [[SearchPhysicianViewController alloc] initWithNibName:@"SearchPhysicianViewController" bundle:nil];
        
        [self.navigationController pushViewController:spVC animated:YES];
    }
    
    else if (self.listType == LIST_STAFF)
    {
        SearchStaffViewController *ssVC = [[SearchStaffViewController alloc] initWithNibName:@"SearchStaffViewController" bundle:nil];
        
        [self.navigationController pushViewController:ssVC animated:YES];
    }
    
    else if (self.listType == LIST_PATIENT)
    {
        SearchPatientViewController *spVC = [[SearchPatientViewController alloc] initWithNibName:@"SearchPatientViewController" bundle:nil];
        
        [self.navigationController pushViewController:spVC animated:YES];
    }
}


- (IBAction)segmentTap:(UIButton *)sender
{
    patientB.selected = physicianB.selected = staffB.selected = groupBtn.selected =NO;
    
    
    sender.selected = YES;
    
    
    searchTF.text = @"";
    
    
    if (sender == groupBtn)
    {
        self.listType = LIST_GROUP;
        
        
        addButton.hidden = YES;
        
        
        searchTF.placeholder = @"Search Group..";
    }
    
    
    if (sender == physicianB)
    {
        self.listType = LIST_PHYSICIAN;
        
        
        addButton.hidden = NO;
        
        
        searchTF.placeholder = @"Search Provider..";
    }
    
    else if (sender == staffB)
    {
        self.listType = LIST_STAFF;
        
        
        addButton.hidden = NO;
        
        
        searchTF.placeholder = @"Search Staff..";
    }
    
    else if (sender == patientB)
    {
        self.listType = LIST_PATIENT;
        
        searchTF.placeholder = @"Search Patient..";

        addButton.hidden = YES;
    }
    
    
    [self setupFetchedController];
    
    
    [listTable reloadData];
}


#pragma mark - update Connectivity

- (void) updateConnectivity:(NSNotification *)note
{
    NSDictionary *dict = note.object;
    
    
    secureL.text = [dict objectForKey:@"status"];
    
    
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
        return self.listFetchResultController.fetchedObjects.count;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.listType == LIST_GROUP)
    {
        {
            GroupListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GroupListCell"];
            
            
            if (cell == nil)
            {
                cell = [[[NSBundle mainBundle] loadNibNamed:@"GroupListCell" owner:self options:nil] lastObject];
                
                cell.userIMGV.layer.cornerRadius = 26;
                
                cell.userIMGV.layer.backgroundColor = [[UIColor clearColor] CGColor];
                
                [cell.userIMGV.layer setMasksToBounds:YES];
            }
            XMPPRoomObject *obj_XMPPRoomObject=nil;
            
            if (searchTF.text.length > 0){
                      obj_XMPPRoomObject = [[self userFilterArr] objectAtIndex:indexPath.row];
            }
            else{
                obj_XMPPRoomObject = [[self listFetchResultController] objectAtIndexPath:indexPath];
            }

            if (obj_XMPPRoomObject.subject != nil && obj_XMPPRoomObject.subject.length > 0) {
                  cell.userNameLB.text=obj_XMPPRoomObject.subject;
            }
            else if (obj_XMPPRoomObject.name!=nil && obj_XMPPRoomObject.name.length > 0)
            {
                   cell.userNameLB.text=obj_XMPPRoomObject.name;
            }
            else{
                   cell.userNameLB.text=obj_XMPPRoomObject.room_jidStr;
            }
            
            
      
            if ([obj_XMPPRoomObject isPatientRoom] == 0)
                cell.userIMGV.image = [UIImage imageNamed:@"group_profile"];
            else
            {
                cell.userNameLB.textColor = [UIColor colorWithRed:255/255.0 green:84.0/255.0 blue:57.0/255.0 alpha:1];
                
                cell.userIMGV.image = [UIImage imageNamed:@"red_group_profile"];
            }
            return cell;
        }
    }
    else
    {
    
    UserListCell *tbCell = [tableView dequeueReusableCellWithIdentifier:listTBID];
    if (tbCell == nil)
    {
        
       //UserListCell_MyContact.xib
        
        tbCell = [[[NSBundle mainBundle] loadNibNamed:@"UserListCell_MyContact" owner:self options:nil] lastObject];
        
        tbCell.userIMGV.layer.cornerRadius = 30;
        
        tbCell.userIMGV.layer.masksToBounds = YES;
        
        tbCell.roleLB.hidden = NO;
        tbCell.lblThirdRow.hidden =NO;
        tbCell.lblFourthRow.hidden =NO;
        
    }
    tbCell.roleLB.text = @"";
    tbCell.lblThirdRow.text = @"";
    tbCell.lblFourthRow.text = @"";
        
        
    if (searchTF.text.length > 0)
    {
        tbCell.userNameLB.text = [(NSManagedObject *)[self.userFilterArr objectAtIndex:indexPath.row] valueForKey:@"nickname"];
        
        
        XMPPUserCoreDataStorageObject *user = (XMPPUserCoreDataStorageObject *)[self.userFilterArr objectAtIndex:indexPath.row];
        
        
        VCard *vCard = [AppDel fetchVCard:user.jid];
        
        
        if (vCard.name != nil)
        {
            if (![vCard.designation isEqualToString:@""])
            {
                tbCell.userNameLB.text = [NSString stringWithFormat:@"%@, %@", vCard.name, vCard.designation];
                
                
                if (searchTF.text.length>0)
                {
                    
                    
                    
                    
                    
                    // If attributed text •••• userNameLB ••• is supported (iOS6+)
                    
                    
                    
                    if ([tbCell.userNameLB respondsToSelector:@selector(setAttributedText:)])
                    {
                        NSString *texet = tbCell.userNameLB.text;
                        // Define general attributes for the entire text
                        NSDictionary *attribs = @{
                                                  NSForegroundColorAttributeName: tbCell.userNameLB.textColor,
                                                  NSFontAttributeName: tbCell.userNameLB .font
                                                  };
                        NSMutableAttributedString *attributedText =
                        [[NSMutableAttributedString alloc] initWithString:texet
                                                               attributes:attribs];
                        
                        // Red text attributes
                        UIColor *blueColor = colorSearchText
                        
                        NSRange redTextRange = [texet rangeOfString:searchTF.text options:NSCaseInsensitiveSearch];
                        // * Notice that usage of rangeOfString in this case may cause some bugs - I use it here only for demonstration
                        
                        [attributedText setAttributes:@{NSForegroundColorAttributeName:blueColor,NSFontAttributeName:  tbCell.userNameLB .font}
                                                range:redTextRange];
                        tbCell.userNameLB .attributedText = attributedText;
                        
                    }
                    
                    else{
                                       tbCell.userNameLB.text = [NSString stringWithFormat:@"%@, %@", vCard.name, vCard.designation];
                    }
                    
                    
                }
                else{
                    
                    
                tbCell.userNameLB.text = [NSString stringWithFormat:@"%@, %@", vCard.name, vCard.designation];
                }
                
                
                
                
            }
            
            else
            {
                
               
                
    
                
                
                if (searchTF.text.length>0)
                {
                    
                    
                    
                   
                    
                    // If attributed text •••• userNameLB ••• is supported (iOS6+)
                    
                    
                    
                    if ([tbCell.userNameLB respondsToSelector:@selector(setAttributedText:)])
                    {
                         NSString *texet = vCard.name;
                        // Define general attributes for the entire text
                        NSDictionary *attribs = @{
                                                  NSForegroundColorAttributeName: tbCell.userNameLB.textColor,
                                                  NSFontAttributeName: tbCell.userNameLB .font
                                                  };
                        NSMutableAttributedString *attributedText =
                        [[NSMutableAttributedString alloc] initWithString:texet
                                                               attributes:attribs];
                        
                        // Red text attributes
                        UIColor *blueColor = colorSearchText
                        
                        NSRange redTextRange = [texet rangeOfString:searchTF.text options:NSCaseInsensitiveSearch];
                        // * Notice that usage of rangeOfString in this case may cause some bugs - I use it here only for demonstration

                        [attributedText setAttributes:@{NSForegroundColorAttributeName:blueColor,NSFontAttributeName:  tbCell.userNameLB .font}
                                                range:redTextRange];
                        tbCell.userNameLB .attributedText = attributedText;
                        
                    }
                    
                    else{
                        tbCell.userNameLB.text = vCard.name;
                    }
                    
                    
                }
                else{
                    
                    
                    tbCell.userNameLB.text =[NSString stringWithFormat:@"%@", vCard.name];
                }
                
                
                

                
              
              
            }
            
            
            
    VCardAffilication *affliation = [[vCard.affilications filteredOrderedSetUsingPredicate:[NSPredicate predicateWithFormat:@"isPrimary == 1"]] lastObject];
            
            if (affliation)
            {
                tbCell.lblThirdRow.text = affliation.name;
                
               
                //Attribute Text for lblThirdRow
                {
                    
                    if (searchTF.text.length>0)
                    {
                        
                        
                        
                        
                        
                        // If attributed text •••• userNameLB ••• is supported (iOS6+)
                        
                        
                        
                        if ([tbCell.lblThirdRow respondsToSelector:@selector(setAttributedText:)])
                        {
                            NSString *texet = tbCell.lblThirdRow.text;
                            // Define general attributes for the entire text
                            NSDictionary *attribs = @{
                                                      NSForegroundColorAttributeName: tbCell.lblThirdRow.textColor,
                                                      NSFontAttributeName: tbCell.lblThirdRow .font
                                                      };
                            NSMutableAttributedString *attributedText =
                            [[NSMutableAttributedString alloc] initWithString:texet
                                                                   attributes:attribs];
                            
                            // Red text attributes
                            UIColor *blueColor = colorSearchText
                            
                            NSRange redTextRange = [texet rangeOfString:searchTF.text options:NSCaseInsensitiveSearch];
                            // * Notice that usage of rangeOfString in this case may cause some bugs - I use it here only for demonstration
                            
                            [attributedText setAttributes:@{NSForegroundColorAttributeName:blueColor,NSFontAttributeName:  tbCell.lblThirdRow .font}
                                                    range:redTextRange];
                            tbCell.lblThirdRow .attributedText = attributedText;
                            
                        }
                        
                        else{
                          tbCell.lblThirdRow.text = affliation.name;
                        }
                        
                        
                    }
                    else{
                        
                         tbCell.lblThirdRow.text = affliation.name;
                    }
                    
                    
                    
                    
                }
                
                
            }
            
            tbCell.lblFourthRow.text = [NSString stringWithFormat:@"%@", vCard.title];
            //Attribute Text for lblFourthRow
            {
                if (searchTF.text.length>0)
                {
                    
                    
                    
                    
                    
                    // If attributed text •••• userNameLB ••• is supported (iOS6+)
                    
                    
                    
                    if ([tbCell.lblFourthRow respondsToSelector:@selector(setAttributedText:)])
                    {
                        NSString *texet = tbCell.lblFourthRow.text;
                        // Define general attributes for the entire text
                        NSDictionary *attribs = @{
                                                  NSForegroundColorAttributeName: tbCell.lblFourthRow.textColor,
                                                  NSFontAttributeName: tbCell.lblFourthRow .font
                                                  };
                        NSMutableAttributedString *attributedText =
                        [[NSMutableAttributedString alloc] initWithString:texet
                                                               attributes:attribs];
                        
                        // Red text attributes
                        UIColor *blueColor = colorSearchText
                        
                        NSRange redTextRange = [texet rangeOfString:searchTF.text options:NSCaseInsensitiveSearch];
                        // * Notice that usage of rangeOfString in this case may cause some bugs - I use it here only for demonstration
                        
                        [attributedText setAttributes:@{NSForegroundColorAttributeName:blueColor,NSFontAttributeName:  tbCell.lblFourthRow .font}
                                                range:redTextRange];
                        tbCell.lblFourthRow .attributedText = attributedText;
                        
                    }
                    
                    else{
                      tbCell.lblFourthRow.text = [NSString stringWithFormat:@"%@", vCard.title];
                    }
                    
                    
                }
                else{
                    
                   tbCell.lblFourthRow.text = [NSString stringWithFormat:@"%@", vCard.title];
                }
            }
            XMPPJID *toJID = [XMPPJID jidWithString:vCard.userJID];
            tbCell.roleLB.text =[toJID user];
            //Attribute Text for roleLB
            {
                if (searchTF.text.length>0)
                {
                    
                    
                    
                    
                    
                    // If attributed text •••• userNameLB ••• is supported (iOS6+)
                    
                    
                    
                    if ([tbCell.roleLB respondsToSelector:@selector(setAttributedText:)])
                    {
                        NSString *texet = tbCell.roleLB.text;
                        // Define general attributes for the entire text
                        NSDictionary *attribs = @{
                                                  NSForegroundColorAttributeName: tbCell.roleLB.textColor,
                                                  NSFontAttributeName: tbCell.roleLB .font
                                                  };
                        NSMutableAttributedString *attributedText =
                        [[NSMutableAttributedString alloc] initWithString:texet
                                                               attributes:attribs];
                        
                        // Red text attributes
                        UIColor *blueColor = colorSearchText
                        
                        NSRange redTextRange = [texet rangeOfString:searchTF.text options:NSCaseInsensitiveSearch];
                        // * Notice that usage of rangeOfString in this case may cause some bugs - I use it here only for demonstration
                        
                        [attributedText setAttributes:@{NSForegroundColorAttributeName:blueColor,NSFontAttributeName:  tbCell.roleLB .font}
                                                range:redTextRange];
                        tbCell.roleLB .attributedText = attributedText;
                        
                    }
                    
                    else{
                     tbCell.roleLB.text =[toJID user];
                    }
                    
                    
                }
                else{
                    
                    tbCell.roleLB.text =[toJID user];
                }
            }
            
            
            
        }
        
        tbCell.userIMGV.image =user.photo;
        
        if(tbCell.userIMGV.image==nil)
        {
            tbCell.userIMGV.image=[UIImage imageNamed:@"Profile"];
        }
        
    
    }
    
    else
    {
        tbCell.userNameLB.text = [(NSManagedObject *)[[self.listFetchResultController fetchedObjects] objectAtIndex:indexPath.row] valueForKey:@"nickname"];
        
        
        XMPPUserCoreDataStorageObject *user = (XMPPUserCoreDataStorageObject *)[[self.listFetchResultController fetchedObjects] objectAtIndex:indexPath.row];
        
        
        VCard *vCard = [AppDel fetchVCard:user.jid];
        
        
        if (vCard.name != nil)
        {
            if (![vCard.designation isEqualToString:@""])
            {
                tbCell.userNameLB.text = [NSString stringWithFormat:@"%@, %@", vCard.name, vCard.designation];
            }
            
            else
            {
                tbCell.userNameLB.text = [NSString stringWithFormat:@"%@", vCard.name];
            }
            
            
            tbCell.lblFourthRow.text = [NSString stringWithFormat:@"%@", vCard.title];
            
            
            VCardAffilication *affliation = [[vCard.affilications filteredOrderedSetUsingPredicate:[NSPredicate predicateWithFormat:@"isPrimary == 1"]] lastObject];
            
            if (affliation)
            {
                tbCell.lblThirdRow.text = affliation.name;
            }
            XMPPJID *toJID = [XMPPJID jidWithString:vCard.userJID];
            tbCell.roleLB.text =[toJID user];
            
            
        }
        
        
            tbCell.userIMGV.image =user.photo;
            if(tbCell.userIMGV.image==nil)
            {
                tbCell.userIMGV.image=[UIImage imageNamed:@"Profile"];
                
                
            }
     
    }
    
    
    return tbCell;
    }
    return nil;
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 92;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    [self.view endEditing:YES];
    
    
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    
    
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    
    
    if (networkStatus != NotReachable)
    {
        if (self.listType == LIST_PHYSICIAN)
        {
            PhysicianProfileViewController *ppVC = [[PhysicianProfileViewController alloc] initWithNibName:@"PhysicianProfileViewController" bundle:nil];
            
            ppVC.fromSearch = NO;
            
            
            if (searchTF.text.length == 0)
            {
                ppVC.toUserName = [(XMPPJID*)[[[self.listFetchResultController fetchedObjects] objectAtIndex:indexPath.row] jid] user];
            }
            
            else
            {
                ppVC.toUserName = [(XMPPJID*)[[self.userFilterArr objectAtIndex:indexPath.row] jid] user];
            }
            
            
            [self.navigationController pushViewController:ppVC animated:YES];
        }
        
        else if (self.listType == LIST_STAFF)
        {
            StaffProfileViewController *spVC = [[StaffProfileViewController alloc] initWithNibName:@"StaffProfileViewController" bundle:nil];
            
            spVC.fromSearch = NO;
            
            
            if (searchTF.text.length == 0)
            {
                spVC.toUserName = [(XMPPJID*)[[[self.listFetchResultController fetchedObjects] objectAtIndex:indexPath.row] jid] user];
            }
            
            else
            {
                spVC.toUserName = [(XMPPJID*)[[self.userFilterArr objectAtIndex:indexPath.row] jid] user];
            }
            
            
            [self.navigationController pushViewController:spVC animated:YES];
        }
        
        else if (self.listType == LIST_PATIENT)
        {
            PatientProfileViewController *ppVC = [[PatientProfileViewController alloc] initWithNibName:@"PatientProfileViewController" bundle:nil];
            
            ppVC.fromSearch = NO;
            
            
            if (searchTF.text.length == 0)
            {
                ppVC.toUserName = [(XMPPJID*)[[[self.listFetchResultController fetchedObjects] objectAtIndex:indexPath.row] jid] user];
            }
            
            else
            {
                ppVC.toUserName = [(XMPPJID*)[[self.userFilterArr objectAtIndex:indexPath.row] jid] user];
            }
            
            
            [self.navigationController pushViewController:ppVC animated:YES];
        }
        else if (self.listType == LIST_GROUP)
        {
            {
                
                [searchTF resignFirstResponder];
                
                
                XMPPRoomObject *room=nil;
                
                if (searchTF.text.length > 0){
                    room = [[self userFilterArr] objectAtIndex:indexPath.row];
                }
                else{
                    room = [[self listFetchResultController] objectAtIndexPath:indexPath];
                }
                

                
             
                XMPPRoomObject *alreadyJoined = [[[AppDel roomsArr] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"room_jidStr=%@", room.room_jidStr]] lastObject];
                
                GroupProfileViewController *Obj_groupProfileViewController = [[GroupProfileViewController alloc] initWithNibName:@"GroupProfileViewController" bundle:nil];
                Obj_groupProfileViewController.roomObj = room;
                if (alreadyJoined)
                {

                    Obj_groupProfileViewController.xmppRoom = alreadyJoined.room;
                    
                }
                
                else
                {
                 
                    Obj_groupProfileViewController.xmppRoom = room.room;
                    
                    [room.room activate:[AppDel xmppStream]];
                    
                    [room.room addDelegate:AppDel delegateQueue:[AppDel xmppDelegateQueue]];
                    
                    if(room.lastMessageDate==nil)
                    {
                        room.lastMessageDate=[NSDate date];
                    }
                    
                    
                    NSXMLElement * history=[NSXMLElement elementWithName:@"history"];
                    NSString * seconds=[NSString stringWithFormat:@"%ld",(long)[[NSDate date] timeIntervalSinceDate:room.lastMessageDate]];
                    
                    if([seconds intValue]<30)
                    {
                        seconds=@"30";
                    }
                    
                    [history addAttributeWithName:@"seconds" stringValue:seconds];
                    
                    [room.room joinRoomUsingNickname:[[XMPPJID jidWithString:[AppDel myJID]] user] history:history];
                }
                [self.navigationController pushViewController:Obj_groupProfileViewController animated:YES];
            }
        }
        
    }
    
    else
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"No Internet Connection." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
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
    [listTable reloadData];
}


#pragma mark - ASIRequestDelegate

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [AppDel hideSpinner];
    
    
    NSString *trimmedString = [[[request responseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] mutableCopy];
    
    
    NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:nil];
    
    
    if ([[responseDict objectForKey:@"err-code"] intValue] != 0)
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"We were unable to process your request. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        
        
        return;
    }
    
    
    if (request.tag == TAG_FETCHPROFILE)
    {
        DDXMLElement *element = [[DDXMLElement alloc] initWithXMLString:trimmedString error:nil];
        
        
        NSMutableDictionary *staffDictionary = [NSMutableDictionary dictionary];
        
        [staffDictionary setObject:[[element elementForName:@"StaffUserName"] stringValue]		forKey:@"StaffUserName"];
        
        [staffDictionary setObject:[[element elementForName:@"PhysicianUserName"] stringValue]	forKey:@"PhysicianUserName"];
        
        [staffDictionary setObject:[[element elementForName:@"StaffPic"] stringValue]			forKey:@"StaffPic"];
        
        [staffDictionary setObject:[[element elementForName:@"StaffFname"] stringValue]			forKey:@"StaffFname"];
        
        [staffDictionary setObject:[[element elementForName:@"StaffLname"] stringValue]			forKey:@"StaffLname"];
        
        [staffDictionary setObject:[[element elementForName:@"StaffEmail"] stringValue]			forKey:@"StaffEmail"];
        
        [staffDictionary setObject:[[element elementForName:@"StaffPhone"] stringValue]			forKey:@"StaffPhone"];
        
        [staffDictionary setObject:[[element elementForName:@"AvailableHoursFrom"] stringValue]	forKey:@"AvailableHoursFrom"];
        
        [staffDictionary setObject:[[element elementForName:@"AvailableHoursTo"] stringValue]	forKey:@"AvailableHoursTo"];
        
        [staffDictionary setObject:[[element elementForName:@"LoginStatus"] stringValue]		forKey:@"LoginStatus"];
        
        
      
    }
}


- (void)requestFailed:(ASIHTTPRequest *)request
{
    [AppDel hideSpinner];
    
    
    if (request.tag == TAG_FETCHPROFILE)
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"We were unable to process your request. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}




- (void)setRequiredFont2
{
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [searchTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
    }
    else
    {
        [searchTF setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:16.00]];
    }
}



@end

