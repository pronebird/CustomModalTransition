//
//  ModalPresentationController.m
//  CustomModalTransition
//
//  Created by pronebird on 2/19/15.
//  Copyright (c) 2015 codeispoetry.ru. All rights reserved.
//

#import "ModalPresentationController.h"

@implementation ModalPresentationController

- (BOOL)shouldRemovePresentersView {
    return YES;
}

- (void)containerViewWillLayoutSubviews {
    self.presentedView.frame = [self frameOfPresentedViewInContainerView];
}

@end
