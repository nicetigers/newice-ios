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

#import "Event.h"
#import "EventGroup.h"
#import "Section.h"

@interface NWIEventTableViewController ()



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
    
    self.labelTitle.text = self.selectedEvent.eventTitle;
    self.labelLocation.text = self.selectedEvent.eventLocation;
    self.labelDescription.text = self.selectedEvent.eventDescription;
    self.labelSection.text = self.selectedEvent.eventGroup.section.formattedName;
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    NSDateFormatter *timeFormatter = [NSDateFormatter new];
    [timeFormatter setDateStyle:NSDateFormatterNoStyle];
    [timeFormatter setTimeStyle:NSDateFormatterShortStyle];
    self.labelDate.text = [dateFormatter stringFromDate:self.selectedEvent.eventStart];
    self.labelStartTime.text = [timeFormatter stringFromDate:self.selectedEvent.eventStart];
    self.labelEndtime.text = [timeFormatter stringFromDate:self.selectedEvent.eventEnd];
    
    self.labelType.text = [self.eventsManager eventTypeForKey:self.selectedEvent.eventType];
    
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

#pragma mark - Table view data source

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

#pragma mark - Navigation
/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
}
*/

@end
