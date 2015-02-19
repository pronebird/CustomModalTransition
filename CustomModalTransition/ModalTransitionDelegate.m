//
//  ModalTransitionDelegate.m
//  CustomModalTransition
//
//  Created by pronebird on 2/19/15.
//  Copyright (c) 2015 codeispoetry.ru. All rights reserved.
//

#import "ModalTransitionDelegate.h"
#import "ModalTransitionAnimator.h"
#import "ModalPresentationController.h"

@implementation ModalTransitionDelegate

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return [ModalTransitionAnimator new];
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [ModalTransitionAnimator new];
}

- (UIPresentationController*)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source {
    return [[ModalPresentationController alloc] initWithPresentedViewController:presented presentingViewController:source];
}

@end
