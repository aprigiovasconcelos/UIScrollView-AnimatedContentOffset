//
//  UIScrollView+AnimatedContentOffset.m
//
//  Created by Aprigio Vasconcelos on 1/18/14.
//  Copyright (c) 2014 Aprigio Vasconcelos. All rights reserved.
//

#import "UIScrollView+AnimatedContentOffset.h"
#import <objc/runtime.h>

@implementation UIScrollView (AnimatedContentOffset)

static const NSString *KEY_DURATION = @"Duration";
static const NSString *KEY_TIME_OFFSET = @"TimeOffset";
static const NSString *KEY_LAST_STEP = @"LastStep";
static const NSString *KEY_INITIAL_CONTENT_OFFSET = @"InitialContentOffset";
static const NSString *KEY_TARGET_CONTENT_OFFSET = @"TargetContentOffset";
static const NSString *KEY_ANIMATION_CURVE = @"AnimationCurve";

double linearInterpolation(double t) {
	return t;
}

double quadraticEaseIn(double t) {
	return t * t;
}

double quadraticEaseOut(double t) {
	return -(t * (t - 2));
}

double quadraticEaseInOut(double t) {
	return (t < 0.5) ? (2 * t * t) : (-2 * t * t) + (4 * t) - 1;
}

double interpolate(double from, double to, double time) {
	return (to - from) * time + from;
}

- (void)setContentOffset:(CGPoint)contentOffset animatedWithDuration:(NSTimeInterval)duration
{
	[self setContentOffset:contentOffset animatedWithDuration:duration animationCurve:UIViewAnimationCurveEaseInOut];
}

- (void)setContentOffset:(CGPoint)contentOffset animatedWithDuration:(NSTimeInterval)duration animationCurve:(UIViewAnimationCurve)animationCurve
{
	[self setInititalContentOffset:self.contentOffset];
	[self setTargetContentOffset:contentOffset];
	[self setDuration:duration];
	[self setAnimationCurve:animationCurve];
	[self setLastStep:CACurrentMediaTime()];
	[self setTimeOffset:0.0];

	CADisplayLink *timer = [CADisplayLink displayLinkWithTarget:self selector:@selector(step:)];
	[timer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)step:(CADisplayLink *)timer
{
	CFTimeInterval duration = [self duration];
	CFTimeInterval timeOffset = [self timeOffset];
	CFTimeInterval lastStep = [self lastStep];

	CFTimeInterval thisStep = CACurrentMediaTime();
	CFTimeInterval stepDuration = thisStep - lastStep;
	[self setLastStep:thisStep];

	timeOffset = MIN(timeOffset + stepDuration, duration);

	CFTimeInterval time = timeOffset / duration;

	UIViewAnimationCurve animationCurve = [self animationCurve];

	switch (animationCurve) {
		case UIViewAnimationCurveLinear:
			time = linearInterpolation(time);
			break;

		case UIViewAnimationCurveEaseIn:
			time = quadraticEaseIn(time);
			break;

		case UIViewAnimationCurveEaseOut:
			time = quadraticEaseOut(time);
			break;

		case UIViewAnimationCurveEaseInOut:
			time = quadraticEaseInOut(time);
			break;

		default:
			break;
	}

	CGPoint contentOffset = [self interpolateFromValue:[self initialContentOffset] toValue:[self targetContentOffset] time:time];

	self.contentOffset = contentOffset;

	if (timeOffset >= duration) {
		[timer invalidate];
		objc_removeAssociatedObjects(self);
	}

	[self setTimeOffset:timeOffset];
}

- (CGPoint)interpolateFromValue:(CGPoint)fromValue toValue:(CGPoint)toValue time:(CFTimeInterval)time
{
	return CGPointMake(interpolate(fromValue.x, toValue.x, time), interpolate(fromValue.y, toValue.y, time));
}

- (void)setDuration:(CFTimeInterval)duration
{
	objc_setAssociatedObject(self, &KEY_DURATION, @(duration), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CFTimeInterval)duration
{
	NSNumber *value = objc_getAssociatedObject(self, &KEY_DURATION);
	return [value doubleValue];
}

- (void)setTimeOffset:(CFTimeInterval)timeOffset
{
	objc_setAssociatedObject(self, &KEY_TIME_OFFSET, @(timeOffset), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CFTimeInterval)timeOffset
{
	NSNumber *value = objc_getAssociatedObject(self, &KEY_TIME_OFFSET);
	return [value doubleValue];
}

- (void)setLastStep:(CFTimeInterval)lastStep
{
	objc_setAssociatedObject(self, &KEY_LAST_STEP, @(lastStep), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CFTimeInterval)lastStep
{
	NSNumber *value = objc_getAssociatedObject(self, &KEY_LAST_STEP);
	return [value doubleValue];
}

- (void)setInititalContentOffset:(CGPoint)initialContentOffset
{
	NSValue *value = [NSValue valueWithCGPoint:initialContentOffset];
	objc_setAssociatedObject(self, &KEY_INITIAL_CONTENT_OFFSET, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGPoint)initialContentOffset
{
	NSValue *value = objc_getAssociatedObject(self, &KEY_INITIAL_CONTENT_OFFSET);
	return [value CGPointValue];
}

- (void)setTargetContentOffset:(CGPoint)targetContentOffset
{
	NSValue *value = [NSValue valueWithCGPoint:targetContentOffset];
	objc_setAssociatedObject(self, &KEY_TARGET_CONTENT_OFFSET, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGPoint)targetContentOffset
{
	NSValue *value = objc_getAssociatedObject(self, &KEY_TARGET_CONTENT_OFFSET);
	return [value CGPointValue];
}

- (void)setAnimationCurve:(UIViewAnimationCurve)animationCurve
{
	objc_setAssociatedObject(self, &KEY_ANIMATION_CURVE, @(animationCurve), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIViewAnimationCurve)animationCurve
{
	NSNumber *value = objc_getAssociatedObject(self, &KEY_ANIMATION_CURVE);
	return [value integerValue];
}

@end
