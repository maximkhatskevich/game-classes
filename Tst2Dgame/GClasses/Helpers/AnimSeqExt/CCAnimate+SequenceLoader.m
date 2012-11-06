//
//  CCAnimation+SequenceLoader.m
//  TurtlePower
//
//  Created by Andreas Löw on 16.12.10.
//  Copyright 2010 code-and-web. All rights reserved.
//

#import "CCAnimate+SequenceLoader.h"

#import "CCAnimation+SequenceLoader.h"

@implementation CCAnimate (sequenceLoader)

+ (id)actionWithFrameSequence:(NSString *)frameNameFormat
                   frameDelay:(float)frameDelay
{
    id result = nil;
    
    //===
    
    CCAnimation *animationFrames =
    [CCAnimation framesWithNameFormat:frameNameFormat
                             andDelay:frameDelay];
    
    result = [self actionWithAnimation:animationFrames];
    
    //===
    
    return result;
}

+ (id)loopActionWithFrameSequence:(NSString *)frameNameFormat
                       frameDelay:(float)frameDelay
{
    return [CCRepeatForever actionWithAction:
            [self actionWithFrameSequence:frameNameFormat
                               frameDelay:frameDelay]];
}

@end

