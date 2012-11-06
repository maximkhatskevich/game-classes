//
//  BaseLevelCtrl.h
//  Alien
//
//  Created by Max on 05.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCScene.h"

#import "GSprite.h"
#import "GLayerWithCamera.h"
#import "GTileMapInfo.h"
#import "GTileMap.h"
#import "CCNode+GNode.h"
#import "GLayer.h"
#import "GSpriteParams.h"
#import "GShapeCache.h"

@class GLayerWithCamera;
@class GDebugDrawLayer;
@class GTileMapInfo;

@interface GLevel : CCScene

//=== base decoration layers

//camera-attached background layer, always sync-ed with camera:
@property(nonatomic, readonly) CCLayer *cameraBackgroundLayer;

//static layer for 1-st plan decorations and GameObject-sprites:
@property(nonatomic, readonly) GLayerWithCamera *gameLayer;

//static layer behind gameLayer for wrawing debug data:
@property(nonatomic, readonly) GDebugDrawLayer *debugDrawLayer;

@property(readonly, getter = contentScale) float contentScale;

//whole level size in columns and rows of screens:
@property(readonly) CGSize sizeInScreens;
@property(readonly) CGSize sizeInPointsEstimate;
@property(readonly) CGRect rectInPointsEstimate;

@property(nonatomic, retain) NSMutableDictionary *layers;
@property(nonatomic, retain) NSMutableArray *tileMaps;

@property float activeBorderWidth;

//===

- (float) contentScale;
- (CGSize) sizeInScreens;
- (CGSize) sizeInPointsEstimate;
- (CGRect)rectInPointsEstimate;

//=== layers

- (GLayer *)addLayerWithId:(int)layerId;
- (void)addLayer:(GLayer *)targetLayer withId:(int)layerId;
- (GLayer *)getLayerWithId:(int)layerId;

//=== tile maps

- (GTileMapInfo *)addTileMapWithName:(NSString *)tileMapName;
- (void)registerTileMap:(GTileMapInfo *)tileMapInfo;

//=== UPDATE

- (void)update:(ccTime)dt;
- (void)moveLayers;
- (CGPoint)adjustCameraPosition;

//=== Memory usage optimization

- (void)optimizeMemoryUsage;

//=== Camera

- (void)cameraMoved:(CGPoint)positionDelta;
- (CGRect)adjustCameraRect;

//=== controls

- (void)bindWithControls;
- (void)applyControls;

//===

- (void)levelFinished;

@end
