//
//  SearchViewController.m
//  IMYourDoc
//
//  Created by Sarvjeet on 09/02/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import "UserListCell.h"
#import "SearchViewController.h"
#import "StaffProfileViewController.h"
#import "PatientProfileViewController.h"
#import "PhysicianProfileViewController.h"


@interface SearchViewController ()


@end


@implementation SearchViewController


#pragma mark - View LifeCycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    
    counter = 1;
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    [self setRequiredFont2];
    
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
    
    
    if (self.searchType == 1)
    {
        statusL.text = @"Provider";
    }
    
    else if (self.searchType == 2)
    {
        statusL.text = @"Staff";
    }
    
    else if (self.searchType == 3)
    {
        statusL.text = @"Patient";
    }
}


- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    

}


- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}


- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - IBAction

- (IBAction)backTap
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Update Connectivity

- (void) updateConnectivity:(NSNotification *)note
{
    NSDictionary *dict = note.object;
    
    
    secureL.text = [dict objectForKey:@"status"];
    
    
    [secureIcon setImage:[UIImage imageNamed:[dict objectForKey:@"image"]]];
}


#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.searchArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserListCell *tbCell = [tableView dequeueReusableCellWithIdentifier:@"LIST_TB_CELLID"];
    
    
    if (tbCell == nil)
    {
        tbCell = [[[NSBundle mainBundle] loadNibNamed:@"UserListCell" owner:self options:nil] lastObject];
        
        tbCell.userIMGV.layer.cornerRadius = 30;
        
        tbCell.userIMGV.layer.masksToBounds = YES;
    }
    
    
    if ([[[self.searchArr objectAtIndex:indexPath.row] valueForKey:@"designation"] isEqualToString: @""])
    {
        tbCell.userNameLB.text = [NSString stringWithFormat:@"%@ %@", [[self.searchArr objectAtIndex:indexPath.row] valueForKey:@"first_name"], [[self.searchArr objectAtIndex:indexPath.row] valueForKey:@"last_name"]];
    }
    
    else
    {
        tbCell.userNameLB.text = [NSString stringWithFormat:@"%@ %@, %@", [[self.searchArr objectAtIndex:indexPath.row] valueForKey:@"first_name"], [[self.searchArr objectAtIndex:indexPath.row] valueForKey:@"last_name"], [[self.searchArr objectAtIndex:indexPath.row] valueForKey:@"designation"]];
    }

    
 
    
    
    [tbCell.userIMGV downloadFromURL:[NSURL URLWithString:[[self.searchArr objectAtIndex:indexPath.row] valueForKey:@"image_url"]]];
    
    tbCell.roleLB.hidden = NO;
    
    tbCell.roleLB.text = [[self.searchArr objectAtIndex:indexPath.row] valueForKey:@"job_title"];
    
    
    return tbCell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    [self.view endEditing:YES];
    
    
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    
    
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    
    
    if (networkStatus != NotReachable)
    {
        if (self.searchType == 1)       //Physician
        {
            PhysicianProfileViewController *ppVC = [[PhysicianProfileViewController alloc] initWithNibName:@"PhysicianProfileViewController" bundle:nil];
            
            ppVC.fromSearch = YES;
            
            ppVC.toUserName = [[self.searchArr objectAtIndex:indexPath.row] valueForKey:@"username"];
            
            [self.navigationController pushViewController:ppVC animated:YES];
        }
        
        else if (self.searchType == 2)  //Staff
        {
            StaffProfileViewController *spVC = [[StaffProfileViewController alloc] initWithNibName:@"StaffProfileViewController" bundle:nil];
            
            spVC.fromSearch = YES;
            
            spVC.toUserName = [[self.searchArr objectAtIndex:indexPath.row] valueForKey:@"username"];
            
            [self.navigationController pushViewController:spVC animated:YES];
        }
        
        else if (self.searchType == 3)  //Patient
        {
            PatientProfileViewController *ppVC = [[PatientProfileViewController alloc] initWithNibName:@"PatientProfileViewController" bundle:nil];
            
            ppVC.fromSearch = YES;
            
            ppVC.toUserName = [[self.searchArr objectAtIndex:indexPath.row] valueForKey:@"username"];
            
            [self.navigationController pushViewController:ppVC animated:YES];
        }
    }
    
    else
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"No Internet Connection." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}


#pragma mark - Scroll methods

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(floorf( scrollView.contentOffset.y) == floorf(scrollView.contentSize.height - scrollView.frame.size.height))
    {
        if (self.searchType == 1) // Physician
        {
            if ([[self.searchParam objectForKey:@"hasMore"] intValue] == 1)
            {
                NSDictionary *searchDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                            
                                            @"search", @"method",
                                            
                                            @"Physician", @"user_type",
                                            
                                            [self.searchParam objectForKey:@"phyName"], @"name",
                                            
                                            [self.searchParam objectForKey:@"hospID"], @"hosp_id",
                                            
                                            [self.searchParam objectForKey:@"pracType"], @"practice_type",
                                            
                                            [self.searchParam objectForKey:@"proID"], @"pic_no",
                                            
                                            [[NSUserDefaults standardUserDefaults] objectForKey:@"loginToken"], @"login_token",
                                            
                                            [NSNumber numberWithInt:counter], @"start",
                                            
                                            nil];
                
                
                
                [AppDel showSpinnerWithText:@"Fetching more..."];
                
                [[WebHelper sharedHelper] setWebHelperDelegate:self];
                
                [[WebHelper sharedHelper] sendRequest:searchDict tag:S_SearchPhysician delegate:self];
            }

        }
        else if (self.searchType == 2) // Staff
        {
            if ([[self.searchParam objectForKey:@"hasMore"] intValue] == 1)
            {
                NSDictionary *searchDict = [NSDictionary dictionaryWithObjectsAndKeys:
                              
                              @"search", @"method",
                              
                              @"Staff", @"user_type",
                              
                              [self.searchParam objectForKey:@"staffName"], @"name",
                              
                              [self.searchParam objectForKey:@"hospID"], @"hosp_id",
                              
                              [self.searchParam objectForKey:@"practiceType"], @"practice_type",
                              
                              [[NSUserDefaults standardUserDefaults] objectForKey:@"loginToken"], @"login_token",
                              
                              [NSNumber numberWithInt:counter], @"start",
                              
                              nil];
                
                [AppDel showSpinnerWithText:@"Fetching more..."];
                
                [[WebHelper sharedHelper] setWebHelperDelegate:self];
                
                [[WebHelper sharedHelper] sendRequest:searchDict tag:S_SearchStaff delegate:self];

            }
        }
        else if (self.searchType == 3)  // Patient
        {
            if ([[self.searchParam objectForKey:@"hasMore"] intValue] == 1)
            {
                NSDictionary *searchDict = [NSDictionary dictionaryWithObjectsAndKeys:
                              
                              @"search", @"method",
                              
                              @"Patient", @"user_type",
                              
                              [self.searchParam objectForKey:@"patName"], @"name",
                              
                              [[NSUserDefaults standardUserDefaults] objectForKey:@"loginToken"], @"login_token",
                              
                              [NSNumber numberWithInt:counter], @"start",
                              
                              nil];
                
                
                
                [AppDel showSpinnerWithText:@"Fetching more..."];
                
                [[WebHelper sharedHelper] setWebHelperDelegate:self];
                
                [[WebHelper sharedHelper] sendRequest:searchDict tag:S_SearchPatient delegate:self];
            }
        }
    }
}



- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        if(floorf(scrollView.contentOffset.y) == floorf(scrollView.contentSize.height - scrollView.frame.size.height))
        {
            if (self.searchType == 1) // Physician
            {
                if ([[self.searchParam objectForKey:@"hasMore"] intValue] == 1)
                {
                    NSDictionary *searchDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                
                                                @"search", @"method",
                                                
                                                @"Physician", @"user_type",
                                                
                                                [self.searchParam objectForKey:@"phyName"], @"name",
                                                
                                                [self.searchParam objectForKey:@"hospID"], @"hosp_id",
                                                
                                                [self.searchParam objectForKey:@"pracType"], @"practice_type",
                                                
                                                [self.searchParam objectForKey:@"proID"], @"pic_no",
                                                
                                                [[NSUserDefaults standardUserDefaults] objectForKey:@"loginToken"], @"login_token",
                                                
                                                [NSNumber numberWithInt:counter], @"start",
                                                
                                                nil];
                    
                    
                    
                    [AppDel showSpinnerWithText:@"Fetching more..."];
                    
                    [[WebHelper sharedHelper] setWebHelperDelegate:self];
                    
                    [[WebHelper sharedHelper] sendRequest:searchDict tag:S_SearchPhysician delegate:self];
                }
                
            }
            else if (self.searchType == 2) // Staff
            {
                if ([[self.searchParam objectForKey:@"hasMore"] intValue] == 1)
                {
                    NSDictionary *searchDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                
                                                @"search", @"method",
                                                
                                                @"Staff", @"user_type",
                                                
                                                [self.searchParam objectForKey:@"staffName"], @"name",
                                                
                                                [self.searchParam objectForKey:@"hospID"], @"hosp_id",
                                                
                                                [self.searchParam objectForKey:@"practiceType"], @"practice_type",
                                                
                                                [[NSUserDefaults standardUserDefaults] objectForKey:@"loginToken"], @"login_token",
                                                
                                                [NSNumber numberWithInt:counter], @"start",
                                                
                                                nil];
                    
                    [AppDel showSpinnerWithText:@"Fetching more..."];
                    
                    [[WebHelper sharedHelper] setWebHelperDelegate:self];
                    
                    [[WebHelper sharedHelper] sendRequest:searchDict tag:S_SearchStaff delegate:self];
                    
                }
            }
            else if (self.searchType == 3)  // Patient
            {
                if ([[self.searchParam objectForKey:@"hasMore"] intValue] == 1)
                {
                    NSDictionary *searchDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                
                                                @"search", @"method",
                                                
                                                @"Patient", @"user_type",
                                                
                                                [self.searchParam objectForKey:@"patName"], @"name",
                                                
                                                [[NSUserDefaults standardUserDefaults] objectForKey:@"loginToken"], @"login_token",
                                                
                                                [NSNumber numberWithInt:counter], @"start",
                                                
                                                nil];
                    
                    
                    
                    [AppDel showSpinnerWithText:@"Fetching more..."];
                    
                    [[WebHelper sharedHelper] setWebHelperDelegate:self];
                    
                    [[WebHelper sharedHelper] sendRequest:searchDict tag:S_SearchPatient delegate:self];
                }
            }

        }
    }
}


#pragma mark - Response

- (void)didReceivedresponse:(NSDictionary *)response
{
    [AppDel hideSpinner];
    
    if ([WebHelper sharedHelper].tag == S_SearchPhysician)    // Search Physician
    {
        if ([[response objectForKey: @"err-code"] intValue] == 1)
        {
            
            
            if ([[response objectForKey:@"users"] count])
            {
                counter++;
                
                [self.searchParam setObject:[response objectForKey:@"has_more"] forKey:@"hasMore"];
                
                [self.searchArr addObjectsFromArray:[[response objectForKey:@"users"] mutableCopy]];
                
                [searchTB reloadData];
            }
        }
    }
    
    else if ([WebHelper sharedHelper].tag == S_SearchStaff)    // Search Staff
    {
        if ([[response objectForKey: @"err-code"] intValue] == 1)
        {
            if ([[response objectForKey:@"users"] count])
            {
                counter++;
                
                [self.searchParam setObject:[response objectForKey:@"has_more"] forKey:@"hasMore"];
                
                [self.searchArr addObjectsFromArray:[[response objectForKey:@"users"] mutableCopy]];
                
                [searchTB reloadData];
            }
        }
    }
    
    else if ([WebHelper sharedHelper].tag == S_SearchPatient)    // Search Patient
    {
        if ([[response objectForKey: @"err-code"] intValue] == 1)
        {
            if ([[response objectForKey:@"users"] count])
            {
                counter++;

                [self.searchParam setObject:[response objectForKey:@"has_more"] forKey:@"hasMore"];
                
                [self.searchArr addObjectsFromArray:[[response objectForKey:@"users"] mutableCopy]];
                
                [searchTB reloadData];
            }
        }
    }



}


- (void)didFailedWithError: (NSError *) error
{
    [AppDel hideSpinner];
    
    [[[UIAlertView alloc] initWithTitle:nil message:@"Unable to connect to the server, Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}



#pragma mark - Set Required Font


- (void)setRequiredFont2
{
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [statusL setFont:[UIFont fontWithName:@"CentraleSansRndMedium" size:25.00]];
    }
    else
    {
        [statusL setFont:[UIFont fontWithName:@"CentraleSansRndMedium" size:20.00]];
    }
}


@end

