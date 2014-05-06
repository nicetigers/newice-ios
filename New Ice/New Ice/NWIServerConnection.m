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

#import "NWICourseServerConnection.h"
#import "NWIEventsServerConnection.h"

#import "User.h"
#import "Course.h"
#import "Section.h"
#import "UserSectionTable.h"

@interface NWIServerConnection ()

@property (nonatomic, strong) NSDate *lastConnected;
@property (nonatomic, strong) NSString *netid;

@property (nonatomic, strong) NWICourseServerConnection *courseServerConnection;
@property (nonatomic, strong) NWIEventsServerConnection *eventsServerConnection;
@property (nonatomic, assign) BOOL idle;

-(void)pull;
-(void)pullUserByNetID:(NSString *)netID makeAsynchronous:(BOOL)async;
-(void)processDownloadedUserData:(NSData *)data;
-(User *)getUserByNetID:(NSString *)netID;
-(void)syncEnrollmentForUser:(User *)user;


@end

@implementation NWIServerConnection

#pragma mark - Server code

-(id)init
{
    self = [super init];
    if (self) {
        self.idle = YES;
        self.lastConnected = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastConnected"];
    }
    return self;
}

-(void)sync
{
    if (!self.idle) {
        return;
    }
    self.idle = NO;
    [self.authenticator showAuthenticationViewIfNeededWithCompletionHandler:^(BOOL shown) {
        [self pull];
        self.idle = YES;
    }];
}

-(void)pull
{
    NSLog(@"syncing");
    
    User *curUser = [self getUserByNetID:self.netid];
    [self syncEnrollmentForUser:curUser];
    NSDate *lastConnected = self.lastConnected;
    [self.eventsServerConnection pullEventsForUser:self.netid lastConnected:&lastConnected];
    self.lastConnected = lastConnected;
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
    NSDictionary *courseSectionsMap = [self.courseServerConnection getCourseSectionsMap];
    NSDictionary *sectionsColor = [self.courseServerConnection getSectionColors];
    for (NSString *courseID in courseSectionsMap.allKeys) {
        Course *courseObject = [self.courseServerConnection getCourseByID:courseID.integerValue];
        for (NSNumber *sectionID in courseSectionsMap[courseID]) {
            Section *sectionObject = nil;
            for (Section *someSection in courseObject.sections) {
                if ([someSection.serverID isEqualToNumber:sectionID]) {
                    sectionObject = someSection;
                }
            }
            if (sectionObject) {
                NSString *hexString = sectionsColor[sectionID.stringValue][@"color"];
                NSNumber *colorHex = nil;
                if (hexString) {
                    unsigned int hexInt = 0;
                    // Create scanner
                    NSScanner *scanner = [NSScanner scannerWithString:hexString];
                    
                    // Tell scanner to skip the # character
                    [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"#"]];
                    
                    // Scan hex value
                    [scanner scanHexInt:&hexInt];
                    
                    colorHex = [NSNumber numberWithUnsignedInt:hexInt];
                }
                [self enrollUser:user inSection:sectionObject withColor:colorHex];
            }
        }
    }
}
-(void)enrollUser:(User *)user inSection:(Section *)sectionObject withColor:(NSNumber *)colorHex
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
        enrollmentObject.color = colorHex;
        //[self.managedObjectContext save:&error];
        if (error) {
            NSLog(@"Error saving enrollment for user %@ and section %@. \n Error: %@", user.netid, sectionObject.name, error.description);
            return;
        }
    } else{
        // TODO update section color
        UserSectionTable *enrollmentObject = fetched.lastObject;
        enrollmentObject.color = colorHex;
        //[self.managedObjectContext save:&error];
        if (error) {
            NSLog(@"Error saving enrollment for user %@ and section %@. \n Error: %@", user.netid, sectionObject.name, error.description);
            return;
        }
    }
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
        
        
        [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextDidSaveNotification object:delegate.managedObjectContext queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            [_managedObjectContext performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:) withObject:note waitUntilDone:YES];
        }];
    }
    return _managedObjectContext;
}
-(NWICourseServerConnection *)courseServerConnection
{
    if (!_courseServerConnection) {
        _courseServerConnection = [NWICourseServerConnection new];
        _courseServerConnection.managedObjectContext = self.managedObjectContext;
    }
    return _courseServerConnection;
}
-(NWIEventsServerConnection *)eventsServerConnection
{
    if (!_eventsServerConnection) {
        _eventsServerConnection = [NWIEventsServerConnection new];
        _eventsServerConnection.managedObjectContext = self.managedObjectContext;
        _eventsServerConnection.courseServerConnection = self.courseServerConnection;
    }
    return _eventsServerConnection;
}

-(void)setLastConnected:(NSDate *)lastConnected
{
    if (lastConnected != _lastConnected) {
        _lastConnected = lastConnected;
        [[NSUserDefaults standardUserDefaults] setObject:_lastConnected forKey:@"lastConnected"];
    }
}

@end
