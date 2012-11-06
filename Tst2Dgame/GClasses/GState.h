//
//  GState.h
//  Alien
//
//  Created by Max on 14.08.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GState : NSObject

@property(readonly) int previousValue;
@property(readonly) int currentValue;
@property(readonly) int targetValue;

@property(readonly) BOOL isChangeRequested;

@property(readonly) BOOL isLocked;

@property(readonly) BOOL isJustChanged;

+ (id)createInstance;

- (BOOL)changeValue:(int)newValue;
- (void)applyChange;
- (void)cancelChange;

- (void)lock;
- (void)unlock;

@end
