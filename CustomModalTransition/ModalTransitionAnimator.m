//
//  ModalTransitionAnimator.m
//  CustomModalTransition
//
//  Created by pronebird on 29/05/14.
//  Copyright (c) 2014 codeispoetry.ru. All rights reserved.
//

#import "ModalTransitionAnimator.h"

@implementation ModalTransitionAnimator

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
	return 0.5;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
	UIViewController* destination = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
	
	if([destination isBeingPresented]) {
		[self animatePresentation:transitionContext];
	} else {
		[self animateDismissal:transitionContext];
	}
}

//
// Calculate a final frame for presenting controller according to interface orientation
// Presenting controller should always slide down and its top should coincide with the bottom of screen
//
- (CGRect)presentingControllerFrameWithContext:(id<UIViewControllerContextTransitioning>)transitionContext {
	CGRect frame = transitionContext.containerView.bounds;
	
	if(floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1) // iOS 8+
	{
		//
		// On iOS 8, UIKit handles rotation using transform matrix
		// Therefore we should always return a frame for portrait mode
		//
		return CGRectMake(0, CGRectGetHeight(frame), CGRectGetWidth(frame), CGRectGetHeight(frame));
	}
	else
	{
		//
		// On iOS 7, UIKit does not handle rotation
		// To make sure our view is moving in the right direction (always down) we should
		// fix the frame accoding to interface orientation.
		//
		UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
		
		switch (orientation) {
			case UIInterfaceOrientationLandscapeLeft:
				return CGRectMake(CGRectGetHeight(frame), 0, CGRectGetWidth(frame), CGRectGetHeight(frame));
				break;
			case UIInterfaceOrientationLandscapeRight:
				return CGRectMake(-CGRectGetHeight(frame), 0, CGRectGetWidth(frame), CGRectGetHeight(frame));
				break;
			case UIInterfaceOrientationPortraitUpsideDown:
				return CGRectMake(0, -CGRectGetHeight(frame), CGRectGetWidth(frame), CGRectGetHeight(frame));
				break;
			default:
			case UIInterfaceOrientationPortrait:
				return CGRectMake(0, CGRectGetHeight(frame), CGRectGetWidth(frame), CGRectGetHeight(frame));
				break;
		}
	}
}

- (void)animatePresentation:(id<UIViewControllerContextTransitioning>)transitionContext
{
	UIViewController* source = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
	UIViewController* destination = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
	UIView* container = transitionContext.containerView;
	
	// Orientation bug fix
	// See: http://stackoverflow.com/a/20061872/351305
	destination.view.frame = container.bounds;
	source.view.frame = container.bounds;
	
	// Add controllers
	[container addSubview:destination.view];
	[container addSubview:source.view];
	
	// Move destination snapshot back in Z plane
	// Important: original transform3d is different from CATransform3DIdentity
	CATransform3D originalTransform = destination.view.layer.transform;
	
	// Apply custom transform
	CATransform3D perspectiveTransform = originalTransform;
	perspectiveTransform.m34 = 1.0 / -1000.0;
	perspectiveTransform = CATransform3DTranslate(perspectiveTransform, 0, 0, -100);
	destination.view.layer.transform = perspectiveTransform;
	
	// Start appearance transition for source controller
	// Because UIKit does not do this automatically
	[source beginAppearanceTransition:NO animated:YES];
	
	// Animate
	[UIView animateKeyframesWithDuration:0.5 delay:0.0 options:UIViewKeyframeAnimationOptionCalculationModeCubic animations:^{
		[UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:1.0 animations:^{
			source.view.frame = [self presentingControllerFrameWithContext:transitionContext];
		}];
		[UIView addKeyframeWithRelativeStartTime:0.2 relativeDuration:0.8 animations:^{
			destination.view.layer.transform = originalTransform;
		}];
	} completion:^(BOOL finished) {
		// Important: remove source view
		// Otherwise it may show up on rotation..
		[source.view removeFromSuperview];
		
		// End appearance transition for source controller
		[source endAppearanceTransition];
		
		// Finish transition
		[transitionContext completeTransition:YES];
	}];
}

- (void)animateDismissal:(id<UIViewControllerContextTransitioning>)transitionContext
{
	UIViewController* source = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
	UIViewController* destination = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
	UIView* container = transitionContext.containerView;
	
	// Orientation bug fix
	// See: http://stackoverflow.com/a/20061872/351305
	destination.view.frame = container.bounds;
	source.view.frame = container.bounds;
	
	// Add controllers
	[container addSubview:source.view];
	[container addSubview:destination.view];
	
	// Start appearance transition for destination controller
	// Because UIKit does not do this automatically
	[destination beginAppearanceTransition:YES animated:YES];

	// Move destination view below source view
	destination.view.frame = [self presentingControllerFrameWithContext:transitionContext];
	
	// Animate
	[UIView animateKeyframesWithDuration:0.5 delay:0.0 options:UIViewKeyframeAnimationOptionCalculationModeCubic animations:^{
		[UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:1.0 animations:^{
			destination.view.frame = container.bounds;
		}];
		[UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:1.0 animations:^{
			// Important: original transform3d is different from CATransform3DIdentity
			CATransform3D perspectiveTransform = source.view.layer.transform;
			
			perspectiveTransform.m34 = 1.0 / -1000.0;
			perspectiveTransform = CATransform3DTranslate(perspectiveTransform, 0, 0, -100);
			source.view.layer.transform = perspectiveTransform;
		}];
	} completion:^(BOOL finished) {
		// End appearance transition for destination controller
		[destination endAppearanceTransition];
		
		// Remove source view
		[source.view removeFromSuperview];
		
		//
		// iOS 8 beta 5 Patch:
		// UIKit removes destination.view from hierarchy and leaves the blank screen.
		// Manually adding UILayoutContainer to window hierarchy magically solves the problem.
		//
		if(floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1) {
			[destination.view.window addSubview:destination.view];
		}
		
		// Finish transition
		[transitionContext completeTransition:YES];
	}];
}

@end
