//
//  Constents.h
//  IMYourDoc
//
//  Created by Harminder on 03/02/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#ifndef IMYourDoc_Constents_h
#define IMYourDoc_Constents_h


#endif

static NSString *const INBOX_THREAD_PAGE_SIZE = @"10";
static NSString *const kXMPPmyJID = @"kXMPPmyJID";
static NSString *const kXMPPmyPassword = @"kXMPPmyPassword";

#define ASI_REGISTRATION_REQ 10023

#define TAG_PIN_Grobal 8902080
#define TAG_Alert_Grobal 89334080
#define ASI_LOGIN_REQ 109200

#define TAG_REQUEST_FEEDBACK 10920

#define TAG_FILE_UPLOADER 10293

#define TAG_REQUEST_AUDIT  4

#define TAG_REQUEST_UPDATE 5

#define TAG_ALERT_UPDATE   56

#define TAG_CAMERA_ACTIONSHEET 156

#define XMPPREACHABILITY @"XMPPREACHABILITY"

#define AppDel (AppDelegate *)[[UIApplication sharedApplication] delegate]



//


#define Timer_BackGround 120 // in seconds


typedef enum : NSUInteger
{
    S_Login,
    S_Logout,
    S_BlockUser,
    S_PhySignup,
    S_AddNetwork,
    S_GroupReadby,
    S_BlockDevice,
    S_OfflineChat,
    S_SearchStaff,
    S_UpdateEmail,
    S_StaffSignup,
    S_EditProfile,
    S_PersonalInfo,
    S_PracticeList,
    S_PatientSignup,
    S_UnblockDevice,
    S_AccountConfig,
    S_SearchPatient,
    S_SendInvitation,
    S_UpdatePassword,
    S_GetUserProfile,
    S_RemoveXMPPUser,
    S_ShowRequestList,
    S_SearchPhysician,
    S_GetStaffProfile,
    S_UserDevicesList,
    S_GetOfflineStatus,
    S_GetSurveyDetails,
    S_GetPatientProfile,
    S_SendSurveyResponse,
    S_DeviceRegistration,
    S_GetPhyscianProfile,
    S_CancelSubscription,
    S_ForgotPasswordStep1,
    S_ForgotPasswordStep2,
    S_RespondToInvitation,
    S_RegisterForPushNotification,
    
    S_ValidateUserName,
    S_Feedback,
    S_PracticeTypes_jobTitle_designationList,
    S_UpdatePin,
    S_HospitalsList,
    S_UpdateLocation,
    S_SubmitUserResponse,
    
    S_CheckAppVersion,
    S_SubmitChatMessages,
    S_UpdateMessageReceivers ,
    S_GenerateDeviceToken,
    S_XmppLogin,
    S_Send_notification_device,
    S_Resend_notification_device,
    S_GetMessageStatus,
    S_GetAnnouncement,
    S_GetPaymentKeyDetails,
    S_SendInvitationV2,
    S_RespondToInvitationV2,
    S_SubscribeUser,
    S_CheckSubscription  ,
    S_Update_payment_details,
    S_UpdateSecurityInfo,
    S_ReportCloseConversation,
    S_GetRoomMembers,
    S_GetResendMessageStatus,
    
     // Broad cast module
    S_B_Create_broadcast_list,
    S_B_Update_broadcast_list,
    S_B_Create_broadcast_message,
    S_B_mark_broadcast_message_delivery,
    S_B_add_menbers,
    S_B_add_member,
    S_B_delete_member,
    S_B_broadcast_lists,
    
 }
Services;
typedef enum : NSUInteger
{
    RegistrationTypePatient ,
    RegistrationTypeStaff,
    RegistrationTypePhysician,
}   RegistrationType;




#define kfile_xsl  @"file_xlsx"
#define kfile_pdf @"file_pdf"
#define kfile_text  @"text_icon"
#define kfile_word  @"file_doc"
#define kfile_ppt @"file_ppt"
#define kfile_extra @"file_extra"

#ifdef DEBUG
#define NSLogDebug(format, ...) \
NSLog(@"<%s:%d> %s, " format, \
strrchr("/" __FILE__, '/') + 1, __LINE__, __PRETTY_FUNCTION__, ## __VA_ARGS__)
#else
#define NSLogDebug(format, ...)
#endif
