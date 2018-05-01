//
//  AppDelegate.h
//  IMYourDoc
//
//  Created by Sarvjeet on 15/01/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//




#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreLocation/CoreLocation.h>
#import <LocalAuthentication/LocalAuthentication.h>

#import "JSON.h"
#import "Base64.h"
#import "WebHelper.h"
#import "OpenUDID.h"
#import "ChatMessage+ClassMethod.h"
#import "IMConstants.h"
#import "FileUplader.h"
#import "Reachability.h"
#import "FontTextField.h"
#import "MBProgressHUD.h"
#import "ASIHTTPRequest.h"

#import "CoreDataHelper.h"
#import "IMYourDocButton.h"
#import "RDCallbackAlertView.h"
#import "NSString+Validations.h"
#import "NSNotificationAdditions.h"
#import "IMYourDocAPIGeneratorClass.h"
#import "UIViewController+IMYourDoc_ComposeAction.h"

#import "XMPP.h"
#import "XMPPMUC.h"
#import "XMPPRoom.h"
#import "XMPPRoomObject.h"
#import "XMPPFramework.h"
#import "XMPPReconnect.h"
#import "XMPPvCardTemp.h"
#import "XMPPRoomObject.h"
#import "XMPPvCardTempAdr.h"
#import "XMPPDateTimeProfiles.h"
#import "XMPPMessage+XEP_0085.h"
#import "XMPPRoomAffaliations.h"
#import "XMPPRoomMemoryStorage.h"
#import "XMPPvCardAvatarModule.h"
#import "XMPPvCardCoreDataStorage.h"
#import "XMPPRosterCoreDataStorage.h"
#import "XMPPvCardCoreDataStorageObject.h"
#import "XMPPCapabilitiesCoreDataStorage.h"
#import "OfflineContact.h"
#import "OfflineMessages.h"
#import "AnnouncementWebViewController.h"

#import "InboxMessage+ClassMethods.h"
#import "ConversationLog+ClassMethod.h"
#import "ActiveConverstion+ClassMethod.h"
#import "FontLabel.h"
#import "NSString+Validations.h"
#import "NSMutableArray+OlderMessages.h"

#import "IMYOURDOCNavigationController.h"

#import "NSDictionary+MessageBody.h"
typedef enum : int
{
    SendChatStateType_composing = 0 ,
    SendChatStateType_composing1 = 1,
    SendChatStateType_gone2 =2,
    SendChatStateType_NO = 3 ,
    SendChatStateType_gone = 4,
    SendChatStateType_delivered =5,
    SendChatStateType_displayed =6
} SendChatStateType;

typedef enum : int
{
    isPhysician = 0 ,
    isPatient = 1,
    isStaff =2
}isFromType;


@class BroadCastMessageSender;
@class VCard;
@class HomeViewController;
@class LoginViewController;

@interface NSDictionary (IMYourDOC_JSON)

-(NSString *)JSONString;

@end


@protocol SecureDelegate <NSObject>

- (void)hide:(id)object;
- (void)show:(id)object;

@end


@interface AppDelegate : UIResponder <CLLocationManagerDelegate, UIApplicationDelegate, MBProgressHUDDelegate, XMPPRoomDelegate, XMPPRosterDelegate,WebHelperDelegate>
{
    BOOL isXmppConnected, isAppInBackgroundMsg, customCertEvaluation;
    
    
    NSString *password;
    
    
    UIBackgroundTaskIdentifier bgTask;
    
    
    NSTimer *sessionCheckTimer, *locationUpdateTimer;
    
    
    NSMutableArray *globalArrayForPatientToDeductSession;
    
    
    NSManagedObjectContext *managedObjectContext_vCard, *managedObjectContext_roster, *managedObjectContext_capabilities;
    
    
    UIAlertView *alertFileMessage, *alertForGroupChat, *consistentErrorAlert, *alertMessageForNewChat, *alertViewForSubscriptionRequest;
    
    UIAlertController *alertController2CheckSessionPin, *alertController2AuthenticaionFailed;
    
    
    MBProgressHUD *spinner;
    
    
    // internet Rechablity  --
    // networkReachability  --
    Reachability *internetRechablity, *networkReachability_internet , * reachability_HostAddress_ApiServer ,* reachanlity_HostAddress_OpenFire;
    
    
    XMPPRoster *xmppRoster;
    
    XMPPStream *xmppStream;
    
    XMPPReconnect *xmppReconnect;
    
    XMPPCapabilities *xmppCapabilities;
    
    XMPPvCardTempModule *xmppvCardTempModule;
    
    XMPPvCardCoreDataStorage *xmppvCardStorage;
    
    XMPPvCardAvatarModule *xmppvCardAvatarModule;
    
    XMPPRosterCoreDataStorage *xmppRosterStorage;
    
    XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;
    
    
    BOOL allowSSLHostNameMismatch, allowSelfSignedCertificates;
    
    
    NSOperationQueue * que_t;
    
    // GCD queues
    dispatch_queue_t rosterQueue;
    dispatch_queue_t loggingQueue;
    dispatch_queue_t xmppDelegateQueue;

}
@property(nonatomic,strong)  Reachability *internetRechablity, *networkReachability_internet , * reachability_HostAddress_ApiServer ,* reachanlity_HostAddress_OpenFire;
@property (weak, nonatomic) id<SecureDelegate> secureDelegate;

@property (strong, nonatomic) UIWindow *window;

@property (assign, nonatomic) int loginFailCount;

@property (strong, nonatomic) NSString *loginUserName;

@property (strong, nonatomic) IMYOURDOCNavigationController *navController;

@property (strong, nonatomic) NSMutableArray *fetchedEmailsFromDevice, *fetchedPhonesFromDevice;



@property (nonatomic, retain) HomeViewController *homeView;

@property (nonatomic, retain) LoginViewController *loginView;


@property (nonatomic, assign) BOOL isManuallyDisconnect, bool_SignoutRetry, bool_SignoutFirstTime;





@property (nonatomic, strong) IBOutlet UIButton *composeButton;

@property (nonatomic, retain) NSMutableData *notificationreqData;

@property (nonatomic, retain) NSMutableDictionary *fileMessageTOURL;

@property (nonatomic, assign) NSInteger isLoggedState, isFromPhysician;

@property (nonatomic, retain) NSString *myJID, *keyforPendingUser, *keyforDeclinedUser, *jidFromPushToStartChat;

@property (nonatomic, retain) NSMutableArray *fromJid, *roomsArr, *pendingUserArr, *declinedUserArr, *notifyArrayForChat, *openConversationArray, *fileQue , *arr_LogOfPushIDs;

@property (nonatomic, strong) XMPPMUC *mucmodule;

@property (nonatomic, strong) XMPPRoster *xmppRoster;

@property (nonatomic, strong) XMPPStream *xmppStream;

@property (nonatomic, strong) XMPPReconnect *xmppReconnect;

@property (nonatomic, strong) XMPPCapabilities *xmppCapabilities;

@property (nonatomic, strong) XMPPvCardTempModule *xmppvCardTempModule;

@property (nonatomic, strong) XMPPvCardAvatarModule *xmppvCardAvatarModule;

@property (nonatomic, strong) XMPPRosterCoreDataStorage *xmppRosterStorage;

@property (nonatomic, strong) XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;

@property (nonatomic, strong) dispatch_queue_t xmppDelegateQueue;

@property (nonatomic, strong) UIAlertController *alertController2CheckSessionPin, *alertController2AuthenticaionFailed;

@property (nonatomic,strong) UIImage * image;

@property (nonatomic, assign) NSInteger request_count;

@property(nonatomic,retain) NSDate *inActiveTime;


@property(nonatomic,strong)    NSOperationQueue * failedFileQueue;


@property(nonatomic,assign)BOOL appIsDisconnected;
@property(nonatomic,assign,getter=isManualRosterFetchBool)BOOL manualRosterFetchBool;

- (NSManagedObjectContext *)managedObjectContext_vCard;

- (NSManagedObjectContext *)managedObjectContext_roster;

- (NSManagedObjectContext *)managedObjectContext_capabilities;


- (XMPPRoomObject *)fetchRoom:(NSString *)roomJID;

- (XMPPRoomObject *)fetchOrInsertRoom:(XMPPRoom *)room;

- (XMPPUserCoreDataStorageObject *)fetchUserForJIDString:(NSString *)jid;





#pragma mark - Reachability

- (void)networkChange:(NSNotification *)note;


#pragma mark - MBProgressHUD

- (void)hideSpinner;

- (void)setSpinnerText:(NSString *)text;

- (void)showSpinnerWithText:(NSString *)text;

- (void)hideSpinnerAfterDelayWithText:(NSString *)text andImageName:(NSString *)imageName;
-(void)hideSpinnerafterDelay:(NSTimeInterval)time;

#pragma mark - Void

- (void)hideButton;

- (void)bringButton;

- (void)enterPinAlert;

- (void)playSoundForKey;

- (void)signOutFromApp;

- (void)signOutFromAppSilent;

- (void)resetXMPPCoreDataStorage;

- (void)processAfterDeviceRegistration;


- (void)setLoginType:(NSInteger)isLogged;

- (void)setUserType:(NSInteger)isPhysician;


- (void)setProfilePic:(NSString *)imageData withImage:(NSData *)imageData1;


- (void)sendFileTransFerNotification:(NSString *)toUser withFileName:(NSString *)fName withImage:(UIImage *)img;


#pragma mark - Connect

- (BOOL)connect;

- (BOOL)isConnected;

/*- (BOOL)appIsDisconnected;*/


- (void)resendMessage:(ChatMessage *) chatmessage;

- (void)recheckAndResendMessage:(ChatMessage *)message;


- (void)sendMsg:(NSString *)msg toIMYourDocUser:(NSString *)toUser withMessageID:(NSString *)msgID;

- (void)sendChatState:(SendChatStateType)chatState withBuddy:(NSString *)buddy withMessageID:(NSString *)msgID isGroupChat:(BOOL) isgpchat;
- (void)sendDeliveredForMessageID:(NSString *)messageID fromJID:(NSString *)fromJID;

- (void)sendFileTransferMessagetoUser:(NSString *)toUser withFileName:(NSString *)fName withImage:(NSString *)img withMessageID:(NSString *)messageID type:(NSString *) type ;

- (void)sendFileTransferMessagetoGroup:(NSString *)toGroup withFileName:(NSString *)fName withImage:(NSString *)img withMessageID:(NSString *)messageID type:(NSString *) type ;


-(NSArray *)fetchChatMessageOfNoneReceiverStatus; // fetch message for send delivery to server.

- (VCard *)fetchVCard:(XMPPJID *)jid;

-(OfflineContact *)fetchInsertExternamContact:(NSString *)streamJID phoneNo:(NSString *)phoneNo email:(NSString *)email firstName:(NSString *)firstName lastName:(NSString *)lastName;

-(void)addInboxMessage:(ChatMessage *)message;
-(InboxMessage*)addInboxMessageGroupChat:(ChatMessage *)message;

- (BOOL)addChatMessage:(ChatMessage*)message toInboxMessage:(InboxMessage*)inboxMessage;

-(InboxMessage*)addInboxMessageWithThreadModel:(ThreadContentModel*)threadContentModel;

- (void) getRoster;
- (void)getVcard:(XMPPJID *)jid;

#pragma mark - load old messages

- (void) clearChatDataOnLogout;


/*
 *
 *
 * @param userJID:  is the id of user to whom we are chating.
 * @return : nil
 *
 * @see hideHUDForView:animated:
 * @
 */

-(void)sendGroupMessageToServer:(NSString *)messageID roomJID:(NSString *)roomJID;

-(void)addTimerForMessage:(NSString *) messageID;

-(void)loadPhoneContacts;

#pragma mark -connection

- (BOOL)isConnecting;

- (BOOL)isAuthenticating;



#pragma mark for catedory 
#pragma mark - Service Response
-(void)service_ReportCloseConversationWithjid:(NSString*)jid;


- (NSUInteger )unreadMessages;
- (void) backgroundNotification:(NSString *)message withxMPPmessage:(XMPPMessage *)xMPPmessage;
-(ChatMessage *)insertChatMessage:(NSString *)messageID;



#pragma mark simpel
-(void)updateOpenConversationArray:(NSString *)forURI;


#pragma broadcast 
-(void)addBcInboxMessage:(ChatMessage *)message;




@end

