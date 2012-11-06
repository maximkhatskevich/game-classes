//
//  GPushButton.m
//  Alien
//
//  Created by Max on 14.09.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GPushButton.h"

#import "cocos2d.h"

@implementation GPushButton

#pragma mark Creation

+ (GPushButton *)pushButtonWithNormalFrameName:(NSString *)normalSpriteFrameName
                           andTouchedFrameName:(NSString *)touchedSpriteFrameName
{
    GPushButton *result = nil;
    
    //===
    
    CCSpriteFrame *normalSpriteFrame =
    [[CCSpriteFrameCache sharedSpriteFrameCache]
     spriteFrameByName:normalSpriteFrameName];
    
    CCSpriteFrame *touchedSpriteFrame =
    [[CCSpriteFrameCache sharedSpriteFrameCache]
     spriteFrameByName:touchedSpriteFrameName];
    
    if((normalSpriteFrame != nil) &&
       (touchedSpriteFrame != nil))
    {
        result = [[self class] spriteWithSpriteFrame:normalSpriteFrame];
        result.normalSpriteFrame = normalSpriteFrame;
        result.touchedSpriteFrame = touchedSpriteFrame;
    }
    
    //===
    
    return result;
}

#pragma mark Initialization

- (id)initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect rotated:(BOOL)rotated
{
	self = [super initWithTexture:texture rect:rect rotated:rotated];
    
	if(self)
	{
		_normalSpriteFrame = nil;
        _touchedSpriteFrame = nil;
    }
    return self;
}

#pragma mark CleanUp

- (void)dealloc
{
    self.normalSpriteFrame = nil;
    self.touchedSpriteFrame = nil;
    
    //===
    
    [super dealloc];
}

#pragma mark Touch Delegate

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    BOOL result = NO;
    
    //===
    
    result = [super ccTouchBegan:touch withEvent:event];
    
    if(result)
    {
        [self setDisplayFrame:self.touchedSpriteFrame];
    }
    
    //===
    
    return result;
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    [super ccTouchEnded:touch withEvent:event];
    
    //===
    
	[self setDisplayFrame:self.normalSpriteFrame];
}

@end
