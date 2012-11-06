//
//  SneakyJoystickSkinnedBase.m
//  SneakyJoystick
//
//  Created by CJ Hanson on 2/18/10.
//  Copyright 2010 Hanson Interactive. All rights reserved.
//

#import "SneakyJoystickSkinnedBase.h"
#import "SneakyJoystick.h"

@implementation SneakyJoystickSkinnedBase

- (void)cleanup
{
    [super cleanup];
    
    [_backgroundSprite removeFromParentAndCleanup:YES];
    [_thumbSprite removeFromParentAndCleanup:YES];
    [_joystick removeFromParentAndCleanup:YES];
}

- (id) init
{
	self = [super init];
	if(self != nil){
		_backgroundSprite = nil;
		_thumbSprite = nil;
		_joystick = nil;
		
		[self schedule:@selector(updatePositions)];
	}
	return self;
}

- (void) updatePositions
{
	if(_joystick &&
       _thumbSprite)
    {
		[_thumbSprite setPosition:_joystick.stickPosition];
    }
}

- (void) setContentSize:(CGSize)s
{
	contentSize_ = s;
	_backgroundSprite.contentSize = s;
	_joystick.joystickRadius = s.width/2;
}

- (void)setBackgroundSprite:(CCSprite *)aSprite
{
	if(_backgroundSprite &&
       _backgroundSprite.parent)
    {
		[_backgroundSprite removeFromParentAndCleanup:YES];
	}
    
    //===
    
	if(aSprite)
    {
        _backgroundSprite = aSprite;
		[self addChild:_backgroundSprite z:0];
		[self setContentSize:_backgroundSprite.contentSize];
	}
}

- (void)setThumbSprite:(CCSprite *)aSprite
{
	if(_thumbSprite &&
       _thumbSprite.parent)
    {
		[_thumbSprite removeFromParentAndCleanup:YES];
	}
    
    //===
    
	if(aSprite)
    {
        _thumbSprite = aSprite;
		[self addChild:_thumbSprite z:1];
		[_joystick setThumbRadius:_thumbSprite.contentSize.width/2];
	}
}

- (void)setJoystick:(SneakyJoystick *)aJoystick
{
	if(_joystick &&
       _joystick.parent)
    {
		[_joystick removeFromParentAndCleanup:YES];
	}
    
    //===
    
	if(aJoystick)
    {
        _joystick = aJoystick;
		[self addChild:_joystick z:2];
        
		if(_thumbSprite)
        {
			[_joystick setThumbRadius:_thumbSprite.contentSize.width/2];
            
		} else {
            
			[_joystick setThumbRadius:0];
        }
		
		if(_backgroundSprite)
        {
			[_joystick setJoystickRadius:_backgroundSprite.contentSize.width/2];
        }
	}
}

@end
