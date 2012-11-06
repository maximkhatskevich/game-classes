//
//  IntroLayer.h
//  Alien
//
//  Created by Максим & Марго on 15.07.12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import "cocos2d.h"

@interface GTransitionScene : CCScene

+ (CCScene *)sceneWithSprite:(NSString *)spriteName
                      target:(id)target
                 andSelector:(SEL)nextSceneSelector;

@property(nonatomic, copy) NSString *spriteName;
@property(nonatomic, retain) id target;
@property(assign) SEL nextSceneSelector;

@end
