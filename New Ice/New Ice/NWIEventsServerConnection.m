//
//  NWIEventsManager.m
//  New Ice
//
//  Created by Naphat Sanguansin on 4/26/14.
//
//
#import <CoreData/CoreData.h>
#import "NWIEventsServerConnection.h"
#import "NWICourseServerConnection.h"

#import "Event.h"
#import "Section.h"


@interface NWIEventsServerConnection ()

-(void)processDownloadedEvents:(NSData *)data clearOldEvents:(BOOL)clear;

@end

@implementation NWIEventsServerConnection

//-(void)pullEventsForCourseIDs:(NSArray *)courseIDs makeAsynchronous:(BOOL)async
//{
//    NSError *error;
//    NSData *data = [NSJSONSerialization dataWithJSONObject:courseIDs options:0 error:&error];
//    if (error) {
//        NSLog(@"Error encoding JSON. \nError: %@", error.description);
//        return;
//    }
//    NSString *stringValue = [[NSString alloc] initWithData:data encoding:NSStringEncodingConversionAllowLossy];
//    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/get/bycourses/0?courseIDs=%@", SERVER_URL, stringValue]]];
//    if (async) {
//        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//            if (connectionError) {
//                NSLog(@"Error downloading events for courses %@. \nError: %@", courseIDs, connectionError.description);
//                return;
//            }
//            [self processDownloadedEvents:data];
//        }];
//    } else {
//        NSURLResponse *response;
//        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
//        if (error) {
//            NSLog(@"Error downloading events for courses %@. \nError: %@", courseIDs, error.description);
//            return;
//        }
//        [self processDownloadedEvents:data];
//    }
//}
-(void)pullEventsForUser:(NSString *)netid lastConnected:(NSDate **)lastConnected
{
    NSError *error;
    NSInteger lastSyncedInt = [*lastConnected timeIntervalSince1970];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/get/%d", SERVER_URL, (int) lastSyncedInt]]];
    NSURLResponse *response;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (error) {
        NSLog(@"Error downloading events. \nError: %@", error.description);
        [self pullEventsForUser:netid lastConnected:lastConnected];
        return;
    }
    *lastConnected = [NSDate date];
    NSLog(@"downloaded events");
    [self processDownloadedEvents:data clearOldEvents:lastSyncedInt == 0];
}

-(void)processDownloadedEvents:(NSData *)data clearOldEvents:(BOOL)clear
{
    // TODO process hidden events
    NSError *error;
    NSDictionary *parsed = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    NSArray *eventsArray = parsed[@"events"];
    if (error) {
        NSLog(@"Error parsing downloaded events. \nError: %@", error.description);
        return;
    }
//    if (clear) {
//        NSManagedObjectModel *model = self.managedObjectContext.persistentStoreCoordinator.managedObjectModel;
//        NSFetchRequest *fetchRequest = [model fetchRequestFromTemplateWithName:@"AllEvents" substitutionVariables:@{}];
//        NSArray *fetched = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
//        for (Event *event in fetched) {
//            [self.managedObjectContext deleteObject:event];
//        }
//        [self.managedObjectContext save:&error];
//        if (error) {
//            NSLog(@"Error deleting events. \nError: %@", error.description);
//            return;
//        }
//    }
    NSMutableSet *toBeDeleted;
    if (clear) {
        NSManagedObjectModel *model = self.managedObjectContext.persistentStoreCoordinator.managedObjectModel;
        NSFetchRequest *fetchRequest = [model fetchRequestFromTemplateWithName:@"AllEvents" substitutionVariables:@{}];
        NSArray *fetched = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        toBeDeleted = [NSMutableSet setWithArray:fetched];
    }
    NSInteger count = 0;
    
    for (NSDictionary *eventDict in eventsArray) {
        Event *eventObject = [self updateEventWithEventDict:eventDict];
        if (clear) {
            if ([toBeDeleted containsObject:eventObject]) {
                [toBeDeleted removeObject:eventObject];
            }
        }
        count++;
    }
    NSLog(@"processed %d events", (int) count);
    if (clear) {
        for (Event *eventObject in toBeDeleted) {
            [self.managedObjectContext deleteObject:eventObject];
        }
    }
    [self.managedObjectContext save:&error];
    if (error) {
        NSLog(@"Error saving events. \nError: %@", error.description);
        return;
    }
}
-(Event *)updateEventWithEventDict:(NSDictionary *)eventDict
{
    NSError *error;
    NSManagedObjectModel *model = self.managedObjectContext.persistentStoreCoordinator.managedObjectModel;
    NSFetchRequest *fetchRequest = [model fetchRequestFromTemplateWithName:@"EventByID" substitutionVariables:@{@"SERV_ID":  eventDict[@"event_id"]}];
    NSArray *fetched = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    Event *eventObject;
    if (fetched.count > 0) {
        // TODO before replacing, should check if modified time is newer
        eventObject = fetched.lastObject;
    } else {
        eventObject = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
        eventObject.serverID = [NSNumber numberWithInteger:[eventDict[@"event_id"] integerValue]];
        eventObject.eventGroupID = [NSNumber numberWithInteger:[eventDict[@"event_group_id"] integerValue]];
        Section *sectionObject = [self.courseServerConnection getSectionByID:[eventDict[@"section_id"] integerValue]];
        [sectionObject addEventsObject:eventObject];
    }
    eventObject.eventStart = [NSDate dateWithTimeIntervalSince1970:[eventDict[@"event_start"] doubleValue]];
    eventObject.eventEnd = [NSDate dateWithTimeIntervalSince1970:[eventDict[@"event_end"] doubleValue]];
    eventObject.modifiedTime = [NSDate dateWithTimeIntervalSince1970:[eventDict[@"modified_time"] doubleValue]];
    eventObject.eventTitle = eventDict[@"event_title"];
    eventObject.eventDescription = eventDict[@"event_description"];
    eventObject.eventLocation = eventDict[@"event_location"];
    eventObject.eventType = eventDict[@"event_type"];
    
    // handle recurrence
    if ([eventDict.allKeys containsObject:@"recurrence_days"]) {
        NSData *jsonRecur = [NSJSONSerialization dataWithJSONObject:eventDict[@"recurrence_days"] options:0 error:&error];
        if (error)
        {
            NSLog(@"error serializing json for recurrence days. error: %@", error.description);
            return nil;
        }
        eventObject.recurrenceDays = [[NSString alloc] initWithData:jsonRecur encoding:NSStringEncodingConversionAllowLossy];
        eventObject.recurrenceInterval = [NSNumber numberWithInteger:[eventDict[@"recurrence_interval"] integerValue]];
        eventObject.recurrenceEndDate = [NSDate dateWithTimeIntervalSince1970:[eventDict[@"recurrence_end"] doubleValue]];
    }
    
    return eventObject;
}
@end