//
//  MyListener.h
//  StackEM
//
//  Created by YunCholHo on 2/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#ifndef _MYLISTENER_H_
#define _MYLISTENER_H_

#import <UIKit/UIKit.h>
#include <Box2D/Box2D.h>
#include "GLES-Render.h"

const int32 k_maxContactPoints = 2048;

class MyListener : public b2ContactListener
{
public:
	MyListener();
	virtual ~MyListener();
	
	virtual void PreSolve(b2Contact* contact, const b2Manifold* oldManifold);
	virtual void PostSolve(b2Contact* contact, const b2ContactImpulse* impulse);
//	{
//		B2_NOT_USED(contact);
//		B2_NOT_USED(impulse);
//	}
	
	BOOL	isContact() { return m_bContact; }
	void	setContact(BOOL bContact) { m_bContact = bContact; }
    int     getContactCount();
	
protected:
	BOOL	m_bContact;
    void    addContact(b2Body* body1, b2Body* body2);
    void    addContact(b2Body* body);
    void    delContact(b2Body* body1, b2Body* body2);
	
};

class DestructionListener : public b2DestructionListener {
public:
	void SayGoodbye(b2Fixture* fixture) { B2_NOT_USED(fixture); }
	void SayGoodbye(b2Joint* joint);
};

#endif // _MYLISTENER_H_
