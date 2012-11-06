//
//  GSpriteParams.h
//  Alien
//
//  Created by Max on 24.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "cocos2d.h"

@interface GSpriteParams : NSObject

@property(assign) CGPoint position;
@property(assign) float rotation;
@property(assign) float scale;

@property(assign) int tag;

+ (id)paramsWithPosition:(CGPoint)targetPosition
                   scale:(float)targetScale
             andRotation:(float)targetRotation;

+ (id)paramsWithPosition:(CGPoint)targetPosition
               andRotation:(float)targetRotation;


+ (id)paramsWithPosition:(CGPoint)targetPosition
                     tag:(NSInteger)targetTag
             andRotation:(float)targetRotation;

@end
