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

@property (weak, nonatomic) IBOutlet UITextField *tfTitle;
@property (weak, nonatomic) IBOutlet UITextField *tfDate;
@property (weak, nonatomic) IBOutlet UITextField *tfStartTime;
@property (weak, nonatomic) IBOutlet UITextField *tfEndtime;
@property (weak, nonatomic) IBOutlet UITextField *tfLocation;
@property (weak, nonatomic) IBOutlet UITextField *tfSection;
@property (weak, nonatomic) IBOutlet UITextField *tvType;
@property (weak, nonatomic) IBOutlet UITextView *tfDescription;

@property (nonatomic, strong) NWIEventsManager *eventsManager;

@end
