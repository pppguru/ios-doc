//
//  SignupTypesViewController.m
//  IMYourDoc
//
//  Created by Sarvjeet on 20/01/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import <QuartzCore/QuartzCore.h>

#import "SignupTypesViewController.h"
#import "SignupStepOneViewController.h"
#import "PatientStepOneViewController.h"
#import "PhysSignupStepOneViewController.h"


@interface SignupTypesViewController ()


@end


@implementation SignupTypesViewController


#pragma mark - View LifeCycle

- (void) viewDidLoad
{
    [super viewDidLoad];
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    [self setRequiredFont2];
    
    patientRegisBtn.userInteractionEnabled = providerRegisBtn.userInteractionEnabled = staffRegisBtn.userInteractionEnabled = YES;

    
    
    // Device orientation handling...
    
    if ([[UIDevice currentDevice] orientation] == UIInterfaceOrientationLandscapeLeft || [[UIDevice currentDevice] orientation] == UIInterfaceOrientationLandscapeRight)
    {
        patLeadSpaceConst.constant = patTrailSpaceConst.constant = provLeadSpaceConst.constant = provTrailSpaceConst.constant = staffLeadSpaceConst.constant = staffTrailSpaceConst.constant = 80.00;
        
        [regisChoicesContainer layoutIfNeeded];
    }
    else
    {
        patLeadSpaceConst.constant = patTrailSpaceConst.constant = provLeadSpaceConst.constant = provTrailSpaceConst.constant = staffLeadSpaceConst.constant = staffTrailSpaceConst.constant = 20.00;
        
        [regisChoicesContainer layoutIfNeeded];
    }

    
    [self setRequiredAttributes];
    
    
	self.regisContainerHeight = regisChoicesContainer.frame.size.height;
}


- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    [self setRequiredFont2];
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


#pragma mark - Void


- (void)willAnimateRotationToInterfaceOrientation:
(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration
{
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
        toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        patLeadSpaceConst.constant = patTrailSpaceConst.constant = provLeadSpaceConst.constant = provTrailSpaceConst.constant = staffLeadSpaceConst.constant = staffTrailSpaceConst.constant = 80.00;
        
        [regisChoicesContainer layoutIfNeeded];
    }
    else
    {
        patLeadSpaceConst.constant = patTrailSpaceConst.constant = provLeadSpaceConst.constant = provTrailSpaceConst.constant = staffLeadSpaceConst.constant = staffTrailSpaceConst.constant = 20.00;
        
        [regisChoicesContainer layoutIfNeeded];
    }
}


- (void)staffAnimationMethod
{
	if (staffInfoSelected)
	{
		[UIView animateWithDuration:0.5 animations:^{
			
			staffInfoImgV.image = [UIImage imageNamed:@"Info_on"];
			
			staffTFHeightConstraint.constant -= 0.2 * self.regisContainerHeight;
			
			staffContainerHeightConstraint.constant -= 0.2 * self.regisContainerHeight;
			
            
			[self.view layoutIfNeeded];
			
            
			staffInfoSelected = NO;
			
		} completion:^(BOOL finished){
			
			staffTxtView.hidden = YES;
			
		}];
	}
	
	else
	{
		[UIView animateWithDuration:0.5 animations:^{
			
			staffInfoImgV.image = [UIImage imageNamed:@"Info_over"];
			
			staffContainerHeightConstraint.constant += 0.2 * self.regisContainerHeight;
			
			staffTFHeightConstraint.constant += 0.2 * self.regisContainerHeight;
			
			staffTxtView.hidden = NO;
			
            staffTxtView.contentOffset = CGPointMake(staffTxtView.contentOffset.x, 0);

			[self.view layoutIfNeeded];
			
            
			staffInfoSelected = YES;
			
		}];
	}
}


- (void)patientAnimationMethod
{
	if (patientInfoSelected)
	{
		[UIView animateWithDuration:0.5 animations:^{
			
			patientInfoImgV.image = [UIImage imageNamed:@"Info_on"];
			
			patientTFHeightConstraint.constant -= 0.2 * self.regisContainerHeight;
			
			patientContainerHeightConstraint.constant -= 0.2 * self.regisContainerHeight;
            
			
			[self.view layoutIfNeeded];
			
			patientInfoSelected = NO;
			
		} completion:^(BOOL finished){
			
			patientTxtView.hidden = YES;
			
		}];
	}
	
	else
	{
		[UIView animateWithDuration:0.5 animations:^{
			
			patientInfoImgV.image = [UIImage imageNamed:@"Info_over"];
			
			patientContainerHeightConstraint.constant += 0.2 * self.regisContainerHeight;
			
			patientTFHeightConstraint.constant += 0.2 * self.regisContainerHeight;
			
			patientTxtView.hidden = NO;
			
            patientTxtView.contentOffset = CGPointMake(patientTxtView.contentOffset.x, 0);
            
			[self.view layoutIfNeeded];
			
			patientInfoSelected = YES;
		}];
	}
}


- (void)providerAnimationMethod
{
	if (providerInfoSelected)
	{
		[UIView animateWithDuration:0.5 animations:^{
			
			providerInfoImgV.image = [UIImage imageNamed:@"Info_on"];
			
			providerTFHeightConstraint.constant -= 0.2 * self.regisContainerHeight;
			
			providerContainerHeightConstraint.constant -= 0.2 * self.regisContainerHeight;
			
            
			[self.view layoutIfNeeded];
			
			providerInfoSelected = NO;
			
		} completion:^(BOOL finished){
			
			providerTxtView.hidden = YES;
			
		}];
	}
	
	else
	{
		[UIView animateWithDuration:0.5 animations:^{
			
			providerInfoImgV.image = [UIImage imageNamed:@"Info_over"];
			
			providerContainerHeightConstraint.constant += 0.2 * self.regisContainerHeight;
			
			providerTFHeightConstraint.constant += 0.2 * self.regisContainerHeight;
			
			providerTxtView.hidden = NO;
            
            providerTxtView.contentOffset = CGPointMake(providerTxtView.contentOffset.x, 0);

			
			[self.view layoutIfNeeded];
			
			providerInfoSelected = YES;
			
		}];
	}
}


#pragma mark - IBAction

- (IBAction)navBack
{
    LoginViewController *loginVC = [[LoginViewController alloc] initWithNibName: @"LoginViewController" bundle: nil];
    
    [self.navigationController pushViewController: loginVC animated: NO];
}


- (IBAction)staffInfo
{
    if (providerInfoSelected)
    {
        [self providerAnimationMethod];
		
		
		[self staffAnimationMethod];
    }
	
    else if (patientInfoSelected)
    {
        [self patientAnimationMethod];
        
		
		[self staffAnimationMethod];
    }
	
    else
    {
        [self staffAnimationMethod];
    }
}


- (IBAction)patientInfo
{
	if (staffInfoSelected)
	{
		[self staffAnimationMethod];
		
		
		[self patientAnimationMethod];
	}
	
	else if (providerInfoSelected)
	{
		[self providerAnimationMethod];
		
		
		[self patientAnimationMethod];
	}
	
	else
	{
		[self patientAnimationMethod];
	}
}


- (IBAction)staffSignup
{
	staffLbl.backgroundColor =  [UIColor colorWithRed:156.0/255.0 green:205.0/255.0 blue:32.0/255.0 alpha:1.0];
	
    patientRegisBtn.userInteractionEnabled = providerRegisBtn.userInteractionEnabled = NO;
	
    SignupStepOneViewController *signupOneVC = [[SignupStepOneViewController alloc] initWithNibName:@"SignupStepOneViewController" bundle:nil];
    
    signupOneVC.registrationType = RegistrationTypeStaff;
    
    [self.navigationController pushViewController:signupOneVC animated:YES];
}


- (IBAction)providerInfo
{
    if (patientInfoSelected)
    {
        [self patientAnimationMethod];
        
		
		[self providerAnimationMethod];
    }
	
    else if (staffInfoSelected)
    {
        [self staffAnimationMethod];
        
		
		[self providerAnimationMethod];
    }
	
    else
    {
        [self providerAnimationMethod];
    }
}


- (IBAction)patientSignup
{
    patientLbl.backgroundColor =  [UIColor colorWithRed:156.0/255.0 green:205.0/255.0 blue:32.0/255.0 alpha:1.0];
	
    staffRegisBtn.userInteractionEnabled = providerRegisBtn.userInteractionEnabled = NO;
    
    PatientStepOneViewController *signupOneVC = [[PatientStepOneViewController alloc] initWithNibName:@"PatientStepOneViewController" bundle:nil];
    
    signupOneVC.registrationType = RegistrationTypePatient;
    
    [self.navigationController pushViewController:signupOneVC animated:YES];
}


- (IBAction)providerSignup
{
    providerLbl.backgroundColor =  [UIColor colorWithRed:156.0/255.0 green:205.0/255.0 blue:32.0/255.0 alpha:1.0];
    
    patientRegisBtn.userInteractionEnabled = staffRegisBtn.userInteractionEnabled = NO;
    
    SignupStepOneViewController *signupOneVC = [[SignupStepOneViewController alloc] initWithNibName:@"SignupStepOneViewController" bundle:nil];
    
    signupOneVC.registrationType = RegistrationTypePhysician;
    
    [self.navigationController pushViewController:signupOneVC animated:YES];
}


#pragma mark - Fonts

- (void) setRequiredAttributes
{

    
    patientLbl.layer.cornerRadius = providerLbl.layer.cornerRadius = staffLbl.layer.cornerRadius = 5.0f;
    
    patientLbl.clipsToBounds = providerLbl.clipsToBounds = staffLbl.clipsToBounds = YES;
    
    patientTxtView.hidden = providerTxtView.hidden = staffTxtView.hidden = YES;
    
    patientLbl.backgroundColor = providerLbl.backgroundColor = staffLbl.backgroundColor = [UIColor colorWithRed:175.0/255.0 green:177.0/255.0 blue:180.0/255.0 alpha:1.0];
}


#pragma mark - Font Settings

- (void)setRequiredFont2
{
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [patientRegisBtn.titleLabel setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:30.00]];
        
        [providerRegisBtn.titleLabel setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:30.00]];

        [staffRegisBtn.titleLabel setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:30.00]];
        
        
        [patientTxtView setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:25.00]];
        
        [providerTxtView setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:25.00]];

        [staffTxtView setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:25.00]];
    }
    else
    {
        [patientRegisBtn.titleLabel setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
        
        [providerRegisBtn.titleLabel setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
        
        [staffRegisBtn.titleLabel setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
        
        
        [patientTxtView setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:12.00]];
        
        [providerTxtView setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:12.00]];
        
        [staffTxtView setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:12.00]];

    }
}


@end

