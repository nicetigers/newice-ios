//
//  NWIAppDelegate.h
//  New Ice
//
//  Created by Naphat Sanguansin on 4/23/14.
//
//

#import <UIKit/UIKit.h>

@class NWIAuthenticator, NWIServerConnection;

@interface NWIAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NWIAuthenticator *authenticator;
@property (strong, nonatomic) NWIServerConnection *serverConnection;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;

@end
