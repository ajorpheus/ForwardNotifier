#import "FNNotiBlockChecker.h"
#import "Tweak.h"
#include "GLog.h"

struct SBIconImageInfo iconspecs;

// Settings
BOOL receiver;
BOOL errorlog;
BOOL lockstateenabled;
int pcspecifier;

// Settings
int methodspecifier;
BOOL keyauthentication;
NSString *user;
NSString *ip;
NSString *port;
NSString *password;
NSString *command;
NSString *finalCommand;
NSArray *arguments;

// Notifications
NSString *pc;
NSString *title;
NSMutableString *finalTitle;
NSString *message;
NSMutableString *finalMessage;
NSString *bundleID;
NSString *appName;
BOOL locked;

// For the error output
NSPipe *out;
static BBServer *notificationserver = nil;

@interface StringCleaner:NSObject
-(NSString*)removeUTFChars: (NSString*) badString;
@end

@implementation StringCleaner
-(NSString*)removeUTFChars: (NSString*) badString{
    NSString *s = badString; 
    NSMutableString *sant = [@"" mutableCopy];
    NSRange fullRange = NSMakeRange(0, [s length]);
    [s enumerateSubstringsInRange:fullRange
                          options:NSStringEnumerationByComposedCharacterSequences
                       usingBlock:^(NSString *substring, NSRange substringRange,
                                    NSRange enclosingRange, BOOL *stop)
    {
        long num = substringRange.length ;
        RLog(@"QWERTYASDF: %@ %@", substring, @(num));
        
        if (num > 1) {
            [sant appendString:@"X"];
        } else {
            [sant appendString:substring] ;
        }
    }];
    RLog (@"QWERTYASDF: Result: -%@-", sant);
    
    return sant;
}
@end

static void loadPrefs() {
    NSString *str = @"Hello world";
    [str writeToFile:@"/private/var/mobile/hello.txt" atomically:YES encoding:NSUTF8StringEncoding error:nil];

    NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.greg0109.forwardnotifierprefs.plist"];
    RLog(@"QWERTYASDF: STARTING in function loadPrefs, Line 77");
    receiver = prefs[@"receiver"] ? [prefs[@"receiver"] boolValue]:NO;
    errorlog = prefs[@"errorlog"] ? [prefs[@"errorlog"] boolValue]:NO;
    lockstateenabled = prefs[@"lockstateenabled"] ? [prefs[@"lockstateenabled"] boolValue]:YES;
    pcspecifier = prefs[@"pcspecifier"] ? [prefs[@"pcspecifier"] intValue]:0;
    RLog(@"QWERTYASDF: in function loadPrefs, Line 82");

    methodspecifier = prefs[@"methodspecifier"] ? [prefs[@"methodspecifier"] intValue]:0;
    keyauthentication = prefs[@"keyauthentication"] ? [prefs[@"keyauthentication"] boolValue]:NO;
    user = prefs[@"user"] && !([prefs[@"user"] isEqualToString:@""]) ? [prefs[@"user"] stringValue]:@"user";
    ip = prefs[@"ip"] && !([prefs[@"ip"] isEqualToString:@""]) ? [prefs[@"ip"] stringValue]:@"ip";
    port = prefs[@"port"] && !([prefs[@"port"] isEqualToString:@""]) ? [prefs[@"port"] stringValue]:@"22";
    RLog(@"QWERTYASDF: in function loadPrefs, Line 93");
    password = prefs[@"password"] && !([prefs[@"password"] isEqualToString:@""]) ? [prefs[@"password"] stringValue]:@"password";
    user = [user stringByReplacingOccurrencesOfString:@" " withString:@""];
    ip = [ip stringByReplacingOccurrencesOfString:@" " withString:@""];
    password = [password stringByReplacingOccurrencesOfString:@" " withString:@""];

    // NOTI BLOCK STUFF
    [FNNotiBlockChecker reloadFilters];
}

static dispatch_queue_t getBBServerQueue() {
    static dispatch_queue_t queue;
    static dispatch_once_t predicate;

    RLog(@"QWERTYASDF: in function  getBBServerQueue, Line 107");

    dispatch_once(&predicate, ^{
        void *handle = dlopen(NULL, RTLD_GLOBAL);
        if(handle) {
            dispatch_queue_t __weak *pointer = (__weak dispatch_queue_t *)dlsym(handle, "__BBServerQueue");
            if(pointer) {
                queue = *pointer;
            }
            dlclose(handle);
        }
    });
    return queue;
}

%hook BBServer

- (id)initWithQueue:(id)arg1 {

    RLog(@"QWERTYASDF: in function  hook BBServer, Line 126");

    notificationserver = %orig;
    return notificationserver;
}

- (id)initWithQueue:(id)arg1 dataProviderManager:(id)arg2 syncService:(id)arg3 dismissalSyncCache:(id)arg4 observerListener:(id)arg5 utilitiesListener:(id)arg6 conduitListener:(id)arg7 systemStateListener:(id)arg8 settingsListener:(id)arg9 {

    RLog(@"QWERTYASDF: in function  hook BBServer, Line 134");

    notificationserver = %orig;
    return notificationserver;
}
- (void)dealloc {
    if(notificationserver == self) {
        notificationserver = nil;
    }
    %orig;
}

%end

void testnotif(NSString *titletest, NSString *messagetest) {

    BBBulletin *bulletin = [[%c(BBBulletin) alloc] init];

    RLog(@"QWERTYASDF: in function  getBBServerQueue, Line 151");

    bulletin.title = titletest;
    bulletin.message = messagetest;
    RLog(@"QWERTYASDF: in function  getBBServerQueue, Line 155");

    bulletin.sectionID = @"com.apple.Preferences";
    bulletin.bulletinID = [[NSProcessInfo processInfo] globallyUniqueString];
    bulletin.recordID = [[NSProcessInfo processInfo] globallyUniqueString];
    bulletin.publisherBulletinID = [[NSProcessInfo processInfo] globallyUniqueString];
    bulletin.date = [NSDate date];
    bulletin.defaultAction = [%c(BBAction) actionWithLaunchBundleID:@"prefs:root=ForwardNotifier" callblock:nil];

    RLog(@"QWERTYASDF: in function  getBBServerQueue, Line 164");

    dispatch_sync(getBBServerQueue(), ^{
        [notificationserver publishBulletin:bulletin destinations:14];
    });
}

BOOL isItLocked() {

    RLog(@"QWERTYASDF: in function  isItLocked, Line 173");

    if(lockstateenabled) {
        RLog(@"QWERTYASDF: in function  isItLocked: lockstateenabled=true, Line 176");

        locked = [[%c(SBLockStateAggregator) sharedInstance] lockState];
    } else {
        RLog(@"QWERTYASDF: in function  isItLocked: lockstateenabled=false, Line 180");

        locked = YES;
    }
    RLog(@"QWERTYASDF: in function  isItLocked, Line 184");

    return locked;
}


void sanitizeText() { // Thanks Tom for the idea of using \ everywhere :P
    NSLog(@"******************************* QWERTYASDF: in function  sanitizeText, Line 191 ( title: %@)", title);

    RLog(@"******** QWERTYASDF: in function  sanitizeText, Line 190");
    RLog(@"QWERTYASDF: in function  sanitizeText, Line 191 ( title: %@)", title);
    RLog(@"QWERTYASDF: in function  sanitizeText, Line 192 ( message: %@)", message);

    StringCleaner *stringCleaner = [[StringCleaner alloc]init];
    title = [stringCleaner removeUTFChars:title] ; 
    message = [stringCleaner removeUTFChars:message] ; 
    RLog(@"QWERTYASDF: in function  sanitizeText, Line 197 ( cleaned title: %@)", title);
    RLog(@"QWERTYASDF: in function  sanitizeText, Line 198 ( cleaned message: %@)", message);

    finalTitle = [@"" mutableCopy];

    RLog(@"QWERTYASDF: in function  sanitizeText: just before title eval, Line 202");
    for(int i = 0; i < title.length; i++) {
        RLog(@"QWERTYASDF: in function  sanitizeText, Line 204");
        NSString *charSelected = [title substringWithRange:NSMakeRange(i, 1)];
        RLog(@"QWERTYASDF: in function  sanitizeText, Line 206 ( charSelected: %@)", charSelected);

        if([charSelected isEqualToString:@" "]) {
            RLog(@"QWERTYASDF: in function  sanitizeText, Line 209");
            charSelected = @" ";
            RLog(@"QWERTYASDF: in function  sanitizeText, Line 211 ( charSelected: %@)", charSelected);
        } else {
            RLog(@"QWERTYASDF: in function  sanitizeText, Line 213");

            charSelected = [NSString stringWithFormat:@"\\%@", charSelected];
            RLog(@"QWERTYASDF: in function  sanitizeText, Line 216 ( charSelected: %@)", charSelected);
        }

        RLog(@"QWERTYASDF: in function  sanitizeText, Line 219 ( title: %@ -> finalTitle -> %@ )", title, finalTitle);
        [finalTitle appendString:charSelected];
    }
    RLog(@"QWERTYASDF: in function  sanitizeText: end of finalTitle eval, Line 222");

    finalMessage = [@"" mutableCopy];
    RLog(@"QWERTYASDF: in function  sanitizeText, Line 225 (finalMessage:%@     ,  message: %@)", finalMessage, message);

    for(int i = 0; i < message.length; i++) {
        RLog(@"QWERTYASDF: in function  sanitizeText : just before substringWithRange, Line 228");
        NSString *charSelected = [message substringWithRange:NSMakeRange(i, 1)];
        RLog(@"QWERTYASDF: in function  sanitizeText, Line 230 ( charSelected: %@)", charSelected);

        if([charSelected isEqualToString:@" "]) {
            RLog(@"QWERTYASDF: in function  sanitizeText, Line 233");
            charSelected = @" ";
            RLog(@"QWERTYASDF: in function  sanitizeText, Line 235 ( charSelected: %@)", charSelected);
        } else {
            RLog(@"QWERTYASDF: in function  sanitizeText, Line 237");
            charSelected = [NSString stringWithFormat:@"\\%@", charSelected];
            RLog(@"QWERTYASDF: in function  sanitizeText, Line 239 ( charSelected: %@)", charSelected);
        }
        
        [finalMessage appendString:charSelected];
        RLog(@"QWERTYASDF: in function  sanitizeText, Line 243 ( finalMessage: %@)", finalMessage);
    }
    RLog(@"QWERTYASDF: in function  sanitizeText: end of finalMessage eval, Line 245");

    RLog(@"******** QWERTYASDF: end of function  sanitizeText, Line 247");
    RLog(@"QWERTYASDF: in function  sanitizeText, Line 248 (finalMessage:%@     ,  message: %@)", finalMessage, message);
    RLog(@"QWERTYASDF: in function  sanitizeText, Line 249 (finalTitle:%@     ,  title: %@)", finalTitle, title);
    RLog(@"******** QWERTYASDF: end of function  sanitizeText, Line 250");
}

void pushnotif(BOOL override) {
    RLog(@"QWERTYASDF: in function  pushnotif, Line 254");


    if(!override) {
        RLog(@"QWERTYASDF: in function  pushnotif, Line 258");

        isItLocked();
    } else {
        RLog(@"QWERTYASDF: in function  pushnotif, Line 262");

        locked = YES;
    }
    if(methodspecifier == 0) { // SSH
        RLog(@"QWERTYASDF: in function  pushnotif:SSH, Line 267");

        if([[[NSUserDefaults standardUserDefaults] stringForKey:@"ForwardNotifier-Status"] isEqual:@"1"] && (locked)) {
            RLog(@"QWERTYASDF: in function  pushnotif: ForwardNotifier-Status 1 and Locked=true, Line 270");

            dispatch_queue_t sendnotif = dispatch_queue_create("Send Notif", NULL);
            dispatch_async(sendnotif, ^{
                RLog(@"QWERTYASDF: in function  pushnotif: ForwardNotifier-Status 1 and Locked=true, Line 274");
                pc = [NSString stringWithFormat:@"%@@%@", user, ip];

                RLog(@"******** QWERTYASDF: in function  pushnotif: just before sanitizeText, Line 277");
                sanitizeText();
                RLog(@"********** QWERTYASDF: BACK from sanitizeText, Line 279");

                if(pcspecifier == 0) { // Linux
                RLog(@"QWERTYASDF: in function  pushnotif: pcspecifier Linux, Line 282");

                    finalCommand = [NSString stringWithFormat:@"\"$(echo %@)\" \"$(echo %@)\"", finalTitle, finalMessage];
                    command = [NSString stringWithFormat:@"notify-send -i applications-development %@", finalCommand];
                    //RLog(@"ForwardNotifier: %@", command);
                } else if(pcspecifier == 1) { // MacOS
                RLog(@"QWERTYASDF: in function  pushnotif: pcspecifier macos, Line 288");
                    finalCommand = [NSString stringWithFormat:@"-title \"$(echo %@)\" -message \"$(echo %@)\"", finalTitle, finalMessage];
                    command = [NSString stringWithFormat:@"/usr/local/bin/terminal-notifier -sound pop %@", finalCommand];
                } else if(pcspecifier == 2) { // iOS
                RLog(@"QWERTYASDF: in function  pushnotif: pcspecifier ios, Line 292");
                    finalCommand = [NSString stringWithFormat:@"\"$(echo %@)\" \"$(echo %@)\"", finalTitle, finalMessage];
                    command = [NSString stringWithFormat:@"ForwardNotifierReceiver %@", finalCommand];
                } else if(pcspecifier == 3) { // Windows
                RLog(@"QWERTYASDF: in function  pushnotif: pcspecifier windows, Line 296");
                    finalCommand = [NSString stringWithFormat:@"-title \"$(echo %@)\" -message \"$(echo %@)\"", finalTitle, finalMessage];
                    command = [NSString stringWithFormat:@"ForwardNotifierReceiver %@", finalCommand];
                }
                RLog(@"******* QWERTYASDF: in function  pushnotif: evaluating command , Line 300 (command: %@)", command);

                if(keyauthentication) {
                    RLog(@"QWERTYASDF: in function  pushnotif:keyauth block , Line 303");

                    if([port isEqual:@"22"]) {
                        arguments = @[ @"-i", password, pc, command ];
                    } else {
                        arguments = @[ @"-i", password, pc, @"-p", port, command ];
                    }
                    RLog(@"QWERTYASDF: in function  pushnotif:keyauth block, Line 310");

                    NSTask *task = [[NSTask alloc] init];
                    RLog(@"QWERTYASDF: in function  pushnotif:keyauth block, Line 313");

                    [task setLaunchPath:@"/usr/bin/ssh"];
                    [task setArguments:arguments];
                    RLog(@"QWERTYASDF: in function  pushnotif:keyauth block, Line 317");

                    out = [NSPipe pipe];
                    [task setStandardError:out];
                    [task launch];
                    [task waitUntilExit];

                    RLog(@"******* QWERTYASDF: in function  FINISHED SENDING COMMAND sanitizeText, Line 326");

                } else {
                    RLog(@"QWERTYASDF: in function  pushnotif:keyauth else block, Line 329");

                    if([port isEqual:@"22"]) {
                        RLog(@"QWERTYASDF: in function  pushnotif:keyauth else block, Line 332");
                        arguments = @[ @"-p", password, @"ssh", @"-o", @"StrictHostKeyChecking=no", pc, command ];
                    } else {
                        RLog(@"QWERTYASDF: in function  pushnotif:keyauth else block, Line 335");
                        arguments = @[ @"-p", password, @"ssh", @"-o", @"StrictHostKeyChecking=no", pc, @"-p", port, command ];
                    }
                    RLog(@"QWERTYASDF: in function  pushnotif, Line 338");

                    NSTask *task = [[NSTask alloc] init];
                    [task setLaunchPath:@"/usr/bin/sshpass"];
                    [task setArguments:arguments];

                    RLog(@"QWERTYASDF: in function  pushnotif, Line 344");

                    out = [NSPipe pipe];
                    [task setStandardError:out];
                    [task launch];
                    [task waitUntilExit];

                    RLog(@"QWERTYASDF: in function  sanitizeText, Line 351");
                    RLog(@"******* QWERTYASDF: in function  FINISHED SENDING COMMAND sanitizeText, Line 352");

                }

                RLog(@"QWERTYASDF: in function  pushnotif: just before some file ops, Line 356");

                NSFileHandle *read = [out fileHandleForReading];
                NSData *dataRead = [read readDataToEndOfFile];
                NSString *erroroutput = [[NSString alloc] initWithData:dataRead encoding:NSUTF8StringEncoding];
                if([erroroutput length] > 2 && errorlog) {
                    testnotif(@"ForwardNotifier Error", erroroutput);
                }
            });
        }
    } else if(methodspecifier == 1) { // Crossplatform Server
        RLog(@"QWERTYASDF: in function  pushnotif: Crossplatform server, Line 367");
        // Get Icon data
        RLog(@"QWERTYASDF: in function  pushnotif, Line 369");

        SBApplicationIcon *icon = [((SBIconController *)[%c(SBIconController) sharedInstance]).model expectedIconForDisplayIdentifier:bundleID];
        RLog(@"QWERTYASDF: in function  pushnotif, Line 372");

        UIImage *image = nil;
        iconspecs.size = CGSizeMake(60, 60);
        iconspecs.scale = [UIScreen mainScreen].scale;
        iconspecs.continuousCornerRadius = 12;
        image = [icon generateIconImageWithInfo:iconspecs];
        RLog(@"QWERTYASDF: in function  pushnotif, Line 379");

        NSData *iconData = UIImagePNGRepresentation(image);
        NSString *iconBase64;
        if(![title isEqualToString:@"ForwardNotifier Test"]) {
            RLog(@"QWERTYASDF: in function  pushnotif, Line 384");

            iconBase64 = [iconData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
        } else {
            RLog(@"QWERTYASDF: in function  pushnotif, Line 388");

            iconBase64 = forwardNotifierIconBase64;
        }
        // Base64 both title and message
        RLog(@"QWERTYASDF: in function  pushnotif, Line 393");

        NSData *titleData = [title dataUsingEncoding:NSUTF8StringEncoding];
        NSString *titleBase64 = [titleData base64EncodedStringWithOptions:0];
        NSData *messageData = [message dataUsingEncoding:NSUTF8StringEncoding];
        NSString *messageBase64 = [messageData base64EncodedStringWithOptions:0];
        if([[[NSUserDefaults standardUserDefaults] stringForKey:@"ForwardNotifier-Status"] isEqual:@"1"] && (locked)) {
            RLog(@"QWERTYASDF: in function  pushnotif, Line 400");

            dispatch_queue_t sendnotif = dispatch_queue_create("Send Notif", NULL);
            dispatch_async(sendnotif, ^{
                title = [title stringByReplacingOccurrencesOfString:@"\""
                                                         withString:@"\\"
                                                                     "\""];
                message = [message stringByReplacingOccurrencesOfString:@"\""
                                                             withString:@"\\"
                                                                         "\""];
                if(pcspecifier == 0) { // Linux
                    command = [NSString stringWithFormat:@"{\"Title\": \"%@\", \"Message\": \"%@\", \"OS\": \"Linux\", \"img\": \"%@\", \"appname\": \"%@\"}", titleBase64, messageBase64, iconBase64, appName];
                } else if(pcspecifier == 1) { // MacOS
                    command = [NSString stringWithFormat:@"{\"Title\": \"%@\", \"Message\": \"%@\", \"OS\": \"MacOS\", \"img\": \"%@\"}", titleBase64, messageBase64, iconBase64];
                } else if(pcspecifier == 2) { // iOS
                    command = [NSString stringWithFormat:@"{\"Title\": \"%@\", \"Message\": \"%@\", \"OS\": \"iOS\", \"img\": \"%@\"}", titleBase64, messageBase64, iconBase64];
                } else if(pcspecifier == 3) { // Windows
                    command = [NSString stringWithFormat:@"{\"Title\": \"%@\", \"Message\": \"%@\", \"OS\": \"Windows\", \"img\": \"%@\"}", titleBase64, messageBase64, iconBase64];
                }
                NSTask *task = [[NSTask alloc] init];
                [task setLaunchPath:@"/usr/bin/curl"];
                [task setArguments:@[ @"-sS", [NSString stringWithFormat:@"%@:8000", ip], @"-d", command ]];
                out = [NSPipe pipe];
                [task setStandardError:out];
                [task launch];
                [task waitUntilExit];
                NSFileHandle *read = [out fileHandleForReading];
                NSData *dataRead = [read readDataToEndOfFile];
                NSString *erroroutput = [[NSString alloc] initWithData:dataRead encoding:NSUTF8StringEncoding];
                if([erroroutput length] > 2 && errorlog) {
                    if([erroroutput containsString:@"curl"] && ![erroroutput containsString:@"Empty reply"]) {
                        testnotif(@"ForwardNotifier Error", erroroutput);
                    }
                }
            });
        }
    }
}

%group sender


%hook BBServer

- (void)publishBulletin:(BBBulletin *)arg1 destinations:(unsigned long long)arg2 {
    // Ignore dest 2
	struct FNBlockResult blockType = [FNNotiBlockChecker blockTypeForBulletin:arg1 runScript:(arg2 != 2)];
    RLog(@"QWERTYASDF: in function  publishBulletin, Line 448");

    BOOL wantsToBeForwarded = !blockType.block || blockType.forward;
    if(blockType.block) {
        if(!blockType.wakeDevice) {
            arg1.sound = nil;
            arg1.turnsOnDisplay = NO;
        }

        if(!blockType.wakeDevice && !blockType.showInNC && !wantsToBeForwarded)
            return;
    }

    if(!blockType.block || (blockType.wakeDevice || blockType.showInNC)) {
        %orig(arg1, arg2);
        if(blockType.block && !blockType.showInNC) {
            [self _clearBulletinIDs:@[arg1.bulletinID] forSectionID:arg1.sectionID shouldSync:YES];
        }
    }
    RLog(@"QWERTYASDF: in function  publishBulletin, Line 467");


    if(!wantsToBeForwarded) return;

    RLog(@"QWERTYASDF: in function  publishBulletin, Line 472");

    title = arg1.content.title;
    message = arg1.content.message;
    bundleID = arg1.sectionID;
    RLog(@"QWERTYASDF: in function  publishBulletin, Line 477 (title: %@, message: %@, bundleID: %@)", title, message, bundleID);

    SBApplication *app = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:bundleID];
    appName = app.displayName;
    if(([title length] != 0) || ([message length] != 0)) {
        if([title length] == 0) {
            title = app.displayName;
        }
        if(![title containsString:@"ForwardNotifier"] && [arg1.date timeIntervalSinceNow] > -2) { // This helps avoid the notifications to get forwarded again after a respring, which makes them avoid respring loops. If notifications are 2 seconds old, then won't get forwarded.
            NSMutableDictionary *applist = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.greg0109.forwardnotifierblacklist"];
            if(![applist valueForKey:arg1.sectionID] || [[NSString stringWithFormat:@"%@", [applist valueForKey:arg1.sectionID]] isEqual:@"0"]) {
                pushnotif(NO);
            }
        } else if([title isEqualToString:@"ForwardNotifier Test"]) {
            pushnotif(YES);
        }
    }
}

%end


/**
Code to hide the banner dropdown view
**/
%hook NCNotificationShortLookViewController

-(id)_initWithNotificationRequest:(id)arg1 revealingAdditionalContentOnPresentation:(BOOL)arg2 {
	BBBulletin *bulletin = ((NCNotificationRequest *)arg1).bulletin;
	NCNotificationShortLookViewController *temp = %orig;

    struct FNBlockResult blockType = [FNNotiBlockChecker blockTypeForBulletin:bulletin runScript:NO];
	if (blockType.block && !blockType.wakeDevice) {
		self.view.hidden = YES;
		[self.view setUserInteractionEnabled:NO];
	}
	return temp;
}

- (void)viewWillAppear:(BOOL)animated {
	%orig;
	if(self.view.hidden) {
		[self dismissViewControllerAnimated:NO completion:nil];
	}
}

%end


%hook SpringBoard 
- (void)applicationDidFinishLaunching:(id)arg1 {
    [[NSDistributedNotificationCenter defaultCenter] 
        addObserverForName:@"com.greg0109.forwardnotifierreceiver/notification"
            object:nil
            queue:[NSOperationQueue mainQueue]
        usingBlock:^(NSNotification *notification) {
            RLog(@"QWERTYASDF: in function  applicationDidFinishLaunching, Line 533");

            NSString *titlenotif = notification.userInfo[@"title"];
            NSString *messagenotif = notification.userInfo[@"message"];

            RLog(@"QWERTYASDF: in function  applicationDidFinishLaunching, Line 538");

            if([titlenotif isEqualToString:@"ActivateForwardNotifier"]) {
                if([messagenotif isEqualToString:@"true"]) {
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"ForwardNotifier-Status"];
                } else if([messagenotif isEqualToString:@"false"]) {
                    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"ForwardNotifier-Status"];
                }
            } else {
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"ForwardNotifier-Status"];
                title = @"ForwardNotifier Test";
                message = @"This is a test notification";
                testnotif(title, message);
            }
        }];
    %orig;
}
%end 

%end

%group devicereceiver 

%hook SpringBoard 
- (void)applicationDidFinishLaunching:(id)arg1 {
    [[NSDistributedNotificationCenter defaultCenter] addObserverForName:@"com.greg0109.forwardnotifierreceiver/notification"
            object:nil
            queue:[NSOperationQueue mainQueue]
        usingBlock:^(NSNotification *notification) {
            NSString *titlenotif = notification.userInfo[@"title"];
            NSString *messagenotif = notification.userInfo[@"message"];
            testnotif(titlenotif, messagenotif);
        }];
    %orig;
}

%end 

%end

%ctor {
    dlopen("/Library/PreferenceBundles/ForwardNotifier.bundle/ForwardNotifier", RTLD_NOW);
    loadPrefs();
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.greg0109.forwardnotifierprefs.settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
    %init();
    if(receiver) {
        %init(devicereceiver);
    } else {
        %init(sender);
    }
}
