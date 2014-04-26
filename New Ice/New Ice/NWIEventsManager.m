//
//  NWIEventsManager.m
//  New Ice
//
//  Created by Naphat Sanguansin on 4/26/14.
//
//

#import "NWIEventsManager.h"

#import <CoreData/CoreData.h>

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
        NSManagedObjectModel *model = self.managedObjectContext.persistentStoreCoordinator.managedObjectModel;
        NSFetchRequest *fetchRequest = [model fetchRequestFromTemplateWithName:@"EventGroupByID" substitutionVariables:@{@"SERV_ID":  eventDict[@"event_group_id"]}];
        NSArray *fetched = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    }
}

@end
