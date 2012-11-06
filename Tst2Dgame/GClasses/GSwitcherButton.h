//
//  SwitcherSprite.h
//  Alien
//
//  Created by Max on 13.09.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GButton.h"

@class CCSpriteFrame;

@interface GSwitcherButton : GButton

@property BOOL isEnabled;

@property(nonatomic, retain) CCSpriteFrame *enabledSpriteFrame;
@property(nonatomic, retain) CCSpriteFrame *disabledSpriteFrame;

+ (GSwitcherButton *)switcherWithEnabledFrameName:(NSString *)enabledSpriteFrameName
                             andDisabledFrameName:(NSString *)disabledSpriteFrameName;

- (BOOL)enabled;
- (void)setEnabled:(BOOL)newValue;

- (void)switchState;

@end
