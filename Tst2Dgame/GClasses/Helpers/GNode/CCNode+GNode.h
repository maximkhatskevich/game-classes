//
//  CCNode+GNode.h
//  Alien
//
//  Created by Max on 27.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCNode.h"

@interface CCNode (GNode)

@property(readonly) CGPoint absolutePosition;
@property(readonly) CGPoint rightBottomPosition;
@property(readonly) CGPoint leftTopPosition;

//===

- (CGPoint)rightBottomPosition;
- (CGPoint)leftTopPosition;

//===

- (CGPoint)absolutePosition;

//===

- (void)show;
- (void)hide;

- (void)setDisplayFrameNamed:(NSString*)frameName;

- (void)removeSelf;

@end
