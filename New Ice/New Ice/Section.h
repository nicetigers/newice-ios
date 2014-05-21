//
//  Section.h
//  ReCal
//
//  Created by Naphat Sanguansin on 5/21/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ServerObject.h"

@class Course, Event, UserSectionTable;

@interface Section : ServerObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * sectionType;
@property (nonatomic, retain) Course *course;
@property (nonatomic, retain) NSSet *enrollment;
@property (nonatomic, retain) NSSet *events;
@end

@interface Section (CoreDataGeneratedAccessors)

- (void)addEnrollmentObject:(UserSectionTable *)value;
- (void)removeEnrollmentObject:(UserSectionTable *)value;
- (void)addEnrollment:(NSSet *)values;
- (void)removeEnrollment:(NSSet *)values;

- (void)addEventsObject:(Event *)value;
- (void)removeEventsObject:(Event *)value;
- (void)addEvents:(NSSet *)values;
- (void)removeEvents:(NSSet *)values;

@end
