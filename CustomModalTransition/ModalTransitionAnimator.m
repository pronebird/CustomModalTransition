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

- (CGRect)finalFrameForPresentedControllerWithContext:(id<UIViewControllerContextTransitioning>)transitionContext {
	CGRect frame = transitionContext.containerView.bounds;
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
			source.view.frame = [self finalFrameForPresentedControllerWithContext:transitionContext];
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
	destination.view.frame = [self finalFrameForPresentedControllerWithContext:transitionContext];
	
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
		
		// Finish transition
		[transitionContext completeTransition:YES];
	}];
}

@end
