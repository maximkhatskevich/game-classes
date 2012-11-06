//
//  GSprite.m
//  Alien
//
//  Created by Max on 06.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GSprite.h"

@implementation GSprite

// designated initializer
-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect rotated:(BOOL)rotated
{
    self = [super initWithTexture:texture rect:rect rotated:rotated];
    
    //===
    
    self.anchorPoint = ccp(0.0f, 0.0f);
    
    //===
    
    return self;
}

@end
