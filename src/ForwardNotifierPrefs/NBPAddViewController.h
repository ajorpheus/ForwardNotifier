#import "NBPAppChooserViewController.h"
#import "NBPNotificationFilter.h"

@protocol AppFilterDelegate <NSObject>
- (void)newFilter:(FNNotificationFilter *)filter;
@end

@interface NBPAddViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, AppChoserDelegate, UITextFieldDelegate>
@property (nonatomic, retain) id<AppFilterDelegate> delegate;
@property (nonatomic, retain) FNNotificationFilter *currentFilter;
@end