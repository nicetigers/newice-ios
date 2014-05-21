//
//  MutableServerObject.h
//  ReCal
//
//  Created by Naphat Sanguansin on 5/21/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ServerObject.h"


@interface MutableServerObject : ServerObject

@property (nonatomic, retain) NSNumber * modified;

@end
