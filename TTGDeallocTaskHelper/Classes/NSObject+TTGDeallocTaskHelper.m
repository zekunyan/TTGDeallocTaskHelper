//
//  NSObject+TTGDeallocTaskHelper.m
//  TTGDeallocTaskHelper
//
//  Created by tutuge on 16/7/16.
//  Copyright © 2016年 tutuge. All rights reserved.
//

#import "NSObject+TTGDeallocTaskHelper.h"
#import <pthread.h>
#import <objc/runtime.h>

static char TTGDeallocTaskModelKey;
static NSUInteger TTGIdentifierIncrement = 0;
static pthread_mutex_t TTGDeallocTaskIdentifierLock;
NSUInteger TTGDeallocTaskIllegalIdentifier = 0;

/**
 *  Private model
 */
@interface TTGDeallocTaskModel : NSObject {
    pthread_mutex_t _lock;
    CFMutableDictionaryRef _tasksDict;
}
@property (nonatomic, unsafe_unretained) id target;
@end

@implementation TTGDeallocTaskModel

- (instancetype)initWithTarget:(id)target {
    self = [super init];
    if (self) {
        _target = target;
        pthread_mutex_init(&_lock, NULL);
        _tasksDict = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    }
    return self;
}

- (NSUInteger)addTask:(TTGDeallocTaskBlock)taskBlock {
    if (!taskBlock) {
        return TTGDeallocTaskIllegalIdentifier;
    }
    
    pthread_mutex_lock(&TTGDeallocTaskIdentifierLock);
    NSNumber *newIdentifier = [NSNumber numberWithUnsignedInteger:++TTGIdentifierIncrement];
    pthread_mutex_unlock(&TTGDeallocTaskIdentifierLock);
    
    if (newIdentifier) {
        pthread_mutex_lock(&_lock);
        CFDictionarySetValue(_tasksDict, (__bridge const void*)newIdentifier, (__bridge const void*)[taskBlock copy]);
        pthread_mutex_unlock(&_lock);
        return TTGIdentifierIncrement;
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
        CFDictionaryRemoveValue(_tasksDict, (__bridge const void*)identifierNumber);
        pthread_mutex_unlock(&_lock);
        return YES;
    } else {
        return NO;
    }
}

- (void)removeAllTask {
    CFDictionaryRemoveAllValues(_tasksDict);
}

- (void)dealloc {
    [(__bridge NSDictionary *)_tasksDict enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull identifier, TTGDeallocTaskBlock _Nonnull block, BOOL * _Nonnull stop) {
        block(_target, identifier.unsignedIntegerValue);
    }];
    pthread_mutex_destroy(&_lock);
    CFRelease(_tasksDict);
}

@end

@implementation NSObject (TTGDeallocTaskHelper)

+ (void)load {
    pthread_mutex_init(&TTGDeallocTaskIdentifierLock, NULL);
}

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
