//
//  PicPranckScrollView.m
//  PicPranck
//
//  Created by El Khalil Bellakrid on 01/06/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import "PicPranckScrollView.h"

@implementation PicPranckScrollView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

//- (void)startAnimatingScroll
//{
//    if (arrOfImages.count) {
//        [scrollview scrollRectToVisible:CGRectMake(((pageControl.currentPage +1)%arrOfImages.count)*scrollview.frame.size.width, 0, scrollview.frame.size.width, scrollview.frame.size.height) animated:YES];
//        [pageControl setCurrentPage:((pageControl.currentPage +1)%arrOfImages.count)];
//        [self performSelector:@selector(startAnimatingScrl) withObject:nil  afterDelay:3.0];
//    }
//}
//-(void) cancelScrollAnimation{
//    didEndAnimate =YES;
//    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startAnimatingScrl) object:nil];
//}
//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
//{
//    [self cancelScrollAnimation];
//    previousTouchPoint = scrollView.contentOffset.x;
//}
//
//- (IBAction)pgCntlChanged:(UIPageControl *)sender {
//    [scrollview scrollRectToVisible:CGRectMake(sender.currentPage*scrollview.frame.size.width, 0, scrollview.frame.size.width, scrollview.frame.size.height) animated:YES];
//    [self cancelScrollAnimation];
//}
//
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
//    [pageControl setCurrentPage:scrollview.bounds.origin.x/scrollview.frame.size.width];
//}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    [scrollView setContentOffset: CGPointMake(scrollView.contentOffset.x, 0)];
//    
//    int page = floor((scrollView.contentOffset.x - 320) / 320) + 1;
//    float OldMin = 320*page;
//    int Value = scrollView.contentOffset.x -OldMin;
//    float alpha = (Value% 320) / 320.f;
//    
//    
//    if (previousTouchPoint > scrollView.contentOffset.x)
//    page = page+2;
//    else
//    page = page+1;
//    
//    UIView *nextPage = [scrollView.superview viewWithTag:page+1];
//    UIView *previousPage = [scrollView.superview viewWithTag:page-1];
//    UIView *currentPage = [scrollView.superview viewWithTag:page];
//    
//    if(previousTouchPoint <= scrollView.contentOffset.x){
//        if ([currentPage isKindOfClass:[UIImageView class]])
//        currentPage.alpha = 1-alpha;
//        if ([nextPage isKindOfClass:[UIImageView class]])
//        nextPage.alpha = alpha;
//        if ([previousPage isKindOfClass:[UIImageView class]])
//        previousPage.alpha = 0;
//    }else if(page != 0){
//        if ([currentPage isKindOfClass:[UIImageView class]])
//        currentPage.alpha = alpha;
//        if ([nextPage isKindOfClass:[UIImageView class]])
//        nextPage.alpha = 0;
//        if ([previousPage isKindOfClass:[UIImageView class]])
//        previousPage.alpha = 1-alpha;
//    }
//    if (!didEndAnimate && pageControl.currentPage == 0) {
//        for (UIView * imageView in self.subviews){
//            if (imageView.tag !=1 && [imageView isKindOfClass:[UIImageView class]])
//            imageView.alpha = 0;
//            else if([imageView isKindOfClass:[UIImageView class]])
//            imageView.alpha = 1 ;
//        }
//    }
//    
//}


@end
