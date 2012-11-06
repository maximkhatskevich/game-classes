//
//  GSensor.h
//  Alien
//
//  Created by Max on 17.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GSensor : NSObject

@property(readonly) int counter;
@property(readonly) BOOL isActive;
@property(readonly) BOOL isJustBeginContact;
@property(readonly) BOOL isJustEndContact;

+ (id)createInstance;

- (int)beginContact;
- (int)endContact;

- (void)setActive:(BOOL)targetIsActive;

- (void)setActive;
- (void)setInactive;

@end
