//
//  ReadByViewController.h
//  IMYourDoc
//
//  Created by Harminder on 02/04/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import <UIKit/UIKit.h>

#import "FontLabel.h"
#import "AppDelegate.h"


@interface ReadByViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet FontLabel *secureL;
    
    IBOutlet UIImageView *secureIcon;
    
    IBOutlet UITableView *readbyTable;
}


@property (nonatomic, strong) NSArray *users;

@property (nonatomic, strong) ChatMessage *msg;

@property (nonatomic,strong) NSFetchedResultsController * fetch_request_controller;


@end

