//
//  GroupMemberCell.h
//  IMYourDoc
//
//  Created by Sarvjeet on 10/02/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import <UIKit/UIKit.h>

#import "FontLabel.h"
#import "XMPPRoomAffaliations.h"


@interface GroupMemberCell : UITableViewCell
{
    
}


@property (nonatomic, strong) XMPPRoomAffaliations *user;

@property (nonatomic, strong) IBOutlet UIButton *crossBtn;

@property (nonatomic, strong) IBOutlet UIImageView *userImg;

@property (nonatomic, strong) IBOutlet FontLabel *userNameL, *adminL;


@end

