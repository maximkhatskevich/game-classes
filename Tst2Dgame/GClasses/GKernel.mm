//
//  BaseGameKernel.m
//  Alien
//
//  Created by Max on 05.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GKernel.h"

#import "GLES-Render.h"

#import "GTransitionScene.h"
#import "GContactListener.h"
#import "GDebugDrawLayer.h"
#import "GLevel.h"
#import "GObject.h"

#import "mach/mach.h"

//===

float PTM_RATIO = 32.0f;
CGSize winSize = CGSizeZero;

//===

@interface GKernel ()
{
    vm_size_t _prevMem;
}

@end

@implementation GKernel

#pragma mark Creation

+ (GKernel *)sharedInstance
{
    static GKernel *_sharedKernel = nil;
    
    //===
    
    if(!_sharedKernel) {
        _sharedKernel = [[[self class] alloc] init];
    }
    
    //===
    
    return _sharedKernel;
}

#pragma mark Helpers

+ (b2Vec2)boxPointFromCocosPoint: (CGPoint)cocosPoint
{
    return b2Vec2(cocosPoint.x/PTM_RATIO, cocosPoint.y/PTM_RATIO);
}

+ (b2Vec2)boxPointFromCocosCoordsX: (float)xCoord andY: (float)yCoord
{
    return b2Vec2(xCoord/PTM_RATIO, yCoord/PTM_RATIO);
}

+ (CGPoint)cocosPointFromBoxPoint: (b2Vec2) boxPoint
{
    return CGPointMake(boxPoint.x * PTM_RATIO, boxPoint.y*PTM_RATIO);
}

- (CGPoint)cameraPosition
{
    CGPoint result = CGPointZero;
    
    //===
    
    if(self.currentLevel)
    {
        result = self.currentLevel.gameLayer.cameraPosition;
    }
    
    //===
    
    return result;
}

- (void)setCameraPosition:(CGPoint)newValue
{
    self.currentLevel.gameLayer.cameraPosition = newValue;
}

- (void)showMem
{
#ifdef DEBUG
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    /*kern_return_t kerr =*/ task_info(mach_task_self(),
                                       TASK_BASIC_INFO,
                                       (task_info_t)&info,
                                       &size);
    
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    
    host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmStats, &infoCount);
    
    vm_size_t currentMem = info.resident_size;
    currentMem /= 1000000;
    
    if(currentMem != _prevMem) {
        NSLog(@"Memory in use (in MB): %u", currentMem);
        _prevMem = currentMem;
    }
#endif
}

#pragma mark Initialization

- (id)init
{
    self = [super init];
    
    //===
    
    if (self) {
        
        _loadingScreenSpriteName = nil;
        _firstSceneClass = nil;
        
        _lastDt = 0;
        
        _debugMode = NO;
        
        _gameActive = NO;
        
        _prevMem = 0;
    }
    
    //===
    
    return self;
}

- (void)initPTM
{
    //call it before initDebugDraw!!!
 
    //===
    
    //override in subclass if need to change default value!
    //CHANGE value BEFORE call [super initPTM];
    
    //===
    
    PTM_RATIO *= [[CCDirector sharedDirector] contentScaleFactor];
}

//must be called once at creation:
- (void)initDebugDraw
{
    if(!_debugDraw)
    {
        _debugDraw =
        new GLESDebugDraw(PTM_RATIO); //allready with scaleFactor!
        
        //===
        
        [self disableDebugDraw];
//        [self enableDebugDraw];
    }
}

- (void)initContactListener
{
    if(!_contactListener)
        _contactListener = new GContactListener();
}

- (void)initWorldParams
{
    // Define the default gravity vector.
    _defaultGravity.Set(0.0f, -30.0f);
}

- (void)initWithWindow: (UIWindow *)targetWindow
{
    CCGLView *glView = [CCGLView viewWithFrame:[targetWindow bounds]
								   pixelFormat:kEAGLColorFormatRGBA8	//kEAGLColorFormatRGB565
								   depthFormat:0	//GL_DEPTH_COMPONENT24_OES
							preserveBackbuffer:NO
									sharegroup:nil
								 multiSampling:NO
							   numberOfSamples:0];
    
    // Enable multiple touches
	[glView setMultipleTouchEnabled:YES];
    
    CCDirectorIOS *director_ = (CCDirectorIOS*)[CCDirector sharedDirector];
    
    director_.wantsFullScreenLayout = YES;
    
	// Display FSP and SPF
	[director_ setDisplayStats:YES];
	
	// set FPS at 60
	[director_ setAnimationInterval:1.0/60];
	
	// attach the openglView to the director
	[director_ setView:glView];
    
	// for rotation and other messages
	[director_ setDelegate:self];
	
	// 2D projection
	[director_ setProjection:kCCDirectorProjection2D];
    
    //High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
//    if(![director_ enableRetinaDisplay:YES])
//        CCLOG(@"Retina Display Not supported");
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
	
	// If the 1st suffix is not found and if fallback is enabled then fallback suffixes are going to searched. If none is found, it will try with the name without suffix.
	// On iPad HD  : "-ipadhd", "-ipad",  "-hd"
	// On iPad     : "-ipad", "-hd"
	// On iPhone HD: "-hd"
	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
	[sharedFileUtils setEnableFallbackSuffixes:NO];				// Default: NO. No fallback suffixes are going to be used
	[sharedFileUtils setiPhoneRetinaDisplaySuffix:@"-hd"];		// Default on iPhone RetinaDisplay is "-hd"
	[sharedFileUtils setiPadSuffix:@"-ipad"];					// Default on iPad is "ipad"
	[sharedFileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];	// Default on iPad RetinaDisplay is "-ipadhd"
	
	// Assume that PVR images have premultiplied alpha
	[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];
    
    //===
    
    if(director_.winSize.width < director_.winSize.height)
    {
        winSize = CGSizeMake(director_.winSize.height, director_.winSize.width);
        
    } else {
        
        winSize = CGSizeMake(director_.winSize.width, director_.winSize.height);
    }
    
    //===
    
    [self initPTM]; //call it before initDebugDraw!!!
    [self initDebugDraw];
    [self initContactListener];
    [self initWorldParams];
    [self initWorld];
}

#pragma mark CCDirectorDelegate protocol methods

// Supported orientations: Landscape. Customize it for your own needs
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark World management

- (b2World *)initWorld
{    
    // delete the world, if it already exists:
    [self deleteWorld];
    
    //===
    
    _world = new b2World(_defaultGravity);
    _world->SetAllowSleeping(YES);
    _world->SetContinuousPhysics(YES);
    _world->SetDebugDraw(_debugDraw);
    _world->SetContactListener(_contactListener);
    
    //===
    
    return _world;
}

//рекомендуется вызывать при уничтожении уровня, так как одновременно
//два уровня загружены быть не должны, может быть загружен один уровень,
//убран в фон и сейчас активно меню...
- (void)deleteAllWorldObjects
{
    if(_world) {
        //нужно осовободить память, занимаемую текущими объектами мира:
        
        //пробигаемся по всем объектам мира и удаляем их:
        for (b2Body* b = _world->GetBodyList(); b; b = b->GetNext())
        {        
            GObject *o = (GObject *)(b->GetUserData());
            if(o)
            {
                // destroy physics object
                [o markForDelete];        
            }
            else
            {
                // destroy body
                _world->DestroyBody(b);
            }
        }
    }
}

- (void)deleteWorld
{
    [self deleteAllWorldObjects];
    
    if(_world) {
        delete _world;
        _world = nil;
    }
}

#pragma mark CleanUp

- (void)dealloc
{
    self.loadingScreenSpriteName = nil;
    
    [self deleteWorld];
    
    // delete the contact listener
    if(_contactListener) {
        delete _contactListener;
        _contactListener = nil;
    }
    
    // delete the debug draw object
    if(_debugDraw) {
        delete _debugDraw;
        _debugDraw = nil;
    }
    
    //===
    
    // don't forget to call "super dealloc"
    [super dealloc];
}

#pragma mark DebugDraw control

- (void)enableDebugDraw
{
    uint32 flags = 0;
	flags += b2Draw::e_shapeBit;
	flags += b2Draw::e_jointBit;
	//flags += b2Draw::e_aabbBit;
	//flags += b2Draw::e_pairBit;
	//flags += b2Draw::e_centerOfMassBit;
    
    //===
    
    _debugDraw->SetFlags(flags);
}

- (void)disableDebugDraw
{
    //disable all flags:
    _debugDraw->SetFlags(0);
}

- (void)switchDebugDraw
{   
    if(_debugDraw->GetFlags() == 0) { //disabled now
        
        [self enableDebugDraw];
        
    } else { //enabled now
        
        [self disableDebugDraw];
        
    }
}

#pragma mark Scene managemant

- (void)runGame
{
    SEL targetSelector = @selector(node);
    
    if(self.firstSceneClass &&
       targetSelector &&
       [self.firstSceneClass respondsToSelector:targetSelector])
    {
        [[CCDirector sharedDirector] pushScene:
         [GTransitionScene sceneWithSprite:self.loadingScreenSpriteName
                                    target:self.firstSceneClass
                               andSelector:targetSelector]];
        
        // schedule update
        [[CCDirector sharedDirector].scheduler scheduleUpdateForTarget:self
                                                              priority:0
                                                                paused:NO];
    }
}

- (void)runScene:(Class)targetSceneClass
{
    //replace scene for memory optimization!!!
    
    SEL targetSelector = @selector(node);
    
    if(targetSceneClass &&
       targetSelector &&
       [targetSceneClass respondsToSelector:targetSelector])
    {
        [[CCDirector sharedDirector] replaceScene:
         [GTransitionScene
          sceneWithSprite:self.loadingScreenSpriteName
          target:targetSceneClass
          andSelector:targetSelector]];
    }
}

- (void)pushScene:(Class)targetSceneClass
{
    SEL targetSelector = @selector(node);
    
    if(targetSceneClass &&
       targetSelector &&
       [targetSceneClass respondsToSelector:targetSelector])
    {
        [[CCDirector sharedDirector] pushScene:
         [GTransitionScene
          sceneWithSprite:self.loadingScreenSpriteName
          target:targetSceneClass
          andSelector:targetSelector]];
    }
}

- (void)goBack
{
    [[CCDirector sharedDirector] popScene];
}

- (GLevel *)currentLevel
{
    CCScene *curScene = [[CCDirector sharedDirector] runningScene];
    
    if(curScene &&
       [curScene isKindOfClass:[GLevel class]])
    {
        return (GLevel *)curScene;
    }
    else
    {
        return nil;
    }
}

#pragma mark UPDATE

- (void)update: (ccTime)dt
{   
    _lastDt = dt;
    
    //===
    
    //It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation
    //You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/
    
    const float32 timeStep = 1.0f / 30.0f;
    const int32 velocityIterations = 8;
    const int32 positionIterations = 5;
    
    // Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	_world->Step(timeStep, velocityIterations, positionIterations);

    //=== execute game-specific things
    
    [self afterStep];
    
    //=== execute level-specific things
    
    GLevel *curLevel = self.currentLevel;
    if(curLevel)
    {
        [curLevel update:dt];
    }
    
    //=== execute GameObject-specific things and delete unnecessered objects
    
    if(_world)
    {
        for (b2Body *b = _world->GetBodyList(); b; b = b->GetNext())
        {
            GObject *o = (GObject *)(b->GetUserData());
            
            if(o.deleteLater)
            {
                // destroys the body and removes the object from the scene
                [o deleteNow];
                
            } else {
                
                [o update:dt];
            }
        }        
    }
}

- (void)afterStep
{
    //in subclass implement here global interactions:
    //hero contoling via custom HUD layer, etc.
}

@end
