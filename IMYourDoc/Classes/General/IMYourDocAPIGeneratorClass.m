//
//  IMYourDocAPIGeneratorClass.m
//  IMYourDoc
//
//  Created by macbook on 14/05/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//


#import "IMYourDocAPIGeneratorClass.h"


#define KXmlHeader @"<?xml version='1.0' encoding='UTF-8'?>"
#define KLoginURL @"https://imyourdoc.com/Login_new.php"
    //#define KLoginURL @"https://imyourdoc.com/joomla/loginapi_2_1_back2.php"
#define kRegisterURL @""
#define kDevieRegistrationURL @"https://imyourdoc.com/joomla/deviceregapi.php"

#define KSignOutURL @"https://imyourdoc.com/joomla/logoutapi.php"

#define KPhysicianFullProfileForPatientView @"https://imyourdoc.com/joomla/PhysicianFullProfileForPatientView_new.php"

#define KFetchPIC @"https://imyourdoc.com/joomla/fetchPic.php?UserName="

#define KFetchUserFromPIC @"https://imyourdoc.com/FetchUsernameStaff.php?STF="

#define KPatientFullProfileForPhysicianView @"https://imyourdoc.com/joomla/PatientFullProfileForPhysicianView.php"

#define KRemovePhysician @"https://imyourdoc.com/joomla/RemovePhysicianFromList.php"

#define KRemovePatient @""

#define KMonthlySessionCheck @"https://imyourdoc.com/joomla/Session_Zero.php"


#define KPhysicianPersonalProfileURL @"https://imyourdoc.com/joomla/physicianprofileapi.php?UserName=%@"

#define KPatientPersonalProfileURL @"https://imyourdoc.com/joomla/patientprofileapi.php?UserName=%@"

#define KStaffPersonalProfileURL @"https://imyourdoc.com/StaffProfileAPI.php?UserName=%@"



#define KEditPhysicianProfile @"https://imyourdoc.com/joomla/editphysicianprofile.php"

    // Change Email for Physician
#define KChangeEmail @"https://imyourdoc.com/joomla/emailapi.php"


#define KDeviceRegisteredForUserURL @"https://imyourdoc.com/joomla/deviceregistered.php?UserName=%@"

    // At the time of registration...
#define KDeviceregisteredForUserPostURL @"https://imyourdoc.com/joomla/deviceregisteredPost.php?UserName=%@"

#define KChangePasswordURL @"https://imyourdoc.com/joomla/editpasswordapi.php"


#define KchangeSecurityQuestionURL @"https://imyourdoc.com/joomla/securityapi.php"

#define KResetPassWord @"https://imyourdoc.com/joomla/restpassword.php"

#define KRestPinURL @"https://imyourdoc.com/joomla/userpinresetapi.php"


#define KEditPatientProfile @"https://imyourdoc.com/joomla/editpatientprofile.php"

#define KEditStaffProfile @"https://imyourdoc.com/joomla/editstaffprofile.php"

#define KApprovePatient @"https://imyourdoc.com/joomla/ApprovePatient.php"

#define KsessionDeductionURL @"https://imyourdoc.com/joomla/SessionDeductionApi.php"

#define KpushNotificationURL @"https://imyourdoc.com/abhishek/push/push_api.php"  //@"http://advantal.net/anshul/push/push_api.php?username=%@&token=%@"

#define KaddPhysicianURL @"https://imyourdoc.com/joomla/SessionRegistrationApi_New.php";

#define KSearchPhysicianURL @"https://imyourdoc.com/joomla/SearchPhysician.php"

#define KSearchRoomForPatient @"https://imyourdoc.com/joomla/MUCRoomsApi.php?patient_name="

#define KForgotIMYourDocPassWordStepOne @"https://imyourdoc.com/abhishek/Email_System/ResetPassword_GetUser.php?username=%@"

#define KForgotIMYourDocPassWordStepTwo @"https://imyourdoc.com/abhishek/Email_System/ResetPassword_GetEmail.php?"


#define kStaffIMYourDocProfileForPhysician @"https://imyourdoc.com/joomla/StaffProfileView.php"



#define KGetRosterByGroup @"https://imyourdoc.com/abhishek/GetRosterWithGroup_new.php"


#define KSearchStaffURL @"https://imyourdoc.com/SearchStaff.php"

@implementation IMYourDocAPIGeneratorClass

+(NSString *)loginURL
{
    return KLoginURL;
    
}
+(NSString *)selfStringGeneratorLOGIN:(NSString *)forUserName withPassword:(NSString *)Password withDeviceUniqueId:(NSString *)DeviceID
{
    NSString *xmlString= KXmlHeader;
    xmlString =[xmlString stringByAppendingString:@"<Login>"];
    xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<username>%@</username>",forUserName]];
    xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<password>%@</password>",Password]];
    xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<deviceid>%@</deviceid>",DeviceID]];
    xmlString = [xmlString stringByAppendingFormat:@"</Login>"];
		//NSLog(@"%@",xmlString);
    return xmlString;
}


+(NSString *)deviceRegistrationURL
{
    return kDevieRegistrationURL;
}

+(NSString *)selfStringGeneratorDEVICEREGISTERED:(NSString *)forusername withDeviceName:(NSString *)DeviceName withDevicePin:(NSString *)DevicePin withDeviceType:(NSString *)DeviceType;
{
    
    NSString *xmlString= KXmlHeader;
    xmlString =[xmlString stringByAppendingString:@"<DeviceReg>"];
    xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<UserName>%@</UserName>",forusername]];
    xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<DeviceName>%@</DeviceName>",DeviceName]];
    xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<DevicePin>%@</DevicePin>",DevicePin]];
    xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<DeviceType>%@</DeviceType>",DeviceType]];
    xmlString = [xmlString stringByAppendingFormat:@"</DeviceReg>"];
    return xmlString;
}


+(NSString *)signOutUrl
{
    return KSignOutURL;
}

+(NSString *)selfStringGeneratorSIGNOUT:(NSString *)forusername withpassword:(NSString *)Password 
{
    NSString *xmlString=KXmlHeader;
	xmlString =[xmlString stringByAppendingString:@"<Logout>"];
	xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<username>%@</username>",forusername]];
	xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<password>%@</password>",Password]];
    xmlString = [xmlString stringByAppendingFormat:@"</Logout>"];
	return xmlString;
}

    // PHYSICIAN FULL PROFILE API FOR PATIENT

+(NSString *)physicianFullProfileForPatient
{
    return KPhysicianFullProfileForPatientView;
}

+(NSString *)selfStringGeneratorPHYSICIANFULLPROFILEPATIENT:(NSString *)patientUsername withPhysicianUsername:(NSString *)physicianUsername
{
	NSString *xmlString= KXmlHeader;
	xmlString =[xmlString stringByAppendingString:@"<AddedPhysician>"];
	xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<PhysicianUserName>%@</PhysicianUserName>",physicianUsername]];
	xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<PatientUserName>%@</PatientUserName>",patientUsername]];
    xmlString = [xmlString stringByAppendingFormat:@"</AddedPhysician>"];
	return xmlString;
}


    // PATIENT FULL PROFILE API FOR PHYSICIAN

+(NSString *)patientFullProfileForPhysician
{
    return KPatientFullProfileForPhysicianView;
}



+(NSString *)selfStringGeneratorPATIENTFULLPROFILEFORPHYSICIAN:(NSString *)patientUsername withPhysicianUsername:(NSString *)patientUserName
{
	NSString *xmlString=KXmlHeader;
    xmlString =[xmlString stringByAppendingString:@"<AddedPhysician>"];
	xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<PhysicianUserName>%@</PhysicianUserName>",patientUserName]];
	xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<PatientUserName>%@</PatientUserName>",patientUsername]];
    xmlString = [xmlString stringByAppendingFormat:@"</AddedPhysician>"];
    return xmlString;
}


+(NSString *)removePhysicianURL
{
    return KRemovePhysician;
}

+(NSString *)selfStringGeneratorREMOVEPHYSICIAN:(NSString *)forPatientUserName withPhysician:(NSString *)physicianUsername
{
    NSString *xmlString= KXmlHeader;
	xmlString =[xmlString stringByAppendingString:@"<RemovePhysician>"];
	xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<PhysicianUserName>%@</PhysicianUserName>",physicianUsername]];
    xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<PatientUserName>%@</PatientUserName>",forPatientUserName]];
    xmlString = [xmlString stringByAppendingFormat:@"</RemovePhysician>"];
	return xmlString;
}

    // Monthly Session Check
+(NSString *)patientMonthlySessionCheck
{
    return KMonthlySessionCheck;
}


+(NSString *)personalProfileForPhysician
{
    return [NSString stringWithFormat:KPhysicianPersonalProfileURL, [AppData appData].XMPPmyJID];
}


+(NSString *)personalProfileForPatient
{
    return [NSString stringWithFormat:KPatientPersonalProfileURL, [AppData appData].XMPPmyJID];
}

+(NSString *)personalProfileForSTAFF
{
    
    return [NSString stringWithFormat:KStaffPersonalProfileURL, [AppData appData].XMPPmyJID];
}




+(NSString *)editPhysicianProfileURL
{
    return KEditPhysicianProfile;
}

+(NSString *)selfStringGeneratorEDITPHYSICIANPROFILEAPPROVE:(NSString *)forusername withFirstName:(NSString *)FirstName withLastName:(NSString *)lastName withPracticeName:(NSString *)practiceName withPracticeType :(NSString *)practiceType withAddress:(NSString *) address withCity:(NSString *)city withState:(NSString *)state withZip:(NSString *)zip withPhone:(NSString *)phone withAssistanName:(NSString *)physicianAssistantName withAssistantEmail:(NSString *)assistantEmail
{
	NSString *xmlString= KXmlHeader;
	xmlString =[xmlString stringByAppendingString:@"<EditPhysician>"];
	xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<UserName>%@</UserName>",forusername]];
    xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<Fname>%@</Fname>",FirstName]];
    xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<PracticeName>%@</PracticeName>",practiceName]];
    xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<PracticeType>%@</PracticeType>",practiceType]];
    xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<City>%@</City>",city]];
    xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<State>%@</State>",state]];
    xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<Zip>%@</Zip>",zip]];
    xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<Phone>%@</Phone>",phone]];
    xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<Assistant>%@</Assistant>",physicianAssistantName]];
    xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<AssistantEmail>%@</AssistantEmail>",assistantEmail]];
    xmlString = [xmlString stringByAppendingFormat:@"</EditPhysician>"];
  	return xmlString;
}






+(NSString *)changeEmailURL
{
    return KChangeEmail;
}

+(NSString *)selfStringGeneratorCHANGEEMAIL:(NSString *)forusername withnewEmailAddress:(NSString *)NewEmailAddress;
{
	NSString *xmlString= KXmlHeader;
	xmlString =[xmlString stringByAppendingString:@"<Logout>"];
	xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<Username>%@</Username>",forusername]];
    xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<NewEmail>%@</NewEmail>",NewEmailAddress]];
    xmlString = [xmlString stringByAppendingFormat:@"</Logout>"];
	return xmlString;
}

+(NSString *)deviceRegistrationforUserURL
{
    return [NSString stringWithFormat:KDeviceRegisteredForUserURL, [AppData appData].XMPPmyJID];
}

+(NSString *)deviceRegisteredForUserPostURL
{
    return [NSString stringWithFormat:KDeviceregisteredForUserPostURL, [AppData appData].XMPPmyJID];
}

+(NSString *)fetchPICURL
{
    return KFetchPIC; 
}

+(NSString *)fetchUserNameByPic
{
    return KFetchUserFromPIC;
}

+(NSString *)changePassURL
{
    return KChangePasswordURL;
}
+(NSString *)selfStringGeneratorCHANGEPASSWORD:(NSString *)forusername withOldPassword:(NSString *)OldPassword withNewPassword:(NSString *)NewPassword 
{
 	NSString *xmlString= KXmlHeader;
	xmlString =[xmlString stringByAppendingString:@"<EditSeq>"];
    xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<UserName>%@</UserName>",forusername]];
	xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<OldPassword>%@</OldPassword>",OldPassword]];
    xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<NewPassword>%@</NewPassword>",NewPassword]];
    xmlString = [xmlString stringByAppendingFormat:@"</EditSeq>"];
	return xmlString;
}

+(NSString *)changeSecurityQuestion
{
    return KchangeSecurityQuestionURL;
}

+(NSString *)selfStringGeneratorSECURITYQUESTION:(NSString *)forusername withSecurityQuestion:(NSString *)SecurityQus withSecurityAnswer:(NSString *)SecurityAns
{
	NSString *xmlString= KXmlHeader;
    xmlString =[xmlString stringByAppendingString:@"<EditSeq>"];
	xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<Username>%@</Username>",forusername]];
	xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<SecurityQus>%@</SecurityQus>",SecurityQus]];
    xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<SecurityAns>%@</SecurityAns>",SecurityAns]];
    xmlString = [xmlString stringByAppendingFormat:@"</EditSeq>"];
	return xmlString;
}


+(NSString *)resetPassWordURL
{
    return KResetPassWord;
}

+(NSString *)selfStringGeneratorEDITPASSWORD:(NSString *)forUsername withSeqAns:(NSString *)seqAns;
{
	NSString *xmlString= KXmlHeader;
	xmlString =[xmlString stringByAppendingString:@"<ResetPassword>"];
	xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<Username>%@</Username>",forUsername]];
    xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<SeqAns>%@</SeqAns>",seqAns]];
    xmlString = [xmlString stringByAppendingFormat:@"</ResetPassword>"];
	return xmlString;
}

+(NSString *)resetPINURL
{
    return KRestPinURL;
}


+(NSString *)selfStringGeneratorRESETPIN:(NSString *)forusername withSecurityAnswer:(NSString *)SecurityAns 
{
	NSString *xmlString=@"<?xml version='1.0' encoding='UTF-8'?>";
	xmlString =[xmlString stringByAppendingString:@"<ResetPin>"];
	xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<Username>%@</Username>",forusername]];
    xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<SeqAns>%@</SeqAns>",SecurityAns]];
    xmlString = [xmlString stringByAppendingFormat:@"</ResetPin>"];
	return xmlString;
}

+(NSString *)editPatientProfile
{
    return KEditPatientProfile;
}

+(NSString *)selfStringGeneratorEDITPATIENTPROFILE:(NSString *)forfName withlName:(NSString *)lName withusername:(NSString *)username withAddress:(NSString *)Address withCity:(NSString *)City withState:(NSString *)State withZip:(NSString *)Zip withPhone:(NSString *)Phone
{
	NSString *xmlString= KXmlHeader;
	xmlString =[xmlString stringByAppendingString:@"<EditPatient>"];
	xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<Fname>%@</Fname>",forfName]];
	xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<Lname>%@</Lname>",lName]];
	xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<UserName>%@</UserName>",username]];
    xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<Address>%@</Address>",Address]];
    xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<City>%@</City>",City]];
	xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<State>%@</State>",State]];
    xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<Zip>%@</Zip>",Zip]];
    xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<Phone>%@</Phone>",Phone]];
    xmlString = [xmlString stringByAppendingFormat:@"</EditPatient>"];
	return xmlString;
}


+(NSString *)editStaffProfile
{
    return KEditStaffProfile;
}

+(NSString *)selfStringGeneratorEDITSTAFFPROFILE:(NSString *)forfName withlName:(NSString *)lName withusername:(NSString *)username withAddress:(NSString *)Address withCity:(NSString *)City withState:(NSString *)State withZip:(NSString *)Zip withPhone:(NSString *)Phone
{

    
     
    NSString *xmlString= KXmlHeader;
	xmlString =[xmlString stringByAppendingString:@"<editStaffProfile>"];
    xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<UserName>%@</UserName>",username]];
	xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<Fname>%@</Fname>",forfName]];
	xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<Lname>%@</Lname>",lName]];
	
    xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<Address>%@</Address>",Address]];
    xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<City>%@</City>",City]];
	xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<State>%@</State>",State]];
    xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<Zip>%@</Zip>",Zip]];
    xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<Phone>%@</Phone>",Phone]];
    xmlString = [xmlString stringByAppendingFormat:@"</editStaffProfile>"];
	return xmlString;

    
}


+(NSString *)approvePatientURL
{
    return KApprovePatient;
}


+(NSString *)selfStringGeneratorAPPROVEPATIENT:(NSString *)forPatientUserName withPhysician:(NSString *)physicianUsername withResponse:(NSString *)response 
{
	NSString *xmlString= KXmlHeader;
	xmlString =[xmlString stringByAppendingString:@"<ApprovePatient>"];
	xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<PatientUserName>%@</PatientUserName>",forPatientUserName]];
    xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<PhysicianUserName>%@</PhysicianUserName>",physicianUsername]];
    xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<Response>%@</Response>",response]];
    xmlString = [xmlString stringByAppendingFormat:@"</ApprovePatient>"];
	return xmlString;
}



+(NSString *)selfStringGeneratorSESSIONDEDUCTION:(NSString *)Patientusername withPhysicianPIC:(NSString *)physicianPic withProperAction:(NSString *)Action 
{
    
	NSString *xmlString = KXmlHeader;
	xmlString = [xmlString stringByAppendingString:@"<SessionDeduction>"];
	xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<UserName>%@</UserName>",Patientusername]];
	xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<SendMailToUser>%@</SendMailToUser>",physicianPic]];
    xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<Action>%@</Action>",Action]];
    xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<UserType>%@</UserType>",@"Patient"]];
    xmlString = [xmlString stringByAppendingFormat:@"</SessionDeduction>"];
	return xmlString;
}


+(NSString *)sessionDeductionURL
{
    return KsessionDeductionURL;
}


+(NSString *)pushNotificationURL
{
    return [NSString stringWithFormat:KpushNotificationURL, [AppData appData].XMPPmyJID, [[NSUserDefaults standardUserDefaults] stringForKey:@"deviceToken"]];
}


+(NSString *)addPhysicianURL
{
    return KaddPhysicianURL;
}

+(NSString *)selfStringGeneratorADDPHYSICIANURL:(NSString *)forusername withNewPicNumber:(NSString *)doctorPicNumber 
{
	NSString *xmlString= KXmlHeader;
	xmlString =[xmlString stringByAppendingString:@"<SessionReg>"];
	xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<UserName>%@</UserName>",forusername]];
	xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<DocPic>%@</DocPic>",doctorPicNumber]];
    xmlString = [xmlString stringByAppendingFormat:@"</SessionReg>"];
	return xmlString;
}

+(NSString *)searchPhysicianURL
{
    return KSearchPhysicianURL;
}


+(NSString *)selfStringGeneratorSEARCHPHYSICIANFROMPATIENT:(NSString *)forFirstName withLastName:(NSString *)LastName withCity:(NSString *)City withState:(NSString *)State withNPI:(NSString *)NPI withZip:(NSString *)Zip 
{
    NSString *xmlString= KXmlHeader;
    xmlString =[xmlString stringByAppendingString:@"<SearchPhysician>"];
    xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<PhysicianFirstName>%@</PhysicianFirstName>",forFirstName]];
    xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<PhysicianLastName>%@</PhysicianLastName>",LastName]];
    xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<PhysicianCity>%@</PhysicianCity>",City]];
    xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<PhysicianState>%@</PhysicianState>",State]];
    xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<PhysicianNpi>%@</PhysicianNpi>",NPI]];
    xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<PhysicianZip>%@</PhysicianZip>",Zip]];
    xmlString = [xmlString stringByAppendingFormat:@"</SearchPhysician>"];
    return xmlString;
}

+(NSString *)searchRoomForPatientURL
{
    return KSearchRoomForPatient;
}

+(NSString *)selfStringGeneratorFORGOTPASSWORDSTEPTWO:(NSString *)username withEmail:(NSString *)email withDevicePIN:(NSString *)devicepin
{
    NSString *xmlString= KXmlHeader;
    xmlString =[xmlString stringByAppendingString:@"<ForgetPassWord>"];
    xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<username>%@</username>",username]];
    xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<email>%@</email>",email]];
    xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<devicepin>%@</devicepin>",devicepin]];
    xmlString = [xmlString stringByAppendingString:@"<devicetype>iPhone</devicetype>"];
    xmlString = [xmlString stringByAppendingFormat:@"</ForgetPassWord>"];
    return xmlString;
}

+(NSString *)forgotPasswordStepOneURL
{
    return KForgotIMYourDocPassWordStepOne;
}

+(NSString *)forgotPasswordStepTwoURL
{
    return KForgotIMYourDocPassWordStepTwo;
}


+(NSString *)staffFullProfileForPatientURL
{
    return kStaffIMYourDocProfileForPhysician;
}

+(NSString *)selfStringGeneratorSTAFFFULLPROFILEFORPHYSICIAN:(NSString *)patientUsername withPhysicianUsername:(NSString *)physicianUsername
{
       

    
	NSString *xmlString= KXmlHeader;
	xmlString =[xmlString stringByAppendingString:@"<SearchStaff>"];
	xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<StaffUserName>%@</PhysicianUserName>",physicianUsername]];
	xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<PhysicianUserName>%@</PhysicianUserName>",patientUsername]];
    xmlString = [xmlString stringByAppendingFormat:@"</SearchStaff>"];
	return xmlString;
}

+(NSString *)getRosterByGroup
{
    return KGetRosterByGroup;
}

+(NSString *)selfStringGeneratorGETROSTERBYGROUPNAME:(NSString *)uName {
    
  
	NSString *xmlString= @"";
	xmlString =[xmlString stringByAppendingString:@"<roster>"];
	xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<username>%@</username>",uName]];
    xmlString = [xmlString stringByAppendingFormat:@"</roster>"];
	return xmlString;
}


+(NSString *)searchStaffURL
{
    return KSearchStaffURL;
}


+(NSString *)selfStringGeneratorSEARCHSTAFFFROMPHYSICIAN:(NSString *)forFirstName withLastName:(NSString *)LastName withCity:(NSString *)City withState:(NSString *)State withNPI:(NSString *)NPI withZip:(NSString *)Zip 
{
    NSString *xmlString= KXmlHeader;
    xmlString =[xmlString stringByAppendingString:@"<SearchStaff>"];
    xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<StaffFirstName>%@</StaffFirstName>",forFirstName]];
    xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<StaffLastName>%@</StaffLastName>",LastName]];
    xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<StaffCity>%@</StaffCity>",City]];
    xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<StaffState>%@</StaffState>",State]];
    xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<StaffNpi>%@</StaffNpi>",NPI]];
    xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<StaffZip>%@</StaffZip>",Zip]];
    xmlString = [xmlString stringByAppendingFormat:@"</SearchStaff>"];
    return xmlString;
}


+(NSString *)selfStringGeneratorSTAFFPROFILEVIEW:(NSString *)staffUserName withPhysicianUsername:(NSString *)physicianUserName {
    
//    <?xml version='1.0' encoding='UTF-8'?>
//    <SearchStaff>
//    <StaffUserName>staff3</StaffUserName>
//    <PhysicianUserName>pha1</PhysicianUserName>
//    </SearchStaff>  
    
	NSString *xmlString= KXmlHeader;
	xmlString =[xmlString stringByAppendingString:[NSString stringWithFormat:@"<SearchStaff><StaffUserName>%@</StaffUserName>",staffUserName]];
	xmlString = [xmlString stringByAppendingString:[NSString stringWithFormat:@"<PhysicianUserName>%@</PhysicianUserName>",physicianUserName]];
    xmlString = [xmlString stringByAppendingFormat:@"</SearchStaff>"];
	return xmlString;
}


@end
