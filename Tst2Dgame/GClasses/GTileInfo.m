//
//  GTileInfo.m
//  Alien
//
//  Created by Max on 08.08.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GTileInfo.h"

#import "GTileMapInfo.h"
#import "GSprite.h"
#import "GTileMap.h"

@implementation GTileInfo

#pragma mark Creation

+ (id)tileWithFrameName:(NSString *)targetFrameName
                 parent:(GTileMapInfo *)targetParent
            andPosition:(CGPoint)targetPosition
{
    GTileInfo *result = nil;
    
    //===
    
    result = [[[self class] new] autorelease];
    
    result.frameName = targetFrameName;
    result.position = targetPosition;
    result.parent = targetParent;
    
    //===
    
    return result;
}

#pragma mark Initialization

- (id)init
{
    self = [super init];
    if (self) {
        
        _frameName = nil;
        _position = CGPointZero;
        _parent = nil;
        
        _sprite = nil;
    }
    return self;
}

#pragma mark Other

- (void)load
{
    if((!self.isLoaded) && self.parent)
    {
        
        CCSpriteFrame *frame =
                [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:_frameName];
        
        if(frame && self.parent.tileMap)
        {
            _sprite = [GSprite spriteWithSpriteFrame:frame];
            _sprite.position = self.position;
            [self.parent.tileMap addChild:_sprite z:-100];
        }
        
    }
}

- (BOOL)isLoaded
{
    return (self.sprite != nil);
}

- (void)unloaded
{
    //спрайт уже уничтожен...
    
    _sprite = nil;
}

- (CGRect)boundingBox
{
    CGRect result = CGRectZero;
    
    //===
    
    if(self.isLoaded) {
        
        result = self.sprite.boundingBox;
        
    } else if(self.parent) {
        
        result = CGRectMake(self.position.x,
                            self.position.y,
                            self.parent.tileSize.width,
                            self.parent.tileSize.height);
    }
    
    //===
    
    return result;
}

- (CGRect)boundingBoxFact
{
    CGRect result = CGRectZero;
    
    //===
    
    if(self.isLoaded) {
        
        result = self.sprite.boundingBox;
        
    } else {
        
        result = CGRectMake(self.position.x,
                            self.position.y,
                            _parent.tileSize.width,
                            _parent.tileSize.height);
    }
    
    //===
    
    return result;
}

@end
