//
//  RootViewController.m
//  CustomModalTransition
//
//  Created by pronebird on 29/05/14.
//  Copyright (c) 2014 codeispoetry.ru. All rights reserved.
//

#import "RootViewController.h"
#import "ModalTransitionDelegate.h"

@interface RootViewController()

@property (nonatomic) ModalTransitionDelegate* transitionDelegate;

@end

@implementation RootViewController

- (ModalTransitionDelegate*)transitionDelegate {
    if(!_transitionDelegate) {
        _transitionDelegate = [ModalTransitionDelegate new];
    }
    return _transitionDelegate;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
	return UIStatusBarStyleDefault;
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

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	UIViewController* controller = (UIViewController*)segue.destinationViewController;
	
	controller.transitioningDelegate = self.transitionDelegate;
	controller.modalPresentationStyle = UIModalPresentationCustom;
	controller.modalPresentationCapturesStatusBarAppearance = YES;
}

- (IBAction)unwindToRootViewController:(UIStoryboardSegue*)unwindSegue {}

@end
