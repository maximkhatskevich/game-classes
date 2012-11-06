//
//  GSpriteParams.m
//  Alien
//
//  Created by Max on 24.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GSpriteParams.h"

@implementation GSpriteParams

+ (id)paramsWithPosition:(CGPoint)targetPosition
                   scale:(float)targetScale
             andRotation:(float)targetRotation
{
    GSpriteParams *result;
    
    //===
    
    result = [[[self class] new] autorelease];
    
    result.position = targetPosition;
    result.rotation = targetRotation;
    result.scale = targetScale;
    
    //===
    
    return result;
}

+ (id)paramsWithPosition:(CGPoint)targetPosition
               andRotation:(float)targetRotation
{
    return [self paramsWithPosition:targetPosition
                              scale:1
                        andRotation:targetRotation];
}

+ (id)paramsWithPosition:(CGPoint)targetPosition
                     tag:(NSInteger)targetTag
             andRotation:(float)targetRotation
{
    GSpriteParams *result;
    
    //===
    
    result = [[[self class] new] autorelease];
    
    result.position = targetPosition;
    result.tag = targetTag;
    result.rotation = targetRotation;
    
    //===
    
    return result;
}

@end
