//
//  IMYourDocAPIGeneratorClass.h
//  IMYourDoc
//
//  Created by macbook on 14/05/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface IMYourDocAPIGeneratorClass : NSObject
{
    
}


//LOGIN API
+ (NSString *)loginURL;

+ (NSString *)selfStringGeneratorLOGIN:(NSString *)forUserName withPassword:(NSString *)Password withDeviceUniqueId:(NSString *)DeviceID;


// Device Registration
+ (NSString *)deviceRegistrationURL;

+ (NSString *)selfStringGeneratorDEVICEREGISTERED:(NSString *)forusername withDeviceName:(NSString *)DeviceName withDevicePin:(NSString *)DevicePin withDeviceType:(NSString *)DeviceType;


// SignOt Api
+ (NSString *)signOutUrl;

+ (NSString *)selfStringGeneratorSIGNOUT:(NSString *)forusername withpassword:(NSString *)Password;


// PHYSICIAN FULL PROFILE API
+ (NSString *)physicianFullProfileForPatient;

+ (NSString *)selfStringGeneratorPHYSICIANFULLPROFILEPATIENT:(NSString *)patientUsername withPhysicianUsername:(NSString *)physicianUsername;


// PATIENT FULL PROFILE FOR PHYSICIAN
+ (NSString *)patientFullProfileForPhysician;

+ (NSString *)selfStringGeneratorPATIENTFULLPROFILEFORPHYSICIAN:(NSString *)patientUsername withPhysicianUsername:(NSString *)patientUserName;


// Remove Physician
+ (NSString *)removePhysicianURL;

+ (NSString *)selfStringGeneratorREMOVEPHYSICIAN:(NSString *)forPatientUserName withPhysician:(NSString *)physicianUsername;


// Monthly Session Check..
+ (NSString *)patientMonthlySessionCheck;


// personal profile
+ (NSString *)personalProfileForPhysician;


// Personal Profile..
+ (NSString *)personalProfileForPatient;

+ (NSString *)personalProfileForSTAFF;

+ (NSString *)editPhysicianProfileURL;

+ (NSString *)selfStringGeneratorEDITPHYSICIANPROFILEAPPROVE:(NSString *)forusername withFirstName:(NSString *)FirstName withLastName:(NSString *)lastName withPracticeName:(NSString *)practiceName withPracticeType :(NSString *)practiceType withAddress:(NSString *) address withCity:(NSString *)city withState:(NSString *)state withZip:(NSString *)zip withPhone:(NSString *)phone withAssistanName:(NSString *)physicianAssistantName withAssistantEmail:(NSString *)assistantEmail;

+ (NSString *)changeEmailURL;

+ (NSString *)selfStringGeneratorCHANGEEMAIL:(NSString *)forusername withnewEmailAddress:(NSString *)NewEmailAddress;

+ (NSString *)deviceRegistrationforUserURL;


// using during block device info...
+(NSString *)deviceRegisteredForUserPostURL;

+(NSString *)changePassURL;

+(NSString *)selfStringGeneratorCHANGEPASSWORD:(NSString *)forusername withOldPassword:(NSString *)OldPassword withNewPassword:(NSString *)NewPassword;



+(NSString *)changeSecurityQuestion;

+(NSString *)selfStringGeneratorSECURITYQUESTION:(NSString *)forusername withSecurityQuestion:(NSString *)SecurityQus withSecurityAnswer:(NSString *)SecurityAns;

+(NSString *)resetPassWordURL;

+(NSString *)selfStringGeneratorEDITPASSWORD:(NSString *)forUsername withSeqAns:(NSString *)seqAns;


+(NSString *)resetPINURL;

+(NSString *)selfStringGeneratorRESETPIN:(NSString *)forusername withSecurityAnswer:(NSString *)SecurityAns;


+(NSString *)editPatientProfile;

+(NSString *)editStaffProfile;

+(NSString *)selfStringGeneratorEDITPATIENTPROFILE:(NSString *)forfName withlName:(NSString *)lName withusername:(NSString *)username withAddress:(NSString *)Address withCity:(NSString *)City withState:(NSString *)State withZip:(NSString *)Zip withPhone:(NSString *)Phone;


+(NSString *)selfStringGeneratorEDITSTAFFPROFILE:(NSString *)forfName withlName:(NSString *)lName withusername:(NSString *)username withAddress:(NSString *)Address withCity:(NSString *)City withState:(NSString *)State withZip:(NSString *)Zip withPhone:(NSString *)Phone;



+(NSString *)approvePatientURL;

+(NSString *)selfStringGeneratorAPPROVEPATIENT:(NSString *)forPatientUserName withPhysician:(NSString *)physicianUsername withResponse:(NSString *)response;


+(NSString *)selfStringGeneratorSESSIONDEDUCTION:(NSString *)Patientusername withPhysicianPIC:(NSString *)physicianPic withProperAction:(NSString *)Action;

+(NSString *)sessionDeductionURL;

+(NSString *)pushNotificationURL;

+(NSString *)addPhysicianURL;

+(NSString *)selfStringGeneratorADDPHYSICIANURL:(NSString *)forusername withNewPicNumber:(NSString *)doctorPicNumber;

+(NSString *)searchPhysicianURL;

+(NSString *)selfStringGeneratorSEARCHPHYSICIANFROMPATIENT:(NSString *)forFirstName withLastName:(NSString *)LastName withCity:(NSString *)City withState:(NSString *)State withNPI:(NSString *)NPI withZip:(NSString *)Zip;

+(NSString *)selfStringGeneratorFORGOTPASSWORDSTEPTWO:(NSString *)username withEmail:(NSString *)email withDevicePIN:(NSString *)devicepin;

+(NSString *)fetchPICURL;

+(NSString *)fetchUserNameByPic;

+(NSString *)searchRoomForPatientURL;


+(NSString *)forgotPasswordStepOneURL;

+(NSString *)forgotPasswordStepTwoURL;

+(NSString *)staffFullProfileForPatientURL;

+(NSString *)getRosterByGroup;

+(NSString *)selfStringGeneratorGETROSTERBYGROUPNAME:(NSString *)uName;


+(NSString *)selfStringGeneratorSTAFFPROFILEVIEW:(NSString *)staffUserName withPhysicianUsername:(NSString *)physicianUserName;

+(NSString *)searchStaffURL;

+(NSString *)selfStringGeneratorSEARCHSTAFFFROMPHYSICIAN:(NSString *)forFirstName withLastName:(NSString *)LastName withCity:(NSString *)City withState:(NSString *)State withNPI:(NSString *)NPI withZip:(NSString *)Zip;

@end
