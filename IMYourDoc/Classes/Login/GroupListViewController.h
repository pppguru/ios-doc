//
//  GroupListViewController.h
//  IMYourDoc
//
//  Created by OSX on 25/08/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import "ImYouDocViewController.h"
#import "TableDefault.h"
@interface GroupListViewController : ImYouDocViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
{
    
}

@property (strong, nonatomic) IBOutlet FontTextField *txt_search;

@property (strong, nonatomic) IBOutlet TableDefault *tableview_groupList;
@property (nonatomic, strong) NSFetchedResultsController *fetchController_GroupList;


@end
