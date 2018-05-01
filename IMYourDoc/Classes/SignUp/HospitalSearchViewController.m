//
//  HospitalSearchViewController.m
//  IMYourDoc
//
//  Created by Harminder on 03/02/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import "HospitalSearchViewController.h"
#import "UserAffiliationViewController.h"


@interface HospitalSearchViewController () <UserAffiliationViewControllerDelegate>


@end


@implementation HospitalSearchViewController


#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.selectedArray = [[NSMutableArray alloc] init];
    
    
    self.searchedArray = [[NSMutableArray alloc] init];
    
    
    if ([self.delegate respondsToSelector:@selector(selectedHospitals:)])
    {
        self.selectedArray = [self.delegate selectedHospitals:self];
        
        
        [hosptableView reloadData];
    }
}
-(void)addNetworkMethod{
    if (addNetwork)
    {
        addNetwork = NO;
        
        [self.delegate HospitalController:self selectedHosptials:self.selectedArray];
        
        
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    
    [self setRequiredFont2];
    
    
    if (self.fromSearch)
    {
        addNetworkIconWConst.constant = 0.00;
    }
    
    
    if (self.hospitalSelectionMode == HospitalSelectionModeSingle)
    {
        searchInstructionL.text = @"Enter your primary hospital or clinic. Can't find it? Tap the Add Network Button.";
    }
    else
    {
        searchInstructionL.text = @"You can add multiple affiliations in secondary network. Can't find it? Tap the Add Network Button.";
    }
    
    
    
    self.navigationController.navigationBarHidden = YES;
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    [self setRequiredFont2];
    
    if (self.hospitalSelectionMode == HospitalSelectionModeSingle)
    {
        tickBtn.hidden = YES;
        
        searchInstructionL.text = @"Enter your primary hospital or clinic. Can't find it? Tap the Add Network Button.";
        
        if (addNetwork)
        {
            addNetwork = NO;
            
            [self.delegate HospitalController:self selectedHosptials:self.selectedArray];
            
            
            
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    }
    else
    {
        

    }
    

}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    
    self.navigationController.navigationBarHidden = YES;
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView != hosptableView)
    {
        return self.searchedArray.count;
    }
    
    
    return self.selectedArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"tableCell";
    
    
    if (tableView != hosptableView)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        
        
        NSDictionary *hosp = [self.searchedArray objectAtIndex:indexPath.row];
        
        
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
        }
        
        
        cell.textLabel.text = [hosp objectForKey:@"name"];
        
        cell.detailTextLabel.text = [hosp objectForKey:@"city"];
        
        
        return cell;
    }
    
    else
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        
        
        NSDictionary *hosp = [self.selectedArray objectAtIndex:indexPath.row];
        
        
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
        }
        
        
       cell.textLabel.text = [hosp objectForKey:@"name"];
        
       cell.detailTextLabel.text = [hosp objectForKey:@"city"];

        
        
        return cell;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView != hosptableView)
    {
        if (self.hospitalSelectionMode == HospitalSelectionModeSingle)
        {
            [self.selectedArray removeAllObjects];
        }
        
        
        [self.selectedArray addObject:[self.searchedArray objectAtIndex:indexPath.row]];
        
        
        [hosptableView reloadData];
        
        
        [self.searchDisplayController setActive:NO animated:YES];
        
        if (self.hospitalSelectionMode == HospitalSelectionModeSingle)
        {
            [self.delegate HospitalController:self selectedHosptials:self.selectedArray];
            
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView != hosptableView)
    {
        return NO;
    }
    
    
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == hosptableView)
    {
        if (editingStyle == UITableViewCellEditingStyleDelete)
        {
            [self.selectedArray removeObjectAtIndex:indexPath.row];
            
            
            [tableView reloadData];
        }
    }
}


#pragma mark - UISearchDisplayController

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    if (searchString.length > 1)
    {
        [self search:searchString];
    }
    
    
    return YES;
}


#pragma mark - Added Hosp

- (void)AffliationController:(UserAffiliationViewController *)controller addedHosptial:(NSDictionary *)addedHosp
{
    
    if (addedHosp) {
        if (self.hospitalSelectionMode == HospitalSelectionModeSingle)
        {
            [self.selectedArray removeAllObjects];
        }
        
        [self.selectedArray addObject:addedHosp];
        
        
        [hosptableView reloadData];
    }
    }
 


#pragma mark - Void

- (void)search:(NSString *)text
{
    if ([AppDel appIsDisconnected])
    {
        [AppData showAlertWithTitle:nil andMessage:@"No Connection." inVC:self];
    }
    
    else
    {
         NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"hospitalsList", @"method", text, @"name", nil];
     
        [[WebHelper sharedHelper] setWebHelperDelegate:self];
        
        [[WebHelper sharedHelper]sendRequest:dictionary tag:S_HospitalsList delegate:self];
        
        
        
        
        
    }
}


#pragma mark - IBAction

- (IBAction)addTap
{
    UserAffiliationViewController *uaVC = [[UserAffiliationViewController alloc] initWithNibName:@"UserAffiliationViewController" bundle:nil];
    
    addNetwork = YES;
    
    uaVC.delegate = self;
    
    [self.navigationController pushViewController:uaVC animated:YES];
}


- (IBAction)doneTap
{
    if ([self.delegate respondsToSelector:@selector(HospitalController:selectedHosptials:)])
    {
        [self.delegate HospitalController:self selectedHosptials:self.selectedArray];
    }
    
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)action_back:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
    
}

#pragma mark - ASIHTTP


- (void)didReceivedresponse:(NSDictionary *)response
{
    if ([WebHelper sharedHelper].tag == S_HospitalsList)
    {
        if ([[response objectForKey:@"err-code"] intValue] == 1)    // Success
        {
            self.searchedArray = [response objectForKey:@"hospitals_list"];
            
            [self.searchDisplayController.searchResultsTableView reloadData];
        }
        
        
        else if ([[response objectForKey:@"err-code"] intValue] == 300)    // Unable to proceed
        {
                    [self.searchedArray removeAllObjects];
                        [self.searchDisplayController.searchResultsTableView reloadData];
   
        }
    }
}

- (void)didFailedWithError: (NSError *) error
{
    [AppDel hideSpinner];
    
    [[[UIAlertView alloc] initWithTitle:nil message:@"Unable to connect to the server, Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}



#pragma mark - Font Settings

- (void)setRequiredFont2
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

