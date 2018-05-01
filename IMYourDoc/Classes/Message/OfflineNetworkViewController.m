//
//  MessageInboxViewController.m
//  IMYourDoc
//
//  Created by Sarvjeet on 22/01/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import <QuartzCore/QuartzCore.h>

#import "OfflineContact.h"
#import "OfflineMessages.h"
#import "MessageInboxCell.h"
#import "ChatViewController.h"
#import "OfflineChatViewController.h"
#import "OfflineNetworkViewController.h"
#import "UserListCell.h"
#import "OfflineNetworkCell.h"

@interface OfflineNetworkViewController () <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UITextFieldDelegate>
{
    NSMutableArray *arr_records;
     UIView *view_addContact;
    
    NSMutableDictionary  *dict_R_AllArrayContactsV;
     NSMutableDictionary  *dict_R_AllArrayContacts_search;
    NSMutableArray          *arr_R_AllArrayContactsTitleV;
    NSMutableArray          *arr_R_AllArrayContactsTitle_search;
}

@end


@implementation OfflineNetworkViewController
@synthesize segmentbtn_ContactInbox;
@synthesize footerForSDCMain;
#pragma mark - View LifeCycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    

    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"OfflineContact"];
    
    request.predicate = [NSPredicate predicateWithFormat:@"streamJID=%@ and messageCount>%@", [AppDel myJID],[NSNumber numberWithInt:0]];
    
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"lastupdate" ascending:NO]];
    
    self.messageFetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:[AppDel managedObjectContext_roster] sectionNameKeyPath:nil cacheName:nil];
    
    self.messageFetchController.delegate = self;
    
    NSError *error = nil;
    
    
    if (![self.messageFetchController performFetch:&error])
    {
        NSLog(@"....%@", error);
    }

    
   
    
    footerForSDCMain=[[UIControl alloc]initWithFrame:CGRectMake(0, 0, self.searchDisplayController.searchResultsTableView.tableFooterView.frame.size.width, 64)];
    footerForSDCMain.tag=1001;
    FontLabel * name=[[FontLabel alloc]initWithFrame:CGRectMake(40, 5, 250, 20)];
    
    name.text=@"Tap to add new Contact ";
    [footerForSDCMain addSubview:name];
    name.tag=1002;
    FontLabel * detailText=[[FontLabel alloc]initWithFrame:CGRectMake(40, 30, 250, 20)];
    [footerForSDCMain addSubview:detailText];
    detailText.text=@" no name ";
    detailText.tag=1003;
    
    messagesTB.tableFooterView=footerForSDCMain;
    
    
    
    [footerForSDCMain addTarget:self action:@selector(addContact:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [AppDel showSpinnerWithText:@"Loading"];
    
    dispatch_async(dispatch_get_main_queue(),^
                  {
                   
                      
                    [self loadPhoneContacts];
                    [self addExistingAndPhoneContact];
                      [messagesTB reloadData];
                         [AppDel hideSpinner];
                  } );


    

    
}


- (void) viewWillAppear:(BOOL)animated
{
    
    
    [super viewWillAppear:animated];
    
    
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    delegate.secureDelegate = self;
    
    
    
    if (segmentbtn_ContactInbox.selectedSegmentIndex==0)
    {
        messagesTB.tableFooterView.hidden=NO;
        FontLabel *tempView=(FontLabel*)[messagesTB.tableFooterView viewWithTag:1003];
        tempView.text=@"";
        [messagesTB reloadData];
    }

 
    
    self.txt_search.text=@"";
    
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
    
	
	[self searchViewAttribute];
}


- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}


- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    

}


- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


#pragma mark - Service Response

- (void)didReceivedresponse:(NSDictionary *)response
{
    [AppDel hideSpinner];
    
    if ([WebHelper sharedHelper].tag == S_OfflineChat)
    {
        
    }
}



- (void)didFailedWithError: (NSError *) error
{
    [AppDel hideSpinner];
    
    [[[UIAlertView alloc] initWithTitle:nil message:@"Unable to connect to the server, Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}







- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - IBAction

- (IBAction)navBack
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)offlineChatCompose
{
    OfflineChatViewController *offChatVC = [[OfflineChatViewController alloc] initWithNibName:@"OfflineChatViewController" bundle:nil];
    
    [self.navigationController pushViewController:offChatVC animated:YES];
}


#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(segmentbtn_ContactInbox.selectedSegmentIndex==0)
   return [ arr_R_AllArrayContactsTitle_search count];
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    
  
    
    if (segmentbtn_ContactInbox.selectedSegmentIndex==1)
    {
        id<NSFetchedResultsSectionInfo> sectionInfo = [[self.messageFetchController sections] objectAtIndex:section];
        return [sectionInfo numberOfObjects];
}
    else if (segmentbtn_ContactInbox.selectedSegmentIndex==0)
    {
     
        
        NSString *sectionTitle = [arr_R_AllArrayContactsTitle_search objectAtIndex:section];
        NSArray *contactsarr = [dict_R_AllArrayContacts_search objectForKey:sectionTitle];
        return [contactsarr count];
        
         }
    
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
	
    

    
    
    
    if(segmentbtn_ContactInbox.selectedSegmentIndex==1)
    {
        MessageInboxCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageInboxCell"];
        if (cell == nil)
        {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"MessageInboxCell" owner:self options:nil] lastObject];
            
            cell.userImg.layer.cornerRadius = 26;
            
            cell.userImg.layer.backgroundColor = [[UIColor clearColor] CGColor];
            
            [cell.userImg.layer setMasksToBounds:YES];
        }
        
        
        
        
    OfflineContact *offContact = [self.messageFetchController objectAtIndexPath:indexPath];
    
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"sentDate" ascending:YES];
    
    
    [[offContact.message sortedArrayUsingDescriptors:@[descriptor]] lastObject];
    
  
    OfflineMessages *offlineMsg = [[offContact.message sortedArrayUsingDescriptors:@[descriptor]] lastObject];
    
    NSDateFormatter *dateFomatter = [NSDateFormatter new];
    
    dateFomatter.dateFormat = @"EEE dd-MM-YY hh:mm";
    
    cell.dateLbl.text = [dateFomatter stringFromDate:offlineMsg.sentDate];

    cell.userNameLbl.text = [NSString stringWithFormat:@"%@ %@", offContact.firstName, offContact.lastName];
    
    cell.msgLbl.text = offlineMsg.messageContent;

    cell.msgCountLbl.hidden = YES;
    
    cell.msgNotifyIcon.hidden = YES;

    cell.greenNotifyIcon.hidden = YES;
    
    cell.userImg.image = [UIImage imageNamed:@"profile"];
        
        return cell;
}
    else if (segmentbtn_ContactInbox.selectedSegmentIndex==0)
    {
        static NSString *listTBID = @"LIST_TB_CELLID";
        OfflineNetworkCell *tbCell = [tableView dequeueReusableCellWithIdentifier:listTBID];
        if (tbCell == nil)
        {
            
         
            
            tbCell = [[[NSBundle mainBundle] loadNibNamed:@"OfflineNetworkCell" owner:self options:nil] lastObject];
            
            tbCell.userImg.layer.cornerRadius = 30;
            
            tbCell.userImg.layer.masksToBounds = YES;
        }
        
        
        NSString *sectionTitle = [arr_R_AllArrayContactsTitle_search objectAtIndex:indexPath.section];
        
        NSArray *sectionContact = [dict_R_AllArrayContacts_search objectForKey:sectionTitle];

        
        
        id user = [sectionContact objectAtIndex:indexPath.row];
        
        
        if([user isKindOfClass:[NSDictionary class]])
        {
            
            NSDictionary *dict=user;
            
            NSString *fir_name=@"";
            NSString *last_name=@"";
            NSString *middle_name=@"";
//            NSString *email=@"";
//            NSString *phoneNum=@"";
            
            if ( [dict valueForKey:@"kABPersonFirstNameProperty"])fir_name =[dict valueForKey:@"kABPersonFirstNameProperty"];

            if ( [dict valueForKey:@"kABPersonLastNameProperty"])
                last_name =[dict valueForKey:@"kABPersonLastNameProperty"];
//            if ( [dict valueForKey:@"kABPersonEmailProperty"])
//            {
//                email =[dict valueForKey:@"kABPersonEmailProperty"];
//            }
//            if ( [dict valueForKey:@"kABPersonPhone"])
//            {
//                 phoneNum =[dict valueForKey:@"kABPersonPhone"];
//            }
            
            
            
            tbCell.userImg.image = [UIImage imageNamed:@"profile"];
            
            tbCell.userNameLbl.text =[NSString stringWithFormat:@"%@ %@ %@ ",fir_name,middle_name, last_name];
            

            
            
        }
        return tbCell;
        
    }
    

    
    
	return nil;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (segmentbtn_ContactInbox.selectedSegmentIndex==1)
    {
    OfflineChatViewController *offlineChatVC = [[OfflineChatViewController alloc] initWithNibName:@"OfflineChatViewController" bundle:nil];
    
    OfflineContact *offContactSelected = [self.messageFetchController objectAtIndexPath:indexPath];
    
    offlineChatVC.forChat = YES;
    
    offlineChatVC.user = offContactSelected;
    
    [self.navigationController pushViewController:offlineChatVC animated:YES];
    }
    else if(segmentbtn_ContactInbox.selectedSegmentIndex==0)
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
             OfflineContactDetailsViewController*obj_OfflineContactDetails=[[OfflineContactDetailsViewController alloc] initWithNibName:@"OfflineContactDetailsViewController" bundle:nil];
            
            NSString *sectionTitle = [arr_R_AllArrayContactsTitle_search objectAtIndex:indexPath.section];
            NSArray *sectionContacts = [dict_R_AllArrayContacts_search objectForKey:sectionTitle];
            id contact = [sectionContacts objectAtIndex:indexPath.row];
            obj_OfflineContactDetails.dict_OfflineContactDetails=(NSMutableDictionary*)contact;
                [self.navigationController pushViewController:obj_OfflineContactDetails animated:YES];
        });
        
        
        
        
        
   
        
 
    }
    
}


- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if(segmentbtn_ContactInbox.selectedSegmentIndex==0)
    {
          return [arr_R_AllArrayContactsTitle_search indexOfObject:title] ;
    }
    
    return 0;
    
}
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    
    if(segmentbtn_ContactInbox.selectedSegmentIndex==0)
    {
        return arr_R_AllArrayContactsTitle_search;
        
    }
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{  if(segmentbtn_ContactInbox.selectedSegmentIndex==0)
    return [ arr_R_AllArrayContactsTitle_search  objectAtIndex:section];
    return @"";
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
	
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - Void

- (void) searchViewAttribute
{
    searchSubView.layer.cornerRadius = 5.0f;
    
    searchSubView.layer.borderWidth = 0.5f;
    
    searchSubView.layer.borderColor = [[UIColor colorWithRed:175.0/ 250.0 green:177.0/ 250.0 blue:180.0/ 250.0 alpha:1.0] CGColor];
}


#pragma mark - Fetched Results


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if (segmentbtn_ContactInbox.selectedSegmentIndex==1)
    {
         [messagesTB reloadData];
    }
    
   
}


#pragma mark - Text Field

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *search = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    
    
    if (segmentbtn_ContactInbox.selectedSegmentIndex==0)
    {
        if (search.exactLength > 0)
        {
            [self searchExternalContactWithText:search];
            FontLabel *tempView=(FontLabel*)[messagesTB.tableFooterView viewWithTag:1003];
            tempView.text=search;
        }
        else{
            FontLabel *tempView=(FontLabel*)[messagesTB.tableFooterView viewWithTag:1003];
            tempView.text=@"";
            
          
            dict_R_AllArrayContacts_search=dict_R_AllArrayContactsV;
            arr_R_AllArrayContactsTitle_search=arr_R_AllArrayContactsTitleV;
        }
        
    }
    
    if (segmentbtn_ContactInbox.selectedSegmentIndex==1)
    {
        if (search.exactLength > 0)
        {
            
            
            
            self.messageFetchController.fetchRequest.predicate = [NSPredicate predicateWithFormat:@"streamJID=%@ and messageCount>%@ and ( ANY message.messageContent contains[cd] %@ OR firstName contains[cd] %@  OR lastName contains[cd] %@ OR phoneNo contains[cd] %@ OR emailID contains[cd] %@ )", [AppDel myJID],[NSNumber numberWithInt:0],search,search,search,search,search];
        }
        
        else
        {
            self.messageFetchController.fetchRequest.predicate = [NSPredicate predicateWithFormat:@"streamJID=%@ and messageCount>%@", [AppDel myJID],[NSNumber numberWithInt:0]];
        }
        
        
        NSError *error = nil;
        
        
        [self.messageFetchController performFetch:&error];
        
        
    
        
    }
    
        [messagesTB reloadData];

    
    return YES;
}

-(void)searchExternalContactWithText:(NSString*)string
{
    
    
    
    
    

    
    dict_R_AllArrayContacts_search=[dict_R_AllArrayContacts_search searchExternalContactWithText:string contactArray:arr_records ];

    NSArray *arr_temp=[dict_R_AllArrayContacts_search allKeys];
    arr_R_AllArrayContactsTitle_search =(NSMutableArray*)[[arr_temp copy] sortedArrayUsingSelector:@selector(compare:)];

    
    

   
    
    
}



#pragma mark- Segmentbar

- (IBAction)segment_ContactInbox:(id)sender {
    UISegmentedControl *temp=(UISegmentedControl*)sender;
  
    
    self.txt_search.text=@"";
    [self.txt_search resignFirstResponder];
    if (temp.selectedSegmentIndex==0)
    {
        messagesTB.tableFooterView.hidden=NO;
        FontLabel *tempView=(FontLabel*)[messagesTB.tableFooterView viewWithTag:1003];
        tempView.text=@"";
        

         dict_R_AllArrayContacts_search=dict_R_AllArrayContactsV;
           arr_R_AllArrayContactsTitle_search=arr_R_AllArrayContactsTitleV;
    }
    else if(temp.selectedSegmentIndex==1)
    {
        
        messagesTB.tableFooterView.hidden=YES;
        FontLabel *tempView=(FontLabel*)[messagesTB.tableFooterView viewWithTag:1003];
        tempView.text=@"";
        self.messageFetchController.fetchRequest.predicate = [NSPredicate predicateWithFormat:@"streamJID=%@ and messageCount>%@", [AppDel myJID],[NSNumber numberWithInt:0]];
    NSError *error = nil;
    [self.messageFetchController performFetch:&error];
    
    }

    [messagesTB reloadData];
    
}


#pragma mark - contact 

-(void)addExistingAndPhoneContact{
    arr_records =[[NSMutableArray alloc]init];
     CFErrorRef error = nil;
    ABAddressBookRef addressBodok = ABAddressBookCreateWithOptions(nil, &error); // create address book reference object
   

    if (!addressBodok) // test the result, not the error
    {
        NSLog(@"ERROR!!!%@",error);
        return; // bail
        
   
    }
    
    
    if (addressBodok!=NULL)
    {
        NSLog(@"Have address book ");
        
       
        
        
     NSArray* arr_contactsPeople = (__bridge NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBodok);
        
    
        
       
        
        
        
        
        
        if (arr_contactsPeople)
        {
            NSInteger totalContacts =[arr_contactsPeople count];
            for(NSUInteger loop= 0 ; loop < totalContacts; loop++)
            {
                
                
                ABRecordRef person_record = (__bridge ABRecordRef)[arr_contactsPeople objectAtIndex:loop]; // get address book record
                
                
              
                
                
                if (!person_record){
                    continue;
                }
                
                
                
                NSString *firstName=(__bridge NSString *)ABRecordCopyValue(person_record, kABPersonFirstNameProperty);
                NSString *lastName=(__bridge NSString *)ABRecordCopyValue(person_record, kABPersonLastNameProperty);
                
//                ABMultiValueRef phoenes = (ABMultiValueRef)ABRecordCopyValue(record, kABPersonPhoneProperty);
                
                ABMultiValueRef arr_phoenes = (ABMultiValueRef)ABRecordCopyValue(person_record, kABPersonPhoneProperty);
                ABMutableMultiValueRef arr_emails =(ABMultiValueRef) ABRecordCopyValue(person_record, kABPersonEmailProperty);
                
                
                
           
                
                if (firstName==nil&& lastName==nil)
                {
                    continue;
                }
                
                
                NSMutableDictionary *dict_PersonLocal=[NSMutableDictionary new];
                if ( firstName)
                    [dict_PersonLocal setObject:[firstName copy] forKey:@"kABPersonFirstNameProperty"];
                else
                {[dict_PersonLocal setObject:@"" forKey:@"kABPersonFirstNameProperty"];
                    
                }
                firstName = nil;
                
                if ( lastName)
                    [dict_PersonLocal setObject:[lastName copy]forKey:@"kABPersonLastNameProperty"];
                else
                    [dict_PersonLocal setObject:@"" forKey:@"kABPersonLastNameProperty"];
                
                lastName = nil;
                NSMutableArray* arr_PhoneAndEmails=[NSMutableArray new];
                
                if (ABMultiValueGetCount(arr_phoenes) > 0  )
                {
                    for (int i=0; i < ABMultiValueGetCount(arr_phoenes); i++)
                    {
                        
                        NSString *str_PhoneNo = [[(__bridge  NSString*)ABMultiValueCopyValueAtIndex(arr_phoenes, i) componentsSeparatedByCharactersInSet:
                                                       [[NSCharacterSet characterSetWithCharactersInString:@"+0123456789"]
                                                        invertedSet]]
                                                      componentsJoinedByString:@""];
                        NSMutableDictionary *dict_PhoneAndEmails=[NSMutableDictionary new];
                        [dict_PhoneAndEmails setObject:str_PhoneNo forKey:@"kABPersonPhone"];
                        [arr_PhoneAndEmails addObject:dict_PhoneAndEmails];
                        
                    }
                }
                
                
                
                
                if ( ABMultiValueGetCount(arr_emails) > 0 )
                {
                    for (CFIndex j = 0; j < ABMultiValueGetCount(arr_emails); j++)
                    {
                        
                        NSMutableDictionary *dict_PhoneAndEmails=[NSMutableDictionary new];
                        CFStringRef emailRef = ABMultiValueCopyValueAtIndex(arr_emails, j);
                        if(emailRef)
                        {
                            [dict_PhoneAndEmails setObject:(__bridge NSString *)emailRef forKey: [NSString stringWithFormat:@"kABPersonEmailProperty" ]];
                        }
                        else{
                            [dict_PhoneAndEmails setObject:@"" forKey: [NSString stringWithFormat:@"kABPersonEmailProperty" ]];
                        }
                        
                        CFRelease(emailRef);
                        [arr_PhoneAndEmails addObject:dict_PhoneAndEmails];
                        
                    }
                }
                
                [dict_PersonLocal setObject:arr_PhoneAndEmails forKey:@"kArr_PhoneAndEmails"];
                
                if ( ABMultiValueGetCount(arr_emails) > 0 || ABMultiValueGetCount(arr_phoenes) > 0  )
                    [arr_records addObject:dict_PersonLocal];
                
                
                if (arr_phoenes) {
                 CFRelease(arr_phoenes);
                }
                if (arr_emails) {
                    CFRelease(arr_emails);
                    
                }
              
           
            }
            
            
            
            
            {
                NSManagedObjectContext *managedObjectContext = [AppDel managedObjectContext_roster];
                
                NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"OfflineContact"];
                
                NSMutableArray *orderList ;
                
                orderList =[[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
                
                
                
                if (orderList>0)
                {
                    for (OfflineContact * contact in orderList)
                    {
                        
                        NSMutableDictionary *dict_record=[NSMutableDictionary new];
                        if ( contact.firstName) [dict_record setObject:contact.firstName forKey:@"kABPersonFirstNameProperty"];
                        if ( contact.lastName) [dict_record setObject:contact.lastName forKey:@"kABPersonLastNameProperty"];
                        NSMutableArray* arr_PhoneAndEmails=[NSMutableArray new];
                        NSMutableDictionary *dict_PhoneAndEmails=[NSMutableDictionary new];
                        
                        if ( ![contact.phoneNo isEqualToString:@""])
                            [dict_PhoneAndEmails setObject:contact.phoneNo forKey:@"kABPersonPhone"];
                        if ( ![contact.emailID isEqualToString:@""])
                            [dict_PhoneAndEmails setObject:contact.emailID forKey:@"kABPersonEmailProperty"];
                        
                        [arr_PhoneAndEmails addObject:dict_PhoneAndEmails];
                        [dict_record setObject:arr_PhoneAndEmails forKey:@"kArr_PhoneAndEmails"];
                        
                        
                        
                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(kABPersonFirstNameProperty ==[cd]  %@ ) AND (kABPersonLastNameProperty ==[cd]  %@) ", [dict_record objectForKey:@"kABPersonFirstNameProperty"],[dict_record objectForKey:@"kABPersonLastNameProperty"]];
                        
                        NSArray *arr_filteredPredicate = [arr_records filteredArrayUsingPredicate:predicate];
                        if ([arr_filteredPredicate count]>0)
                        {
                            
                            NSLog(@"%@",[[arr_filteredPredicate firstObject] objectForKey:@"kArr_PhoneAndEmails"] );
                            
                        }
                        else
                        {
                            [arr_records addObject:dict_record];
                        }
                        
                        
                        
                        
                        
                        
                    }
                    
                }
                
            }
            
            
            NSSortDescriptor *firstnameDescriptor =[[NSSortDescriptor alloc]initWithKey:@"kABPersonFirstNameProperty" ascending:YES];
            NSSortDescriptor *lastnameDescriptor =[[NSSortDescriptor alloc]initWithKey:@"kABPersonLastNameProperty" ascending:YES];
            NSArray *sortDescriptors=@[firstnameDescriptor,lastnameDescriptor];
            
            if(arr_records)
            {
                arr_records=[[[arr_records copy] sortedArrayUsingDescriptors:sortDescriptors]mutableCopy];
                
                [self addExistingAndPhoneContact2];
            }
        }
        
        CFRelease(addressBodok);
        
    }
   
    
    // get address book contact array
    

   
 

 
    
}
-(void)addExistingAndPhoneContact2
{
    dict_R_AllArrayContactsV=[NSMutableDictionary new];
    dict_R_AllArrayContacts_search=[NSMutableDictionary new];
    arr_R_AllArrayContactsTitleV=[NSMutableArray new];
    arr_R_AllArrayContactsTitle_search=[NSMutableArray new];
    
    dict_R_AllArrayContactsV=[dict_R_AllArrayContactsV sortedArrayWithTitles:arr_records ];
    dict_R_AllArrayContacts_search=dict_R_AllArrayContactsV;
    
    NSArray *arr_temp=[dict_R_AllArrayContacts_search allKeys];
   
    arr_R_AllArrayContactsTitleV =(NSMutableArray*)[[arr_temp copy] sortedArrayUsingSelector:@selector(compare:)];
    arr_R_AllArrayContactsTitle_search=arr_R_AllArrayContactsTitleV;
    
    
    
}



-(void)loadPhoneContacts{
    
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    
    if (status == kABAuthorizationStatusDenied) {

        
             [self addExistingAndPhoneContact];
        return;
    }
    
    CFErrorRef error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    
    if (error) {
        NSLog(@"ABAddressBookCreateWithOptions error: %@", CFBridgingRelease(error));
        if (addressBook) CFRelease(addressBook);
        return;
    }
    
    if (status == kABAuthorizationStatusNotDetermined) {
        
        // present the user the UI that requests permission to contacts ...
        
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            if (error) {
                NSLog(@"ABAddressBookRequestAccessWithCompletion error: %@", CFBridgingRelease(error));
            }
            
            if (granted) {
             
            } else {
                // however, if they didn't give you permission, handle it gracefully, for example...
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    // BTW, this is not on the main thread, so dispatch UI updates back to the main queue
                    
                    
                    [[RDCallbackAlertView alloc] initWithTitle:nil message:@"This app requires access to your contacts to function properly. Please visit to the \"Privacy\" section in the iPhone Settings app." cancelButtonTitle:nil andCompletionHandler:^(int btnIndex)
                     
                     {
                         [self addExistingAndPhoneContact];
                         
                     } otherButtonTitles:@"OK", nil];
                    
                });
            }
            
            if (addressBook) CFRelease(addressBook);
        });
        
    } else if (status == kABAuthorizationStatusAuthorized) {
        if (addressBook) CFRelease(addressBook);
    }
}

#pragma mark- Add Contact
-(void)addContact:(id)sender
{
    UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Create a new contact. " message:@"Please add the detail ." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"Save",nil];
    myAlertView.tag = 5;
  
    
    view_addContact=nil;
    view_addContact = [[UIView alloc] initWithFrame:CGRectMake(10, 0, 300,100)];
    

    UITextField *firstName = [[UITextField alloc]initWithFrame:CGRectMake(10, 0, 250, 20)];
    firstName.placeholder=@"Receiver's First Name";
    firstName.tag=1;
    firstName.delegate=self;
    
    firstName.returnKeyType=UIReturnKeyDone;
    firstName.keyboardType = UIKeyboardTypeDefault;
    firstName.clearButtonMode = UITextFieldViewModeAlways;
    [view_addContact addSubview:firstName];
    
    UITextField *lastName =  [[UITextField alloc]initWithFrame:CGRectMake(10, 30,250, 20)];
    lastName.placeholder=@"Receiver's Last Name";
    lastName.tag=2;
    lastName.delegate=self;
    
    lastName.returnKeyType=UIReturnKeyDone;
    lastName.clearButtonMode = UITextFieldViewModeAlways;
    lastName.keyboardType = UIKeyboardTypeDefault;
    [view_addContact addSubview:lastName];
    
    
    
    UITextField *email =  [[UITextField alloc]initWithFrame:CGRectMake(10, 60, 250, 20)];
    email.tag=3;
    email.returnKeyType=UIReturnKeyDone;
    email.clearButtonMode = UITextFieldViewModeAlways;
    email.placeholder=@"Email Id Or Phone number ";
    email.delegate=self;
    email.keyboardType = UIKeyboardTypeEmailAddress;
    [view_addContact addSubview:email];
    
    
    FontLabel *tempView=(FontLabel*)[messagesTB.tableFooterView viewWithTag:1003];
    
    BOOL valid;
    NSCharacterSet *alphaNums = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:tempView.text];
    valid = [alphaNums isSupersetOfSet:inStringSet];
    
    
    
    
    
    
    
    if (valid)
    {
        email.text=tempView.text;
    }
    else if ([self ValidateEmail:tempView.text ])
    {
        email.text=tempView.text;
    }
    
    else if ([tempView.text rangeOfString:@"@"].location == NSNotFound)
    {
        firstName.text=tempView.text;
    }
    else
    { email.text=tempView.text;
        
    }
    
    
    
    [myAlertView setValue:view_addContact forKey:@"accessoryView"];
    
    
    CGAffineTransform moveUp = CGAffineTransformMakeTranslation(0.0, 0.0);
    [myAlertView setTransform: moveUp];
    [myAlertView show];
    
}
-(void)addContactWithFirstName:(NSString*)firstName1 lastName:(NSString*)lastname1 emailID:(NSString*)email1
{
    
    UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Create a new contact. " message:@"Please add the detail ." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"Save",nil];
    
    
    myAlertView.tag = 5;
    
    view_addContact=nil;
    view_addContact = [[UIView alloc] initWithFrame:CGRectMake(10, 0, 300,100)];
    
    UITextField *firstName = [[UITextField alloc]initWithFrame:CGRectMake(10, 0, 250, 20)];
    firstName.placeholder=@" Receiver's First Name";
    firstName.tag=1;
    firstName.delegate=self;
    firstName.text=firstName1;
    firstName.returnKeyType=UIReturnKeyDone;
    firstName.keyboardType = UIKeyboardTypeDefault;
    firstName.clearButtonMode = UITextFieldViewModeAlways;
    [view_addContact addSubview:firstName];
    
    UITextField *lastName =  [[UITextField alloc]initWithFrame:CGRectMake(10, 30,250, 20)];
    lastName.placeholder=@"Receiver's Last Name";
    lastName.tag=2;
    lastName.delegate=self;
    lastName.text=lastname1;
    lastName.returnKeyType=UIReturnKeyDone;
    lastName.clearButtonMode = UITextFieldViewModeAlways;
    lastName.keyboardType = UIKeyboardTypeDefault;
    [view_addContact addSubview:lastName];
    
    
    UITextField *email =  [[UITextField alloc]initWithFrame:CGRectMake(10, 60, 250, 20)];
    email.tag=3;
    email.delegate=self;
    
    email.clearButtonMode = UITextFieldViewModeAlways;
    email.placeholder=@"Email Id Or Phone number";
    email.text=email1;
    email.keyboardType = UIKeyboardTypeEmailAddress;
    [view_addContact addSubview:email];
    
    
    
    
    
    [myAlertView setValue:view_addContact forKey:@"accessoryView"];
    
    
    CGAffineTransform moveUp = CGAffineTransformMakeTranslation(0.0, 0.0);
    [myAlertView setTransform: moveUp];
    [myAlertView show];
    
    
    
    
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    
    if (alertView.tag==5) {
        if(alertView.cancelButtonIndex == buttonIndex)
        {
            UITextField *firstName=(UITextField*)[view_addContact viewWithTag:1];
            UITextField *lastName=(UITextField*)[view_addContact viewWithTag:2];
            UITextField *email=(UITextField*)[view_addContact viewWithTag:3];
            
            [firstName resignFirstResponder];
            [lastName resignFirstResponder];
            [email resignFirstResponder];
            
        }
        else{
            UITextField *firstName=(UITextField*)[view_addContact viewWithTag:1];
            UITextField *lastName=(UITextField*)[view_addContact viewWithTag:2];
            UITextField *email=(UITextField*)[view_addContact viewWithTag:3];
            
            
            [firstName resignFirstResponder];
            [lastName resignFirstResponder];
            [email resignFirstResponder];
            
            
            if (![self validateFirstName:firstName.text])
            {
                
                [self addContactWithFirstName: @"" lastName:lastName.text emailID:email.text ];
                
                [[[UIAlertView alloc]initWithTitle:nil message:@"Enter First Name." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil]show];
                return;
            }
            if (![self validateLastName:lastName.text ])
            {
                [self addContactWithFirstName: firstName.text lastName:@"" emailID:email.text ];
                [[[UIAlertView alloc]initWithTitle:nil message:@"Enter Last Name." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil]show];
                return;
            }
            
            {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(kABPersonFirstNameProperty ==[cd]  %@ ) AND (kABPersonLastNameProperty ==[cd]  %@) ",firstName.text,lastName.text];
                
                NSArray *arr_filteredPredicate = [arr_records filteredArrayUsingPredicate:predicate];
                if ([arr_filteredPredicate count]>0)
                {
                [self addContactWithFirstName: firstName.text lastName:@"" emailID:email.text ];
                      [[[UIAlertView alloc]initWithTitle:nil message:@"First name And Last name already exist. " delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil]show];
                    return;
                    
                }
               
            }
            

            
            //
            //
            if (email.text.length>0)
            {
                NSCharacterSet* notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
                if ([email.text rangeOfCharacterFromSet:notDigits].location == NSNotFound)
                {
                    // newString consists only of the digits 0 through 9
                    if(![self validatePhoneNumber:email.text])
                    {
                        [self addContactWithFirstName: firstName.text lastName:lastName.text emailID:@"" ];
                        
                        [[[UIAlertView alloc]initWithTitle:nil message:@"Enter 10 digit  phone number. " delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil]show];
                        return;
                    }
                    
                }
                else{
                    if (![self ValidateEmail:email.text ])
                    {
                        [self addContactWithFirstName: firstName.text lastName:lastName.text emailID:@"" ];
                        [[[UIAlertView alloc]initWithTitle:nil message:@"Enter correct email Id." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil]show];
                        return;
                    }
                }
                
                
            }
            
            if((email.text.length>0||[self ValidateEmail:email.text ]))
            {
                NSLog(@"%@ %@ %@ ",firstName.text,lastName.text,email.text);
                
                
                dispatch_async(dispatch_get_main_queue(), ^
                               {
                                   NSLog(@"here .....dispatch_async");
                                   
                                   
                                   NSString *firstNametxt = [firstName text];
                                   NSString *firstName_capitalized = [[[firstNametxt substringToIndex:1] uppercaseString] stringByAppendingString:[firstNametxt substringFromIndex:1]];
                                   
                                   
                                   NSString *lastNametxt = [lastName text];
                                   NSString *lastName_capitalized = [[[lastNametxt substringToIndex:1] uppercaseString] stringByAppendingString:[lastNametxt substringFromIndex:1]];
                                   
                                   
                                   OfflineContact * user_Offline;
                                   
                                   NSCharacterSet* notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
                                   if ([email.text rangeOfCharacterFromSet:notDigits].location == NSNotFound)
                                   {
                                    user_Offline=[AppDel fetchInsertExternamContact:[AppDel myJID] phoneNo: email.text email:nil firstName:firstName_capitalized lastName:lastName_capitalized];
                                   }
                                   else{
                                   user_Offline=[AppDel fetchInsertExternamContact:[AppDel myJID] phoneNo: nil email:email.text
                                                                         firstName:firstName_capitalized lastName:lastName_capitalized];
                                   }
                                   dispatch_async(dispatch_get_main_queue(), ^
                                                  {
                                                      OfflineChatViewController *offlineChatVC = [[OfflineChatViewController alloc] initWithNibName:@"OfflineChatViewController" bundle:nil];
                                                      offlineChatVC.forChat = YES;
                                                      
                                                      NSLog(@"here .....dispatch_async");
                                                      
                                                      
                                                      
                                                      
                                                      offlineChatVC.user = user_Offline;
                                                      [self.navigationController pushViewController:offlineChatVC animated:YES];
                                                      [self addExistingAndPhoneContact];
                                                      [messagesTB reloadData];
                                                      
                                                  });
                                   

                                
                                   
           
                               });
                
                
            }
            else{
                [self addContactWithFirstName: firstName.text lastName:lastName.text emailID:@"" ];
                
                [[[UIAlertView alloc]initWithTitle:nil message:@"Enter email id or phone number. " delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil]show];
            }
            
        }
    }
    
    
    
    
    
    
    
    
}
-(BOOL)validateFirstName:(NSString*)firstName
{
    
    if(firstName.length>0)
        return YES;
    return NO;
}

-(BOOL)validateLastName:(NSString*)lastName
{
    if(lastName.length>0)
        return YES;
    return NO;
}
-(BOOL)validatePhoneNumber:(NSString*)phone
{
    
    NSString *numberRegEx = @"[0-9]{10}";
    NSPredicate *numberTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", numberRegEx];
    if ([numberTest evaluateWithObject:phone] == YES)
        return TRUE;
    else
        return FALSE;
    return YES;
}


-(BOOL)ValidateEmail:(NSString*)email
{
    
    BOOL stricterFilter = NO;
  
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:email];
    
    return YES;
    
}
@end

