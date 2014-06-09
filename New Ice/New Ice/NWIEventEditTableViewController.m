//
//  NWIEventEditTableViewController.m
//  ReCal
//
//  Created by Naphat Sanguansin on 6/8/14.
//
//

#import "NWIEventEditTableViewController.h"

#import "UIColor+NWIHex.h"

#import "Event.h"
#import "Section+Extended.h"
#import "User+Extended.h"

#import "NWIAppDelegate.h"
#import "NWIThemedNavigationController.h"
#import "NWIAuthenticator.h"

@interface NWIEventEditTableViewController ()

@property (nonatomic, weak) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, weak) NWIAuthenticator *authenticator;
@property (nonatomic, strong) UIColor *color;

@end

@implementation NWIEventEditTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.tfEventTitle.text = self.selectedEvent.eventTitle;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    NWIThemedNavigationController *navigationController = (NWIThemedNavigationController *) self.navigationController;
    [navigationController.navigationBar setBarTintColor:self.color];
    [navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [navigationController setViewControllerForPreferredStatusBarStyle:self];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}
-(void)viewWillDisappear:(BOOL)animated
{
    if ([self.managedObjectContext hasChanges]) {
        [self.managedObjectContext rollback];
    }
    
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - Button Event Listeners
- (IBAction)didPressSave:(UIBarButtonItem *)sender
{
    NSError *error;
    [self.managedObjectContext save:&error];
    if (error) {
        NSLog(@"Error saving. Error: %@", error.description);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Text Field Delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // TODO check if valid
    [textField resignFirstResponder];
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (textField.text.length == 0) {
        return NO;
    }
    return YES;
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.tfEventTitle) {
        self.selectedEvent.eventTitle = self.tfEventTitle.text;
        self.selectedEvent.modified = [NSNumber numberWithBool:YES];
    }
}

#pragma mark - Getters/Setters

-(void)setSelectedEvent:(Event *)selectedEvent
{
    if (_selectedEvent != selectedEvent) {
        _selectedEvent = selectedEvent;
        self.color = nil;
    }
}

-(UIColor *)color
{
    if (!_color) {
        _color = [self.selectedEvent.section colorForUser:[User userByNetID:self.authenticator.netid inManagedObjectContext:self.managedObjectContext]];
    }
    return _color;
}

-(NSManagedObjectContext *)managedObjectContext
{
    if (!_managedObjectContext)
    {
        NWIAppDelegate *delegate = [UIApplication sharedApplication].delegate;
        _managedObjectContext = delegate.managedObjectContext;
    }
    return _managedObjectContext;
}
-(NWIAuthenticator *)authenticator
{
    if (!_authenticator) {
        NWIAppDelegate *delegate = [UIApplication sharedApplication].delegate;
        _authenticator = delegate.authenticator;
    }
    return _authenticator;
}

@end
