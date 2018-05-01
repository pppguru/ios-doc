//
//  MessageRingtoneViewController.h
//  IMYourDoc
//
//  Created by Sarvjeet on 23/02/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import <UIKit/UIKit.h>

#import "FontLabel.h"
#import "AppDelegate.h"


@interface MessageRingtoneViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *ringtonesArr;
 
    IBOutlet UILabel *titleL;
    
    IBOutlet FontLabel *secureL;
    
    IBOutlet UIImageView *secureIcon;
    
    IBOutlet UITableView *ringtonesTB;
}


@end

