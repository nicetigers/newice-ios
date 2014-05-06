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

#import "Event.h"
#import "EventGroup.h"
#import "Section.h"
#import "Course.h"
#import "UserSectionTable.h"
#import "User.h"

#define AGENDA_CELL_IDENTIFIER @"agenda reuse identifier"

@interface NWIAgendaViewController ()

@property (nonatomic, strong) NWIEventsManager *eventsManager;
@property (nonatomic, strong) NSArray *eventObjects;
@property (nonatomic, weak) NWIAuthenticator *authenticator;

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
        [self.collectionView reloadData];
    }];
    self.bbiSettings.title = @"\u2699";
    UIFont *f1 = [UIFont systemFontOfSize:24];
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:f1, NSFontAttributeName, nil];
    [self.bbiSettings setTitleTextAttributes:dict forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Collection View
#pragma mark DataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.eventObjects.count;
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:AGENDA_CELL_IDENTIFIER forIndexPath:indexPath];
    if (cell.gestureRecognizers.count == 0) {
        UISwipeGestureRecognizer *swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
        [swipeGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
        [swipeGestureRecognizer setNumberOfTouchesRequired:1];
        [cell addGestureRecognizer:swipeGestureRecognizer];
        //UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        //[panGestureRecognizer requ]
        //[panGestureRecognizer setMaximumNumberOfTouches:1];
        //[panGestureRecognizer set]
        //[cell addGestureRecognizer:panGestureRecognizer];
        //[collectionView.panGestureRecognizer requireGestureRecognizerToFail:panGestureRecognizer];
    }
    UIView *container = [cell viewWithTag:-1];
    container.layer.borderColor = [UIColor lightGrayColor].CGColor;
    container.layer.borderWidth = 0.5;
    
    Event *eventObject = self.eventObjects[indexPath.item];
    
    UILabel *titleLabel = (UILabel *) [container viewWithTag:2];
    titleLabel.text = eventObject.eventTitle;
    
    UILabel *sectionLabel = (UILabel *) [container viewWithTag:3];
    sectionLabel.text = [eventObject.eventGroup.section formattedName];
    
    UILabel *dateLabel = (UILabel *) [container viewWithTag:4];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDoesRelativeDateFormatting:YES];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    dateLabel.text = [dateFormatter stringFromDate:eventObject.eventStart];
    
    UIView *sectionTag = (UIView *) [container viewWithTag:1];
    unsigned int hexColor = 0;
    for (UserSectionTable *enrollment in eventObject.eventGroup.section.enrollment) {
        if ([enrollment.user.netid isEqualToString:self.authenticator.netid]) {
            hexColor = [enrollment.color unsignedIntValue];
        }
    }
    UIColor *color = [UIColor colorFromHexInt:hexColor];
    sectionTag.backgroundColor = color;
    
    
    return cell;
}

#pragma mark - Gesture Recognizer
-(void)handlePanGesture:(UIPanGestureRecognizer *)panGestureRecognizer
{
    [panGestureRecognizer setCancelsTouchesInView:YES];
    UICollectionViewCell *cell = (UICollectionViewCell *) panGestureRecognizer.view;
    CGPoint translation = [panGestureRecognizer translationInView:cell];
    UIView *container = [cell viewWithTag:-1];
    [container setTransform:CGAffineTransformMakeTranslation(translation.x, 0)];
}

-(void)handleSwipeGesture:(UISwipeGestureRecognizer *)swipeGestureRecognizer
{
    NSLog(@"delete");
    UICollectionViewCell *cell = (UICollectionViewCell *) swipeGestureRecognizer.view;
    UIView *container = [cell viewWithTag:-1];
    [container setTransform:CGAffineTransformIdentity];
    [UIView animateWithDuration:0.1 animations:^{
        container.alpha = 0;
    } completion:^(BOOL finished) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hide this event?" message:nil delegate:nil cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        [alert show];
    }];
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.destinationViewController isKindOfClass:[NWIEventTableViewController class]]) {
        NSIndexPath *selected = [self.collectionView indexPathsForSelectedItems].lastObject;
        Event *event = self.eventObjects[selected.item];
        unsigned int hexColor = 0;
        for (UserSectionTable *enrollment in event.eventGroup.section.enrollment) {
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
