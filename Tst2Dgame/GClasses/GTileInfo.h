//
//  GTileInfo.h
//  Alien
//
//  Created by Max on 08.08.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "cocos2d.h"

@class GTileMapInfo;
@class GSprite;

@interface GTileInfo : NSObject

@property(nonatomic, readwrite, copy) NSString *frameName;
@property(readwrite, assign) CGPoint position;
@property(nonatomic, readwrite, assign) GTileMapInfo *parent; //weak!

@property(nonatomic, readonly) GSprite *sprite;
@property(readonly) BOOL isLoaded;

@property(readonly) CGRect boundingBox;
@property(readonly) CGRect boundingBoxFact;

+ (id)tileWithFrameName:(NSString *)targetFrameName
                 parent:(GTileMapInfo *)targetParent
            andPosition:(CGPoint)targetPosition;

- (void)load;
- (void)unloaded;

@end
