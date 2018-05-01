//
//  OfflineContactDetailsViewController.h
//  IMYourDoc
//
//  Created by OSX on 30/06/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "OfflineContactDetailCell.h"
#import  "OfflineChatViewController.h"

@interface OfflineContactDetailsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    IBOutlet UILabel *usernameL;
    
    IBOutlet UITableView *detailTB;
}

@property(nonatomic,strong)NSMutableDictionary *dict_OfflineContactDetails;

@end
