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
#import "User.h"

@interface NWIServerConnection ()

@property (nonatomic, strong) NSDate *lastConnected;
@property (nonatomic, strong) NSString *netid;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

-(void)pull;
-(void)pullUserByNetID:(NSString *)netID makeAsynchronous:(BOOL)async;
-(void)processDownloadedUserData:(NSData *)data;
-(User *)getUserByNetID:(NSString *)netID;


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
    // must download course first
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

@end
