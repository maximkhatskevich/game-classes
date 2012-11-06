//
//  SneakyJoystickSkinnedBase.h
//  SneakyJoystick
//
//  Created by CJ Hanson on 2/18/10.
//  Copyright 2010 Hanson Interactive. All rights reserved.
//

#import "cocos2d.h"

@class SneakyJoystick;

@interface SneakyJoystickSkinnedBase : CCSprite

@property (nonatomic, readonly) CCSprite *backgroundSprite;
@property (nonatomic, readonly) CCSprite *thumbSprite;
@property (nonatomic, readonly) SneakyJoystick *joystick;

- (void)setBackgroundSprite:(CCSprite *)aSprite;
- (void)setThumbSprite:(CCSprite *)aSprite;
- (void)setJoystick:(SneakyJoystick *)aJoystick;

- (void) updatePositions;

@end
