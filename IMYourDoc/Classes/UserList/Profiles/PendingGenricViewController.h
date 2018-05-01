//
//  PendingGenricViewController.h
//  IMYourDoc
//
//  Created by OSX on 02/09/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import "ImYouDocViewController.h"
#import <MessageUI/MessageUI.h>
#import "HospitalListCell.h"

@interface PendingGenricViewController : ImYouDocViewController<MFMailComposeViewControllerDelegate,UITableViewDataSource, UITableViewDelegate>
{
     IBOutlet FontBoldLabel *lbl_nameDes;
    
    __weak IBOutlet FontLabel *lbl_jobProfile;
    
    __weak IBOutlet FontLabel *lbl_userName;
    
    __weak IBOutlet FontLabel *lbl_practiceType;
    
    
    __weak IBOutlet FontLabel *lbl_HospitalNetwork;
    
    IBOutlet SimpleFontButton *mailBtn, *phoneBtn;
      IBOutlet UITableView *hospListTB;
    
}
/**
 * This is response of tableview cell did selected here . it get dictionary from services response.
 *
 * @param :  flagged = 1
 * @param : status = ask
 * @param : type = Free
 * @param : "user_name" = kiranstaff
  * @param : "user_type" = Staff
 * @see : 
 * @
 */

@property (nonatomic, strong) NSMutableDictionary *dict_passingArumentsOfUser;


//practiceLbl.text = [self.profileDict valueForKey:@"practice_type"];
//
//hospitalLbl.text = [self.profileDict valueForKey:@"primary_hospital"];
/**
 * This is response of  we get from  method -> getUserProfileOther
 *
 * @param   designation = "";
  * @param   email = "vijayvir@imyourdoc.com";
  * @param  "err-code" = 1;
 * @param   "job_title" = "";
  * @param   message = "User profile data.";
  * @param   name = "kiranstaff kiran";
 * @param    "other_hospitals" =     (
 * @param    );
  * @param   phone = 1234567895;
  * @param   "pic_no" = Staff5917;
  * @param   pin = 1234;
  * @param   "practice_type" = "Home Health";
 * @param    "primary_hosp_id" = 90335;
  * @param   "primary_hospital" = "Asa A Spiritual Abode Detox & Residential Treatmnt";
 * @param    "privacy_enabled" = 0;
  * @param   "request_already_sent" = 0;
  * @param   "seq_ans" = asd;
  * @param   "seq_ques" = asd;
  * @param   session = 0;
  * @param   type = Staff;
 * @param   "user_name" = kiranstaff;
 * @param    zip = 123456;@
 */
@property (nonatomic, strong) NSMutableDictionary *dict_profile;

- (IBAction)mailTap;
- (IBAction)phoneTap;
- (IBAction)action_acceptTap;
- (IBAction)action_DeclineTap;
- (IBAction)action_FlagTap;



@end
