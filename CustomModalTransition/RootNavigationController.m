//
//  RootNavigationController.m
//  CustomModalTransition
//
//  Created by pronebird on 29/05/14.
//  Copyright (c) 2014 codeispoetry.ru. All rights reserved.
//

#import "RootNavigationController.h"

@implementation RootNavigationController

// Forward status bar appearance to child view controller
- (UIViewController*)childViewControllerForStatusBarStyle {
    return self.topViewController;
}

- (UIViewController*)childViewControllerForStatusBarHidden {
    return self.topViewController;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (UIStoryboardSegue*)segueForUnwindingToViewController:(UIViewController *)toViewController fromViewController:(UIViewController *)fromViewController identifier:(NSString *)identifier {
    // UIKit bug: http://stackoverflow.com/a/28607309/351305
    return [toViewController segueForUnwindingToViewController:toViewController fromViewController:fromViewController identifier:identifier];
}

@end
