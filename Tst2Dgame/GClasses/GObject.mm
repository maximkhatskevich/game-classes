//
//  GObject.m
//  Alien
//
//  Created by Максим & Марго on 15.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GObject.h"

#import "CCNode+GNode.h"

@interface GObject ()
{
    CCAction *_currentStateAction;
}

@end

@implementation GObject

#pragma mark Creation

+ (id)dynamicObjectWithShape:(NSString *)shapeName
              andSpriteFrame:(NSString *)spriteFrameName
{
    return [self objectWithBodyType:b2_dynamicBody
                              shape:shapeName
                     andSpriteFrame:spriteFrameName];
}

+ (id)dynamicObjectWithShape:(NSString *)shapeName
{
    return [self objectWithBodyType:b2_dynamicBody
                              shape:shapeName
                        spriteFrame:nil
                            andRect:CGRectZero];
}

+ (id)staticObjectWithShape:(NSString *)shapeName
             andSpriteFrame:(NSString *)spriteFrameName
{
    return [self objectWithBodyType:b2_staticBody
                              shape:shapeName
                     andSpriteFrame:spriteFrameName];
}

+ (id)staticObjectWithShape:(NSString *)shapeName
                    andRect:(CGRect)targetRect
{
    return [self objectWithBodyType:b2_staticBody
                              shape:shapeName
                        spriteFrame:nil
                            andRect:targetRect];
}

+ (id)staticObjectWithShape:(NSString *)shapeName
{
    return [self objectWithBodyType:b2_staticBody
                              shape:shapeName
                        spriteFrame:nil
                            andRect:CGRectZero];
}

+ (id)kinematicObjectWithShape:(NSString *)shapeName
                andSpriteFrame:(NSString *)spriteFrameName
{
    return [self objectWithBodyType:b2_kinematicBody
                              shape:shapeName
                     andSpriteFrame:spriteFrameName];
}

+ (id)objectWithBodyType:(b2BodyType)bodyType
                   shape:(NSString *)shapeName
          andSpriteFrame:(NSString *)spriteFrameName
{
    return [self objectWithBodyType:bodyType
                              shape:shapeName
                        spriteFrame:spriteFrameName
                            andRect:CGRectZero];
}

+ (id)objectWithBodyType:(b2BodyType)bodyType
                   shape:(NSString *)shapeName
             spriteFrame:(NSString *)spriteFrameName
                 andRect:(CGRect)targetRect
{
    return [[[[self class] alloc] initWithBodyType:bodyType
                                             shape:shapeName
                                       spriteFrame:spriteFrameName
                                           andRect:targetRect] autorelease];
}

#pragma mark Initialization

+ (void)loadSharedResources
{
    //in subclass you can
    //load here frames and shapes for instances of this class...
    
    //load here .plist with frames for sprite
    //[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"frames.plist"];
    
    //load here .plist with shapes for self
    //[[GShapeCache sharedShapeCache] addShapesWithFile:@"shapes.plist"];
}

+ (void)releaseSharedResources
{
    //
}

- (void)bindStateAction:(id)targetAction withState:(int)targetState
{
    id key = [NSNumber numberWithInt:targetState];
    
    [self.stateActions removeObjectForKey:key]; //clear before set new value
    [self.stateActions setObject:targetAction forKey:key];
}

//prepare all animations for object here:
- (void)bindStateActions
{
    //bind state actions (with animations and etc.) here in subclass...
}

-(void) setBodyShape:(NSString*)shapeName
{
    b2Fixture *f;
    while((f = _body->GetFixtureList()))
    {
        _body->DestroyFixture(f);
    }
    
    if(shapeName)
    {
        GShapeCache *shapeCache = [GShapeCache sharedShapeCache];
        [shapeCache addFixturesToBody:_body forShapeName:shapeName];
        
        //NOTE: anchorPoint (0;0) by default in PhysicsEditor
        self.anchorPoint = [shapeCache anchorPointForShape:shapeName];
    }
}

- (id)initWithBodyType:(b2BodyType)bodyType
                 shape:(NSString *)shapeName
           spriteFrame:(NSString *)spriteFrameName
               andRect:(CGRect)targetRect
{
    CCSpriteFrameCache *frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
    
    //=== check spriteFrameName param:
    
    CCSpriteFrame *frame = nil;
    
    if(spriteFrameName)
    {
        frame = [frameCache spriteFrameByName:spriteFrameName];
        
        if(spriteFrameName && (!frame))
        {
            NSLog(@"WARNING! SpriteFrame with spriteFrameName '%@' was not found!",
                  spriteFrameName);
        }
    }
    
    //=== init sprite:
    
    if(frame)
    {
        self = [super initWithTexture:frame.texture rect:frame.rect rotated:NO];
        [self setDisplayFrame:frame];
    } else {
        self = [super initWithFile:@"empty.png" rect:targetRect];
    }
    
    //=== init body:
    
    b2World *world_ = [GKernel sharedInstance].world;
    
    b2BodyDef bodyDef;
    bodyDef.type = bodyType;
    bodyDef.position.Set(0, 0);
    bodyDef.angle = 0;
    _body = world_->CreateBody(&bodyDef);
    
    // set user data and retain self
    _body->SetUserData([self retain]);
    
    //=== load shapes:
        
    // set shape
    if(shapeName)
    {
        [self setBodyShape:shapeName];            
    }
    
    //=== helper - object own "autorelease" pool for multythread apps:
    
    self.keptObjects = [NSMutableArray array];
    
    //===
    
    _state = [GState createInstance];
    [self keepObject:_state];
    
    _stateActions = [NSMutableDictionary dictionary];
    [self keepObject:_stateActions];
    
    //=== prepare for animation:
    
    [self bindStateActions];

    //=== init params:
    
    _objectTag = 0;
    _deleteLater = NO;
    
    //===
    
    _previousPosition = CGPointZero;
    _lastPositionDelta = CGPointZero;
    
    _currentStateAction = nil;
    
    //===
    
    _syncRotationWithBody = YES;
    
    //===
    
    return self;
}

-(id) init
{
    NSAssert(0, @"GObject must NOT be called with init");
    return nil;
}

#pragma mark CleanUp

- (void)markForDelete
{
    if(!self.deleteLater)
    {
        // remove object from cocos2d parent node
        if(self.parent != nil)
        {
            [self removeSelf];
        }
        
        self.body->SetActive(NO);
        self.body->SetLinearVelocity(b2Vec2_zero);
        self.body->SetAngularVelocity(0);
        self.body->SetGravityScale(0);
        
        [self setFilterWithCategory:0
                            andMask:0];
        
        [self unKeepObject:_stateActions];
        _stateActions = nil;
        
        //===
        
        _deleteLater = YES;
    }
}

- (void)deleteNow
{
    self.keptObjects = nil;
    
    // delete the body
    [self destroyBody];
}

- (void)destroyBody
{
    if([self retainCount] > 1)
    {
        NSLog(@"Before final RELEASE, class = %@, retain count = %d",
              [self class],
              [self retainCount]);
    }
    
    //===
    
    if(([self retainCount] == 1) && //wait while all contacts will be destroyed
       _body)
    {
        // destroy the body and release the instance count
        // which was part of the body userdata
        _body->GetWorld()->DestroyBody(_body);
        _body = 0;
        
        //===
        
        //see initWithBody...
        //_body->SetUserData([self retain]);
        // release self -
        [self release];
    }
}

- (void)dealloc
{
    
    
    //===
    
    [super dealloc];
}

#pragma mark UPDATE

- (void)processExternalSignals
{
    //обработка сигналов от сенсоров etc.
}

//обработка запроса состояния:
- (void)processStateRequest
{
    //обработка запросов на переключение текущего состояния
    
    if(self.state.isChangeRequested)
    {
        [self.state applyChange];
    }
}

- (BOOL)mustChangeCurrentStateAction
{
    return self.state.isJustChanged;
}

- (CCAction *)actionForState:(int)targetState
{
    CCAction *result = nil;
    
    //===
    
    result = (CCAction *)[self.stateActions objectForKey:
                          [NSNumber numberWithInt:targetState]];
    
    //===
    
    return result;
}

- (void)processStateChange
{
    if(self.state.isJustChanged)
    {
        if([self mustChangeCurrentStateAction])
        {
            CCAction *newStateAction =
            [self actionForState:self.state.currentValue];
            
            if(_currentStateAction)
            {
                [self stopAction:_currentStateAction];
            }
            
            if(newStateAction)
            {            
                _currentStateAction = newStateAction;
                
                [self runAction:newStateAction];
            }
        }
        
        [self stateChanged];
    }
}

- (void)stateChanged
{
    //
}

- (void)processState
{
    //
}

-(void)update: (ccTime)dt
{   
//    [[GKernel sharedInstance] showTime:
//     [NSString stringWithFormat:@"%@ start UPDATE"]];
    
    _previousPosition = self.position;
    
    //===
    
    b2Vec2 position = _body->GetPosition();
    self.position = CGPointMake(PTM_RATIO * position.x, PTM_RATIO * position.y);
    
    if(self.syncRotationWithBody)
    {
        self.rotation = -1 * CC_RADIANS_TO_DEGREES(_body->GetAngle());
    }
    
    _lastPositionDelta = ccpSub(self.position, _previousPosition);
    
    //===
    
//    [[GKernel sharedInstance] showTime:
//     [NSString stringWithFormat:@"BEFORE processExternalSignals"]];
        
    //обработка показаний от сенсоров:
    [self processExternalSignals];
    
//    [[GKernel sharedInstance] showTime:
//     [NSString stringWithFormat:@"AFTER processExternalSignals"]];
    
    //===
    
//    [[GKernel sharedInstance] showTime:
//     [NSString stringWithFormat:@"BEFORE processStateRequest"]];
    
    //обработаем запрос на изменение состояния:
    [self processStateRequest];
    
//    [[GKernel sharedInstance] showTime:
//     [NSString stringWithFormat:@"AFTER processStateRequest"]];
    
    //===
    
//    [[GKernel sharedInstance] showTime:
//     [NSString stringWithFormat:@"BEFORE processStateChange"]];
    
    //обработаем изменение состояния:
    [self processStateChange];
    
//    [[GKernel sharedInstance] showTime:
//     [NSString stringWithFormat:@"AFTER processStateChange"]];
    
    //===
    
//    [[GKernel sharedInstance] showTime:
//     [NSString stringWithFormat:@"BEFORE processState"]];
    
    //обработаем текущее состояние:
    [self processState];
    
//    [[GKernel sharedInstance] showTime:
//     [NSString stringWithFormat:@"AFTER processState"]];
    
}

#pragma mark Contact processing

- (void)presolveContact:(GContact *)contact
{
    //
}

- (void)beginContact:(GContact *)contact
{
    //
}

- (void)endContact:(GContact *)contact
{
    //
}

#pragma mark Helpers

//retain any object and release on dealloc:
- (void)keepObject:(id)targetObject
{
    [self.keptObjects addObject:targetObject];
}

- (void)unKeepObject:(id)targetObject
{
    [self.keptObjects removeObject:targetObject];
}

-(void) setPhysicsPosition:(b2Vec2)pos
{
    self.position = [GKernel cocosPointFromBoxPoint:pos];
    _body->SetTransform(pos, _body->GetAngle());
}

-(void) setCcPosition:(CGPoint)pos
{
    [super setPosition:pos];
    _body->SetTransform([GKernel boxPointFromCocosPoint:pos],
                        _body->GetAngle());
}

-(void) setBodyAngle: (float)angle
{
    _body->SetTransform(_body->GetWorldCenter(), angle);
}

-(void) addEdgeFrom:(b2Vec2)start to:(b2Vec2)end
{
    b2EdgeShape edgeShape;
    edgeShape.Set(start, end);
    _body->CreateFixture(&edgeShape,0);
}

-(void) clrCollisionMaskBits:(uint16)bits forId:(NSString*)fixtureId
{
    b2Fixture *f = _body->GetFixtureList();
    while(f)
    {
        if(!fixtureId  || ([fixtureId isEqualToString:(NSString*)f->GetUserData()]))
        {
            b2Filter filter = f->GetFilterData();
            filter.maskBits &= ~bits;        
            f->SetFilterData(filter);
        }
        f = f->GetNext();            
    }  
}

-(void) addCollisionMaskBits:(uint16)bits forId:(NSString*)fixtureId
{
    b2Fixture *f = _body->GetFixtureList();
    while(f)
    {
        if(!fixtureId || ([fixtureId isEqualToString:(NSString*)f->GetUserData()]))
        {
            b2Filter filter = f->GetFilterData();
            filter.maskBits |= bits;        
            f->SetFilterData(filter);
        }
        f = f->GetNext();            
    } 
}

-(void) setCollisionMaskBits:(uint16)bits forId:(NSString*)fixtureId
{
    b2Fixture *f = _body->GetFixtureList();
    while(f)
    {
        if(!fixtureId || ([fixtureId isEqualToString:(NSString*)f->GetUserData()]))
        {
            b2Filter filter = f->GetFilterData();
            filter.maskBits = bits;        
            f->SetFilterData(filter);
        }
        f = f->GetNext();            
    } 
}

-(void) setCollisionMaskBits:(uint16)bits
{
    [self setCollisionMaskBits:bits forId:nil];
}

-(void) clrCollisionMaskBits:(uint16)bits
{
    [self clrCollisionMaskBits:bits forId:nil];
}

-(void) addCollisionMaskBits:(uint16)bits
{
    [self addCollisionMaskBits:bits forId:nil];
}

-(void) addCollisionCategoryBits:(uint16)bits
{
    [self addCollisionCategoryBits:bits forId:nil];
}

-(void) clrCollisionCategoryBits:(uint16)bits
{
    [self clrCollisionCategoryBits:bits forId:nil];
}

-(void) setCollisionCategoryBits:(uint16)bits
{
    [self setCollisionCategoryBits:bits forId:nil];
}

-(void) addCollisionCategoryBits:(uint16)bits forId:(NSString*)fixtureId
{
    b2Fixture *f = _body->GetFixtureList();
    while(f)
    {
        if(!fixtureId || ([fixtureId isEqualToString:(NSString*)f->GetUserData()]))
        {
            b2Filter filter = f->GetFilterData();
            filter.categoryBits |= bits;        
            f->SetFilterData(filter);
        }
        f = f->GetNext();
    }        
}

-(void) clrCollisionCategoryBits:(uint16)bits forId:(NSString*)fixtureId
{
    b2Fixture *f = _body->GetFixtureList();
    while(f)
    {
        if(!fixtureId || ([fixtureId isEqualToString:(NSString*)f->GetUserData()]))
        {
            b2Filter filter = f->GetFilterData();
            filter.categoryBits &= ~bits;        
            f->SetFilterData(filter);
        }
        f = f->GetNext();
    }        
}

-(void) setCollisionCategoryBits:(uint16)bits forId:(NSString*)fixtureId
{
    b2Fixture *f = _body->GetFixtureList();
    while(f)
    {
        if(!fixtureId || ([fixtureId isEqualToString:(NSString*)f->GetUserData()]))
        {
            b2Filter filter = f->GetFilterData();
            filter.categoryBits = bits;        
            f->SetFilterData(filter);
        }
        f = f->GetNext();
    }        
}

- (void)setSensorForAllFixtures:(BOOL)isSensor
{
    if(self.body)
    {
        b2Fixture *fix = self.body->GetFixtureList();
        while(fix)
        {
            fix->SetSensor(isSensor);
            
            fix = fix->GetNext();
        }
    }
}

- (b2Fixture *)fixtureWithId:(NSString *)fixtureId
{
    b2Fixture *result = nil;
    
    //===
    
    if(self.body)
    {
        b2Fixture *fix = self.body->GetFixtureList();
        NSString *tmpStr = nil;
        
        while(fix)
        {
            tmpStr = (NSString *)fix->GetUserData();
            
            if([tmpStr isEqualToString:fixtureId]) {
                result = fix;
                break;
            }
            
            fix = fix->GetNext();
        }
    }
    
    //===
    
    return result;
}

- (void)setFilterWithCategory:(uint16)targetCategoryBits
                      andMask:(uint16)targetMaskBits
{
    if(self.body)
    {
        b2Fixture *fix = self.body->GetFixtureList();
        while(fix)
        {
            b2Filter filter = fix->GetFilterData();
            filter.categoryBits = targetCategoryBits;
            filter.maskBits = targetMaskBits;
            
            fix->SetFilterData(filter);
            
            fix = fix->GetNext();
        }
    }
}

- (void)forFixtureWithId:(NSString *)fixtureId
             setCategory:(uint16)targetCategoryBits
                 andMask:(uint16)targetMaskBits
{
    b2Fixture *fix = [self fixtureWithId:fixtureId];
    
    if(fix)
    {
        b2Filter filter = fix->GetFilterData();
        filter.categoryBits = targetCategoryBits;
        filter.maskBits = targetMaskBits;
        
        fix->SetFilterData(filter);
    }
}

- (NSString*) description
{
    b2Vec2 pos = self.body->GetPosition();
    b2Vec2 vel = self.body->GetLinearVelocity();
	return [NSString stringWithFormat:@"<%@ = %08X | pos:(%f,%f) active=%d awake=%d vel=(%f,%f)>", 
            [self class], 
            (unsigned int)self,
            pos.x, pos.y, 
            self.body->IsActive(), 
            self.body->IsAwake(),
            vel.x, vel.y
            ];
}
@end
