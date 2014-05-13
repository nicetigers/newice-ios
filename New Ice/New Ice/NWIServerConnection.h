//
//  NWIServerConnection.h
//  New Ice
//
//  Created by Naphat Sanguansin on 4/25/14.
//
//

#import <Foundation/Foundation.h>

@class NWIAuthenticator;

@interface NWIServerConnection : NSObject

@property (nonatomic, strong) NWIAuthenticator *authenticator;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

-(void)sync;
-(void)syncEvents;

@end
