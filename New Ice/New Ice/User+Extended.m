//
//  User+Extended.m
//  ReCal
//
//  Created by Naphat Sanguansin on 5/21/14.
//
//

#import "User+Extended.h"

@implementation User (Extended)

+(User *)userByNetID:(NSString *)netID inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSError *error;
    NSManagedObjectModel *model = managedObjectContext.persistentStoreCoordinator.managedObjectModel;
    NSFetchRequest *fetchRequest = [model fetchRequestFromTemplateWithName:@"UserByNetID" substitutionVariables:@{@"NET_ID":  netID}];
    NSArray *fetched = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"Error proccessing fetch request for net id %@. Error: %@", netID, error.description);
        return nil;
    }
    if (fetched.count > 0) {
        return fetched.lastObject;
    }
    return nil;
}

@end
