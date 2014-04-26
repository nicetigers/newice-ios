//
//  NWIEventsManager.h
//  New Ice
//
//  Created by Naphat Sanguansin on 4/26/14.
//
//

#import <Foundation/Foundation.h>

@class NWICourseManager;

@interface NWIEventsManager : NSObject

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NWICourseManager *courseManager;
-(void)pullEventsForCourseIDs:(NSArray *)courseIDs makeAsynchronous:(BOOL)async;

@end
