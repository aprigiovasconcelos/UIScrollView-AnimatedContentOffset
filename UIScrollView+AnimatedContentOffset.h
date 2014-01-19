//
//  UIScrollView+AnimatedContentOffset.h
//
//  Created by Aprigio Vasconcelos on 1/18/14.
//  Copyright (c) 2014 Aprigio Vasconcelos. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (AnimatedContentOffset)

- (void)setContentOffset:(CGPoint)contentOffset animatedWithDuration:(NSTimeInterval)duration;
- (void)setContentOffset:(CGPoint)contentOffset animatedWithDuration:(NSTimeInterval)duration animationCurve:(UIViewAnimationCurve)animationCurve;

@end
