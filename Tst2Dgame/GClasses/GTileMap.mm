//
//  GContiniousSpriteCanvas.m
//  Alien
//
//  Created by Max on 06.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GTileMap.h"

#import "GKernel.h"
#import "GObject.h"

@implementation GTileMap

#pragma mark Creation

+ (id)tileMapWithName:(NSString *)batchName
        columnsNumber:(int)colNum andRowsNumber:(int)rowNum
{
    GTileMap *result;
    
    //===
    
    result = [GTileMap batchNodeWithFile:
              [batchName stringByAppendingString:@".png"]];
    
    result.columnsNumber = colNum;
    result.rowsNumber = rowNum;
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:
     [batchName stringByAppendingString:@".plist"]];
    
    //===
    
    return result;
}

+ (id)tileMapWithTexture:(CCTexture2D *)batchTexture
           columnsNumber:(int)colNum andRowsNumber:(int)rowNum
{
    GTileMap *result;
    
    //===
    
    result = [GTileMap batchNodeWithTexture:batchTexture];
    
    result.columnsNumber = colNum;
    result.rowsNumber = rowNum;
    
    //===
    
    return result;
}

#pragma mark Initialization

-(id) initWithTexture:(CCTexture2D*)tex capacity:(NSUInteger)n
{
    self = [super initWithTexture:tex capacity:n];
    
    //===
    
    if (self) {
        
        self.segments = [NSMutableArray array];
        
        self.anchorPoint = ccp(0, 0);
        _tileSize = CGSizeZero;
    }
    
    //===
    
    return self;
}

#pragma mark Tiles management

- (void)addTilesWithNameFormat:(NSString *)tileNameFormat
                    fromColumn:(int)fromColumnIndex
                    tillColumn:(int)tillColumnIndex
{
    [self addTilesWithNameFormat:tileNameFormat
                           atRow:-1
                      fromColumn:fromColumnIndex
                      tillColumn:tillColumnIndex];
}

- (void)addTilesWithNameFormat:(NSString *)tileNameFormat
                         atRow:(int)rowIndex
                    fromColumn:(int)fromColumnIndex
                    tillColumn:(int)tillColumnIndex
{
    BOOL useRowInNameFormat = (rowIndex != -1);
    
    if(rowIndex == -1) {
        rowIndex = 1;
    }
    
    for (int col = fromColumnIndex; col <= tillColumnIndex; col++)
    {
        //=== определяем имя фрейма для спрайта:
        
        NSString *frameName =
        (useRowInNameFormat ?
         [NSString stringWithFormat:tileNameFormat, rowIndex, col] :
         [NSString stringWithFormat:tileNameFormat, col]);
        
        //ищем в кэше фрейм с заданным именем:
        
        CCSpriteFrame *frame =
        [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
        
        if(frame)
        {
            GSprite *tmp = [GSprite spriteWithSpriteFrame:frame];
            tmp.spriteFrameName = frameName; //for debug purposes...
            [self addTile:tmp atColumn:col andRow:rowIndex];
        }
    }
}

//adds segment to list and sets position for him

- (void)addTile:(CCNode *)newTile
       atColumn:(int)colIndex
         andRow:(int)rowIndex
{
    if(!newTile)
        return;
    
    //===
    
    if((_tileSize.width == 0) ||
       (_tileSize.height == 0))
    {
        //первый тайл инициализирует размеры будущей сетки:
        _tileSize = newTile.boundingBox.size;
    }
    
    //=== calculate position
    
    CGPoint newTilePosition = CGPointZero;
    
    newTilePosition = ccp((colIndex - 1) * _tileSize.width,
                          (_rowsNumber - rowIndex) * _tileSize.height);
    
    //===
    
    if([newTile isKindOfClass:[GObject class]])
    {        
        [(GObject *)newTile setCcPosition:newTilePosition];
        
    } else {
        
        newTile.position = newTilePosition;
    }
    
    [self addChild:newTile z:-100];
    
    //===
    
    [self.segments addObject:newTile];
}

#pragma mark CleanUp

- (void)cleanup
{
	[super cleanup];
}

- (void)dealloc
{
    self.segments = nil;
    
    //===
    
    [super dealloc];
}

#pragma mark Size info

- (float)widthEstimated
{
    return _tileSize.width * _columnsNumber;
}

- (float)heightEstimated
{
    return _tileSize.height * _rowsNumber;
}

- (float)widthFact
{
    float result = 0;
    
    //===
    
    for (GSprite *segment in self.segments) {
        
        float buf = segment.rightBottomPosition.x;
        if(buf > result) {
            result = buf;
        }
    }
    
    //===
    
    return result;
}

- (float)heightFact
{
    float result = 0;
    
    //===
    
    for (GSprite *segment in self.segments) {
        
        float buf = segment.leftTopPosition.y;
        if(buf > result) {
            result = buf;
        }
    }
    
    //===
    
    return result;
}

@end
