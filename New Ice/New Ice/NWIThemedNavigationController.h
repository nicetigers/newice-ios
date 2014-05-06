//
//  NWIThemedNavigationController.h
//  New Ice
//
//  Created by Naphat Sanguansin on 5/6/14.
//
//

#import <UIKit/UIKit.h>

@interface NWIThemedNavigationController : UINavigationController

@property (nonatomic, weak) UIViewController *viewControllerForPreferredStatusBarStyle;
@property (nonatomic, assign) NWITheme theme;

@end
