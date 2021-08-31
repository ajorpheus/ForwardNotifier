#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CCUIToggleModule : NSObject
- (void)refreshState;
@end

@interface ForwardNotifierCC : CCUIToggleModule {
    BOOL _selected;
}

@end
