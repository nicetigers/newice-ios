//
//  NWIEventsManager.m
//  New Ice
//
//  Created by Naphat Sanguansin on 5/3/14.
//
//

#import <CoreData/CoreData.h>
#import "NWIEventsManager.h"
#import "NWIAppDelegate.h"

@interface NWIEventsManager ()

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation NWIEventsManager

-(NSManagedObjectContext *)managedObjectContext
{
    if (!_managedObjectContext)
    {
        NWIAppDelegate *delegate = [UIApplication sharedApplication].delegate;
        _managedObjectContext = delegate.managedObjectContext;
    }
    return _managedObjectContext;
}

@end
