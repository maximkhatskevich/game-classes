//
//  GSensor.m
//  Alien
//
//  Created by Max on 17.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GSensor.h"

@interface GSensor ()
{
    int _lastProcessedCounterValue;
}

- (void)processed;

@end

@implementation GSensor

- (void)processed
{
    _lastProcessedCounterValue = _counter;
}

+ (id)createInstance
{
    return [[[self class] new] autorelease];
}

- (id)init
{
    self = [super init];
    if (self) {
        _counter = _lastProcessedCounterValue = 0;
    }
    return self;
}

- (BOOL)isActive
{
    return _counter > 0;
}

- (BOOL)isJustBeginContact
{
    BOOL result = ((_lastProcessedCounterValue < 1) && (1 <= _counter));
    
    //===
    
    if(result)
    {
        [self processed];
    }
    
    //===
    
    return result;
}

- (BOOL)isJustEndContact
{
    BOOL result = ((_counter <= 0) && (0 < _lastProcessedCounterValue));
    
    //===
    
    if(result)
    {
        [self processed];
    }
    
    //===
    
    return result;
}

- (int)beginContact
{
    _counter++;
    
    //если только что сенсор был НЕ активен,
    //теперь он только-что стал активен,
    //а состояние в противоположной зоне НЕ было обработано:
    if((_counter == 1) && (1 <= _lastProcessedCounterValue)) {
        _lastProcessedCounterValue = 0;
    }
    
    return _counter;
}

- (int)endContact
{
    _counter--;
    
    //если только что сенсор был активен,
    //теперь он только-что стал НЕ активен,
    //а состояние в противоположной зоне НЕ было обработано:
    if((_lastProcessedCounterValue <= 0) && (0 == _counter)) {
        _lastProcessedCounterValue = 1;
    }
    
    return _counter;
}

- (void)setActive:(BOOL)targetIsActive
{
    _counter = (targetIsActive ? 1 : 0);
    
    //    //если только что сенсор был НЕ активен,
    //    //теперь он только-что стал активен,
    //    //а состояние в противоположной зоне НЕ было обработано:
    //    if((_counter == 1) && (1 <= _lastProcessedCounterValue)) {
    //        _lastProcessedCounterValue = 0;
    //    }
    //
    //    //если только что сенсор был активен,
    //    //теперь он только-что стал НЕ активен,
    //    //а состояние в противоположной зоне НЕ было обработано:
    //    if((_lastProcessedCounterValue <= 0) && (0 == _counter)) {
    //        _lastProcessedCounterValue = 1;
    //    }
}

- (void)setActive
{
    [self setActive:YES];
}

- (void)setInactive
{
    [self setActive:NO];
}

@end
