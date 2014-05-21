//
//  Course.h
//  ReCal
//
//  Created by Naphat Sanguansin on 5/21/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ServerObject.h"

@class Section, Semester;

@interface Course : ServerObject

@property (nonatomic, retain) NSString * courseListings;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *sections;
@property (nonatomic, retain) Semester *semester;
@end

@interface Course (CoreDataGeneratedAccessors)

- (void)addSectionsObject:(Section *)value;
- (void)removeSectionsObject:(Section *)value;
- (void)addSections:(NSSet *)values;
- (void)removeSections:(NSSet *)values;

@end
