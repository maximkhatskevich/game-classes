/*
 MIT License
 
 Copyright (c) 2010 Andreas Loew / www.code-and-web.de
 
 For more information about htis module visit
 http://www.PhysicsEditor.de

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import "GContact.h"

#import "cocos2d.h"
#import "Box2D.h"
#import "GObject.h"

@implementation GContact

-(id) initWithObject:(GObject *)myOwnObject
          ownFixture:(b2Fixture *)myOwnFixture
         otherObject:(GObject *)theOtherObject
        otherFixture:(b2Fixture *)theOtherFixture
           b2Contact:(b2Contact *)theB2Contact
{
    self = [super init];
    if(self)
    {
        self.otherObject = theOtherObject;
        self.ownFixture = myOwnFixture;
        self.ownFixtureId = (NSString *)self.ownFixture->GetUserData();
        self.otherFixture = theOtherFixture;
        self.otherFixtureId = (NSString *)self.otherFixture->GetUserData();
        self.box2dContact = theB2Contact;
    }
    return self;
}

+ (id)contactWithObject:(GObject *)ownObject
             ownFixture:(b2Fixture *)ownFixture
            otherObject:(GObject *)otherObject
           otherFixture:(b2Fixture *)otherFixture
              b2Contact:(b2Contact *)contact
{
    return [[[GContact alloc] initWithObject:ownObject
                                  ownFixture:ownFixture
                                 otherObject:otherObject 
                                otherFixture:otherFixture
                                   b2Contact:contact] autorelease];
}

-(void) setEnabled:(BOOL)enabled
{
    _box2dContact->SetEnabled(enabled);
}

-(CGPoint) point
{
    b2WorldManifold manifold;
    b2Vec2 p;
    
    self.box2dContact->GetWorldManifold(&manifold);
    p = manifold.points[0];
    
    return ccp(p.x, p.y);
}

-(void) dealloc
{
    self.otherObject = nil;
    self.ownFixture = nil;
    self.ownFixtureId = nil;
    self.otherFixture = nil;
    self.otherFixtureId = nil;
    self.box2dContact = nil;
    
    //===
    
    [super dealloc];
}

@end


