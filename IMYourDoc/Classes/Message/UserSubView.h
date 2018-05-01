//
//  UserSubView.h
//  IMYourDoc
//
//  Created by Harminder on 09/02/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import <UIKit/UIKit.h>

#import "AppDelegate.h"


@interface UserSubView : UIControl
{
    
}


@property (nonatomic, strong) IBOutlet UILabel *nameLB;

@property (nonatomic, strong) IBOutlet UIButton *actionBtn;

@property (nonatomic, strong) IBOutlet UIImageView *profileImage;

@property (nonatomic, strong) XMPPUserCoreDataStorageObject *user;


@end

