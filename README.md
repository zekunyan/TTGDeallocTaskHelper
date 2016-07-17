# TTGDeallocTaskHelper

[![CI Status](http://img.shields.io/travis/zekunyan/TTGDeallocTaskHelper.svg?style=flat)](https://travis-ci.org/zekunyan/TTGDeallocTaskHelper)
[![Version](https://img.shields.io/cocoapods/v/TTGDeallocTaskHelper.svg?style=flat)](http://cocoapods.org/pods/TTGDeallocTaskHelper)
[![License](https://img.shields.io/cocoapods/l/TTGDeallocTaskHelper.svg?style=flat)](http://cocoapods.org/pods/TTGDeallocTaskHelper)
[![Platform](https://img.shields.io/cocoapods/p/TTGDeallocTaskHelper.svg?style=flat)](http://cocoapods.org/pods/TTGDeallocTaskHelper)

## What

TTGDeallocTaskHelper is useful to perform tasks after object dealloc.

## Requirements

iOS 6 and later.

## Installation

TTGDeallocTaskHelper is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "TTGDeallocTaskHelper"
```

## Usage
```
#import "NSObject+TTGDeallocTaskHelper.h"

// Some object
id object;
        
// Add dealloc task
[object ttg_addDeallocTask:^(__unsafe_unretained id object, NSUInteger identifier) {
    // After object dealloc, do you job.
    // ...
}];

// object has been released. And the tasks will be performed.
object = nil;
```


## API
Callback block definition.  

```
typedef void (^TTGDeallocTaskBlock)(__unsafe_unretained id object, NSUInteger identifier);
```

Add dealloc task.
```
/**
 *  Add dealloc task to object.
 *
 *  @param taskBlock The dealloc task
 *
 *  @return The task identifier
 */
- (NSUInteger)ttg_addDeallocTask:(TTGDeallocTaskBlock)taskBlock;
```

Remove specific task by identifier.
```
/**
 *  Remove task by identifier.
 *
 *  @param identifier The task identifier
 *
 *  @return Remove success or not
 */
- (BOOL)ttg_removeDeallocTaskByIdentifier:(NSUInteger)identifier;
```

Remove all dealloc tasks.
```
/**
 *  Remove all dealloc tasks.
 */
- (void)ttg_removeAllDeallocTasks;
```

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Author

zekunyan, zekunyan@163.com

## License

TTGDeallocTaskHelper is available under the MIT license. See the LICENSE file for more info.
