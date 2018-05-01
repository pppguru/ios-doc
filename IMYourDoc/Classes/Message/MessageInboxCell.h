//
//  InboxMessageCell.h
//  IMYourDoc
//
//  Created by Sarvjeet on 22/01/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import <UIKit/UIKit.h>

#import "FontLabel.h"
#import "FontHeaderLabel.h"


@interface MessageInboxCell : UITableViewCell
{
    
}


@property (strong, nonatomic) IBOutlet UIImageView *userImg, *greenNotifyIcon, *msgNotifyIcon;

@property (strong, nonatomic) IBOutlet FontLabel *userNameLbl, *msgLbl, *dateLbl, *msgCountLbl;



@end

