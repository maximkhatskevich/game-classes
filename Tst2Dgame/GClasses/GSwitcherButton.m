//
//  SwitcherSprite.m
//  Alien
//
//  Created by Max on 13.09.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GSwitcherButton.h"

#import "cocos2d.h"

@interface GSwitcherButton ()
{
    BOOL _isEnabled;
}

@end

@implementation GSwitcherButton

#pragma mark Creation

+ (GSwitcherButton *)switcherWithEnabledFrameName:(NSString *)enabledSpriteFrameName
                             andDisabledFrameName:(NSString *)disabledSpriteFrameName
{
    GSwitcherButton *result = nil;
    
    //===
    
    CCSpriteFrame *enabledSpriteFrame =
    [[CCSpriteFrameCache sharedSpriteFrameCache]
     spriteFrameByName:enabledSpriteFrameName];
    
    CCSpriteFrame *disabledSpriteFrame =
    [[CCSpriteFrameCache sharedSpriteFrameCache]
     spriteFrameByName:disabledSpriteFrameName];
    
    if((enabledSpriteFrame != nil) &&
       (disabledSpriteFrame != nil))
    {
        result = [[self class] spriteWithSpriteFrame:enabledSpriteFrame];
        result.enabledSpriteFrame = enabledSpriteFrame;
        result.disabledSpriteFrame = disabledSpriteFrame;
    }
    
    //===
    
    return result;
}

#pragma mark Initialization

-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect rotated:(BOOL)rotated
{
	self = [super initWithTexture:texture rect:rect rotated:rotated];
    
	if(self)
	{
		_isEnabled = YES;
        
        _enabledSpriteFrame = nil;
        _disabledSpriteFrame = nil;
    }
    return self;
}

#pragma mark CleanUp

- (void)dealloc
{
    self.enabledSpriteFrame = nil;
    self.disabledSpriteFrame = nil;
    
    //===
    
    [super dealloc];
}

#pragma mark Control

- (BOOL)enabled
{
    return _isEnabled;
}

- (void)setEnabled:(BOOL)newValue
{
    if(_isEnabled != newValue)
    {
        _isEnabled = newValue;
        
        [self setDisplayFrame:(self.enabled ?
                               self.enabledSpriteFrame :
                               self.disabledSpriteFrame)];
    }
}

- (void)switchState
{
    self.enabled = (!self.enabled);
}

#pragma mark Touch Delegate

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    [super ccTouchEnded:touch withEvent:event];
    
    //===
    
	[self switchState];
}

@end
