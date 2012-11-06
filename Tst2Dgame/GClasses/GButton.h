//
//  GButton.h
//  Alien
//
//  Created by Max on 13.09.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCSprite.h"

#import "CCTouchDelegateProtocol.h"

@interface GButton : CCSprite<CCTargetedTouchDelegate>

@property(readonly) BOOL isTouched;

- (void)setOnTouchTarget:(id)target andSelector:(SEL)targetSelector;
- (void)setOnReleaseTarget:(id)target andSelector:(SEL)targetSelector;

- (void)performOnTouchSelector;
- (void)performOnReleaseSelector;

@end
