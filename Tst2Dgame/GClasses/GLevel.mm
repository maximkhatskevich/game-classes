//
//  BaseLevelCtrl.m
//  Alien
//
//  Created by Max on 05.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GLevel.h"

#import "GDebugDrawLayer.h"
#import "GKernel.h"

@interface GLevel ()

@property(nonatomic, retain) NSMutableArray *tileMapsForLoad;
@property(nonatomic, retain) NSMutableArray *tileMapsForUnload;

@end

@implementation GLevel

- (float) contentScale
{
    return [CCDirector sharedDirector].contentScaleFactor;
}

- (CGSize) sizeInScreens
{
    //override in subclass to define level size:
    return CGSizeMake(1, 1);
}

- (CGSize) sizeInPointsEstimate
{
    CGSize sizeInScreens = self.sizeInScreens;
    
    return CGSizeMake(sizeInScreens.width * winSize.width,
                      sizeInScreens.height * winSize.height);
}

- (CGRect)rectInPointsEstimate
{
    CGSize sizeInPointsEstimate = self.sizeInPointsEstimate;
    
    return CGRectMake(0, 0,
                      sizeInPointsEstimate.width,
                      sizeInPointsEstimate.height);
}

#pragma mark CleanUp

- (void)dealloc
{    
    NSLog(@"Before deleteAllWorldObjects...");
    [[GKernel sharedInstance] showMem];
    
    //одновременно два уровня загружены в память быть НЕ должны,
    //потому при уничтожении данного уровня удаляем ВСЕ объекты
    //из мира, так как ожидаем, что в мире сейчас ТОЛЬКО объекты данного уровня:
    [[GKernel sharedInstance] deleteAllWorldObjects];
    
    //=== слои удалятся при автоматической очистке children_
    
    for (GTileMapInfo *info in self.tileMaps)
    {
        [info unload];
        info.parent = nil;
    }
    self.tileMaps = nil;
    self.tileMapsForLoad = nil;
    self.tileMapsForUnload = nil;
    
    self.layers = nil;
    
    //===
    
    [super dealloc];
}

#pragma mark Initialization

- (id)init
{
    self = [super init];
    
    //===
    
    if (self) {
        
        self.tileMaps = [NSMutableArray array];
        _activeBorderWidth = (winSize.width / 2);
        
        self.tileMapsForLoad = [NSMutableArray array];
        self.tileMapsForUnload = [NSMutableArray array];
        
        self.layers = [NSMutableDictionary dictionary];
        
        //=== init camera background layer:
        
        _cameraBackgroundLayer = [CCLayer node];
        _cameraBackgroundLayer.anchorPoint = ccp(0, 0);
        [self addChild:_cameraBackgroundLayer z:-100];
        
        //=== init game layer:
        
        _gameLayer = [GLayerWithCamera node];
        [self addChild:_gameLayer z:0];
        
        //=== init debugDrawlayer:
        
        _debugDrawLayer = [GDebugDrawLayer node];
        [_gameLayer addChild:_debugDrawLayer z:100];
        
        //=== camera
        
        //выставляем ограничение максимальной позиции камеры по-умолчанию:
        _gameLayer.cameraRect = self.rectInPointsEstimate;
    }
    
    //===
    
    return self;
}

#pragma mark Layer management

- (GLayer *)addLayerWithId:(int)layerId
{
    GLayer *result = [GLayer layerWithParent:self.gameLayer andZOrder:layerId];
    [self addLayer:result withId:layerId];
    
    //===
    
    return result;
}

- (void)addLayer:(GLayer *)targetLayer withId:(int)layerId
{
    [self.layers setObject:targetLayer forKey:[NSNumber numberWithInt:layerId]];
}

- (GLayer *)getLayerWithId:(int)layerId
{
    return [self.layers objectForKey:[NSNumber numberWithInt:layerId]];
}

#pragma mark TileMaps managemant

- (GTileMapInfo *)addTileMapWithName:(NSString *)tileMapName
{
    //default values for parent and rows & cols MUST be defined before this!
    
    GTileMapInfo *result = [GTileMapInfo tileMapWithName:tileMapName];
    
    //===
    
    [self registerTileMap:result];
    
    //===
    
    return result;
}

- (void)registerTileMap:(GTileMapInfo *)tileMapInfo
{
    if(tileMapInfo) {
        
        [self.tileMaps addObject:tileMapInfo];
    }
}

#pragma mark UPDATE

- (void)update: (ccTime)dt
{
    //=== применим сигналы от HUD к элементам уровня:
    
    [self applyControls];
    
    //=== двигаем слои, если нужно:
    
    [self moveLayers];
    
    //=== двигаем камеру, если нужно:
    
    //обновляем обаласть, в которой камера может двигаться в следующий раз:
    self.gameLayer.cameraRect = [self adjustCameraRect];
    
    self.gameLayer.cameraPosition = [self adjustCameraPosition];
    
    //===
    
    GTileMapInfo *info = nil;
    
    if(self.tileMapsForLoad.count)
    {
        info = [self.tileMapsForLoad objectAtIndex:0];
        
        if(info.isAbleToLoad) {
            
            [info load];
            
        } else if(info.isAbleToUnLoad) { // loaded
            
            [self.tileMapsForLoad removeObject:info];
        }
        
    } else if(self.tileMapsForUnload.count) {
        
        info = [self.tileMapsForUnload objectAtIndex:0];
        
        if(info.isAbleToUnLoad) {
            
            [info unload];
            
        } else if(info.isAbleToLoad) { // unloaded
            
            [self.tileMapsForUnload removeObject:info];
//            [[CCTextureCache sharedTextureCache] removeUnusedTextures];
        }
        
    }
}

- (void)moveLayers
{
    //=== даем команду всем слоям двигаться, если нужно:
    
    for (CCNode *child in [self.layers allValues])
    {
        if([child isKindOfClass:[GLayer class]])
        {
            [(GLayer *)child move];
        }
    }
}

- (CGPoint)adjustCameraPosition
{
    //override in subclass to set here new camera position!!!
    return self.gameLayer.cameraRect.origin;
}

#pragma mark Memory usage optimization

- (void)optimizeMemoryUsage
{
    CGPoint camPos = self.gameLayer.cameraPosition;
    
    CGRect activeRect = CGRectMake(camPos.x - self.activeBorderWidth,
                                   camPos.y - self.activeBorderWidth,
                                   winSize.width + self.activeBorderWidth * 2,
                                   winSize.height + self.activeBorderWidth * 2);
    
    for (GTileMapInfo *info in self.tileMaps)
    {
        CGRect selfRect = info.absoluteFactRect;
        
        if(!CGRectIsEmpty(CGRectIntersection(selfRect, activeRect)))
        {
            //LOAD:
            [self.tileMapsForLoad addObject:info];
            
        } else {
            
            //UNload:
            [self.tileMapsForUnload addObject:info];
        }
    }
    
}

#pragma mark Camera

- (void)cameraMoved:(CGPoint)positionDelta
{
    //реализуем смещение слоев при движении камеры:
    
    for (GLayer *child in [self.layers allValues]) {
        
        [child adjustPositionToCamera:positionDelta];
    }
    
    //===
    
    //реализуем оптимизацию использования памяти декорациями:
    [self optimizeMemoryUsage];
}

- (CGRect)adjustCameraRect
{
    //override in subclass to specify dynamic camera rect!
    return self.gameLayer.cameraRect;
}

#pragma mark Controls

- (void)bindWithControls
{
    //[super bindWitControls];
    
    //===
    
    //in subclass bind here particular values with controls on HUD layer
    //if needed
}

- (void)applyControls
{
    //[super applyControls];
    
    //===
    
    //in subclass apply here signals from HUD to level game objects and layers...
}

#pragma mark -

- (void)levelFinished
{
    //
}

#pragma mark SceneManagement

-(void) onEnter
{
	[super onEnter];
    
    //===
    
    [self bindWithControls];
    
    [self optimizeMemoryUsage];
}

@end
