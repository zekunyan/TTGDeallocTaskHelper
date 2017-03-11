//
//  NSObject+TTGDeallocTaskHelper.m
//  TTGDeallocTaskHelper
//
//  Created by tutuge on 16/7/16.
//  Copyright © 2016年 tutuge. All rights reserved.
//

#import "NSObject+TTGDeallocTaskHelper.h"
#include <libkern/OSAtomic.h>
#import <pthread.h>
#import <objc/runtime.h>

static const char TTGDeallocTaskModelKey; // Associated object key
const NSUInteger TTGDeallocTaskIllegalIdentifier = 0; // illegal identifier

/**
 *  Private model
 */
@interface TTGDeallocTaskModel : NSObject
@property (nonatomic, assign) pthread_mutex_t lock;
@property (nonatomic, strong) NSMutableDictionary *tasksDict;
@property (nonatomic, unsafe_unretained) id target;
@end

@implementation TTGDeallocTaskModel

- (instancetype)initWithTarget:(id)target {
    self = [super init];
    if (self) {
        _target = target;
        pthread_mutex_init(&_lock, NULL);
        _tasksDict = [NSMutableDictionary new];
    }
    return self;
}

- (NSUInteger)addTask:(TTGDeallocTaskBlock)taskBlock {
    // Global increase identifier
    static volatile NSUInteger globalIdentifier = 0;
    
    if (!taskBlock) {
        return TTGDeallocTaskIllegalIdentifier;
    }
    
    NSUInteger newIdentifier = OSAtomicIncrement64(&globalIdentifier);
    NSNumber *newIdentifierNumber = @(newIdentifier);
    
    if (newIdentifierNumber) {
        pthread_mutex_lock(&_lock);
        [_tasksDict setObject:[taskBlock copy] forKey:newIdentifierNumber];
        pthread_mutex_unlock(&_lock);
        return newIdentifier;
    } else {
        return TTGDeallocTaskIllegalIdentifier;
    }
}

- (BOOL)removeTaskWithIdentifier:(NSUInteger)identifier {
    if (identifier == TTGDeallocTaskIllegalIdentifier) {
        return NO;
    }
    
    NSNumber *identifierNumber = [NSNumber numberWithUnsignedInteger:identifier];
    if (identifierNumber) {
        pthread_mutex_lock(&_lock);
        [_tasksDict removeObjectForKey:identifierNumber];
        pthread_mutex_unlock(&_lock);
        return YES;
    } else {
        return NO;
    }
}

- (void)removeAllTask {
    pthread_mutex_lock(&_lock);
    [_tasksDict removeAllObjects];
    pthread_mutex_unlock(&_lock);
}

- (void)dealloc {
    [_tasksDict enumerateKeysAndObjectsUsingBlock:^(NSNumber *identifier, TTGDeallocTaskBlock block, BOOL * _Nonnull stop) {
        block(_target, identifier.unsignedIntegerValue);
    }];
    pthread_mutex_destroy(&_lock);
}

@end

@implementation NSObject (TTGDeallocTaskHelper)

- (NSUInteger)ttg_addDeallocTask:(TTGDeallocTaskBlock)taskBlock {
    if (!taskBlock) {
        return TTGDeallocTaskIllegalIdentifier;
    }
    
    TTGDeallocTaskModel *model = nil;
    
    @synchronized (self) {
        model = objc_getAssociatedObject(self, &TTGDeallocTaskModelKey);
        if (!model) {
            model = [[TTGDeallocTaskModel alloc] initWithTarget:self];
            objc_setAssociatedObject(self, &TTGDeallocTaskModelKey, model, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    
    NSUInteger newIdentifier = [model addTask:taskBlock];
    
    return newIdentifier;
}

- (BOOL)ttg_removeDeallocTaskByIdentifier:(NSUInteger)identifier {
    TTGDeallocTaskModel *model = objc_getAssociatedObject(self, &TTGDeallocTaskModelKey);
    if (model) {
        return [model removeTaskWithIdentifier:identifier];
    } else {
        return NO;
    }
}

- (void)ttg_removeAllDeallocTasks {
    TTGDeallocTaskModel *model = objc_getAssociatedObject(self, &TTGDeallocTaskModelKey);
    if (model) {
        [model removeAllTask];
    }
}

@end
