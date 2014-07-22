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
	// Because UIKit does not remove views from hierarchy when transition finished
	[source beginAppearanceTransition:NO animated:YES];
	
	[UIView animateKeyframesWithDuration:0.5 delay:0.0 options:UIViewKeyframeAnimationOptionCalculationModeCubic animations:^{
		[UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:1.0 animations:^{
			CGRect sourceRect = source.view.frame;
			sourceRect.origin.y = CGRectGetHeight(container.bounds);
			source.view.frame = sourceRect;
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
		[transitionContext completeTransition:finished];
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
	// Because UIKit does not remove views from hierarchy when transition finished
	[destination beginAppearanceTransition:YES animated:YES];

	// Move destination view below source view
	CGRect destRect = destination.view.frame;
	destRect.origin.y = CGRectGetHeight(container.bounds);
	destination.view.frame = destRect;
	
	// Animate
	[UIView animateKeyframesWithDuration:0.5 delay:0.0 options:UIViewKeyframeAnimationOptionCalculationModeCubic animations:^{
		[UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:1.0 animations:^{
			CGRect destRect = destination.view.frame;
			destRect.origin.y = 0;
			destination.view.frame = destRect;
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
		
		// We don't have to remove source.view here as UIKit takes care of this on dismiss
		
		// Finish transition
		[transitionContext completeTransition:finished];
	}];
}

@end
