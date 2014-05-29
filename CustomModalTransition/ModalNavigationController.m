//
//  ModalNavigationController.m
//  CustomModalTransition
//
//  Created by pronebird on 29/05/14.
//  Copyright (c) 2014 codeispoetry.ru. All rights reserved.
//

#import "ModalNavigationController.h"

@implementation ModalNavigationController

// Forward status bar appearance to child view controller
- (UIViewController*)childViewControllerForStatusBarStyle {
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

@end
