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
    cell.layer.borderColor = [UIColor lightGrayColor].CGColor;
    cell.layer.borderWidth = 0.5;
    
    Event *eventObject = self.eventObjects[indexPath.row];
    
    UILabel *titleLabel = (UILabel *) [cell viewWithTag:2];
    titleLabel.text = eventObject.eventTitle;
    
    UILabel *sectionLabel = (UILabel *) [cell viewWithTag:3];
    sectionLabel.text = [NSString stringWithFormat:@"%@ - %@", eventObject.eventGroup.section.course.courseListings, eventObject.eventGroup.section.name];
    
    UILabel *dateLabel = (UILabel *) [cell viewWithTag:4];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDoesRelativeDateFormatting:YES];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    dateLabel.text = [dateFormatter stringFromDate:eventObject.eventStart];
    
    UIView *sectionTag = (UIView *) [cell viewWithTag:1];
    unsigned int hexColor = 0;
    for (UserSectionTable *enrollment in eventObject.eventGroup.section.enrollment) {
        if ([enrollment.user.netid isEqualToString:self.authenticator.netid]) {
            hexColor = [enrollment.color unsignedIntValue];
        }
    }
    UIColor *color = [UIColor colorWithRed:((CGFloat) ((hexColor & 0xFF0000) >> 16))/255
                                     green:((CGFloat) ((hexColor & 0x00FF00) >> 8))/255
                                      blue:((CGFloat) (hexColor & 0x0000FF))/255
                                     alpha:1.0];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
