#import <Foundation/Foundation.h>
#import "../ForwardNotifierPrefs/NBPNotificationFilter.h"

struct FNBlockResult {
    BOOL block;
    BOOL forward;
    BOOL showInNC;
    BOOL wakeDevice;
};

@interface BBSound
@end

@interface BBBulletinRequest
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSString *bulletinID;
@property (nonatomic, copy) NSString *sectionID;
@property (nonatomic, retain) BBSound *sound;
@property (assign, nonatomic) BOOL turnsOnDisplay;
@end

@class BBSectionIcon, BBAction, BBContent;
@interface BBBulletin : BBBulletinRequest
@property (nonatomic, retain) BBSectionIcon *icon;
@property (nonatomic, retain) NSString *recordID;
@property (nonatomic, retain) NSString *publisherBulletinID;
@property (nonatomic, retain) NSString *sectionDisplayName;
@property (nonatomic, retain) NSDate *date;
@property (nonatomic, copy) BBAction *defaultAction;
@property (nonatomic, retain) BBContent *content;
@end

@interface BBAction : NSObject
+ (id)actionWithLaunchURL:(id)arg1 callblock:(/*^block*/ id)arg2;
+ (id)actionWithLaunchBundleID:(id)arg1 callblock:(/*^block*/ id)arg2;
+ (id)actionWithCallblock:(/*^block*/ id)arg1;
+ (id)actionWithAppearance:(id)arg1;
+ (id)actionWithLaunchURL:(id)arg1;
+ (id)actionWithActivatePluginName:(id)arg1 activationContext:(id)arg2;
+ (id)actionWithIdentifier:(id)arg1;
+ (id)actionWithIdentifier:(id)arg1 title:(id)arg2;
+ (id)actionWithLaunchBundleID:(id)arg1;
@end

@class BBContent;
@interface BBContent : NSObject
@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) NSString *title;
@end

@interface BBServer
- (void)publishBulletin:(id)arg1 destinations:(unsigned long long)arg2;
- (void)_clearBulletinIDs:(id)arg1 forSectionID:(id)arg2 shouldSync:(BOOL)arg3;
@end

@interface NCNotificationViewController : UIViewController
@end

@interface NCNotificationShortLookViewController : NCNotificationViewController
- (id)_initWithNotificationRequest:(id)arg1 revealingAdditionalContentOnPresentation:(BOOL)arg2;
@end

@interface NCNotificationRequest
@property (nonatomic, readonly) BBBulletin *bulletin;
@end

@interface FNNotiBlockChecker : NSObject
+ (struct FNBlockResult)blockTypeForBulletin:(BBBulletin *)bulletin;
+ (BOOL)areWeCurrentlyInSchedule:(NSDate *)startTime arg2:(NSDate *)endTime arg3:(NSArray *)weekdays;
+ (BOOL)doesMessageMatchFilterType:(BOOL)titleMatches arg2:(BOOL)subtitleMatches arg3:(BOOL)messageMatches arg4:(int)filterType;
+ (void)reloadFilters;
@end