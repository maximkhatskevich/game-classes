//
//  GState.m
//  Alien
//
//  Created by Max on 14.08.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GState.h"

@interface GState ()
{
    BOOL _changed;
}

@end

@implementation GState

+ (id)createInstance
{
    return [[[self class] new] autorelease];
}

- (id)init
{
    self = [super init];
    if (self) {
        
        _previousValue = _currentValue = _targetValue = 0;
        _changed = NO;
        _isLocked = NO;
    }
    return self;
}

- (BOOL)changeValue:(int)newValue
{
    BOOL result = NO;
    
    //===
    
    if(!self.isLocked)
    {
        if(_targetValue != newValue)
        {
            _targetValue = newValue;
            
            //===
            
            result = YES;
//            NSLog(@"Target state = %d", _targetValue);
        }
    }
    
    //===
    
    return result;
}

- (void)applyChange
{
    if(self.isChangeRequested)
    {
        _previousValue = _currentValue;
        _currentValue = _targetValue;
        
        //===
        
        _changed = YES;
        
//        NSLog(@"Current state = %d", _currentValue);
    }
}

- (void)cancelChange
{
    _targetValue = _currentValue;
}

- (BOOL)isChangeRequested
{
    return (BOOL)(_currentValue != _targetValue);
}

- (BOOL)isJustChanged
{
    BOOL result = _changed;
    
    //===
    
    _changed = NO;
    
    //===
    
    return result;
}

- (void)lock
{
    _isLocked = YES;
    
//    NSLog(@"State LOCKED");
}

- (void)unlock
{
    _isLocked = NO;
    
//    NSLog(@"State UNlocked");
}

@end
