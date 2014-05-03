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
#import "NWIEventsManager.h"
#import "Event.h"
#import "EventGroup.h"
#import "Section.h"
#import "Course.h"

#define AGENDA_CELL_IDENTIFIER @"agenda reuse identifier"

@interface NWIAgendaViewController ()

@property (nonatomic, strong) NWIEventsManager *eventsManager;
@property (nonatomic, strong) NSArray *eventObjects;

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
