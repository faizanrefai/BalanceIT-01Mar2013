//
//  MyListener.m
//  StackEM
//
//  Created by YunCholHo on 2/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "MyListener.h"
#import "BodyUserData.h"
#import "StackEMAppDelegate.h"

NSMutableArray* aryContact1;
NSMutableArray* aryContact2;
b2Body* m_pStick;

MyListener::MyListener()
{
	m_bContact = FALSE;
    aryContact1 = [[NSMutableArray alloc] init];
    aryContact2 = [[NSMutableArray alloc] init];
    m_pStick = nil;
}

MyListener::~MyListener()
{
    [aryContact1 release];
    [aryContact2 release];
}

int MyListener::getContactCount() 
{ 
    return [aryContact1 count]; 
}

void MyListener::PreSolve(b2Contact* contact, const b2Manifold* oldManifold)
{
	const b2Manifold* manifold = contact->GetManifold();
    
    if(manifold->pointCount == 0)
    {
        b2Fixture* fixtureA = contact->GetFixtureA();
        b2Fixture* fixtureB = contact->GetFixtureB();
        for (int32 i = 0; i < oldManifold->pointCount; ++i)
        {
            b2Body* body1 = fixtureA->GetBody();
            b2Body* body2 = fixtureB->GetBody();
            
            delContact(body1, body2);
        }
    }
    
	if (manifold->pointCount == 0)
		return;
	
	if (oldManifold->pointCount != 0)
		return;
	[(StackEMAppDelegate*)[UIApplication sharedApplication].delegate playSound:0];
	b2Fixture* fixtureA = contact->GetFixtureA();
	b2Fixture* fixtureB = contact->GetFixtureB();
	
	b2PointState state1[b2_maxManifoldPoints], state2[b2_maxManifoldPoints];
	b2GetPointStates(state1, state2, oldManifold, manifold);
	
	b2WorldManifold worldManifold;
	contact->GetWorldManifold(&worldManifold);
	
//    [aryContact removeAllObjects];
    
	for (int32 i = 0; i < manifold->pointCount; ++i)
	{
		b2Vec2 normal = worldManifold.normal;
		b2Vec2 position = worldManifold.points[i];
		b2PointState pointstate1 = state1[i];
		b2PointState pointstate2 = state2[i];
		b2Body* body1 = fixtureA->GetBody();
		b2Body* body2 = fixtureB->GetBody();
		BodyUserData* data1 = (BodyUserData*)body1->GetUserData();
		BodyUserData* data2 = (BodyUserData*)body2->GetUserData();
		
		if (data1 == NULL || data2 == NULL)
			continue;

		if (pointstate1 == b2_nullState && pointstate2 == b2_addState)
		{
			int nType1 = [data1 bodyType];
			int nType2 = [data2 bodyType];
			if ((nType1 != BT_Static && nType1 != BT_Dynamic) &&
				(nType2 != BT_Static && nType2 != BT_Dynamic))
				continue;
			setContact(TRUE);
		}

        if([data1 bodyType] == BT_Static)
            m_pStick = body1;
		if([data2 bodyType] == BT_Static)
            m_pStick = body2;
    }

	for (int32 i = 0; i < manifold->pointCount; ++i)
	{
		b2Vec2 normal = worldManifold.normal;
		b2Vec2 position = worldManifold.points[i];
		b2Body* body1 = fixtureA->GetBody();
		b2Body* body2 = fixtureB->GetBody();
		BodyUserData* data1 = (BodyUserData*)body1->GetUserData();
		BodyUserData* data2 = (BodyUserData*)body2->GetUserData();
		
		if (data1 == NULL || data2 == NULL)
			continue;
        
        addContact(body1, body2);
    }

//	for (int32 i = 0; i < manifold->pointCount; ++i)
//	{
//		b2Vec2 normal = worldManifold.normal;
//		b2Vec2 position = worldManifold.points[i];
//		b2Body* body1 = fixtureA->GetBody();
//		b2Body* body2 = fixtureB->GetBody();
//		BodyUserData* data1 = (BodyUserData*)body1->GetUserData();
//		BodyUserData* data2 = (BodyUserData*)body2->GetUserData();
//		
//		if (data1 == NULL || data2 == NULL)
//			continue;
//        
//        addContact(body1, body2);
//    }
}

void MyListener::addContact(b2Body* body1, b2Body* body2)
{
    if(m_pStick == nil)
        return;
    
    BOOL    fIsValid = NO;
    if(body1 == m_pStick || body2 == m_pStick)
        fIsValid = YES;
    
    for(unsigned int i = 0; i < [aryContact1 count]; i++)
    {
        if(fIsValid == YES)
            break;
        NSNumber*   n1 = (NSNumber*)[aryContact1 objectAtIndex:i];
        int nBody1 = [n1 intValue];
        b2Body* bodyExist = (b2Body*)nBody1;
        
        if(bodyExist == body1 || bodyExist == body2)
            fIsValid = YES;

        NSNumber*   n2 = (NSNumber*)[aryContact2 objectAtIndex:i];
        int nBody2 = [n2 intValue];
        bodyExist = (b2Body*)nBody2;

        if(bodyExist == body1 || bodyExist == body2)
            fIsValid = YES;
    }
    
    if(fIsValid == NO)
        return;
    
    for(unsigned int i = 0; i < [aryContact1 count]; i++)
    {
        NSNumber*   n1 = (NSNumber*)[aryContact1 objectAtIndex:i];
        int nBody1 = [n1 intValue];
        b2Body* bodyExist1 = (b2Body*)nBody1;
        
        NSNumber*   n2 = (NSNumber*)[aryContact2 objectAtIndex:i];
        int nBody2 = [n2 intValue];
        b2Body* bodyExist2 = (b2Body*)nBody2;
        
        if(((bodyExist1 == body1) && (bodyExist2 == body2)) ||
           ((bodyExist2 == body1) && (bodyExist1 == body2)))
            return;
    }

    int nBody1 = (int)body1;
    [aryContact1 addObject:[[NSNumber alloc]initWithInt:nBody1]];
    int nBody2 = (int)body2;
    [aryContact2 addObject:[[NSNumber alloc]initWithInt:nBody2]];
//    addContact(body1);
//    addContact(body2);
}

void MyListener::delContact(b2Body* body1, b2Body* body2)
{
    if(m_pStick == nil)
        return;
    
    for(unsigned int i = 0; i < [aryContact1 count]; i++)
    {
        NSNumber*   n1 = (NSNumber*)[aryContact1 objectAtIndex:i];
        int nBody1 = [n1 intValue];
        b2Body* bodyExist1 = (b2Body*)nBody1;
        
        NSNumber*   n2 = (NSNumber*)[aryContact2 objectAtIndex:i];
        int nBody2 = [n2 intValue];
        b2Body* bodyExist2 = (b2Body*)nBody2;
        
        if(((bodyExist1 == body1) && (bodyExist2 == body2)) ||
           ((bodyExist2 == body1) && (bodyExist1 == body2)))
        {
            [aryContact1 removeObjectAtIndex:i];
            [aryContact2 removeObjectAtIndex:i];
        }
    }
}

void MyListener::addContact(b2Body* body)
{
//    if(body == m_pStick)
//        return;
//    
//    for(unsigned int i = 0; i < [aryContact count]; i++)
//    {
//        NSNumber*   n = (NSNumber*)[aryContact objectAtIndex:i];
//        int nBody = [n intValue];
//        b2Body* bodyExist = (b2Body*)nBody;
//        if(bodyExist == body)
//            return;
//    }
//    
//    int nBody = (int)body;
//    [aryContact addObject:[[NSNumber alloc]initWithInt:nBody]];
}

void MyListener::PostSolve(b2Contact* contact, const b2ContactImpulse* impulse)
{
   B2_NOT_USED(contact);
   B2_NOT_USED(impulse);
}
						   
////////////////////////////////////////////////////////////////////
/// class DestructionListener
////////////////////////////////////////////////////////////////////

void DestructionListener::SayGoodbye(b2Joint* joint)
{
}