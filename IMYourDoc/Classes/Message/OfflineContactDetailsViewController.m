//
//  OfflineContactDetailsViewController.m
//  IMYourDoc
//
//  Created by OSX on 30/06/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import "OfflineContactDetailsViewController.h"

@interface OfflineContactDetailsViewController (){
    
    NSMutableArray *arr_Phone;
    NSMutableArray *arr_email;
}

@end

@implementation OfflineContactDetailsViewController
@synthesize dict_OfflineContactDetails;

- (void)viewDidLoad {
    [super viewDidLoad];
    
 
    [self setArrayOfPhoneAndEmail];

    
    
    
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    [self setIntialCondition];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
    // Dispose of any resources that can be recreated.
}
#pragma mark - helper method

-(void)setArrayOfPhoneAndEmail
{
    arr_email=[NSMutableArray new];
    arr_Phone=[NSMutableArray new];
    NSMutableArray *arr_PhoneAndEmails;
    arr_PhoneAndEmails=(NSMutableArray*)[dict_OfflineContactDetails objectForKey:@"kArr_PhoneAndEmails"];
    if ([arr_PhoneAndEmails count]>0)
    {
        for(NSMutableDictionary * dict_PhoneAndEmails in arr_PhoneAndEmails)
        {
            
            
            if([[[dict_PhoneAndEmails allKeys]lastObject]isEqualToString:@"kABPersonPhone"])
            {
                [arr_Phone addObject:[dict_PhoneAndEmails objectForKey:@"kABPersonPhone"]];
            }
            else  if([[[dict_PhoneAndEmails allKeys]lastObject]isEqualToString:@"kABPersonEmailProperty"])
            {
                [arr_email addObject:[dict_PhoneAndEmails objectForKey:@"kABPersonEmailProperty"]];
            }
        }
        
    }
    
    [detailTB reloadData];
    
    
}
-(void)setIntialCondition{
    NSString *fir_name=@"";
    NSString *last_name=@"";
    NSString *middle_name=@"";
    
    if ( [dict_OfflineContactDetails valueForKey:@"kABPersonFirstNameProperty"])fir_name =[dict_OfflineContactDetails valueForKey:@"kABPersonFirstNameProperty"];
    if ( [dict_OfflineContactDetails valueForKey:@"kABPersonMiddleNameProperty"])middle_name =[dict_OfflineContactDetails valueForKey:@"kABPersonMiddleNameProperty"];
    if ( [dict_OfflineContactDetails valueForKey:@"kABPersonLastNameProperty"])last_name =[dict_OfflineContactDetails valueForKey:@"kABPersonLastNameProperty"];
    usernameL.text=[NSString stringWithFormat:@"%@ %@ %@ ",fir_name,middle_name,last_name];
}
#pragma mark - tableviewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([arr_Phone count]>0&&[arr_email count]>0)
    {
        return 2;
    }
    
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 65;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    if([arr_Phone count]>0&&[arr_email count]>0)
    {
        if (section==0)
        {
            return   @"Phone";
        }
        else if (section==1){
            return   @"Email";
        }
        
    }
    else  if([arr_Phone count]>0)
    {
        return @"Phone";
    }
    else  if([arr_email count]>0)
    {
        return  @"Email";
    }
    
    
    
    return @"";
    
    
    
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   
    if([arr_Phone count]>0&&[arr_email count]>0)
    {
        if (section==0)
        {
         return   [arr_Phone count];
        }
        else if (section==1){
                return   [arr_email count];
        }
        
    }
    else  if([arr_Phone count]>0)
    {
        return [arr_Phone count];
    }
    else  if([arr_email count]>0)
    {
        return [arr_email count];
    }
    
    
    return 0;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *listTBID = @"LIST_TB_CELLID";
    OfflineContactDetailCell *tbCell = [tableView dequeueReusableCellWithIdentifier:listTBID];
    if (tbCell == nil)
    {
        tbCell = [[[NSBundle mainBundle] loadNibNamed:@"OfflineContactDetailCell" owner:self options:nil] lastObject];
    }
    
    
    if([arr_Phone count]>0&&[arr_email count]>0)
    {
        if (indexPath.section==0)
        {
             tbCell.detailL.text=[arr_Phone objectAtIndex:indexPath.row];
        }
        else if (indexPath.section==1){
           tbCell.detailL.text=[arr_email objectAtIndex:indexPath.row];
        }
        
    }
    else  if([arr_Phone count]>0)
    {
       tbCell.detailL.text=[arr_Phone objectAtIndex:indexPath.row];
    }
    else  if([arr_email count]>0)
    {
         tbCell.detailL.text=[arr_email objectAtIndex:indexPath.row];
    }


    [tbCell.btn_nav addTarget:self action:@selector(action_btn_nav:) forControlEvents:UIControlEventTouchUpInside];
    return tbCell;
}
-(void )action_btn_nav:(UIButton *)sender
{
    
    OfflineContactDetailCell *cell = (OfflineContactDetailCell *)[[sender.superview superview] superview];
    NSIndexPath *indexPath = [detailTB indexPathForCell:cell];
    [self tableView:detailTB didSelectRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{


    {
        dispatch_async(dispatch_get_main_queue(), ^
                       {

                           if([arr_Phone count]>0&&[arr_email count]>0)
                           {
                               if (indexPath.section==0)
                               {
                                   
        
                                   
                                   OfflineChatViewController *offlineChatVC = [[OfflineChatViewController alloc] initWithNibName:@"OfflineChatViewController" bundle:nil];
                                   offlineChatVC.forChat = YES;
                                   OfflineContact * user=[AppDel fetchInsertExternamContact:
                                                          [AppDel myJID]
                                                                                    phoneNo: [arr_Phone objectAtIndex:indexPath.row]
                                                                                      email:@""
                                                                                  firstName:[dict_OfflineContactDetails valueForKey:@"kABPersonFirstNameProperty"]
                                                                                   lastName:[dict_OfflineContactDetails valueForKey:@"kABPersonLastNameProperty"]];
                                   
                                   offlineChatVC.user = user;
                                   [self.navigationController pushViewController:offlineChatVC animated:YES];
                                   
                                   
                                   
                               }
                               else if (indexPath.section==1)
                               {
                                   
                                   OfflineChatViewController *offlineChatVC = [[OfflineChatViewController alloc] initWithNibName:@"OfflineChatViewController" bundle:nil];
                                   offlineChatVC.forChat = YES;
                                   OfflineContact * user=[AppDel fetchInsertExternamContact:
                                                          [AppDel myJID]
                                                                                    phoneNo:@""
                                                                                      email:[arr_email objectAtIndex:indexPath.row]
                                                                                  firstName:[dict_OfflineContactDetails valueForKey:@"kABPersonFirstNameProperty"]
                                                                                   lastName:[dict_OfflineContactDetails valueForKey:@"kABPersonLastNameProperty"]];
                                   
                                   offlineChatVC.user = user;
                                   [self.navigationController pushViewController:offlineChatVC animated:YES];
                                   
                                   
                               }
                               
                           }
                           else  if([arr_Phone count]>0)
                           {
                               OfflineChatViewController *offlineChatVC = [[OfflineChatViewController alloc] initWithNibName:@"OfflineChatViewController" bundle:nil];
                               offlineChatVC.forChat = YES;
                               OfflineContact * user=[AppDel fetchInsertExternamContact:
                                                      [AppDel myJID]
                                                                                phoneNo:[arr_Phone objectAtIndex:indexPath.row]
                                                                                  email:@""
                                                                              firstName:[dict_OfflineContactDetails valueForKey:@"kABPersonFirstNameProperty"]
                                                                               lastName:[dict_OfflineContactDetails valueForKey:@"kABPersonLastNameProperty"]];
                               
                               offlineChatVC.user = user;
                               [self.navigationController pushViewController:offlineChatVC animated:YES];
                           }
                           else  if([arr_email count]>0)
                           {
                               OfflineChatViewController *offlineChatVC = [[OfflineChatViewController alloc] initWithNibName:@"OfflineChatViewController" bundle:nil];
                               offlineChatVC.forChat = YES;
                               OfflineContact * user=[AppDel fetchInsertExternamContact:
                                                      [AppDel myJID]
                                                                                phoneNo:@""
                                                                                  email:[arr_email objectAtIndex:indexPath.row]
                                                                              firstName:[dict_OfflineContactDetails valueForKey:@"kABPersonFirstNameProperty"]
                                                                               lastName:[dict_OfflineContactDetails valueForKey:@"kABPersonLastNameProperty"]];
                               
                               offlineChatVC.user = user;
                               [self.navigationController pushViewController:offlineChatVC animated:YES];
                           }
                           
                           
                          
                    
                            
                   
                       });
        
        
        
        
        
        
        
        
    }
    
}




@end
