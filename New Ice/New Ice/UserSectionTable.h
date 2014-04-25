//
//  UserSectionTable.h
//  New Ice
//
//  Created by Naphat Sanguansin on 4/25/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Section, User;

@interface UserSectionTable : NSManagedObject

@property (nonatomic, retain) NSDate * addDate;
@property (nonatomic, retain) Section *section;
@property (nonatomic, retain) User *user;

@end
