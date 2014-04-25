//
//  EventGroup.h
//  New Ice
//
//  Created by Naphat Sanguansin on 4/25/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ServerObject.h"

@class Event, Section;

@interface EventGroup : ServerObject

@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSDate * modifiedTime;
@property (nonatomic, retain) NSString * recurrenceDays;
@property (nonatomic, retain) NSNumber * recurrenceInterval;
@property (nonatomic, retain) NSSet *events;
@property (nonatomic, retain) Section *section;
@end

@interface EventGroup (CoreDataGeneratedAccessors)

- (void)addEventsObject:(Event *)value;
- (void)removeEventsObject:(Event *)value;
- (void)addEvents:(NSSet *)values;
- (void)removeEvents:(NSSet *)values;

@end
