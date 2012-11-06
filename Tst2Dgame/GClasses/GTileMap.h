//
//  GContiniousSpriteCanvas.h
//  Alien
//
//  Created by Max on 06.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "GSprite.h"

@interface GTileMap : CCSpriteBatchNode

@property(assign) int columnsNumber;
@property(assign) int rowsNumber;

@property(nonatomic, readwrite, retain) NSMutableArray *segments;
@property(readonly) CGSize tileSize;

@property(readonly) float widthEstimated;
@property(readonly) float heightEstimated;

@property(readonly) float widthFact;
@property(readonly) float heightFact;

//=== Creation

+ (id)tileMapWithName:(NSString *)batchName
        columnsNumber:(int)colNum andRowsNumber:(int)rowNum;

+ (id)tileMapWithTexture:(CCTexture2D *)batchTexture
        columnsNumber:(int)colNum andRowsNumber:(int)rowNum;

//=== Tiles management

- (void)addTilesWithNameFormat:(NSString *)tileNameFormat
                    fromColumn:(int)fromColumnIndex
                    tillColumn:(int)tillColumnIndex;
- (void)addTilesWithNameFormat:(NSString *)tileNameFormat
                         atRow:(int)rowIndex
                    fromColumn:(int)fromColumnIndex
                    tillColumn:(int)tillColumnIndex;

- (void)addTile:(CCNode *)newTile
       atColumn:(int)colIndex
         andRow:(int)rowIndex;

@end
