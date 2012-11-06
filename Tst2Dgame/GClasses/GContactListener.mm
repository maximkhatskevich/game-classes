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

#import "GContactListener.h"

#import "cocos2d.h"

#import "GObject.h"

GContactListener::GContactListener()
: b2ContactListener()
{
}

GContactListener::~GContactListener() 
{
}

/**
 * Calls constructed selectors on the objects involved in the collision
 *
 * If a is an object of type A, and b is object of type B this method will
 * call 
 *
 * universal selector:
 *    [a <contactType>:GContactB];
 *    [b <contactType>:GContactA];
 *
 * typed selector:
 *    [a <contactType>WithB:GContactB];
 *    [b <contactType>WithA:GContactA];
 *
 * @param contact the b2Contact 
 * @param contactType string containing "beginContact", "endContact" or "presolveContact"
 */
void GContactListener::notifyObjects(b2Contact *contact, NSString *contactType)
{
    b2Body *bodyA = contact->GetFixtureA()->GetBody();
    b2Body *bodyB = contact->GetFixtureB()->GetBody();
    
    GObject *a = (GObject *)bodyA->GetUserData();
    GObject *b = (GObject *)bodyB->GetUserData();
    
    if((!a.deleteLater) &&
       (!b.deleteLater))
    {
        NSString *nameContactUniversal = [NSString stringWithFormat:@"%@:", contactType];
        NSString *nameContactA = [NSString stringWithFormat:@"%@With%@:", contactType, NSStringFromClass([a class])];
        NSString *nameContactB = [NSString stringWithFormat:@"%@With%@:", contactType, NSStringFromClass([b class])];
        
        SEL selectorContactWithB = NSSelectorFromString(nameContactB);
        SEL selectorContactUniversal = NSSelectorFromString(nameContactUniversal);
        if([a respondsToSelector:selectorContactWithB])
        {
            // perform designated contact listener
            GContact *contactWithB = [GContact
                                      contactWithObject:a
                                      ownFixture:contact->GetFixtureA()
                                      otherObject:b
                                      otherFixture:contact->GetFixtureB()
                                      b2Contact:contact];
            
            [a performSelector:selectorContactWithB
                    withObject:contactWithB];
        }
        else if([a respondsToSelector:selectorContactUniversal])
        {
            // perform universal contact listener
            GContact *contactWithB = [GContact
                                      contactWithObject:a
                                      ownFixture:contact->GetFixtureA()
                                      otherObject:b
                                      otherFixture:contact->GetFixtureB()
                                      b2Contact:contact];
            
            [a performSelector:selectorContactUniversal
                    withObject:contactWithB];
        }
        
        SEL selectorContactWithA = NSSelectorFromString(nameContactA);
        if([b respondsToSelector:selectorContactWithA])
        {
            // perform designated contact listener
            GContact *contactWithA = [GContact
                                      contactWithObject:b
                                      ownFixture:contact->GetFixtureB()
                                      otherObject:a
                                      otherFixture:contact->GetFixtureA()
                                      b2Contact:contact];
            
            [b performSelector:selectorContactWithA
                    withObject:contactWithA];
        }
        else if([b respondsToSelector:selectorContactUniversal])
        {
            // perform universal contact listener
            GContact *contactWithA = [GContact
                                      contactWithObject:b
                                      ownFixture:contact->GetFixtureB()
                                      otherObject:a
                                      otherFixture:contact->GetFixtureA()
                                      b2Contact:contact];
            
            [b performSelector:selectorContactUniversal
                    withObject:contactWithA];        
        }
    }
}

/// Called when two fixtures begin to touch.
void GContactListener::BeginContact(b2Contact* contact) 
{
    notifyObjects(contact, @"beginContact");        
}

/// Called when two fixtures cease to touch.
void GContactListener::EndContact(b2Contact* contact) 
{ 
    notifyObjects(contact, @"endContact");
}

/// This is called after a contact is updated. This allows you to inspect a
/// contact before it goes to the solver. If you are careful, you can modify the
/// contact manifold (e.g. disable contact).
/// A copy of the old manifold is provided so that you can detect changes.
/// Note: this is called only for awake bodies.
/// Note: this is called even when the number of contact points is zero.
/// Note: this is not called for sensors.
/// Note: if you set the number of contact points to zero, you will not
/// get an EndContact callback. However, you may get a BeginContact callback
/// the next step.
void GContactListener::PreSolve(b2Contact* contact, const b2Manifold* oldManifold)
{
    B2_NOT_USED(contact);
    B2_NOT_USED(oldManifold);

    notifyObjects(contact, @"presolveContact");        
}

/// This lets you inspect a contact after the solver is finished. This is useful
/// for inspecting impulses.
/// Note: the contact manifold does not include time of impact impulses, which can be
/// arbitrarily large if the sub-step is small. Hence the impulse is provided explicitly
/// in a separate data structure.
/// Note: this is only called for contacts that are touching, solid, and awake.
void GContactListener::PostSolve(b2Contact* contact, const b2ContactImpulse* impulse)
{
    B2_NOT_USED(contact);
    B2_NOT_USED(impulse);
}


