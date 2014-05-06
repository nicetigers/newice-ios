//
//  Section.h
//  New Ice
//
//  Created by Naphat Sanguansin on 4/25/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ServerObject.h"

@class Course, EventGroup, UserSectionTable;

@interface Section : ServerObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * sectionType;
@property (nonatomic, retain) Course *course;
@property (nonatomic, retain) NSSet *enrollment;
@property (nonatomic, retain) NSSet *eventGroups;
@end

@interface Section (CoreDataGeneratedAccessors)

- (void)addEnrollmentObject:(UserSectionTable *)value;
- (void)removeEnrollmentObject:(UserSectionTable *)value;
- (void)addEnrollment:(NSSet *)values;
- (void)removeEnrollment:(NSSet *)values;

- (void)addEventGroupsObject:(EventGroup *)value;
- (void)removeEventGroupsObject:(EventGroup *)value;
- (void)addEventGroups:(NSSet *)values;
- (void)removeEventGroups:(NSSet *)values;
-(NSString *)formattedName;

@end
