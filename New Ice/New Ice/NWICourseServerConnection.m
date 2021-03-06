//
//  NWICourseManager.m
//  New Ice
//
//  Created by Naphat Sanguansin on 4/25/14.
//
//
#import <CoreData/CoreData.h>
#import "NWICourseServerConnection.h"
#import "Course.h"
#import "Section.h"

@interface NWICourseServerConnection ()

-(void)pullCourseByID:(NSInteger)courseID makeAsynchronous:(BOOL)async;
-(void)processDownloadedData:(NSData *)data;
-(Section *)getOrCreateSection:(NSDictionary *)sectionDict;

@end

@implementation NWICourseServerConnection

-(Course *)getCourseByID:(NSInteger)courseID
{
    NSError *error;
    NSManagedObjectModel *model = self.managedObjectContext.persistentStoreCoordinator.managedObjectModel;
    NSFetchRequest *fetchRequest = [model fetchRequestFromTemplateWithName:@"CourseByID" substitutionVariables:@{@"SERV_ID":  [NSNumber numberWithInteger:courseID]}];
    NSArray *fetched = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"Error proccessing fetch request for course id %d. Error: %@", courseID, error.description);
        return nil;
    }
    if (fetched.count > 0) {
        return fetched.lastObject;
    }
    // must download course first
    [self pullCourseByID:courseID makeAsynchronous:NO];
    return [self getCourseByID:courseID]; // DANGER can go into infinite loop if given errorneous course ID
}
-(Section *)getSectionByID:(NSInteger)sectionID
{
    NSError *error;
    NSManagedObjectModel *model = self.managedObjectContext.persistentStoreCoordinator.managedObjectModel;
    NSFetchRequest *fetchRequest = [model fetchRequestFromTemplateWithName:@"SectionByID" substitutionVariables:@{@"SERV_ID":  [NSNumber numberWithInteger:sectionID]}];
    NSArray *fetched = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"Error proccessing fetch request for section id %d. Error: %@", sectionID, error.description);
        return nil;
    }
    if (fetched.count > 0) {
        return fetched.lastObject;
    } else {
        return nil;
    }
}

-(NSDictionary *)getCourseSectionsMap;
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/get/sections", SERVER_URL]]];
    NSURLResponse *response;
    NSError *error;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (error) {
        NSLog(@"Error downloading course sections map. \nError: %@", error.description);
        return nil;
    }
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error) {
        NSLog(@"Error parsing json. \nError: %@", error.description);
    }
    return dict;
}

-(NSDictionary *)getSectionColors
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/get/section-colors", SERVER_URL]]];
    NSURLResponse *response;
    NSError *error;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (error) {
        NSLog(@"Error downloading section colors. \nError: %@", error.description);
        return nil;
    }
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error) {
        NSLog(@"Error parsing json. \nError: %@", error.description);
        return nil;
    }
    return dict;
}

-(void)pullCourseByID:(NSInteger)courseID makeAsynchronous:(BOOL)async
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/get/course/%d", SERVER_URL, courseID]]];
    if (async) {
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (connectionError) {
                NSLog(@"Error downloading course id %d. \n Error: %@", courseID, connectionError.description);
                return;
            }
            [self processDownloadedData:data];
        }];
    } else {
        NSURLResponse *response;
        NSError *error;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        if (error) {
            NSLog(@"Error downloading course id %d. \n Error: %@", courseID, error.description);
            return;
        }
        [self processDownloadedData:data];
    }
}

-(void)processDownloadedData:(NSData *)data
{
    NSError *error;
    NSDictionary *courseDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if (error) {
        NSLog(@"Error processing data. Error: %@", error.description);
        return;
    }
    NSManagedObjectModel *model = self.managedObjectContext.persistentStoreCoordinator.managedObjectModel;
    NSFetchRequest *fetchRequest = [model fetchRequestFromTemplateWithName:@"CourseByID" substitutionVariables:@{@"SERV_ID":  [NSNumber numberWithInteger:[courseDict[@"course_id"] integerValue]]}];
    NSArray *fetched = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"Error proccessing fetch request for course id %@. Error: %@", courseDict[@"course_id"], error.description);
        return;
    }
    Course *courseObject;
    if (fetched.count > 0) {
        courseObject = fetched.lastObject;
    } else {
        courseObject = [NSEntityDescription insertNewObjectForEntityForName:@"Course" inManagedObjectContext:self.managedObjectContext];
        courseObject.serverID = [NSNumber numberWithInteger:[courseDict[@"course_id"] integerValue]];
    }
    courseObject.title = courseDict[@"course_title"];
    courseObject.courseListings = courseDict[@"course_listings"];
    courseObject.desc = courseDict[@"course_description"];
    for (NSString *sectionType in [courseDict[@"sections"] allKeys]) {
        for (NSMutableDictionary *sectionDict in courseDict[@"sections"][sectionType]) {
            sectionDict[@"section_type"] = sectionType;
            [courseObject addSectionsObject:[self getOrCreateSection:sectionDict]];
        }
    }
    [self.managedObjectContext save:&error];
    if (error) {
        NSLog(@"Error saving course for id %@. Error: %@", courseObject.serverID, error.description);
        return;
    }
}

-(Section *)getOrCreateSection:(NSDictionary *)sectionDict
{
    NSError *error;
    NSManagedObjectModel *model = self.managedObjectContext.persistentStoreCoordinator.managedObjectModel;
    NSFetchRequest *fetchRequest = [model fetchRequestFromTemplateWithName:@"SectionByID" substitutionVariables:@{@"SERV_ID":  [NSNumber numberWithInteger:[sectionDict[@"section_id"] integerValue]]}];
    NSArray *fetched = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"Error proccessing fetch request for section id %@. Error: %@", sectionDict[@"section_id"], error.description);
        return nil;
    }
    Section *sectionObject;
    if (fetched.count > 0) {
        sectionObject = fetched.lastObject;
    } else {
        sectionObject = [NSEntityDescription insertNewObjectForEntityForName:@"Section" inManagedObjectContext:self.managedObjectContext];
        sectionObject.serverID = [NSNumber numberWithInteger:[sectionDict[@"section_id"] integerValue]];
    }
    sectionObject.name = sectionDict[@"section_name"];
    sectionObject.sectionType = sectionDict[@"section_type_code"];
    return sectionObject;
}


@end
