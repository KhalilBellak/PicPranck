//
//  PicPranckViewControllerAnimatedTransitioning.m
//  PicPranck
//
//  Created by El Khalil Bellakrid on 26/02/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import "PicPranckViewControllerAnimatedTransitioning.h"

#pragma mark -

@implementation PicPranckViewControllerAnimatedTransitioning

#pragma mark PicPranckViewControllerAnimatedTransitioning

-(id)initWithtabBarController:(UITabBarController *)iTabBarController andIndex:(NSInteger)iIndex {
    self= [super init];
    self.tabBarController = iTabBarController;
    self.index=iIndex;
    return self;
}

#pragma mark UIViewControllerAnimatedTransitioning

-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.4;
}

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {

    NSInteger lastIndex = self.index;
    self.transitionContext = transitionContext;
    
    //From and To VCs
    UIView *containerView = transitionContext.containerView;
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    if(!fromViewController || !toViewController) return;
    
    [containerView addSubview:toViewController.view];
    
    //Direction of animation
    CGFloat viewWidth = toViewController.view.bounds.size.width;
    if (self.tabBarController.selectedIndex < lastIndex)
        viewWidth = -viewWidth;
    
    toViewController.view.transform = CGAffineTransformMakeTranslation(viewWidth, 0);
    
    //Animation
    [UIView animateWithDuration:[self transitionDuration:self.transitionContext]  delay: 0.0  usingSpringWithDamping: 1.2 initialSpringVelocity: 2.5  options:UIViewAnimationOptionTransitionNone animations:^{
        
        toViewController.view.transform = CGAffineTransformIdentity;
        fromViewController.view.transform = CGAffineTransformMakeTranslation(-viewWidth, 0);
        
    } completion:^(BOOL finish){
        
        [self.transitionContext completeTransition:YES];
        fromViewController.view.transform = CGAffineTransformIdentity;
        
    }];
}
@end
