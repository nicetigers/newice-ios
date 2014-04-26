//
//  NWIEventsManager.m
//  New Ice
//
//  Created by Naphat Sanguansin on 4/26/14.
//
//
#import <CoreData/CoreData.h>
#import "NWIEventsManager.h"
#import "NWICourseManager.h"

#import "EventGroup.h"
#import "Event.h"
#import "Section.h"


@interface NWIEventsManager ()

-(void)processDownloadedEvents:(NSData *)data;

@end

@implementation NWIEventsManager

-(void)pullEventsForCourseIDs:(NSArray *)courseIDs makeAsynchronous:(BOOL)async
{
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:courseIDs options:0 error:&error];
    if (error) {
        NSLog(@"Error encoding JSON. \n Error: %@", error.description);
        return;
    }
    NSString *stringValue = [[NSString alloc] initWithData:data encoding:NSStringEncodingConversionAllowLossy];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/get/bycourses/0?courseIDs=%@", SERVER_URL, stringValue]]];
    if (async) {
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (connectionError) {
                NSLog(@"Error downloading events for courses %@. \n Error: %@", courseIDs, connectionError.description);
                return;
            }
            [self processDownloadedEvents:data];
        }];
    } else {
        NSURLResponse *response;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        if (error) {
            NSLog(@"Error downloading events for courses %@. \n Error: %@", courseIDs, error.description);
            return;
        }
        [self processDownloadedEvents:data];
    }
}

-(void)processDownloadedEvents:(NSData *)data
{
    NSError *error;
    NSArray *eventsArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error) {
        NSLog(@"Error parsing downloaded events. \n Error: %@", error.description);
        return;
    }
    for (NSDictionary *eventDict in eventsArray) {
        EventGroup *eventGroupObject = [self getOrCreateEventGroupForEventDict:eventDict];
        Event *eventObject = [self getOrCreateEventForEventDict:eventDict];
        [eventGroupObject addEventsObject:eventObject]; // TODO what if the event is already added to this event group?
    }
    [self.managedObjectContext save:&error];
    if (error) {
        NSLog(@"Error saving events. \nError: %@", error.description);
        return;
    }
}
-(EventGroup *)getOrCreateEventGroupForEventDict:(NSDictionary *)eventDict
{
    NSError *error;
    NSManagedObjectModel *model = self.managedObjectContext.persistentStoreCoordinator.managedObjectModel;
    NSFetchRequest *fetchRequest = [model fetchRequestFromTemplateWithName:@"EventGroupByID" substitutionVariables:@{@"SERV_ID":  eventDict[@"event_group_id"]}];
    NSArray *fetched = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    EventGroup *eventGroupObject;
    if (fetched.count > 0) {
        // TODO should check whether recurrence pattern has changed, and delete all corresponding events
        // TODO before replacing, should check if modified time is newer
        eventGroupObject = fetched.lastObject;
    } else {
        eventGroupObject = [NSEntityDescription insertNewObjectForEntityForName:@"EventGroup" inManagedObjectContext:self.managedObjectContext];
        eventGroupObject.startDate = [NSDate dateWithTimeIntervalSince1970:[eventDict[@"event_start"] doubleValue]];
        eventGroupObject.modifiedTime = [NSDate dateWithTimeIntervalSince1970:[eventDict[@"modified_time"] doubleValue]];
        eventGroupObject.serverID = [NSNumber numberWithInteger:[eventDict[@"event_group_id"] integerValue]];
        Section *sectionObject = [self.courseManager getSectionByID:[eventDict[@"section_id"] integerValue]];
        [sectionObject addEventGroupsObject:eventGroupObject];
        if ([eventDict.allKeys containsObject:@"recurrence_days"]) {
            eventGroupObject.recurrenceDays = eventDict[@"recurrence_days"];
            eventGroupObject.recurrenceInterval = [NSNumber numberWithInteger:[eventDict[@"recurrence_interval"] integerValue]];
            eventGroupObject.endDate = [NSDate dateWithTimeIntervalSince1970:[eventDict[@"recurrence_end"] doubleValue]];
        }
        [self.managedObjectContext save:&error];
        if (error) {
            NSLog(@"Error saving new event group. \nError: %@", error.description);
            return nil;
        }
    }
    return eventGroupObject;
}
-(Event *)getOrCreateEventForEventDict:(NSDictionary *)eventDict
{
    NSError *error;
    NSManagedObjectModel *model = self.managedObjectContext.persistentStoreCoordinator.managedObjectModel;
    NSFetchRequest *fetchRequest = [model fetchRequestFromTemplateWithName:@"EventByID" substitutionVariables:@{@"SERV_ID":  eventDict[@"event_id"]}];
    NSArray *fetched = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    Event *eventObject;
    if (fetched.count > 0) {
        // TODO should check whether recurrence pattern has changed, and delete all corresponding events
        // TODO before replacing, should check if modified time is newer
        eventObject = fetched.lastObject;
    } else {
        eventObject = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
        eventObject.serverID = [NSNumber numberWithInteger:[eventDict[@"event_id"] integerValue]];
        [self.managedObjectContext save:&error];
        if (error) {
            NSLog(@"Error saving new event. \nError: %@", error.description);
            return nil;
        }
    }
    eventObject.eventStart = [NSDate dateWithTimeIntervalSince1970:[eventDict[@"event_start"] doubleValue]];
    eventObject.eventEnd = [NSDate dateWithTimeIntervalSince1970:[eventDict[@"event_end"] doubleValue]];
    eventObject.modifiedTime = [NSDate dateWithTimeIntervalSince1970:[eventDict[@"modified_time"] doubleValue]];
    eventObject.eventTitle = eventDict[@"event_title"];
    eventObject.eventDescription = eventDict[@"event_description"];
    eventObject.eventLocation = eventDict[@"event_location"];
    eventObject.eventType = eventDict[@"event_type"];
    return eventObject;
}
@end