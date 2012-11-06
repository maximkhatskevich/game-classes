//
//  GLayerWithCamera.h
//  Alien
//
//  Created by Max on 11.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"

@interface GLayerWithCamera : CCLayer

@property(readonly) CGPoint previousCameraPosition;
@property CGPoint cameraPosition;

@property(readonly) CGPoint lastCameraPositionDelta;

@property(assign) CGRect cameraRect;

@property(assign) BOOL softCameraMove;
@property(assign) BOOL softCameraYMove;

//=== Camera implementation

- (void)cameraMoved;

@end
