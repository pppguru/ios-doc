//
//  GroupMembersViewController.h
//  IMYourDoc
//
//  Created by Nipun on 20/01/15.
//
//


#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "FontLabel.h"
#import "AppDelegate.h"


@interface GroupMembersViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchDisplayDelegate, NSFetchedResultsControllerDelegate,WebHelperDelegate>
{
    IBOutlet FontLabel *secureL;
    
    IBOutlet UILabel *titleL;
    
    IBOutlet UIButton *addSrchBarBtn;
    
    IBOutlet UIImageView *addIcon, *secureIcon;
    
    IBOutlet NSLayoutConstraint *TBVertSpaceConstraint;
}


@property (nonatomic, strong) XMPPRoom *xmppRoom;

@property (nonatomic, strong) XMPPRoomObject *roomObj;

@property (nonatomic, strong) NSFetchedResultsController *fetchController;


@property (nonatomic, strong) IBOutlet UISearchBar *searchbar;

@property (nonatomic, strong) IBOutlet UITableView *userTableView;


- (IBAction)addSearchBar;


@end

