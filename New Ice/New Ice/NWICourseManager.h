//
//  NWICourseManager.h
//  New Ice
//
//  Created by Naphat Sanguansin on 4/25/14.
//
//

#import <Foundation/Foundation.h>

@class Course, Section;

@interface NWICourseManager : NSObject

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

-(Course *)getCourseByID:(NSInteger)courseID;
-(Section *)getSectionByID:(NSInteger)sectionID;
-(NSDictionary *)getCourseSectionsMap;


@end
