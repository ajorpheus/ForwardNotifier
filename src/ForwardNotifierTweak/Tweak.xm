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

GLog *logger = [[GLog alloc] initWithIP:@"10.0.0.99" andPort:@"5000"];
static void loadPrefs() {
    [logger sendLog:@"QWERTYASDF: *********** Your logs"];
    NSLog(@"QWERTYASDF: in loadPrefs forwardNotifierLog ");
    NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.greg0109.forwardnotifierprefs.plist"];
    NSLog(@"QWERTYASDF: in function loadPrefs, Line 41");
    receiver = prefs[@"receiver"] ? [prefs[@"receiver"] boolValue]:NO;
    errorlog = prefs[@"errorlog"] ? [prefs[@"errorlog"] boolValue]:NO;
    lockstateenabled = prefs[@"lockstateenabled"] ? [prefs[@"lockstateenabled"] boolValue]:YES;
    pcspecifier = prefs[@"pcspecifier"] ? [prefs[@"pcspecifier"] intValue]:0;
    NSLog(@"QWERTYASDF: in function loadPrefs, Line 46");
    NSLog(@"QWERTYASDF: in function  loadPrefs, Line 47");
    NSLog(@"QWERTYASDF: in function  loadPrefs, Line 48");
    NSLog(@"QWERTYASDF: in function  loadPrefs, Line 49");


    methodspecifier = prefs[@"methodspecifier"] ? [prefs[@"methodspecifier"] intValue]:0;
    keyauthentication = prefs[@"keyauthentication"] ? [prefs[@"keyauthentication"] boolValue]:NO;
    user = prefs[@"user"] && !([prefs[@"user"] isEqualToString:@""]) ? [prefs[@"user"] stringValue]:@"user";
    ip = prefs[@"ip"] && !([prefs[@"ip"] isEqualToString:@""]) ? [prefs[@"ip"] stringValue]:@"ip";
    port = prefs[@"port"] && !([prefs[@"port"] isEqualToString:@""]) ? [prefs[@"port"] stringValue]:@"22";
    NSLog(@"QWERTYASDF: in function loadPrefs, Line 57");
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

    NSLog(@"QWERTYASDF: in function  getBBServerQueue, Line 71");

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

    NSLog(@"QWERTYASDF: in function  hook BBServer, Line 90");

    notificationserver = %orig;
    return notificationserver;
}

- (id)initWithQueue:(id)arg1 dataProviderManager:(id)arg2 syncService:(id)arg3 dismissalSyncCache:(id)arg4 observerListener:(id)arg5 utilitiesListener:(id)arg6 conduitListener:(id)arg7 systemStateListener:(id)arg8 settingsListener:(id)arg9 {

    NSLog(@"QWERTYASDF: in function  hook BBServer, Line 98");

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

    NSLog(@"QWERTYASDF: in function  getBBServerQueue, Line 115");

    bulletin.title = titletest;
    bulletin.message = messagetest;
    NSLog(@"QWERTYASDF: in function  getBBServerQueue, Line 119");

    bulletin.sectionID = @"com.apple.Preferences";
    bulletin.bulletinID = [[NSProcessInfo processInfo] globallyUniqueString];
    bulletin.recordID = [[NSProcessInfo processInfo] globallyUniqueString];
    bulletin.publisherBulletinID = [[NSProcessInfo processInfo] globallyUniqueString];
    bulletin.date = [NSDate date];
    bulletin.defaultAction = [%c(BBAction) actionWithLaunchBundleID:@"prefs:root=ForwardNotifier" callblock:nil];

    NSLog(@"QWERTYASDF: in function  getBBServerQueue, Line 128");

    dispatch_sync(getBBServerQueue(), ^{
        [notificationserver publishBulletin:bulletin destinations:14];
    });
}

BOOL isItLocked() {

    NSLog(@"QWERTYASDF: in function  isItLocked, Line 137");

    if(lockstateenabled) {
        NSLog(@"QWERTYASDF: in function  isItLocked: lockstateenabled=true, Line 140");

        locked = [[%c(SBLockStateAggregator) sharedInstance] lockState];
    } else {
        NSLog(@"QWERTYASDF: in function  isItLocked: lockstateenabled=false, Line 144");

        locked = YES;
    }
    NSLog(@"QWERTYASDF: in function  isItLocked, Line 148");

    return locked;
}

void sanitizeText() { // Thanks Tom for the idea of using \ everywhere :P
    NSLog(@"QWERTYASDF: in function  sanitizeText, Line 154");

    finalTitle = [@"" mutableCopy];
    NSLog(@"QWERTYASDF: in function  sanitizeText, Line 157");

    for(int i = 0; i < title.length; i++) {
        NSLog(@"QWERTYASDF: in function  sanitizeText, Line 160");

        NSString *charSelected = [title substringWithRange:NSMakeRange(i, 1)];
        NSLog(@"QWERTYASDF: in function  sanitizeText, Line 163");

        if([charSelected isEqualToString:@" "]) {
            NSLog(@"QWERTYASDF: in function  sanitizeText, Line 166");
            charSelected = @" ";
        } else {
            NSLog(@"QWERTYASDF: in function  sanitizeText, Line 169");

            charSelected = [NSString stringWithFormat:@"\\%@", charSelected];
        }
        NSLog(@"QWERTYASDF: in function  sanitizeText, Line 173");

        [finalTitle appendString:charSelected];
    }
    NSLog(@"QWERTYASDF: in function  sanitizeText, Line 177");

    finalMessage = [@"" mutableCopy];
    NSLog(@"QWERTYASDF: in function  sanitizeText, Line 180");

    for(int i = 0; i < message.length; i++) {
        NSLog(@"QWERTYASDF: in function  sanitizeText, Line 183");

        NSString *charSelected = [message substringWithRange:NSMakeRange(i, 1)];
        NSLog(@"QWERTYASDF: in function  sanitizeText, Line 186");

        if([charSelected isEqualToString:@" "]) {
          NSLog(@"QWERTYASDF: in function  sanitizeText, Line 189");

            charSelected = @" ";
        } else {
            NSLog(@"QWERTYASDF: in function  sanitizeText, Line 193");

            charSelected = [NSString stringWithFormat:@"\\%@", charSelected];
        }
        NSLog(@"QWERTYASDF: in function  sanitizeText, Line 197");

        [finalMessage appendString:charSelected];
    }
}

void pushnotif(BOOL override) {
    NSLog(@"QWERTYASDF: in function  pushnotif, Line 204");


    if(!override) {
        NSLog(@"QWERTYASDF: in function  pushnotif, Line 208");

        isItLocked();
    } else {
        NSLog(@"QWERTYASDF: in function  pushnotif, Line 212");

        locked = YES;
    }
    if(methodspecifier == 0) { // SSH
        NSLog(@"QWERTYASDF: in function  pushnotif:SSH, Line 217");

        if([[[NSUserDefaults standardUserDefaults] stringForKey:@"ForwardNotifier-Status"] isEqual:@"1"] && (locked)) {
            NSLog(@"QWERTYASDF: in function  pushnotif: ForwardNotifier-Status 1 and Locked=true, Line 220");

            dispatch_queue_t sendnotif = dispatch_queue_create("Send Notif", NULL);
            dispatch_async(sendnotif, ^{
                NSLog(@"QWERTYASDF: in function  pushnotif: ForwardNotifier-Status 1 and Locked=true, Line 224");
                pc = [NSString stringWithFormat:@"%@@%@", user, ip];
                NSLog(@"******** QWERTYASDF: in function  pushnotif: just before sanitizeText, Line 226");
                sanitizeText();
                if(pcspecifier == 0) { // Linux
                NSLog(@"QWERTYASDF: in function  pushnotif: pcspecifier Linux, Line 229");

                    finalCommand = [NSString stringWithFormat:@"\"$(echo %@)\" \"$(echo %@)\"", finalTitle, finalMessage];
                    command = [NSString stringWithFormat:@"notify-send -i applications-development %@", finalCommand];
                    //NSLog(@"ForwardNotifier: %@", command);
                } else if(pcspecifier == 1) { // MacOS
                NSLog(@"QWERTYASDF: in function  pushnotif: pcspecifier macos, Line 235");
                    finalCommand = [NSString stringWithFormat:@"-title \"$(echo %@)\" -message \"$(echo %@)\"", finalTitle, finalMessage];
                    command = [NSString stringWithFormat:@"/usr/local/bin/terminal-notifier -sound pop %@", finalCommand];
                } else if(pcspecifier == 2) { // iOS
                NSLog(@"QWERTYASDF: in function  pushnotif: pcspecifier ios, Line 239");
                    finalCommand = [NSString stringWithFormat:@"\"$(echo %@)\" \"$(echo %@)\"", finalTitle, finalMessage];
                    command = [NSString stringWithFormat:@"ForwardNotifierReceiver %@", finalCommand];
                } else if(pcspecifier == 3) { // Windows
                NSLog(@"QWERTYASDF: in function  pushnotif: pcspecifier windows, Line 243");
                    finalCommand = [NSString stringWithFormat:@"-title \"$(echo %@)\" -message \"$(echo %@)\"", finalTitle, finalMessage];
                    command = [NSString stringWithFormat:@"ForwardNotifierReceiver %@", finalCommand];
                }
                if(keyauthentication) {
                    NSLog(@"QWERTYASDF: in function  pushnotif:keyauth block , Line 248");

                    if([port isEqual:@"22"]) {
                        arguments = @[ @"-i", password, pc, command ];
                    } else {
                        arguments = @[ @"-i", password, pc, @"-p", port, command ];
                    }
                    NSLog(@"QWERTYASDF: in function  pushnotif:keyauth block, Line 255");

                    NSTask *task = [[NSTask alloc] init];
                    NSLog(@"QWERTYASDF: in function  pushnotif:keyauth block, Line 258");

                    [task setLaunchPath:@"/usr/bin/ssh"];
                    [task setArguments:arguments];
                    NSLog(@"QWERTYASDF: in function  pushnotif:keyauth block, Line 262");

                    out = [NSPipe pipe];
                    [task setStandardError:out];
                    [task launch];
                    [task waitUntilExit];
                } else {
                    NSLog(@"QWERTYASDF: in function  pushnotif:keyauth else block, Line 269");

                    if([port isEqual:@"22"]) {
                        NSLog(@"QWERTYASDF: in function  pushnotif:keyauth else block, Line 272");
                        arguments = @[ @"-p", password, @"ssh", @"-o", @"StrictHostKeyChecking=no", pc, command ];
                    } else {
                        NSLog(@"QWERTYASDF: in function  pushnotif:keyauth else block, Line 275");
                        arguments = @[ @"-p", password, @"ssh", @"-o", @"StrictHostKeyChecking=no", pc, @"-p", port, command ];
                    }
                    NSLog(@"QWERTYASDF: in function  pushnotif, Line 278");

                    NSTask *task = [[NSTask alloc] init];
                    [task setLaunchPath:@"/usr/bin/sshpass"];
                    [task setArguments:arguments];

                    NSLog(@"QWERTYASDF: in function  pushnotif, Line 284");

                    out = [NSPipe pipe];
                    [task setStandardError:out];
                    [task launch];
                    [task waitUntilExit];
                }

                NSLog(@"QWERTYASDF: in function  pushnotif: just before some file ops, Line 292");

                NSFileHandle *read = [out fileHandleForReading];
                NSData *dataRead = [read readDataToEndOfFile];
                NSString *erroroutput = [[NSString alloc] initWithData:dataRead encoding:NSUTF8StringEncoding];
                if([erroroutput length] > 2 && errorlog) {
                    testnotif(@"ForwardNotifier Error", erroroutput);
                }
            });
        }
    } else if(methodspecifier == 1) { // Crossplatform Server
        NSLog(@"QWERTYASDF: in function  pushnotif: Crossplatform server, Line 303");
        // Get Icon data
        NSLog(@"QWERTYASDF: in function  pushnotif, Line 305");

        SBApplicationIcon *icon = [((SBIconController *)[%c(SBIconController) sharedInstance]).model expectedIconForDisplayIdentifier:bundleID];
        NSLog(@"QWERTYASDF: in function  pushnotif, Line 308");

        UIImage *image = nil;
        iconspecs.size = CGSizeMake(60, 60);
        iconspecs.scale = [UIScreen mainScreen].scale;
        iconspecs.continuousCornerRadius = 12;
        image = [icon generateIconImageWithInfo:iconspecs];
        NSLog(@"QWERTYASDF: in function  pushnotif, Line 315");

        NSData *iconData = UIImagePNGRepresentation(image);
        NSString *iconBase64;
        if(![title isEqualToString:@"ForwardNotifier Test"]) {
            NSLog(@"QWERTYASDF: in function  pushnotif, Line 320");

            iconBase64 = [iconData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
        } else {
            NSLog(@"QWERTYASDF: in function  pushnotif, Line 324");

            iconBase64 = forwardNotifierIconBase64;
        }
        // Base64 both title and message
        NSLog(@"QWERTYASDF: in function  pushnotif, Line 329");

        NSData *titleData = [title dataUsingEncoding:NSUTF8StringEncoding];
        NSString *titleBase64 = [titleData base64EncodedStringWithOptions:0];
        NSData *messageData = [message dataUsingEncoding:NSUTF8StringEncoding];
        NSString *messageBase64 = [messageData base64EncodedStringWithOptions:0];
        if([[[NSUserDefaults standardUserDefaults] stringForKey:@"ForwardNotifier-Status"] isEqual:@"1"] && (locked)) {
            NSLog(@"QWERTYASDF: in function  pushnotif, Line 336");

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

        NSLog(@"QWERTYASDF: in function  pushnotif, Line 384");

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
    NSLog(@"QWERTYASDF: in function  pushnotif, Line 403");


    if(!wantsToBeForwarded) return;

    NSLog(@"QWERTYASDF: in function  pushnotif, Line 408");

    title = arg1.content.title;
    message = arg1.content.message;
    bundleID = arg1.sectionID;
    NSLog(@"QWERTYASDF: in function  pushnotif, Line 413");

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
            NSLog(@"QWERTYASDF: in function  pushnotif, Line 469");

            NSString *titlenotif = notification.userInfo[@"title"];
            NSString *messagenotif = notification.userInfo[@"message"];

            NSLog(@"QWERTYASDF: in function  pushnotif, Line 474");

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
