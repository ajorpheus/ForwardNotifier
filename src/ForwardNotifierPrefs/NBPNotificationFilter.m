//
//  FNNotificationFilter.m
//  thing
//
//  Created by Tomer Shemesh on 12/1/18.
//  Copyright © 2018 Tomer Shemesh. All rights reserved.
//

#import "NBPNotificationFilter.h"

@implementation FNNotificationFilter

- (id)copyWithZone:(NSZone *)zone {
    FNNotificationFilter *copy = [[FNNotificationFilter allocWithZone:zone] init];
    copy.filterName = self.filterName;
    copy.filterText = self.filterText;
    copy.scriptName = self.scriptName;
    copy.rootScript = self.rootScript;
    copy.blockType = self.blockType;
    copy.appToBlock = self.appToBlock;
    copy.onSchedule = self.onSchedule;
    copy.startTime = self.startTime;
    copy.endTime = self.endTime;
    copy.filterType = self.filterType;
    copy.whitelistMode = self.whitelistMode;
    copy.blockMode = self.blockMode;
    copy.enableScript = self.enableScript;
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
        self.scriptName = [dict objectForKey:@"scriptName"];
        self.rootScript = [[dict objectForKey:@"rootScript"] boolValue];
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
        self.enableScript = [((NSNumber *)[dict objectForKey:@"enableScript"]) boolValue];
        self.wakeDevice = [((NSNumber *)[dict objectForKey:@"wakeDevice"]) boolValue];
        self.showInNC = [((NSNumber *)[dict objectForKey:@"showInNC"]) boolValue];

        self.startTime = [dict objectForKey:@"startTime"];
        self.endTime = [dict objectForKey:@"endTime"];
        self.weekDays = [NSMutableArray arrayWithArray:[dict objectForKey:@"weekDays"]];
    }
    return self;
}

- (NSDictionary *)encodeToDictionary {
    NSMutableDictionary *dict =
        [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 self.filterName, @"filterName",
                                 self.filterText, @"filterText",
                                 self.scriptName, @"scriptName",
                                 @(self.rootScript), @"rootScript",
                                 @(self.blockType), @"blockType",
                                 @(self.filterType), @"filterType",
                                 @(self.onSchedule), @"onSchedule",
                                 @(self.whitelistMode), @"whitelistMode",
                                 @(self.blockMode), @"blockMode",
                                 @(self.forward), @"forward",
                                 @(self.enableScript), @"enableScript",
                                 @(self.wakeDevice), @"wakeDevice",
                                 @(self.showInNC), @"showInNC",
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
