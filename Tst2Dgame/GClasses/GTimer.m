//
//  GTimer.m
//  Alien
//
//  Created by Max on 07.08.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GTimer.h"

@interface GTimer ()
{
    BOOL _isProcessed;
}

@end

@implementation GTimer

+ (id)timerWithInterval:(ccTime)targetInterval
{
    GTimer *result = nil;
    
    //===
    
    result = [[[self class] new] autorelease];
    result.interval = targetInterval;
    
    //===
    
    return result;
}

- (id)init
{
    self = [super init];
    if (self) {
        _interval = _currentValue = 0;
        _loop = YES;
        _isProcessed = NO;
    }
    return self;
}

- (BOOL)timeIsOver: (ccTime)dt
{
    BOOL result = NO;
    
    //===
    
    if(!_isProcessed)
    {
        if(_currentValue <= _interval) {
            [self incWithDelta:dt];
        }
        
        if(_currentValue >= _interval) {
            
            if(self.loop) {
                _currentValue = 0;
            } else {
                _isProcessed = YES;
            }
            
            result = YES;
        }
    }
    
    //===
    
    return result;
}

- (void)incWithDelta:(ccTime)dt
{
    _currentValue += dt;
}

- (void)reset
{
    _currentValue = 0;
    _isProcessed = NO;
}

- (BOOL)isActive
{
    return (self.loop || (_currentValue < _interval));
}

@end
