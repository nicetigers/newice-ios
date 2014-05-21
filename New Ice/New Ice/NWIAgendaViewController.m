//
//  NWIAgendaViewController.m
//  New Ice
//
//  Created by Naphat Sanguansin on 5/3/14.
//
//

#import <QuartzCore/QuartzCore.h>
#import "NWIAgendaViewController.h"
#import "UIViewController+NWIViewController.h"
#import "UIColor+NWIHex.h"
#import "NWIEventTableViewController.h"

#import "NWIAppDelegate.h"
#import "NWIEventsManager.h"
#import "NWIAuthenticator.h"
#import "NWIServerConnection.h"

#import "Event.h"
#import "Section+FormattedName.h"
#import "Course.h"
#import "UserSectionTable.h"
#import "User.h"

#define AGENDA_CELL_IDENTIFIER @"agenda reuse identifier"
#define PADDING_CELL_IDENTIFIER @"padding"
@interface NWIAgendaViewController ()

@property (nonatomic, strong) NWIEventsManager *eventsManager;
@property (nonatomic, strong) NSArray *eventObjects;
@property (nonatomic, weak) NWIAuthenticator *authenticator;
@property (nonatomic, weak) NWIServerConnection *serverConnection;

@end

@implementation NWIAgendaViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.eventObjects = [self.eventsManager getFutureEvents];
    [[NSNotificationCenter defaultCenter] addObserverForName:NOTIF_DATA_UPDATE object:nil queue:nil usingBlock:^(NSNotification *note) {
        self.eventObjects = [self.eventsManager getFutureEvents];
        [self.tableView reloadData];
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:NOTIF_REFRESH_EVENTS_COMPLETE object:nil queue:nil usingBlock:^(NSNotification *note) {
        [self.refreshControl endRefreshing];
        self.eventObjects = [self.eventsManager getFutureEvents];
        [self.tableView reloadData];
    }];
    self.bbiSettings.title = @"\u2699";
    UIFont *f1 = [UIFont systemFontOfSize:24];
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:f1, NSFontAttributeName, nil];
    [self.bbiSettings setTitleTextAttributes:dict forState:UIControlStateNormal];
    [self.refreshControl addTarget:self action:@selector(refreshAgenda) forControlEvents:UIControlEventValueChanged];
}

-(void)refreshAgenda
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_REFRESH_EVENTS object:self userInfo:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View
#pragma mark DataSource
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row % 2 == 0) {
        return 112;
    }
    else{
        return 20;
    }
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.eventObjects.count * 2;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.row % 2 == 0;
}
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Hide";
}

/*-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"commit");
}
 */
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row % 2 == 1) {
        return [tableView dequeueReusableCellWithIdentifier:PADDING_CELL_IDENTIFIER];
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:AGENDA_CELL_IDENTIFIER forIndexPath:indexPath];
    UIView *container = [cell viewWithTag:-1];
    container.layer.borderColor = [UIColor lightGrayColor].CGColor;
    container.layer.borderWidth = 0.5;
    
    Event *eventObject = self.eventObjects[indexPath.row/2];
    
    UILabel *titleLabel = (UILabel *) [container viewWithTag:2];
    titleLabel.text = eventObject.eventTitle;
    
    UILabel *sectionLabel = (UILabel *) [container viewWithTag:3];
    sectionLabel.text = [eventObject.section formattedName];
    
    UILabel *dateLabel = (UILabel *) [container viewWithTag:4];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDoesRelativeDateFormatting:YES];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    dateLabel.text = [dateFormatter stringFromDate:eventObject.eventStart];
    
    UIView *sectionTag = (UIView *) [container viewWithTag:1];
    unsigned int hexColor = 0;
    for (UserSectionTable *enrollment in eventObject.section.enrollment) {
        if ([enrollment.user.netid isEqualToString:self.authenticator.netid]) {
            hexColor = [enrollment.color unsignedIntValue];
        }
    }
    UIColor *color = [UIColor colorFromHexInt:hexColor];
    sectionTag.backgroundColor = color;
    
    return cell;
}

#pragma mark - Getters/Setters

-(NWIEventsManager *)eventsManager
{
    if (!_eventsManager)
    {
        _eventsManager = [NWIEventsManager new];
    }
    return _eventsManager;
}

-(NWIAuthenticator *)authenticator
{
    if (!_authenticator) {
        NWIAppDelegate *delegate = [UIApplication sharedApplication].delegate;
        _authenticator = delegate.authenticator;
    }
    return _authenticator;
}

-(NWIServerConnection *)serverConnection
{
    if (!_serverConnection) {
        NWIAppDelegate *delegate = [UIApplication sharedApplication].delegate;
        _serverConnection = delegate.serverConnection;
    }
    return _serverConnection;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.destinationViewController isKindOfClass:[NWIEventTableViewController class]]) {
        NSIndexPath *selected = [self.tableView indexPathsForSelectedRows].lastObject;
        Event *event = self.eventObjects[selected.row/2];
        unsigned int hexColor = 0;
        for (UserSectionTable *enrollment in event.section.enrollment) {
            if ([enrollment.user.netid isEqualToString:self.authenticator.netid]) {
                hexColor = [enrollment.color unsignedIntValue];
            }
        }
        UIColor *color = [UIColor colorFromHexInt:hexColor];
        
        
        NWIEventTableViewController *eventsVC = [segue destinationViewController];
        eventsVC.selectedEvent = event;
        eventsVC.color = color;
        eventsVC.eventsManager = self.eventsManager;
    }
}

@end
