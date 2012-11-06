//
//  GLayerWithCamera.m
//  Alien
//
//  Created by Max on 11.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GLayerWithCamera.h"

#import "GKernel.h"
#import "GLevel.h"

@interface GLayerWithCamera ()
{
    CGPoint _cameraPosition;
}

@end

@implementation GLayerWithCamera

- (void)dealloc
{
    //
    
    //===
    
    [super dealloc];
}

#pragma mark Initialization

- (id)init
{
    self = [super init];
    if (self) {
        
        self.anchorPoint = ccp(0, 0);
        
        _previousCameraPosition = CGPointZero;
        _cameraPosition = CGPointZero;
        _cameraRect = CGRectZero;
        
        _softCameraMove = YES;
        _softCameraYMove = NO;
        
    }
    return self;
}

#pragma mark Camera implementation

- (CGPoint)cameraPosition
{
    return _cameraPosition;
}

- (void)setCameraPosition:(CGPoint)newValue
{
    if((_cameraPosition.x != newValue.x) ||
       (_cameraPosition.y != newValue.y))
    {
        //проверяем, не выходит ли новое положение камеры за пределы ограничений,
        //если выходит - подправляем:
        
        CGSize winSize = [CCDirector sharedDirector].winSize;
        
        //уменьшаем область возможных позиций камеры на текущий размер экрана:
        CGRect cameraPositionRect_ = CGRectMake(_cameraRect.origin.x,
                                                _cameraRect.origin.y,
                                                _cameraRect.size.width - winSize.width,
                                                _cameraRect.size.height - winSize.height);
        
        CGPoint cameraMinPosition = cameraPositionRect_.origin;
        CGPoint cameraMaxPosition = ccp(cameraPositionRect_.origin.x +
                                        cameraPositionRect_.size.width,
                                        cameraPositionRect_.origin.y +
                                        cameraPositionRect_.size.height);
        
        //===
        
        //проверяем нижние границы:
        if(newValue.x < cameraMinPosition.x)
            newValue.x = cameraMinPosition.x;
        
        if(newValue.y < cameraMinPosition.y)
            newValue.y = cameraMinPosition.y;
        
        //проверяем верхние границы:
        if(newValue.x > cameraMaxPosition.x)
            newValue.x = cameraMaxPosition.x;
        
        if(newValue.y > cameraMaxPosition.y)
            newValue.y = cameraMaxPosition.y;
        
        //=== ограничиваем скорость камеры для ее плавного движения:
        
        if(self.softCameraMove)
        {
            float cameraMaxSpeed = dV(600) * [GKernel sharedInstance].lastDt;
            
            float dX = newValue.x - _cameraPosition.x;
            
            if (dX > cameraMaxSpeed)
                dX = cameraMaxSpeed;
            else if(dX < -cameraMaxSpeed)
                dX = -cameraMaxSpeed;
            
            newValue.x = _cameraPosition.x + dX;
            
            //===
            
            if(_softCameraYMove)
            {
                float dY = newValue.y - _cameraPosition.y;
                
                if (dY > cameraMaxSpeed)
                    dY = cameraMaxSpeed;
                else if(dY < -cameraMaxSpeed)
                    dY = -cameraMaxSpeed;
                
                newValue.y = _cameraPosition.y + dY;
            }
        }
    }
    
    //после предобработки снова имеет смысл проверить,
    //а отличается ли новое значение от текущего, и если да, то применять его:
    if((_cameraPosition.x != newValue.x) ||
       (_cameraPosition.y != newValue.y))
    {
        //запомним предыдущее положение:
        _previousCameraPosition = _cameraPosition;
        
        //===
        
        //принимаем новое значение:
        _cameraPosition = newValue;
        
        //===
        
        //пошлем уведомление в контроллер уровня о смещении камеры:
        [self cameraMoved];
    }
}

- (CGPoint)lastCameraPositionDelta
{
    return ccpSub(_cameraPosition, _previousCameraPosition);
}

- (void)cameraMoved
{
    if(self.parent &&
       [self.parent isKindOfClass:[GLevel class]])
    {
        [((GLevel *)self.parent) cameraMoved:self.lastCameraPositionDelta];
    }
}

-(void) visit
{
    kmGLPushMatrix();
    
	kmGLTranslatef(-_cameraPosition.x,
                   -_cameraPosition.y,
                   0);
	
	[super visit];
	
	kmGLPopMatrix();
}

@end
