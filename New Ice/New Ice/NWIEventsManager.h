//
//  NWIEventsManager.h
//  New Ice
//
//  Created by Naphat Sanguansin on 4/26/14.
//
//

#import <Foundation/Foundation.h>

@interface NWIEventsManager : NSObject

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
-(void)pullEventsForCourseID:(NSInteger)courseID;

@end
