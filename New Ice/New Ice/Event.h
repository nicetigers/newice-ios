//
//  Event.h
//  New Ice
//
//  Created by Naphat Sanguansin on 4/25/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class EventGroup;

@interface Event : NSManagedObject

@property (nonatomic, retain) NSString * eventDescription;
@property (nonatomic, retain) NSDate * eventEnd;
@property (nonatomic, retain) NSString * eventLocation;
@property (nonatomic, retain) NSDate * eventStart;
@property (nonatomic, retain) NSString * eventTitle;
@property (nonatomic, retain) NSString * eventType;
@property (nonatomic, retain) NSDate * modifiedTime;
@property (nonatomic, retain) EventGroup *eventGroup;

@end
