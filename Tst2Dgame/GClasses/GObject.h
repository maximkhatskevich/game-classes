//
//  GObject.h
//  Alien
//
//  Created by Максим & Марго on 15.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSprite.h"

#import "cocos2d.h"
#import "Box2D.h"
#import "GContact.h"
#import "GShapeCache.h"
#import "GState.h"
#import "GSensor.h"
#import "GTimer.h"
#import "GKernel.h"

@interface GObject : GSprite

@property(assign) BOOL syncRotationWithBody;

@property(assign) int objectTag; //!< tag might be used to query an object
@property(nonatomic, readwrite, retain) NSMutableArray *keptObjects;
@property(nonatomic, readonly) b2Body *body;

//!< flag to delete the object on update phase:
@property(assign) bool deleteLater;

@property(nonatomic, readonly) GState *state;
@property(nonatomic, readonly) NSMutableDictionary *stateActions;

@property(readonly) CGPoint previousPosition;
@property(readonly) CGPoint lastPositionDelta;

//=== Creation

+ (id)dynamicObjectWithShape:(NSString *)shapeName
              andSpriteFrame:(NSString *)spriteFrameName;
+ (id)dynamicObjectWithShape:(NSString *)shapeName;

+ (id)staticObjectWithShape:(NSString *)shapeName
             andSpriteFrame:(NSString *)spriteFrameName;
+ (id)staticObjectWithShape:(NSString *)shapeName
                    andRect:(CGRect)targetRect;
+ (id)staticObjectWithShape:(NSString *)shapeName;

+ (id)kinematicObjectWithShape:(NSString *)shapeName
                andSpriteFrame:(NSString *)spriteFrameName;

+ (id)objectWithBodyType:(b2BodyType)bodyType
                          shape:(NSString *)shapeName
          andSpriteFrame:(NSString *)spriteFrameName;
+ (id)objectWithBodyType:(b2BodyType)bodyType
                   shape:(NSString *)shapeName
             spriteFrame:(NSString *)spriteFrameName
                 andRect:(CGRect)targetRect;

//=== Initialization

+ (void)loadSharedResources;
+ (void)releaseSharedResources;

- (void)bindStateAction:(id)targetAction withState:(int)targetState;
- (void)bindStateActions;
-(void) setBodyShape:(NSString*)shapeName;

- (id)initWithBodyType:(b2BodyType)bodyType
                 shape:(NSString *)shapeName
           spriteFrame:(NSString *)spriteFrameName
               andRect:(CGRect)targetRect; //init here!

//=== CleanUp

- (void)markForDelete;
- (void)deleteNow;
- (void)destroyBody;

//=== UPDATE

- (void)processExternalSignals;
- (void)processStateRequest;
- (BOOL)mustChangeCurrentStateAction;
- (CCAction *)actionForState:(int)targetState;
- (void)processStateChange;
- (void)processState;
- (void)stateChanged;
- (void)update: (ccTime)dt;

//=== Contact:

- (void)presolveContact:(GContact *)contact;
- (void)beginContact:(GContact *)contact;
- (void)endContact:(GContact *)contact;

//=== Helpers

- (void)keepObject:(id)targetObject;
- (void)unKeepObject:(id)targetObject;

-(void) setPhysicsPosition:(b2Vec2)pos;
-(void) setCcPosition:(CGPoint)pos;

-(void) setBodyAngle: (float)angle;

-(void) addEdgeFrom:(b2Vec2)start to:(b2Vec2)end;

/**
 * Clears mask bits on the object's fixtures
 * Bits to clear must be set to 1
 * @param bits bits to clear
 */
-(void) clrCollisionMaskBits:(uint16)bits;

/**
 * Clears mask bits on the object's fixtures
 * Bits to clear must be set to 1
 * @param bits bits to clear
 * @param forId only change the bits for the given fixtureID
 */
-(void) clrCollisionMaskBits:(uint16)bits forId:(NSString*)fixtureId;

/**
 * Adds mask bits on the object's fixtures
 * Bits to set must be set to 1
 * @param bits bits to set
 */
-(void) addCollisionMaskBits:(uint16)bits;

/**
 * Adds mask bits on the object's fixtures
 * Bits to set must be set to 1
 * @param bits bits to set
 * @param forId only change the bits for the given fixtureID
 */
-(void) addCollisionMaskBits:(uint16)bits forId:(NSString*)fixtureId;

/**
 * Sets the mask bits to the given value
 * @param bits bits
 */
-(void) setCollisionMaskBits:(uint16)bits;

/**
 * Sets the mask bits to the given value
 * @param bits bits
 * @param forId only change the bits for the given fixtureID
 */
-(void) setCollisionMaskBits:(uint16)bits forId:(NSString*)fixtureId;

/**
 * Add bits to the collision category
 * @param bits bits to set
 */
-(void) addCollisionCategoryBits:(uint16)bits;

/**
 * Add bits to the collision category
 * @param bits bits to set
 * @param forId only change the bits for the given fixtureID
 */
-(void) addCollisionCategoryBits:(uint16)bits forId:(NSString*)fixtureId;

/**
 * Clr bits on the collition category
 * Bits to clear must be set to 1
 * @param bits to clr
 */
-(void) clrCollisionCategoryBits:(uint16)bits;

/**
 * Clr bits on the collition category
 * Bits to clear must be set to 1
 * @param bits to clr
 * @param forId only change the bits for the given fixtureID
 */
-(void) clrCollisionCategoryBits:(uint16)bits forId:(NSString*)fixtureId;

/**
 * Sets the category bits to the given value
 * @param bits bits to set
 */
-(void) setCollisionCategoryBits:(uint16)bits;

/**
 * Sets the category bits to the given value
 * @param bits bits to set
 * @param forId only change the bits for the given fixtureID
 */
-(void) setCollisionCategoryBits:(uint16)bits forId:(NSString*)fixtureId;

- (void)setSensorForAllFixtures:(BOOL)isSensor;
- (b2Fixture *)fixtureWithId:(NSString *)fixtureId;
- (void)setFilterWithCategory:(uint16)targetCategoryBits
                      andMask:(uint16)targetMaskBits;
- (void)forFixtureWithId:(NSString *)fixtureId
             setCategory:(uint16)targetCategoryBits
                 andMask:(uint16)targetMaskBits;
@end
