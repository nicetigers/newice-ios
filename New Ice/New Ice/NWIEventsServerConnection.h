//
//  NWIEventsManager.h
//  New Ice
//
//  Created by Naphat Sanguansin on 4/26/14.
//
//

#import <Foundation/Foundation.h>

@class NWICourseServerConnection;

@interface NWIEventsServerConnection : NSObject

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NWICourseServerConnection *courseServerConnection;
-(void)pullEventsForCourseIDs:(NSArray *)courseIDs makeAsynchronous:(BOOL)async;
-(void)pullEventsForUser:(NSString *)netid lastConnected:(NSDate **)lastConnected;

@end
