//
//  GButton.m
//  Alien
//
//  Created by Max on 13.09.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GButton.h"

#import "cocos2d.h"

@interface GButton ()
{
    BOOL _onReleaseSelectorScheduled;
}

@property(nonatomic, retain) UITouch *currentTouch;

@property(nonatomic, readonly) id onTouchTarget; //weak!!!
@property(readonly) SEL onTouchSelector;

@property(nonatomic, readonly) id onReleaseTarget; //weak!!!
@property(readonly) SEL onReleaseSelector;

@end

@implementation GButton

#pragma mark Initialization

-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect rotated:(BOOL)rotated
{
    self = [super initWithTexture:texture rect:rect rotated:rotated];
    
	if(self)
	{
        _currentTouch = nil;
        
		_onTouchTarget = nil;
        _onTouchSelector = 0;
        
        _onReleaseTarget = nil;
        _onReleaseSelector = 0;
        
        _onReleaseSelectorScheduled = NO;
    }
    return self;
}

#pragma mark Touch Delegate

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    BOOL result = NO;
    
    //===
    
    CGPoint location =
    [[CCDirector sharedDirector] convertToGL:
     [touch locationInView:[touch view]]];
    
    if((self.parent != nil) &&
       self.visible &&
       CGRectContainsPoint(self.boundingBox, location))
    {
        result = YES;
        self.currentTouch = touch;
        [self performOnTouchSelector];
    }
    
    //===
    
    return result;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	//
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    if([touch isEqual:self.currentTouch])
    {
        self.currentTouch = nil;
    }
    
    //===
    
    if(!_onReleaseSelectorScheduled)
    {
        _onReleaseSelectorScheduled = YES;
        [self performSelector:@selector(performOnReleaseSelector)
                   withObject:nil
                   afterDelay:0.1];
    }
}

- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
	[self ccTouchEnded:touch withEvent:event];
}

- (BOOL)isTouched
{
    return (self.currentTouch != nil);
}

#pragma mark Scene menegemant

- (void)onEnter
{
    [super onEnter];
    
    //===
    
    [[CCDirector sharedDirector].touchDispatcher
     addTargetedDelegate:self
     priority:INT_MIN+1
     swallowsTouches:YES];
}

- (void)onExit
{
    [[CCDirector sharedDirector].touchDispatcher removeDelegate:self];
    
    //===
    
    [super onExit];
}

- (void)setOnTouchTarget:(id)target andSelector:(SEL)targetSelector
{
    if (target && targetSelector)
    {
        _onTouchTarget = target;
        _onTouchSelector = targetSelector;
    }
}

- (void)setOnReleaseTarget:(id)target andSelector:(SEL)targetSelector;
{
    if (target && targetSelector)
    {
        _onReleaseTarget = target;
        _onReleaseSelector = targetSelector;
    }
}

- (void)performOnTouchSelector
{
    if([self.onTouchTarget respondsToSelector:self.onTouchSelector])
    {
        [self.onTouchTarget performSelector:self.onTouchSelector];
    }
}

- (void)performOnReleaseSelector
{
    if([self.onReleaseTarget respondsToSelector:self.onReleaseSelector])
    {
        [self.onReleaseTarget performSelector:self.onReleaseSelector];
    }
    
    _onReleaseSelectorScheduled = NO;
}

@end
