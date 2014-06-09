//
//  NWIEventEditTableViewController.h
//  ReCal
//
//  Created by Naphat Sanguansin on 6/8/14.
//
//

#import <UIKit/UIKit.h>

@class Event;

@interface NWIEventEditTableViewController : UITableViewController <UITextFieldDelegate>

@property (nonatomic, strong) Event *selectedEvent;

@property (nonatomic, weak) IBOutlet UITextField *tfEventTitle;

-(IBAction)didPressSave:(UIBarButtonItem *)sender;

@end
