//
//  BlockedDevicesViewController.h
//  IMYourDoc
//
//  Created by Manpreet on 05/02/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import <UIKit/UIKit.h>

#import "XMLParser.h"
#import "AppDelegate.h"


@interface BlockedDevicesViewController : UIViewController <XmlParserProtocolDelegate, UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, WebHelperDelegate>
{
    IBOutlet UITableView *blockedTable;
    
    IBOutlet UILabel *titleL;
}


@property (nonatomic, strong) NSMutableArray *blockedArr, *selectedDevice;

//@property (nonatomic, strong) NSMutableDictionary *selectedDevice;


- (void)blockDeviceFetch;


- (IBAction)backTap;


@end

