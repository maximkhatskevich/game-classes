//
//  CCNode+GNode.m
//  Alien
//
//  Created by Max on 27.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCNode+GNode.h"

#import "cocos2d.h"

@implementation CCNode (GNode)

- (CGPoint)absolutePosition
{
	CGPoint ret = self.position;
	CCNode *cn = self;
    
	while (cn.parent)
    {
		cn = cn.parent;
		ret = ccpAdd(ret, cn.position);
	}
    
	return ret;
}

- (CGPoint)rightBottomPosition
{
    CGPoint result = self.position;
    
    //===
    
    result.x += self.boundingBox.size.width;
    
    //===
    
    return result;
}

- (CGPoint)leftTopPosition
{
    CGPoint result = self.position;
    
    //===
    
    result.y += self.boundingBox.size.height;
    
    //===
    
    return result;
}

- (void)show
{
    self.visible = YES;
}

- (void)hide
{
    self.visible = NO;
}

- (void)setDisplayFrameNamed:(NSString*)frameName
{
    [(CCSprite*)self setDisplayFrame:
     [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName]];
}

- (void)removeSelf
{
    [self removeFromParentAndCleanup:YES];
}

@end
