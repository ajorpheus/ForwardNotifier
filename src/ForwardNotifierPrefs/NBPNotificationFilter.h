//
//  FNNotificationFilter.h
//  thing
//
//  Created by Tomer Shemesh on 12/1/18.
//  Copyright © 2018 Tomer Shemesh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NBPAppInfo.h"

@interface FNNotificationFilter : NSObject <NSCopying>
@property (nonatomic, strong) NSString *filterName;
@property (nonatomic, strong) NSString *filterText;
@property (nonatomic, strong) NSString *scriptName;
@property (nonatomic, assign) BOOL rootScript;
@property (nonatomic) NSInteger blockType;
@property (nonatomic) NSInteger filterType;
@property (nonatomic, strong) AppInfo *appToBlock;
@property (nonatomic) BOOL onSchedule;
@property (nonatomic) BOOL whitelistMode;
@property (nonatomic) BOOL forward;
@property (nonatomic) BOOL enableScript;
@property (nonatomic) BOOL wakeDevice;
@property (nonatomic) BOOL showInNC;
@property (nonatomic) NSInteger blockMode;
@property (nonatomic, strong) NSDate *startTime;
@property (nonatomic, strong) NSDate *endTime;
@property (nonatomic, strong) NSArray *weekDays;
- (id)copyWithZone:(NSZone *)zone;
- (NSDictionary *)encodeToDictionary;
- (id)initWithDictionary:(NSDictionary *)dict;
@end
