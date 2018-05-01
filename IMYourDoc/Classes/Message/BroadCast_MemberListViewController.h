//
//  BroadCast_MemberListViewController.h
//  IMYourDoc
//
//  Created by OSX on 17/07/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import "ImYouDocViewController.h"

#import "Broadcast_ContactListCell.h"

 #import "BroadCastGroup.h"
@interface BroadCast_MemberListViewController : ImYouDocViewController<UISearchDisplayDelegate>
{
    // •••••• TableviewContainer
    IBOutlet UISearchBar *searchbarTxtfld;
    IBOutlet UITableView *tableview_memberLst;
}

@property (nonatomic,retain) BroadCastGroup *currnetGroup;
@property (strong, nonatomic) IBOutlet UISearchDisplayController *searchBarController;

@end
