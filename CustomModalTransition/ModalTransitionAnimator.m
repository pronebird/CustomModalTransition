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
	
	// Take destination view snapshot
	UIView* destinationSS = [destination.view snapshotViewAfterScreenUpdates:YES]; // YES because the view hasn't been rendered yet.
	
	// Add snapshot view
	[container addSubview:destinationSS];
	
	// Move destination snapshot back in Z plane
	CATransform3D perspectiveTransform = CATransform3DIdentity;
	perspectiveTransform.m34 = 1.0 / -1000.0;
	perspectiveTransform = CATransform3DTranslate(perspectiveTransform, 0, 0, -100);
	destinationSS.layer.transform = perspectiveTransform;
	
	// Begin transition to forward appearance events
	// Because UIKit does not remove views from hierarchy when transition finished
	[source beginAppearanceTransition:NO animated:YES];
	
	[UIView animateKeyframesWithDuration:0.5 delay:0.0 options:UIViewKeyframeAnimationOptionCalculationModeCubic animations:^{
		[UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:1.0 animations:^{
			CGRect sourceRect = source.view.frame;
			sourceRect.origin.y = CGRectGetHeight([[UIScreen mainScreen] bounds]);
			source.view.frame = sourceRect;
		}];
		[UIView addKeyframeWithRelativeStartTime:0.2 relativeDuration:0.8 animations:^{
			destinationSS.layer.transform = CATransform3DIdentity;
		}];
	} completion:^(BOOL finished) {
		// Remove destination snapshot
		[destinationSS removeFromSuperview];
		
		// Add destination controller to view
		[container addSubview:destination.view];
		
		// Finish transition
		[transitionContext completeTransition:finished];
		
		// End appearance transition
		[source endAppearanceTransition];
	}];
}

- (void)animateDismissal:(id<UIViewControllerContextTransitioning>)transitionContext
{
	UIViewController* source = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
	UIViewController* destination = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
	UIView* container = transitionContext.containerView;
	
	// Take source view snapshot
	UIView* sourceSS = [source.view snapshotViewAfterScreenUpdates:NO];
	
	// Remove source view
	[source.view removeFromSuperview];
	
	// Add snapshot view
	[container addSubview:sourceSS];
	
	// Move destination view below source view
	CGRect destRect = destination.view.frame;
	destRect.origin.y = CGRectGetHeight([[UIScreen mainScreen] bounds]);
	destination.view.frame = destRect;
	
	// Begin transition to forward appearance events
	// Because UIKit does not remove views from hierarchy when transition finished
	[destination beginAppearanceTransition:YES animated:YES];
	
	// Animate
	[UIView animateKeyframesWithDuration:0.5 delay:0.0 options:UIViewKeyframeAnimationOptionCalculationModeCubic animations:^{
		[UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:1.0 animations:^{
			CGRect destRect = destination.view.frame;
			destRect.origin.y = 0;
			destination.view.frame = destRect;
		}];
		[UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:1.0 animations:^{
			CATransform3D perspectiveTransform = CATransform3DIdentity;
			perspectiveTransform.m34 = 1.0 / -1000.0;
			perspectiveTransform = CATransform3DTranslate(perspectiveTransform, 0, 0, -100);
			sourceSS.layer.transform = perspectiveTransform;
		}];
	} completion:^(BOOL finished) {
		// Remove source snapshot
		[sourceSS removeFromSuperview];
		
		// Finish transition
		[transitionContext completeTransition:finished];
		
		// End appearance transition
		[destination endAppearanceTransition];
	}];
}

@end
