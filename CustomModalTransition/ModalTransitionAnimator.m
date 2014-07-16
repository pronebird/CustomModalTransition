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
	
	// Take source view snapshot
	UIView* sourceSS = [source.view snapshotViewAfterScreenUpdates:NO];
	
	// Hide source view while animation
	source.view.hidden = YES;
	
	// Add destination controller to view
	[container addSubview:destination.view];
	
	// Add snapshot view
	[container addSubview:sourceSS];
	
	// Move destination snapshot back in Z plane
	CATransform3D perspectiveTransform = CATransform3DIdentity;
	perspectiveTransform.m34 = 1.0 / -1000.0;
	perspectiveTransform = CATransform3DTranslate(perspectiveTransform, 0, 0, -100);
	destination.view.layer.transform = perspectiveTransform;
	
	// Start appearance transition for source controller
	// Because UIKit does not remove views from hierarchy when transition finished
	[source beginAppearanceTransition:NO animated:YES];
	
	// Animate
	[UIView animateKeyframesWithDuration:0.5 delay:0.0 options:UIViewKeyframeAnimationOptionCalculationModeCubic animations:^{
		[UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:1.0 animations:^{
			CGRect sourceRect = sourceSS.frame;
			sourceRect.origin.y = CGRectGetHeight([[UIScreen mainScreen] bounds]);
			sourceSS.frame = sourceRect;
		}];
		[UIView addKeyframeWithRelativeStartTime:0.2 relativeDuration:0.8 animations:^{
			destination.view.layer.transform = CATransform3DIdentity;
		}];
	} completion:^(BOOL finished) {
		// Remove source snapshot
		[sourceSS removeFromSuperview];
		
		// Unhide source view
		source.view.hidden = NO;
		
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
	
	// Take destination view snapshot
	UIView* destinationSS = [destination.view snapshotViewAfterScreenUpdates:NO];
	
	// Hide destination view while animation
	destination.view.hidden = YES;
	
	// Add destination view
	[container addSubview:source.view];
	
	// Add destination snapshot view
	[container addSubview:destinationSS];
	
	// Move destination view below source view
	CGRect destRect = destinationSS.frame;
	destRect.origin.y = CGRectGetHeight([[UIScreen mainScreen] bounds]);
	destinationSS.frame = destRect;
	
	// Start appearance transition for destination controller
	// Because UIKit does not remove views from hierarchy when transition finished
	[destination beginAppearanceTransition:YES animated:YES];
	
	// Animate
	[UIView animateKeyframesWithDuration:0.5 delay:0.0 options:UIViewKeyframeAnimationOptionCalculationModeCubic animations:^{
		[UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:1.0 animations:^{
			CGRect destRect = destinationSS.frame;
			destRect.origin.y = 0;
			destinationSS.frame = destRect;
		}];
		[UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:1.0 animations:^{
			CATransform3D perspectiveTransform = CATransform3DIdentity;
			perspectiveTransform.m34 = 1.0 / -1000.0;
			perspectiveTransform = CATransform3DTranslate(perspectiveTransform, 0, 0, -100);
			source.view.layer.transform = perspectiveTransform;
		}];
	} completion:^(BOOL finished) {
		// Unhide destination view
		destination.view.hidden = NO;
		
		// End appearance transition for destination controller
		[destination endAppearanceTransition];
		
		// Finish transition
		[transitionContext completeTransition:YES];
	}];
}

@end
