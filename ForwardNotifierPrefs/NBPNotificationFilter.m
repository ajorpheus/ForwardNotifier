//
//  NotificationFilter.m
//  thing
//
//  Created by Tomer Shemesh on 12/1/18.
//  Copyright © 2018 Tomer Shemesh. All rights reserved.
//

#import "NBPNotificationFilter.h"

@implementation NotificationFilter

- (id)copyWithZone:(NSZone *)zone {
    NotificationFilter *copy = [[NotificationFilter allocWithZone:zone] init];
    copy.filterName = self.filterName;
    copy.filterText = self.filterText;
    copy.blockType = self.blockType;
    copy.appToBlock = self.appToBlock;
    copy.onSchedule = self.onSchedule;
    copy.startTime = self.startTime;
    copy.endTime = self.endTime;
    copy.filterType = self.filterType;
    copy.whitelistMode = self.whitelistMode;
    copy.blockMode = self.blockMode;
    copy.forward = self.forward;
    copy.wakeDevice = self.wakeDevice;
    copy.showInNC = self.showInNC;
    copy.weekDays = [NSMutableArray arrayWithArray:self.weekDays];
    copy.filterName = self.filterName;
    return copy;
}

- (id)initWithDictionary:(NSDictionary *)dict {
    if(self = [super init]) {
        self.filterName = [dict objectForKey:@"filterName"];
        self.filterText = [dict objectForKey:@"filterText"];
        self.blockType = [((NSNumber *)[dict objectForKey:@"blockType"]) intValue];
        self.filterType = [((NSNumber *)[dict objectForKey:@"filterType"]) intValue];

        if([dict objectForKey:@"appToBlockIdentifier"] != nil) {
            AppInfo *app = [[AppInfo alloc] init];
            app.appIdentifier = [dict objectForKey:@"appToBlockIdentifier"];
            app.appName = [dict objectForKey:@"appToBlockName"];
            self.appToBlock = app;
        }

        self.onSchedule = [((NSNumber *)[dict objectForKey:@"onSchedule"]) boolValue];
        self.whitelistMode = [((NSNumber *)[dict objectForKey:@"whitelistMode"]) boolValue];
        self.blockMode = [((NSNumber *)[dict objectForKey:@"blockMode"]) intValue];
        self.forward = [((NSNumber *)[dict objectForKey:@"forward"]) boolValue];
        self.wakeDevice = [((NSNumber *)[dict objectForKey:@"wakeDevice"]) boolValue];
        self.showInNC = [((NSNumber *)[dict objectForKey:@"showInNC"]) boolValue];

        self.startTime = [dict objectForKey:@"startTime"];
        self.endTime = [dict objectForKey:@"endTime"];
        self.weekDays = [NSMutableArray arrayWithArray:[dict objectForKey:@"weekDays"]];
    }
    return self;
}

- (NSDictionary *)encodeToDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                         self.filterName, @"filterName",
                                                         self.filterText, @"filterText",
                                                         [NSNumber numberWithInt:self.blockType], @"blockType",
                                                         [NSNumber numberWithInt:self.filterType], @"filterType",
                                                         [NSNumber numberWithBool:self.onSchedule], @"onSchedule",
                                                         [NSNumber numberWithBool:self.whitelistMode], @"whitelistMode",
                                                         [NSNumber numberWithInt:self.blockMode], @"blockMode",
                                                         [NSNumber numberWithBool:self.forward],
                                                         @"forward",
                                                         [NSNumber numberWithBool:self.wakeDevice],
                                                         @"wakeDevice",
                                                         [NSNumber numberWithBool:self.showInNC],
                                                         @"showInNC",
                                                         self.startTime, @"startTime",
                                                         self.endTime, @"endTime",
                                                         self.weekDays, @"weekDays",
                                                         nil];

    if(self.appToBlock != nil) {
        [dict setObject:self.appToBlock.appIdentifier forKey:@"appToBlockIdentifier"];
        [dict setObject:self.appToBlock.appName forKey:@"appToBlockName"];
    }

    return dict;
}

@end
