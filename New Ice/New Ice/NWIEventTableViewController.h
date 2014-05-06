//
//  NWIEventViewControllerTableViewController.h
//  New Ice
//
//  Created by Naphat Sanguansin on 5/4/14.
//
//

#import <UIKit/UIKit.h>

@class Event, NWIEventsManager;

@interface NWIEventTableViewController : UITableViewController

@property (nonatomic, strong) Event *selectedEvent;
@property (nonatomic, strong) UIColor *color;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelDate;
@property (weak, nonatomic) IBOutlet UILabel *labelStartTime;
@property (weak, nonatomic) IBOutlet UILabel *labelEndtime;
@property (weak, nonatomic) IBOutlet UILabel *labelLocation;
@property (weak, nonatomic) IBOutlet UILabel *labelSection;
@property (weak, nonatomic) IBOutlet UILabel *labelType;
@property (weak, nonatomic) IBOutlet UILabel *labelDescription;

@property (nonatomic, strong) NWIEventsManager *eventsManager;

@end
