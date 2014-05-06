//
//  NWIEventsManager.h
//  New Ice
//
//  Created by Naphat Sanguansin on 5/3/14.
//
//

#import <Foundation/Foundation.h>

@interface NWIEventsManager : NSObject

-(NSArray *)getFutureEvents;
-(NSString *)eventTypeForKey:(NSString *)key;

@end
