//
//  GTileMapInfo.m
//  Alien
//
//  Created by Max on 08.08.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GTileMapInfo.h"

#import "GTileMap.h"
#import "GTileInfo.h"


static int defaultColumnsNumber = 1;
static int defaultRowsNumber = 1;

static int defaultZOrder = 0;

static CCNode *defaultParent = nil;

@implementation GTileMapInfo

+ (void)defineDefaultColumnsNumber:(int)colNum
                     andRowsNumber:(int)rowNum
{
    defaultColumnsNumber = colNum;
    defaultRowsNumber = rowNum;
}

+ (void)defineDefaultZOrder:(int)targetZOrder
{
    defaultZOrder = targetZOrder;
}

+ (void)defineDefaultParent:(CCNode *)targetParent
{
    defaultParent = targetParent;
}

#pragma mark Creation

+ (id)tileMapWithName:(NSString *)tileMapName
{
    return [self tileMapWithName:tileMapName
                   columnsNymber:defaultColumnsNumber
                      rowsNumber:defaultRowsNumber
                          parent:defaultParent
                       andZOrder:defaultZOrder];
}

+ (id)tileMapWithName:(NSString *)tileMapName
        columnsNymber:(int)colNum
           rowsNumber:(int)rowNum
               parent:(CCNode *)targetParent
            andZOrder:(int)targetZOrder
{
    GTileMapInfo *result;
    
    //===
    
    result = [[[self class] new] autorelease];
    
    result.name = tileMapName;
    result.columnsNumber = colNum;
    result.rowsNumber = rowNum;
    result.parent = targetParent;
    result.zOrder = targetZOrder;
    
    //загрузим в кэш сведения о фреймах для последующей проверки
    //валидности имен фреймов при наполнении тайлмапа сведениями о сегментах:
    [[CCSpriteFrameCache sharedSpriteFrameCache]
     addSpriteFramesWithFile:[result.name stringByAppendingString:@".plist"]];
    
    //===
    
    return result;
}

#pragma mark initialization

- (id)init
{
    self = [super init];
    if (self) {
        
        _name = nil;
        _zOrder = 0;
        _parent = nil;
        
        self.tiles = [NSMutableArray array];
        
        _tileSize = [CCDirector sharedDirector].winSize;
        _factRect = CGRectZero;
        
        _tileMap = nil;
        
        _position = CGPointZero;
    }
    return self;
}

#pragma mark CleanUp

- (void)dealloc
{
    self.tiles = nil;
    
    //===
    
    [super dealloc];
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
    int tilesCountBefore = _tiles.count;
    
    BOOL useRowInNameFormat = (rowIndex != -1);
    
    if(rowIndex == -1) {
        rowIndex = 1;
    }
    
    //===
    
    for (int col = fromColumnIndex; col <= tillColumnIndex; col++)
    {
        //=== определяем имя фрейма для спрайта:
        
        NSString *frameName =
        (useRowInNameFormat ?
         [NSString stringWithFormat:tileNameFormat, rowIndex, col] :
         [NSString stringWithFormat:tileNameFormat, col]);
        
        [self addSegmentWithName:frameName
                     andPosition:[self tilePositionForColumn:col andRow:rowIndex]];
    }
    
    //===
    
    if(tilesCountBefore != _tiles.count) {
        
        [self updateFactRect];
    }
}

- (void)addSegmentWithName:(NSString *)tileName
               andPosition:(CGPoint)targetPosition
{
    CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache]
                            spriteFrameByName:tileName];
    
    if(frame) {
        GTileInfo *newTile =
        [GTileInfo tileWithFrameName:tileName
                              parent:self
                         andPosition:targetPosition];
        
        [_tiles addObject:newTile];
    }
}

- (CGPoint)tilePositionForColumn:(int)columnIndex
                          andRow:(int)rowIndex
{
    return ccp((columnIndex - 1) * _tileSize.width,
               (_rowsNumber - rowIndex) * _tileSize.height);
}

#pragma mark Other

- (void)updateFactRect
{
    //пробегаем по всем элементам tiles и считаем factRect
    
    if(_tiles.count > 0)
    {
        CGRect result = ((GTileInfo *)[_tiles objectAtIndex:0]).boundingBoxFact;
        
        for (GTileInfo *tile in _tiles) {
            
            result = CGRectUnion(result, tile.boundingBoxFact);
        }
        
        //=== keep actual factrect_:
        
        _factRect = result;
    }
}

- (BOOL)load
{
    BOOL result = NO;
    
    //===
    
    if(self.isAbleToLoad)
    {
        _state = tmWaitForLoading;
        
        //=== загрузим атлас:
        
        [[CCTextureCache sharedTextureCache]
         addImageAsync:[self.name stringByAppendingString:@".png"]
         target:self
         selector:@selector(loadWithTexture:)];
        
        //===
        
        result = YES;
    }
    
    //===
    
    return result;
}

- (void)loadWithTexture:(CCTexture2D *)batchTexture
{
    if(self.parent == nil)
    {
        return;
    }
    
    //===
    
    _state = tmLoading;
    
    //===
    
    _tileMap = [GTileMap tileMapWithTexture:batchTexture
                              columnsNumber:self.columnsNumber
                              andRowsNumber:self.rowsNumber];
    
    if(_tileMap != nil)
    {
        _tileMap.position = self.position;
        
        //=== загрузим все сегменты этого атласа:
        
        for (GTileInfo *info in _tiles) {
            
            [info load];
        }
        
        [self.parent addChild:self.tileMap z:self.zOrder];
        
        _state = tmLoaded;
        
    } else {
        
        NSLog(@"ERROR! GTileMap %@ not loaded!", self.name);
        
        _state = tmUnLoaded;
    }
}

- (BOOL)unload
{
    BOOL result = NO;
    
    //===
    
    if(self.isAbleToUnLoad)
    {
        _state = tmUnLoading;
        
        result = YES;
        
//        NSLog(@"UNloading %@", self.name);
        
//        dispatch_queue_t q =
//        dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//        
//        dispatch_async(q, ^{
           
            //=== обнулим ссылки на спрайты:
        
            for (GTileInfo *info in _tiles) {
                [info unloaded];
            }
            
            //=== выгружаем атлас и все фреймы из памяти:
            
            [self.tileMap removeFromParentAndCleanup:YES];
            //[self.tileMap selfRemove];        
            _tileMap = nil;
            
            //=== чистим кэш
            
//            [[CCTextureCache sharedTextureCache] removeUnusedTextures];
        
            //===
            
            _state = tmUnLoaded;
//        });
    }
    
    //===
    
    return result;
}

- (BOOL)isBusy
{
    return ((_state == tmWaitForLoading) ||
            (_state == tmLoading) ||
            (_state == tmUnLoading));
}

- (BOOL)isAbleToLoad
{
    return (_state == tmUnLoaded);
}

- (BOOL)isAbleToUnLoad
{
    return (_state == tmLoaded);
}

- (BOOL)isUnLoading
{
    return (_state == tmUnLoading);
}

- (CGPoint)absolutePosition
{
	CGPoint ret = CGPointZero; //self.position unneeded cause tile map always in (0;0)
	CCNode *cn = self.parent;
    
	while (cn != nil) {
		ret = ccpAdd( ret, cn.position );
        cn = cn.parent;
	}
    
	return ret;
}

- (CGRect)absoluteFactRect
{
    CGPoint absPos = self.absolutePosition;
    CGRect factRect = self.factRect;
    
    return CGRectOffset(factRect, absPos.x, absPos.y);
}

@end
