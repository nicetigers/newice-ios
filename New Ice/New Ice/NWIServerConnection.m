//
//  NWIServerConnection.m
//  New Ice
//
//  Created by Naphat Sanguansin on 4/25/14.
//
//

#import "NWIServerConnection.h"
#import "NWIAppDelegate.h"
#import "NWIAuthenticator.h"

#import "NWICourseManager.h"
#import "NWIEventsManager.h"

#import "User.h"
#import "Course.h"
#import "Section.h"
#import "UserSectionTable.h"

@interface NWIServerConnection ()

@property (nonatomic, strong) NSDate *lastConnected;
@property (nonatomic, strong) NSString *netid;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NWICourseManager *courseManager;
@property (nonatomic, strong) NWIEventsManager *eventsManager;

-(void)pull;
-(void)pullUserByNetID:(NSString *)netID makeAsynchronous:(BOOL)async;
-(void)processDownloadedUserData:(NSData *)data;
-(User *)getUserByNetID:(NSString *)netID;
-(void)syncEnrollmentForUser:(User *)user;
-(void)getEventsForEnrolledCourses:(User *)user;


@end

@implementation NWIServerConnection

#pragma mark - Server code

-(void)sync
{
    if (!self.netid) {
        return; // not logged in
    }
    [self pull];
}

-(void)pull
{
    User *curUser = [self getUserByNetID:self.netid];
    [self syncEnrollmentForUser:curUser];
    [self getEventsForEnrolledCourses:curUser];
}

#pragma mark Downloading/saving user data

-(void)pullUserByNetID:(NSString *)netID makeAsynchronous:(BOOL)async
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/get/user", SERVER_URL]]];
    if (async) {
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (connectionError) {
                NSLog(@"Error downloading user for net id %@. \n Error: %@", netID, connectionError.description);
                return;
            }
            [self processDownloadedUserData:data];
        }];
    } else {
        NSURLResponse *response;
        NSError *error;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        if (error) {
            NSLog(@"Error downloading user for net id %@. \n Error: %@", netID, error.description);
            return;
        }
        [self processDownloadedUserData:data];
    }
}
-(void)processDownloadedUserData:(NSData *)data
{
    NSError *error;
    NSDictionary *userDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error) {
        NSLog(@"Error processing user data. Error: %@", error.description);
    }
    NSManagedObjectModel *model = self.managedObjectContext.persistentStoreCoordinator.managedObjectModel;
    NSFetchRequest *fetchRequest = [model fetchRequestFromTemplateWithName:@"UserByNetID" substitutionVariables:@{@"NET_ID":  userDict[@"netid"]}];
    NSArray *fetched = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"Error proccessing fetch request for net id %@. Error: %@", userDict[@"netid"], error.description);
        return;
    }
    User *curUser;
    if (fetched.count > 0) {
        curUser = fetched.lastObject;
    } else {
        curUser = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:self.managedObjectContext];
        curUser.netid = userDict[@"netid"];
    }
    curUser.name = userDict[@"name"];
    curUser.lastActivityTime = [NSDate dateWithTimeIntervalSince1970:[userDict[@"lastActivityTime"] doubleValue]];
    [self.managedObjectContext save:&error];
    if (error) {
        NSLog(@"Error saving user for netid %@. Error: %@", curUser.netid, error.description);
        return;
    }
}

#pragma mark Enrollment

-(void)syncEnrollmentForUser:(User *)user
{
    NSDictionary *courseSectionsMap = [self.courseManager getCourseSectionsMap];
    for (NSString *courseID in courseSectionsMap.allKeys) {
        Course *courseObject = [self.courseManager getCourseByID:courseID.integerValue];
        for (NSNumber *sectionID in courseSectionsMap[courseID]) {
            Section *sectionObject = nil;
            for (Section *someSection in courseObject.sections) {
                if ([someSection.serverID isEqualToNumber:sectionID]) {
                    sectionObject = someSection;
                }
            }
            if (sectionObject) {
                [self enrollUser:user inSection:sectionObject];
            }
        }
    }
}
-(void)enrollUser:(User *)user inSection:(Section *)sectionObject
{
    NSError *error;
    NSManagedObjectModel *model = self.managedObjectContext.persistentStoreCoordinator.managedObjectModel;
    NSFetchRequest *fetchRequest = [model fetchRequestFromTemplateWithName:@"Enrollment" substitutionVariables:@{@"USER":  user.objectID, @"SECTION": sectionObject.objectID}];
    NSArray *fetched = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"Error getting enrollment for user %@ and section %@. \n Error: %@", user.netid, sectionObject.name, error.description);
        return;
    }
    if (fetched.count == 0)
    {
        UserSectionTable *enrollmentObject = [NSEntityDescription insertNewObjectForEntityForName:@"UserSectionTable" inManagedObjectContext:self.managedObjectContext];
        enrollmentObject.user = user;
        enrollmentObject.section = sectionObject;
        enrollmentObject.addDate = [NSDate date];
        [self.managedObjectContext save:&error];
        if (error) {
            NSLog(@"Error saving enrollment for user %@ and section %@. \n Error: %@", user.netid, sectionObject.name, error.description);
            return;
        }
    }
}

#pragma mark Events
-(void)getEventsForEnrolledCourses:(User *)user
{
    NSMutableSet *courseIDSet = [NSMutableSet new];
    for (UserSectionTable *enrollmentObject in user.enrollment) {
        [courseIDSet addObject:enrollmentObject.section.course.serverID];
    }
    [self.eventsManager pullEventsForCourseIDs:[courseIDSet allObjects] makeAsynchronous:NO];
}

#pragma mark - getters/setters methods

-(NSString *)netid
{
    if (!_netid) {
        NWIAppDelegate *delegate = [UIApplication sharedApplication].delegate;
        _netid = delegate.authenticator.netid;
    }
    return _netid;
}
-(User *)getUserByNetID:(NSString *)netID
{
    NSError *error;
    NSManagedObjectModel *model = self.managedObjectContext.persistentStoreCoordinator.managedObjectModel;
    NSFetchRequest *fetchRequest = [model fetchRequestFromTemplateWithName:@"UserByNetID" substitutionVariables:@{@"NET_ID":  netID}];
    NSArray *fetched = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"Error proccessing fetch request for net id %@. Error: %@", netID, error.description);
        return nil;
    }
    if (fetched.count > 0) {
        return fetched.lastObject;
    }
    // must download user first
    [self pullUserByNetID:netID makeAsynchronous:NO];
    return [self getUserByNetID:netID]; // DANGER can go into infinite loop if given errorneous netID
}

-(NSManagedObjectContext *)managedObjectContext
{
    if (!_managedObjectContext) {
        NWIAppDelegate *delegate = [UIApplication sharedApplication].delegate;
        NSPersistentStoreCoordinator *coordinator = [delegate persistentStoreCoordinator];
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        _managedObjectContext.persistentStoreCoordinator = coordinator;
    }
    return _managedObjectContext;
}
-(NWICourseManager *)courseManager
{
    if (!_courseManager) {
        _courseManager = [NWICourseManager new];
        _courseManager.managedObjectContext = self.managedObjectContext;
    }
    return _courseManager;
}
-(NWIEventsManager *)eventsManager
{
    if (!_eventsManager) {
        _eventsManager = [NWIEventsManager new];
        _eventsManager.managedObjectContext = self.managedObjectContext;
    }
    return _eventsManager;
}

@end
