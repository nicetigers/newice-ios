//
//  Event.h
//  ReCal
//
//  Created by Naphat Sanguansin on 5/21/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MutableServerObject.h"

@class Section;

@interface Event : MutableServerObject

@property (nonatomic, retain) NSString * eventDescription;
@property (nonatomic, retain) NSDate * eventEnd;
@property (nonatomic, retain) NSString * eventLocation;
@property (nonatomic, retain) NSDate * eventStart;
@property (nonatomic, retain) NSString * eventTitle;
@property (nonatomic, retain) NSString * eventType;
@property (nonatomic, retain) NSDate * modifiedTime;
@property (nonatomic, retain) NSNumber * eventGroupID;
@property (nonatomic, retain) NSString * recurrenceDays;
@property (nonatomic, retain) NSNumber * recurrenceInterval;
@property (nonatomic, retain) NSDate * recurrenceEndDate;
@property (nonatomic, retain) Section *section;

@end
