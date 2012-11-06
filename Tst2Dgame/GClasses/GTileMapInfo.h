//
//  GTileMapInfo.h
//  Alien
//
//  Created by Max on 08.08.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "cocos2d.h"

@class GTileMap;

typedef enum {
    tmUnLoaded = 0,
    tmWaitForLoading = 1, //busy
    tmLoading = 2, //busy
    tmLoaded = 3,
    tmUnLoading = 4 //busy
    
} GTileMapState;

@interface GTileMapInfo : NSObject

@property(nonatomic, copy) NSString *name;
@property(nonatomic, assign) CCNode *parent; //weak!
@property CGPoint position;
@property NSUInteger zOrder;

@property(nonatomic, readwrite, retain) NSMutableArray *tiles;
@property NSUInteger columnsNumber;
@property NSUInteger rowsNumber;
@property(readonly) CGSize tileSize;
@property(readonly) CGRect factRect;

@property(nonatomic, readonly) GTileMap *tileMap;
@property(readonly) GTileMapState state;
@property(readonly) BOOL isBusy;
@property(readonly) BOOL isAbleToLoad;
@property(readonly) BOOL isAbleToUnLoad;
@property(readonly) BOOL isUnLoading;

@property(readonly) CGPoint absolutePosition;
@property(readonly) CGRect absoluteFactRect;

+ (void)defineDefaultColumnsNumber:(int)colNum
                     andRowsNumber:(int)rowNum;
+ (void)defineDefaultZOrder:(int)targetZOrder;
+ (void)defineDefaultParent:(CCNode *)targetParent;

+ (id)tileMapWithName:(NSString *)tileMapName;

+ (id)tileMapWithName:(NSString *)tileMapName
        columnsNymber:(int)colNum
           rowsNumber:(int)rowNum
               parent:(CCNode *)targetParent
            andZOrder:(int)targetZOrder;

- (void)addTilesWithNameFormat:(NSString *)tileNameFormat
                    fromColumn:(int)fromColumnIndex
                    tillColumn:(int)tillColumnIndex;
- (void)addTilesWithNameFormat:(NSString *)tileNameFormat
                         atRow:(int)rowIndex
                    fromColumn:(int)fromColumnIndex
                    tillColumn:(int)tillColumnIndex;

- (void)addSegmentWithName:(NSString *)tileName
               andPosition:(CGPoint)targetPosition;

- (CGPoint)tilePositionForColumn:(int)columnIndex
                          andRow:(int)rowIndex;


//call it on children add
- (void)updateFactRect;

- (BOOL)load;
- (void)loadWithTexture:(CCTexture2D *)batchTexture;
- (BOOL)unload;

@end
