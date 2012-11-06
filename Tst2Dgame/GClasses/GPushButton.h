//
//  GPushButton.h
//  Alien
//
//  Created by Max on 14.09.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GButton.h"

@class CCSpriteFrame;

@interface GPushButton : GButton

@property(nonatomic, retain) CCSpriteFrame *normalSpriteFrame;
@property(nonatomic, retain) CCSpriteFrame *touchedSpriteFrame;

+ (GPushButton *)pushButtonWithNormalFrameName:(NSString *)normalSpriteFrameName
                           andTouchedFrameName:(NSString *)touchedSpriteFrameName;

@end
