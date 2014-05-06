//
//  NWIEventsManager.m
//  New Ice
//
//  Created by Naphat Sanguansin on 5/3/14.
//
//

#import <CoreData/CoreData.h>
#import "NWIEventsManager.h"

#import "NWIAppDelegate.h"
#import "NWIAuthenticator.h"

#import "Event.h"
#import "EventGroup.h"
#import "Section.h"
#import "User.h"
#import "UserSectionTable.h"

@interface NWIEventsManager ()

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NWIAuthenticator *authenticator;


@end

@implementation NWIEventsManager

-(NSArray *)getFutureEvents
{
    if (!self.authenticator.netid) {
        return nil;
    }
    NSError *error;
    
    NSManagedObjectModel *model = self.managedObjectContext.persistentStoreCoordinator.managedObjectModel;
    NSFetchRequest *fetchRequest = [model fetchRequestFromTemplateWithName:@"EventsBeforeDate" substitutionVariables:@{@"START_DATE": [NSDate date]}];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"eventStart" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    NSArray *fetched = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"Error executing fetch request for future events. Error %@", error.description);
        return nil;
    }
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        Event *eventObject = evaluatedObject;
        for (UserSectionTable *enrollment in eventObject.eventGroup.section.enrollment)
        {
            if ([enrollment.user.netid isEqualToString:self.authenticator.netid]) {
                return YES;
            }
        }
        return NO;
    }];
    
    return [fetched filteredArrayUsingPredicate:predicate];
}

-(NSString *)eventTypeForKey:(NSString *)key
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
    NSAttributeDescription *attr = [entity attributesByName][@"eventType"];
    return attr.userInfo[key];
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
