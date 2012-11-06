//
//  GHUDLayer.m
//  Alien
//
//  Created by Max on 06.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GHUDLayer.h"

@implementation GHUDLayer

- (id)init
{
    self = [super init];
    if (self)
    {
        self.isTouchEnabled = YES;
		self.isAccelerometerEnabled = NO;
    }
    return self;
}

- (void)update
{
    //
}

@end
