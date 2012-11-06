//
//  GTimer.h
//  Alien
//
//  Created by Max on 07.08.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "cocos2d.h"

//manual controlled timer for use in update method...

@interface GTimer : NSObject

@property(readonly) ccTime currentValue;
@property(assign) ccTime interval;

@property(assign) BOOL loop;
@property(readonly) BOOL isActive;

+ (id)timerWithInterval:(ccTime)targetInterval;

- (BOOL)timeIsOver:(ccTime)dt;
- (void)incWithDelta:(ccTime)dt;
- (void)reset;

@end
