//
//  NWIEventViewControllerTableViewController.m
//  New Ice
//
//  Created by Naphat Sanguansin on 5/4/14.
//
//

#import "NWIEventTableViewController.h"
#import "NWIThemedNavigationController.h"
#import "UIColor+NWIHex.h"
#import "NWIEventsManager.h"
#import "NWIAppDelegate.h"
#import "NWIAuthenticator.h"

#import "Event.h"
#import "Section+Extended.h"
#import "User+Extended.h"

@interface NWIEventTableViewController ()

@property (nonatomic, weak) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, weak) NWIAuthenticator *authenticator;

@end

@implementation NWIEventTableViewController

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
    
    //self.navigationItem.title = self.selectedEvent.eventTitle;
    
    self.tfTitle.text = self.selectedEvent.eventTitle;
    self.tfLocation.text = self.selectedEvent.eventLocation;
    self.tfDescription.text = self.selectedEvent.eventDescription;
    self.tfSection.text = self.selectedEvent.section.formattedName;
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    NSDateFormatter *timeFormatter = [NSDateFormatter new];
    [timeFormatter setDateStyle:NSDateFormatterNoStyle];
    [timeFormatter setTimeStyle:NSDateFormatterShortStyle];
    self.tfDate.text = [dateFormatter stringFromDate:self.selectedEvent.eventStart];
    self.tfStartTime.text = [timeFormatter stringFromDate:self.selectedEvent.eventStart];
    self.tfEndtime.text = [timeFormatter stringFromDate:self.selectedEvent.eventEnd];
    
    self.tvType.text = [self.eventsManager eventTypeForKey:self.selectedEvent.eventType];
    
    //[[UINavigationBar appearance] setBackgroundColor:[UIColor redColor]];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    NWIThemedNavigationController *navigationController = (NWIThemedNavigationController *) self.navigationController;
    [navigationController.navigationBar setBarTintColor:nil];
    [navigationController.navigationBar setTintColor:[UIColor colorFromHexString:PRIMARY_COLOR_WHITE_THEME]];
    [navigationController setViewControllerForPreferredStatusBarStyle:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - Table view 
#pragma mark Data source

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}

#pragma mark - Navigation
/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
}
*/

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
