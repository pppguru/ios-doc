//
//  MessageRingtoneViewController.m
//  IMYourDoc
//
//  Created by Sarvjeet on 23/02/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import "MessageRingtoneViewController.h"


@interface MessageRingtoneViewController (){
    NSInteger nSelectedIndex;
}


@end


@implementation MessageRingtoneViewController


#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    nSelectedIndex = 0;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    
    [self setRequiredFont1];
    
    ringtonesArr = [[NSMutableArray alloc] initWithObjects:@"Ripple", @"Tample", @"Echobel", @"Diamond", @"Soft", @"Gling", nil];
    
    //Get the current selected audio index
    NSString *strCurrentAlertSoundName = [[NSUserDefaults standardUserDefaults] objectForKey:@"Sound"];
    if (strCurrentAlertSoundName && strCurrentAlertSoundName.length > 0) {
        nSelectedIndex = [ringtonesArr indexOfObject:strCurrentAlertSoundName];
    }
    
    //Update the internet connection status view
    if ([AppDel isConnected])
    {
        secureL.text = @"Securely Connected";
        
        secureIcon.image = [UIImage imageNamed:@"secure_icon"];
    }
    
    else
    {
        secureL.text = @"Not Connected";
        
        secureIcon.image = [UIImage imageNamed:@"unsecure_icon"];
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateConnectivity:) name:XMPPREACHABILITY object:nil];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    [self setRequiredFont1];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - Table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [ringtonesArr count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CellID";
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        cell.textLabel.font = [UIFont fontWithName:@"CentraleSansRndLight" size:cell.textLabel.font.pointSize];
    }
    
    
    cell.textLabel.text = [ringtonesArr objectAtIndex:indexPath.row];
    
    if (nSelectedIndex == indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    
    
    
    
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[NSUserDefaults standardUserDefaults]setObject:[ringtonesArr objectAtIndex:indexPath.row] forKey:@"Sound"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    [AppDel playSoundForKey];
    
    
    [self.navigationController popViewControllerAnimated:YES];
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];;
}


#pragma mark - update Connectivity

- (void) updateConnectivity:(NSNotification *)note
{
    NSDictionary *dict = note.object;
    
    
    secureL.text = [dict objectForKey:@"status"];
    
    
    [secureIcon setImage:[UIImage imageNamed:[dict objectForKey:@"image"]]];
}


#pragma mark - Set required font

- (void)setRequiredFont1
{
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [titleL setFont:[UIFont fontWithName:@"CentraleSansRndMedium" size:25.00]];
    }
    else
    {
        [titleL setFont:[UIFont fontWithName:@"CentraleSansRndMedium" size:20.00]];
    }
}


@end

