//
//  NWIThemedNavigationController.m
//  New Ice
//
//  Created by Naphat Sanguansin on 5/6/14.
//
//

#import "NWIThemedNavigationController.h"

@interface NWIThemedNavigationController ()

@end

@implementation NWIThemedNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.theme = [[[NSUserDefaults standardUserDefaults] valueForKey:@"theme"] intValue];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIViewController *)childViewControllerForStatusBarStyle
{
    return self.viewControllerForPreferredStatusBarStyle;
}

-(void)setViewControllerForPreferredStatusBarStyle:(UIViewController *)viewControllerForPreferredStatusBarStyle
{
    if (_viewControllerForPreferredStatusBarStyle != viewControllerForPreferredStatusBarStyle)
    {
        _viewControllerForPreferredStatusBarStyle = viewControllerForPreferredStatusBarStyle;
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)updateBarStyle
{
    switch (self.theme) {
        case NWIThemeBlack:
            [self.navigationBar setBarStyle:UIBarStyleBlackTranslucent];
            break;
        case NWIThemeWhite:
            [self.navigationBar setBarStyle:UIBarStyleDefault];
            break;
        default:
            break;
    }
}

-(void)setTheme:(NWITheme)theme
{
    if (_theme != theme) {
        _theme = theme;
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:theme] forKey:@"theme"];
        [self updateBarStyle];
    }
}

@end
