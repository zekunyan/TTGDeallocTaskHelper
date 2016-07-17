//
//  NSObject+TTGDeallocTaskHelper.h
//  TTGDeallocTaskHelper
//
//  Created by tutuge on 16/7/16.
//  Copyright © 2016年 tutuge. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 *  Dealloc task block definition.
 *
 *  @param target     the host object
 *  @param identifier task identifier
 */
typedef void (^TTGDeallocTaskBlock)(__unsafe_unretained id object, NSUInteger identifier);

/**
 *  illegal identifier.
 */
extern NSUInteger TTGDeallocTaskIllegalIdentifier;

@interface NSObject (TTGDeallocTaskHelper)

/**
 *  Add dealloc task to object.
 *
 *  @param taskBlock The dealloc task
 *
 *  @return The task identifier
 */
- (NSUInteger)ttg_addDeallocTask:(TTGDeallocTaskBlock)taskBlock;

/**
 *  Remove task by identifier.
 *
 *  @param identifier The task identifier
 *
 *  @return Remove success or not
 */
- (BOOL)ttg_removeDeallocTaskByIdentifier:(NSUInteger)identifier;


/**
 *  Remove all dealloc tasks.
 */
- (void)ttg_removeAllDeallocTasks;

@end
