//
//  IntroLayer.m
//  Alien
//
//  Created by Максим & Марго on 15.07.12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import "GTransitionScene.h"

@implementation GTransitionScene

#pragma mark Creation

+ (CCScene *)sceneWithSprite:(NSString *)spriteName
                      target:(id)target
                 andSelector:(SEL)nextSceneSelector
{
    GTransitionScene *result = nil;
    
    if(!spriteName)
    {
        NSLog(@"Empty loading screen!");
    }
    
    //===
    
    result = [[self class] node];
    
    if(result != nil)
    {
        result.spriteName = spriteName;
        result.target = target;
        result.nextSceneSelector = nextSceneSelector;
    }
    
    //===
    
    return result;
}

#pragma mark Initialization & CleanUp

- (id)init
{
    self = [super init];
    if (self) {
        
        _spriteName = nil;
        _target = nil;
        _nextSceneSelector = 0;
        
    }
    return self;
}

- (void)dealloc
{
    self.spriteName = nil;
    self.target = nil;
    
    //===
    
    [super dealloc];
}

#pragma mark Other

-(void) onEnter
{
	[super onEnter];
    
	// ask director for the window size
	CGSize size = [[CCDirector sharedDirector] winSize];

	CCSprite *background;
	
//	if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ) {
//		background = [CCSprite spriteWithFile:@"Default.png"];
//		background.rotation = 90;
//	} else {
		background = [CCSprite spriteWithFile:self.spriteName];
//	}
	background.position = ccp(size.width/2, size.height/2);
    background.opacity = 0;

	// add the label as a child to this Layer
	[self addChild:background];
	
    [background runAction:
     [CCSequence actions:
      [CCFadeIn actionWithDuration:0.2],
      [CCCallFunc actionWithTarget:self
                          selector:@selector(makeTransition)],
      nil]];

//    [self makeTransition];
    
//	// In one second transition to the new scene
//	[self scheduleOnce:@selector(makeTransition:) delay:0];
}

-(void) makeTransition
{
    if((self.target != nil) &&
       [self.target respondsToSelector:self.nextSceneSelector])
    {
        CCScene *targetScene = [self.target performSelector:self.nextSceneSelector];
        
        targetScene = [CCTransitionFade transitionWithDuration:1.02
                                                         scene:targetScene
                                                     withColor:ccGRAY];
        
        [[CCDirector sharedDirector] replaceScene:targetScene];
    }
}
@end
