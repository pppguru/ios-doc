//
//  TableDefault.m
//  IMYourDoc
//
//  Created by OSX on 25/08/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import "TableDefault.h"


@implementation TableDefault

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 0;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    GroupListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GroupListCell"];

    
    if (cell == nil)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"GroupListCell" owner:self options:nil] lastObject];
        
        cell.userIMGV.layer.cornerRadius = 26;
        
        cell.userIMGV.layer.backgroundColor = [[UIColor clearColor] CGColor];
        
        [cell.userIMGV.layer setMasksToBounds:YES];
    }
    

    

    
    return cell;
}


@end
