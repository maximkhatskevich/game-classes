//
//  BaseGameKernel.h
//  Alien
//
//  Created by Max on 05.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#import "CCNode+GNode.h"

//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
//Box2D is optimized for objects of 1x1 metre therefore it makes sense
//to define the ratio so that your most common object type is 1x1 metre.
extern float PTM_RATIO;

extern CGSize winSize;

/**
 * Set this to 1 if you use high res sprites to define your 
 * collision shapes
 */
#define GB2_HIGHRES_PHYSICS_SHAPES 1

#define dV(SDValue) deviceRelativeValue(SDValue)

#define dVe(iPadSDValue, iPhoneSDValue) deviceRelativeValueExtended(iPadSDValue, iPhoneSDValue)

#define randInt(min, max) randIntValueBeweenMinAndMax(min, max)
#define randFloat(min, max) randFloatValueBeweenMinAndMax(min, max)

#define zfFloat(floatValue) zeroRelativeFactorFloat(floatValue)
#define zfInt(intValue) zeroRelativeFactorInt(floatValue)

#define clampFloat(value, min, max) clampFloatValueBetweenMinAndMax(value, min, max)
#define clampInt(value, min, max) clampIntValueBetweenMinAndMax(value, min, max)

#define inRangeFloat(value, min, max) isFloatValueInRangeBetweenMinAndMax(value, min, max)
#define inRangeInt(value, min, max) isIntValueInRangeBetweenMinAndMax(value, min, max)

static inline float
isFloatValueInRangeBetweenMinAndMax(float value, float min, float max)
{
    if(min > max)
    {
        CC_SWAP(min, max);
    }
    
    return ((min <= value) && (value <= max));
}

static inline int
isIntValueInRangeBetweenMinAndMax(int value, int min, int max)
{
    if(min > max)
    {
        CC_SWAP(min, max);
    }
    
    return ((min <= value) && (value <= max));
}

static inline float
clampFloatValueBetweenMinAndMax(float value, float min, float max)
{
    if(min > max)
    {
        CC_SWAP(min, max);
    }
    
    if(value < min)
    {
        return min;
    }
    
    if(value > max)
    {
        return max;
    }
    
    return value;
}

static inline int
clampIntValueBetweenMinAndMax(int value, int min, int max)
{
    if(min > max)
    {
        CC_SWAP(min, max);
    }
    
    if(value < min)
    {
        return min;
    }
    
    if(value > max)
    {
        return max;
    }
    
    return value;
}

static inline float
zeroRelativeFactorFloat(float value)
{
    return (value < 0 ? -1 : 1);
}

static inline int
zeroRelativeFactorInt(int value)
{
    return (value < 0 ? -1 : 1);
}

static inline float
randFloatValueBeweenMinAndMax(float min, float max)
{
//    if(min > max)
//    {
//        CC_SWAP(min, max);
//    }
    
    float r = (float)rand() / (float)RAND_MAX;
    return (max-min) * r + min;
}

static inline int
randIntValueBeweenMinAndMax(int min, int max)
{
//    if(min > max)
//    {
//        CC_SWAP(min, max);
//    }
    
    float r = (float)rand() / (float)RAND_MAX;
    return (int)((max-min) * r + min);
}

//devic-relative value
static inline float
deviceRelativeValue(const float SDValue)
{
//    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
//    {
        
        return SDValue * CC_CONTENT_SCALE_FACTOR();
        
//    } else {
//        
//        return iPadSDValue / 2 * CC_CONTENT_SCALE_FACTOR();
//        
//    }
}

//extended:
static inline float
deviceRelativeValueExtended(const float iPadSDValue, const float iPhoneSDValue)
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        
        return iPadSDValue * CC_CONTENT_SCALE_FACTOR();
        
    } else {
        
        return iPhoneSDValue * CC_CONTENT_SCALE_FACTOR();
        
    }
}

//===

class  GLESDebugDraw;
struct b2Vec2; 
class b2World;
@class GHUDLayer;

@class GLevel;
@class GObject;
class GContactListener;

/**
 * Type for block callbacks with GB2Node objects
 * Used in iterateObjectsWithBlock
 */
typedef void(^GObjectCallBack)(GObject *);
//typedef return type(^<#block name#>)(<#arguments#>);

//===

/**
 * GKernelBase
 * 
 * Wrapper for the Box2d simulation
 * Implemented as singleton to allow simple adding of new
 * objects
 */

class b2Body;

@interface GKernel : NSObject<CCDirectorDelegate>

@property(nonatomic, copy) NSString *loadingScreenSpriteName;
@property(assign) Class firstSceneClass;

@property(readonly) ccTime lastDt; //last update: dt parameter value

@property(nonatomic, readonly) GLESDebugDraw *debugDraw;
@property(nonatomic, readonly) GContactListener *contactListener;
@property(assign) b2Vec2 defaultGravity;
@property(nonatomic, readonly) b2World *world;

@property(nonatomic, readonly) GLevel *currentLevel;

@property CGPoint cameraPosition;

@property(assign) BOOL debugMode;
@property(assign) BOOL gameActive;

//=== Creation

+ (GKernel *)sharedInstance;

//=== Helpers

/**
 * Convert b2Vec2 to CGPoint honoring PTM_RATIO
 */
+ (b2Vec2)boxPointFromCocosPoint: (CGPoint)cocosPoint;
+ (b2Vec2)boxPointFromCocosCoordsX: (float)xCoord andY: (float)yCoord;

/**
 * Convert CGPoint to b2Vec2 honoring PTM_RATIO
 */
+ (CGPoint)cocosPointFromBoxPoint: (b2Vec2) boxPoint;

- (void)showMem;

//=== Initialization

- (void)initPTM;

- (void)initDebugDraw; //инициализация объекта с настройками DebugDraw
- (void)initContactListener; //инициализация обработчика контактов

//инициализация всего необходимого для запуска cocos2d сцены:
- (void)initWithWindow: (UIWindow *)targetWindow;

//=== World management

- (b2World *)initWorld;

//Delete all objectsm in world
- (void)deleteAllWorldObjects;

//Delete all objects in the world and the world
- (void)deleteWorld;

//=== DebugDraw control

- (void)enableDebugDraw;
- (void)disableDebugDraw;
- (void)switchDebugDraw;

//=== Scene managemant

- (void)runGame;
- (void)runScene:(Class)targetSceneClass;
- (void)pushScene:(Class)targetSceneClass;
- (void)goBack;

//=== UPDATE

- (void)update: (ccTime)dt;
- (void)afterStep;

@end
