//
//  RegisteredDevicesViewController.h
//  IMYourDoc
//
//  Created by Manpreet on 05/02/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import <UIKit/UIKit.h>

#import "AppDelegate.h"


@interface RegisteredDevicesViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, WebHelperDelegate>
{
    IBOutlet UILabel *titleL;
    
    IBOutlet UITableView *registeredTable;
}


@property (nonatomic, strong) NSMutableArray *registeredArr;


- (void)fetchRegisteredDeviceApi;


- (IBAction)backTap;


@end

