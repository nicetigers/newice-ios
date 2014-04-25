//
//  NWICourseManager.h
//  New Ice
//
//  Created by Naphat Sanguansin on 4/25/14.
//
//

#import <Foundation/Foundation.h>

@class Course;

@interface NWICourseManager : NSObject

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

-(Course *)getCourseByID:(NSInteger)courseID;
-(NSDictionary *)getCourseSectionsMap;


@end
