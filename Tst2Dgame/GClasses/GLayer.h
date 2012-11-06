//
//  GLayer.h
//  Alien
//
//  Created by Максим & Марго on 22.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"

@class GLayerWithCamera;

//secondary layer class which moving relative to main game layer camera
//with particular x- and y- camera offset factors, speed & limits:

@interface GLayer : CCLayer

@property(assign) CGPoint cameraOffsetRatio;
@property(assign) CGPoint offsetSpeed; //in pixels per second
@property(assign) CGSize offsetLimit; //in pixels

@property(nonatomic, copy) NSString *debugLabel;

@property(readonly) BOOL isCameraRelated;

@property(readonly) BOOL mustMove;
@property(readonly) BOOL mustMoveByX;
@property(readonly) BOOL mustMoveByY;

@property(readonly) BOOL isLimitedByX;
@property(readonly) BOOL isLimitedByY;

@property(readonly) BOOL isContinuous;

@property(assign) BOOL isContinuousByX;
@property(assign) BOOL isContinuousByY;

@property(readonly) BOOL mustMoveChildren;
@property(readonly) BOOL mustMoveChildrenByX;
@property(readonly) BOOL mustMoveChildrenByY;

//=== service

- (void)camXInc;
- (void)camXDec;

- (void)camYInc;
- (void)camYDec;

- (void)speedXInc;
- (void)speedXDec;

- (void)limXInc;
- (void)limXDec;

//===

+ (id)layerWithParent:(CCNode *)targetParent andZOrder:(int)targetZOrder;

//=== Move

- (void)adjustPositionToCamera:(CGPoint)positionDelta;

- (void)move;
- (void)moveChildrenIfNeeded;

@end
