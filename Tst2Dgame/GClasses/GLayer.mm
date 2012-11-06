//
//  GLayer.m
//  Alien
//
//  Created by Максим & Марго on 22.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GLayer.h"

#import "GKernel.h"
#import "GLevel.h"

@interface GLayer ()
{
    CGSize _offsetCounter;
    CGPoint _offsetFactor;
}

@end

@implementation GLayer

#pragma mark Service

- (void)camXInc
{
    self.cameraOffsetRatio = ccp(self.cameraOffsetRatio.x + 0.05,
                                 self.cameraOffsetRatio.y);
}

- (void)camXDec
{
    self.cameraOffsetRatio = ccp(self.cameraOffsetRatio.x - 0.05,
                                 self.cameraOffsetRatio.y);
}

- (void)camYInc
{
    self.cameraOffsetRatio = ccp(self.cameraOffsetRatio.x,
                                 self.cameraOffsetRatio.y + 0.05);
}

- (void)camYDec
{
    self.cameraOffsetRatio = ccp(self.cameraOffsetRatio.x,
                                 self.cameraOffsetRatio.y - 0.05);
}

- (void)speedXInc
{
    self.offsetSpeed = ccp(self.offsetSpeed.x + 10.0,
                           self.offsetSpeed.y);
}

- (void)speedXDec
{
    self.offsetSpeed = ccp(self.offsetSpeed.x - 10.0,
                           self.offsetSpeed.y);
}

- (void)limXInc
{
    self.offsetLimit = CGSizeMake(self.offsetLimit.width + 1.0,
                                  self.offsetLimit.height);
}

- (void)limXDec
{
    self.offsetLimit = CGSizeMake(self.offsetLimit.width - 1.0,
                                  self.offsetLimit.height);
}

#pragma mark Creation

+ (id)layerWithParent:(CCNode *)targetParent andZOrder:(int)targetZOrder
{
    GLayer *result;
    
    //===
    
    result = [GLayer node];
    
    if (targetParent) {
        
        [targetParent addChild:result z:targetZOrder];
        
    } else {
        
        NSLog(@"WARNING!!! GLayer 'targetParent' is NULL! Layer was not added to any parent and will autoreleased!");
    }
    
    //===
    
    return result;
}

#pragma mark Initialization

- (id)init
{
    self = [super init];
    if (self) {
        
        self.anchorPoint = ccp(0, 0);
        
        //по умолчанию слой НЕ двигается относительно игрового
        //при движении камеры над игровым слоем,
        //для создания эффекта параллакса нужно явно включить 
        _cameraOffsetRatio = ccp(0, 0);
        
        //по умолчанию при обновлении слой НЕ двигается...
        _offsetSpeed = ccp(0, 0);
        _offsetLimit = _offsetCounter = CGSizeZero;
        _offsetFactor = ccp(1, 1);
        
        _debugLabel = nil;
        
        _isContinuousByX = _isContinuousByY = NO;
    }
    return self;
}

#pragma mark Move

- (BOOL)isCameraRelated
{
    return ((_cameraOffsetRatio.x != 0) ||
            (_cameraOffsetRatio.y != 0));
}

- (void)adjustPositionToCamera:(CGPoint)positionDelta
{
    if(self.isCameraRelated)
    {
        CGPoint targetOffset = ccp(positionDelta.x * _cameraOffsetRatio.x,
                                   positionDelta.y * _cameraOffsetRatio.y);
        
        self.position = ccp(self.position.x + targetOffset.x,
                            self.position.y + targetOffset.y);
        
        [self moveChildrenIfNeeded];
    }
}

- (BOOL)mustMove
{
    return (self.mustMoveByX || self.mustMoveByY);
}

- (BOOL)mustMoveByX
{
    return (_offsetSpeed.x != 0);
}

- (BOOL)mustMoveByY
{
    return (_offsetSpeed.y != 0);
}

- (BOOL)isLimitedByX
{
    return (_offsetLimit.width != 0);
}

- (BOOL)isLimitedByY
{
    return (_offsetLimit.height != 0);
}

- (void)move
{
    if(self.mustMove) {
        
        ccTime lastDt = [GKernel sharedInstance].lastDt;
        CGPoint targetOffset = ccp(lastDt * _offsetSpeed.x,
                                   lastDt * _offsetSpeed.y);
        
        //===
        
        if(self.isLimitedByX) {
            
            targetOffset.x = fabsf(targetOffset.x);
            targetOffset.x = clampf(targetOffset.x,
                                        0,
                                        _offsetLimit.width);
            
            if((_offsetCounter.width + targetOffset.x) > _offsetLimit.width)
            {
                _offsetFactor.x *= -1.0;
                targetOffset.x = _offsetLimit.width - _offsetCounter.width;
                _offsetCounter.width = 0;
                
            } else {
                
                _offsetCounter.width += targetOffset.x;
            }
            
            targetOffset.x *= _offsetFactor.x;
        }
        
        //===
        
        if(self.isLimitedByY) {
            
            targetOffset.y = fabsf(targetOffset.y);
            targetOffset.y = clampf(targetOffset.y,
                                        0,
                                        _offsetLimit.height);
            
            if((_offsetCounter.height + targetOffset.y) > _offsetLimit.height)
            {
                _offsetFactor.y *= -1.0;
                targetOffset.y = _offsetLimit.height - _offsetCounter.height;
                _offsetCounter.height = 0;
                
            } else {
                
                _offsetCounter.height += targetOffset.y;
            }
            
            targetOffset.y *= _offsetFactor.y;
        }
        
        //===
        
        self.position = ccp(self.position.x + targetOffset.x,
                            self.position.y + targetOffset.y);
        
        [self moveChildrenIfNeeded];
    }
}

- (BOOL)isContinuous
{
    return (self.isContinuousByX || self.isContinuousByY);
}

- (BOOL)mustMoveChildren
{
    return (self.mustMoveChildrenByX || self.mustMoveChildrenByY);
}

- (BOOL)mustMoveChildrenByX
{
    return ((self.isContinuousByX || self.mustMoveByX) &&
            (!self.isLimitedByX));
}

- (BOOL)mustMoveChildrenByY
{
    return ((self.isContinuousByY || self.mustMoveByY) &&
            (!self.isLimitedByY));
}

- (void)moveChildrenIfNeeded
{
    if((!self.mustMoveChildren) ||
       
       //optimization:
       (!self.visible) ||
       (self.children.count < 2))
    {
        return;
    }
    
    //use absolute position cause self can be child of NON parentLevel.gameLayer!
    //parentLevel.gameLayer.position = parentLevel.gameLayer.absolutePosition
    //cause gamelayer is not moveable - hold position (0;0)!
    //CGPoint selfPos = self.absolutePosition;
    
    //===
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    CGPoint minCoords = [GKernel sharedInstance].cameraPosition; //absolute
    CGPoint maxCoords = ccp(minCoords.x + winSize.width,
                            minCoords.y + winSize.height);
    
    //===
    
    if(self.mustMoveChildrenByX)
    {
        CCNode *left = [self.children objectAtIndex:0]; //most left
        CCNode *right = [self.children lastObject]; //most right
        
        for (CCNode *ch in self.children) {
            if(ch.position.x < left.position.x) {
                left = ch;
            }
            
            if(ch.position.x > right.position.x) {
                right = ch;
            }
        }
        
        //===
        
        float leftWidth;
        float rightWidth;
        
        if([left isKindOfClass:[GTileMap class]])
        {
            leftWidth = ((GTileMap *)left).widthFact;
            
        } else {
            
            leftWidth = left.boundingBox.size.width;
        }
        
        if([right isKindOfClass:[GTileMap class]])
        {
            rightWidth = ((GTileMap *)right).widthFact;
            
        } else {
            
            rightWidth = right.boundingBox.size.width;
        }
        
        //===
        
//        if(xDirRight)
//        {
//            //move right node before left
//            if(right.absolutePosition.x > maxCoords.x) {
//                [right hide];
//                right.position = ccp(left.position.x - rightWidth,
//                                     right.position.y);
//                [right show];
//            }
//            
//        } else { //xDirLeft
//            
//            //move left node after right
//            if((left.absolutePosition.x + leftWidth) < minCoords.x) {
//                [left hide];
//                left.position = ccp(right.position.x + rightWidth,
//                                    left.position.y);
//                [left show];
//            }
//        }
        
        if(right.absolutePosition.x > maxCoords.x) {
        
            //move right node before left
            
            [right hide];
            right.position = ccp(left.position.x - rightWidth,
                                 right.position.y);
            [right show];
            
        } else if((left.absolutePosition.x + leftWidth) < minCoords.x) {
            
            //move left node after right
            
            [left hide];
            left.position = ccp(right.position.x + rightWidth,
                                left.position.y);
            [left show];
        }
            
            
            
    }
    
    //===
    
    if(self.mustMoveChildrenByY)
    {
        CCNode *top = [self.children objectAtIndex:0]; //most top
        CCNode *bottom = [self.children lastObject]; //most bottom
        
        for (CCNode *ch in self.children) {
            if(ch.position.y > top.position.y) {
                top = ch;
            }
            
            if(ch.position.y < bottom.position.y) {
                bottom = ch;
            }
        }
        
        //===
        
        float topHeight;
        float bottomHeight;
        
        if([top isKindOfClass:[GTileMap class]])
        {
            topHeight = ((GTileMap *)top).heightFact;
            
        } else {
            
            topHeight = top.boundingBox.size.height;
        }
        
        if([bottom isKindOfClass:[GTileMap class]])
        {
            bottomHeight = ((GTileMap *)bottom).heightFact;
            
        } else {
            
            bottomHeight = bottom.boundingBox.size.height;
        }
        
        //===
        
//        if(yDirUp)
//        {
//            //move top node under bottom
//            if(top.absolutePosition.y > maxCoords.y) {
//                [top hide];
//                top.position = ccp(top.position.x,
//                                   bottom.position.y - topHeight);
//                [top show];
//            }
//            
//        } else { //xDirDown
//            
//            //move bottom node ontop of top node
//            if((bottom.absolutePosition.y + bottomHeight) < minCoords.y) {
//                [bottom hide];
//                bottom.position = ccp(bottom.position.x,
//                                      top.position.y + topHeight);
//                [bottom show];
//            }
//        }
        
        if(top.absolutePosition.y > maxCoords.y) {
            
            //move top node under bottom
            
            [top hide];
            top.position = ccp(top.position.x,
                               bottom.position.y - topHeight);
            [top show];
            
        } else if((bottom.absolutePosition.y + bottomHeight) < minCoords.y) {
            
            //move bottom node ontop of top node
            
            [bottom hide];
            bottom.position = ccp(bottom.position.x,
                                  top.position.y + topHeight);
            [bottom show];
        }
    }
}

@end
