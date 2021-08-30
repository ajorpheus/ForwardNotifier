#import "FNNotiBlockChecker.h"
#include <objc/runtime.h>

NSMutableDictionary *filters;

@implementation FNNotiBlockChecker

+ (void)reloadFilters {
    NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.greg0109.forwardnotifierprefs.plist"];
    NSData *data = [prefs objectForKey:@"filter_array"];

    if(data != nil) {
        filters = [[NSMutableDictionary alloc] init];
        NSArray *dictFilterarray = (NSArray *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
        for(NSDictionary *dict in dictFilterarray) {
            NotificationFilter *filter = [[objc_getClass("NotificationFilter") alloc] initWithDictionary:dict];
            NSString *dictKey = @"";
            if(filter.appToBlock != nil) {
                dictKey = filter.appToBlock.appIdentifier;
            }

            if(![filters objectForKey:dictKey]) {
                [filters setObject:[[NSMutableArray alloc] init] forKey:dictKey];
            }

            NSMutableArray *appIdfilters = [filters objectForKey:dictKey];
            [appIdfilters addObject:filter];
        }
    }
}

/**
returns whether a message should be filtered based on some boolean logic of filters
**/
+ (BOOL)doesMessageMatchFilterType:(BOOL)titleMatches arg2:(BOOL)subtitleMatches arg3:(BOOL)messageMatches arg4:(int)filterType {
    //NSLog(@"NOTIBLOCK - checking matched: title: %@, subtitle: %@, message: %@, filterType: %d", (titleMatches ? @"true" : @"false"), (subtitleMatches ? @"true" : @"false"), (messageMatches ? @"true" : @"false"), filterType);
    if(filterType == 0) {
        return titleMatches || subtitleMatches || messageMatches;
    } else if(filterType == 1) {
        return titleMatches;
    } else if(filterType == 2) {
        return subtitleMatches;
    } else if(filterType == 3) {
        return messageMatches;
    }
    return NO;
}

/**
returns whether we are currently inbetween the start time and and time and on a weekday set to true in an array of bools
**/
+ (BOOL)areWeCurrentlyInSchedule:(NSDate *)startTime arg2:(NSDate *)endTime arg3:(NSArray *)weekdays {
    //NSLog(@"NOTIBLOCK - checking schedule");

    NSDate *curTime = [NSDate date];

    NSCalendar *calendar = [NSCalendar currentCalendar];

    NSDateComponents *startComponents = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:startTime];
    NSCalendar *newStartCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *newStartTime = [newStartCalendar dateBySettingHour:[startComponents hour] minute:[startComponents minute] second:0 ofDate:curTime options:0];

    NSDateComponents *endComponents = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:endTime];
    NSCalendar *newEndCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *newEndTime = [newEndCalendar dateBySettingHour:[endComponents hour] minute:[endComponents minute] second:0 ofDate:curTime options:0];

    NSInteger curWeekday = [[NSCalendar currentCalendar] component:NSCalendarUnitWeekday
                                                          fromDate:curTime] -
                           1;
    //day of week is not selected
    if(![((NSNumber *)weekdays[curWeekday]) boolValue]) {
        //NSLog(@"NOTIBLOCK - day is not active. skipping filter");
        return false;
    }

    if([[newStartTime earlierDate:newEndTime] isEqualToDate:newEndTime]) { //backwards (start time before end time)
        //NSLog(@"NOTIBLOCK - backwards schedule mode");
        return [[newStartTime earlierDate:curTime] isEqualToDate:newStartTime] || [[newEndTime earlierDate:curTime] isEqualToDate:curTime];
    } else { //regular, check for in between

        //NSLog(@"NOTIBLOCK - regular schedule mode");
        //NSLog(@"NOTIBLOCK - curTime: %f", [curTime timeIntervalSince1970]);
        //NSLog(@"NOTIBLOCK - newStartTime: %f", [newStartTime timeIntervalSince1970]);
        //NSLog(@"NOTIBLOCK - newEndTime: %f", [newEndTime timeIntervalSince1970]);

        //NSLog(@"NOTIBLOCK - is after start - %@", ([[newStartTime earlierDate:curTime] isEqualToDate:newStartTime] ? @"true" : @"false"));
        //NSLog(@"NOTIBLOCK - is before end - %@", ([[newEndTime earlierDate:curTime] isEqualToDate:curTime] ? @"true" : @"false"));
        return [[newEndTime earlierDate:curTime] isEqualToDate:curTime] && [[newStartTime earlierDate:curTime] isEqualToDate:newStartTime];
    }
}

/**
0 - Do not block
1 - Completely Block
2 - Notification Center
**/
+ (int)blockTypeForBulletin:(BBBulletin *)bulletin {
    NSString *title = [bulletin.title lowercaseString];
    NSString *subtitle = [bulletin.subtitle lowercaseString];
    NSString *message = [bulletin.message lowercaseString];
    //NSString *bulletinID = bulletin.bulletinID;
    NSString *sectionId = bulletin.sectionID;

    // //NSLog(@"NOTIBLOCK - Entered publish bulletin for %@ with ID: %@ ", sectionId, bulletinID);
    ////NSLog(@"NOTIBLOCK - BulletinID:%@         Title: %@      Subtitle: %@         Message: %@", bulletinID, title, subtitle, message );

    BOOL filtered = NO;

    if(filters == nil) {
        //NSLog(@"NOTIBLOCK - No filters. returning");
        return 0;
    }

    //NSLog(@"NOTIBLOCK - loading all filters: %lu", (unsigned long)[filters count]);

    NSMutableArray *allFilters = [filters objectForKey:@""];
    NSMutableArray *appFilters = [filters objectForKey:sectionId];

    if(allFilters == nil) {
        allFilters = [[NSMutableArray alloc] init];
    }

    if(appFilters != nil) {
        allFilters = [[allFilters arrayByAddingObjectsFromArray:appFilters] mutableCopy];
    }

    //NSLog(@"NOTIBLOCK - loading relevant filters for --%@--: %lu", sectionId, (unsigned long)[allFilters count]);

    if(title == nil) {
        title = @"";
    }

    if(subtitle == nil) {
        subtitle = @"";
    }

    if(message == nil) {
        message = @"";
    }

    int blockMode = 0;
    for(NotificationFilter *filter in allFilters) {
        //check for schedule and skip if not inside
        if(filter.onSchedule && ![self areWeCurrentlyInSchedule:filter.startTime arg2:filter.endTime arg3:filter.weekDays]) {
            //not inside schedule, skip
            //NSLog(@"NOTIBLOCK - schedule was on, but we determined it is not currently active. skipping filter");
            continue;
        }

        NSString *filterText = [filter.filterText lowercaseString];
        BOOL titleMatches = false;
        BOOL subtitleMatches = false;
        BOOL messageMatches = false;

        //do filtering
        if(filter.blockType == 0) { //starts with
            //NSLog(@"NOTIBLOCK - checking if string starts with text");
            titleMatches = [title hasPrefix:filterText];
            subtitleMatches = [subtitle hasPrefix:filterText];
            messageMatches = [message hasPrefix:filterText];
        } else if(filter.blockType == 1) { //ends with
            //NSLog(@"NOTIBLOCK - checking if string end with text");
            titleMatches = [title hasSuffix:filterText];
            subtitleMatches = [subtitle hasSuffix:filterText];
            messageMatches = [message hasSuffix:filterText];
        } else if(filter.blockType == 2) { //contains
            //NSLog(@"NOTIBLOCK - checking if string contains text");
            titleMatches = [title rangeOfString:filterText].location != NSNotFound;
            subtitleMatches = [subtitle rangeOfString:filterText].location != NSNotFound;
            messageMatches = [message rangeOfString:filterText].location != NSNotFound;
        } else if(filter.blockType == 3) { //exact text
            //NSLog(@"NOTIBLOCK - checking if string matches text");
            titleMatches = [title isEqualToString:filterText];
            subtitleMatches = [subtitle isEqualToString:filterText];
            messageMatches = [message isEqualToString:filterText];
        } else if(filter.blockType == 4) { //regex
            //NSLog(@"NOTIBLOCK - checking if string matches regex");
            NSPredicate *notifTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", filterText];
            titleMatches = ![title isEqualToString:@""] && [notifTest evaluateWithObject:title];
            subtitleMatches = ![subtitle isEqualToString:@""] && [notifTest evaluateWithObject:subtitle];
            messageMatches = ![message isEqualToString:@""] && [notifTest evaluateWithObject:message];
        } else if(filter.blockType == 5) { //always
            //NSLog(@"NOTIBLOCK - app should always be filtered. filtering turned on");
            filtered = YES;
        }

        if([self doesMessageMatchFilterType:titleMatches arg2:subtitleMatches arg3:messageMatches arg4:filter.filterType]) {
            //NSLog(@"NOTIBLOCK - filtering was matched");
            filtered = YES;
        }

        if(filter.whitelistMode) {
            //NSLog(@"NOTIBLOCK - whitelist Mode on");
            filtered = !filtered;
        }

        blockMode = filter.blockMode;
    }

    if(filtered) {
        return blockMode;
    } else {
        return 0;
    }
}

@end
