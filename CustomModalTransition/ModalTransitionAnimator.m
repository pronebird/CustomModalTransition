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
    return 0.6;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController* destination = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    if([destination isBeingPresented]) {
        [self animatePresentation:transitionContext];
    } else {
        [self animateDismissal:transitionContext];
    }
}

- (CGRect)presentingControllerFrameWithContext:(id<UIViewControllerContextTransitioning>)transitionContext {
    CGRect frame = transitionContext.containerView.bounds;

    return CGRectMake(0, CGRectGetHeight(frame), CGRectGetWidth(frame), CGRectGetHeight(frame));
}

- (void)animatePresentation:(id<UIViewControllerContextTransitioning>)transitionContext
{
    NSTimeInterval transitionDuration = [self transitionDuration:transitionContext];
    UIView* sourceView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    UIView* destinationView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView* container = transitionContext.containerView;
    
    // Add destination view to container
    [container insertSubview:destinationView atIndex:0];
    
    // Move destination snapshot back in Z plane
    CATransform3D perspectiveTransform = destinationView.layer.transform;
    perspectiveTransform.m34 = 1.0 / -1000.0;
    perspectiveTransform = CATransform3DTranslate(perspectiveTransform, 0, 0, -100);
    destinationView.layer.transform = perspectiveTransform;
    
    // Animate
    [UIView animateKeyframesWithDuration:transitionDuration delay:0.0
                                 options:UIViewKeyframeAnimationOptionCalculationModeCubic
                              animations:^{
                                  [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:1.0 animations:^{
                                      sourceView.frame = [self presentingControllerFrameWithContext:transitionContext];
                                  }];
                                  [UIView addKeyframeWithRelativeStartTime:0.2 relativeDuration:0.8 animations:^{
                                      destinationView.layer.transform = CATransform3DIdentity;
                                  }];
                              } completion:^(BOOL finished) {
                                  [transitionContext completeTransition:YES];
                              }];
}

- (void)animateDismissal:(id<UIViewControllerContextTransitioning>)transitionContext
{
    NSTimeInterval transitionDuration = [self transitionDuration:transitionContext];
    UIView* sourceView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    UIView* destinationView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView* container = transitionContext.containerView;
    
    // First reset destination view frame
    // This helps to workaround issue navigation bar being 44px instead of 64px
    destinationView.frame = container.bounds;
    
    // Add destination view because it was removed after controller was presented
    // See: shouldRemovePresentersView = YES in presentation controller
    [container addSubview:destinationView];
    
    // Now we can revert destination view frame
    destinationView.frame = [self presentingControllerFrameWithContext:transitionContext];
    
    // Animate
    [UIView animateKeyframesWithDuration:transitionDuration delay:0.0
                                 options:UIViewKeyframeAnimationOptionCalculationModeCubic animations:^{
                                     [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:1.0 animations:^{
                                         destinationView.frame = container.bounds;
                                     }];
                                     [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:1.0 animations:^{
                                         CATransform3D perspectiveTransform = CATransform3DIdentity;
                                         
                                         perspectiveTransform.m34 = 1.0 / -1000.0;
                                         perspectiveTransform = CATransform3DTranslate(perspectiveTransform, 0, 0, -100);
                                         sourceView.layer.transform = perspectiveTransform;
                                     }];
                                 } completion:^(BOOL finished) {
                                     [transitionContext completeTransition:YES];
                                 }];
}

@end
