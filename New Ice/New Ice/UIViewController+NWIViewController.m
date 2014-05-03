//
//  UIViewController+NWIViewController.m
//  New Ice
//
//  Created by Naphat Sanguansin on 5/3/14.
//
//

#import "UIViewController+NWIViewController.h"

@implementation UIViewController (NWIViewController)

-(void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_VIEW_VISIBLE object:self];
}

@end
