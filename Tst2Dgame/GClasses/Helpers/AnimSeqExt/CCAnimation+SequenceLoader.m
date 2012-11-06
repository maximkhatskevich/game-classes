/*
 MIT License
 
 Copyright (c) 2010 Andreas Loew / www.code-and-web.de
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
*/

#import "CCAnimation+SequenceLoader.h"

@implementation CCAnimation (sequenceLoader)

+ (id)framesWithNameFormat:(NSString *)frameNameFormat
                  andDelay:(float)frameDelay
{
    // get sprite frame cache's singleton
    CCSpriteFrameCache *cache = [CCSpriteFrameCache sharedSpriteFrameCache];
    
    // create array for all frames
    NSMutableArray *animFrames = [NSMutableArray array];
    
    // load sequence
    int i = 0;
    CCSpriteFrame *frame = nil;
    while ((i < 2) || //frame #0 and #1 we expect to find in FrameCache anyway
           (frame)) //after first two frames - continue only if there are previous frame
    {
        NSString *name = [NSString stringWithFormat:frameNameFormat,i];
        frame = [cache spriteFrameByName:name];
        
        if(frame)
            [animFrames addObject:frame];
        
        //===
        
        i++;
    }
    
    return [self animationWithSpriteFrames:animFrames delay:frameDelay];
}

@end
