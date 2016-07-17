//
//  TTGViewController.m
//  TTGDeallocTaskHelper
//
//  Created by zekunyan on 07/17/2016.
//  Copyright (c) 2016 zekunyan. All rights reserved.
//

#import "TTGViewController.h"
#import "NSObject+TTGDeallocTaskHelper.h"

@interface TTGViewController ()
@property (weak, nonatomic) IBOutlet UITextView *infoTextView;
@end

@implementation TTGViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (IBAction)runDemo:(id)sender {
    [self showInfo:@"-----------------------------------"];

    // Force object release
    @autoreleasepool {
        id object = [NSObject new];
        
        // Add task
        NSUInteger identifier1 = [object ttg_addDeallocTask:^(__unsafe_unretained id object, NSUInteger identifier) {
            [self showInfo:[NSString stringWithFormat:@"Object: %@ dealloc. Task: %ld", object, (unsigned long)identifier]];
        }];
        [self showInfo:[NSString stringWithFormat:@"Dealloc task %ld create.", (unsigned long)identifier1]];
        
        // Add task
        NSUInteger identifier2 = [object ttg_addDeallocTask:^(__unsafe_unretained id object, NSUInteger identifier) {
            [self showInfo:[NSString stringWithFormat:@"Object: %@ dealloc. Task: %ld", object, (unsigned long)identifier]];
        }];
        [self showInfo:[NSString stringWithFormat:@"Dealloc task %ld create.", (unsigned long)identifier2]];
        
        // Add task
        NSUInteger identifier3 = [object ttg_addDeallocTask:^(__unsafe_unretained id object, NSUInteger identifier) {
            [self showInfo:[NSString stringWithFormat:@"Object: %@ dealloc. Task: %ld", object, (unsigned long)identifier]];
        }];
        [self showInfo:[NSString stringWithFormat:@"Dealloc task %ld create.", (unsigned long)identifier3]];
        
        // Remove task
        [self showInfo:[NSString stringWithFormat:@"Remove task: %ld", (unsigned long)identifier1]];
        [object ttg_removeDeallocTaskByIdentifier:identifier1];
    }
}

- (void)showInfo:(NSString *)info {
    _infoTextView.text = [NSString stringWithFormat:@"%@\n%@", _infoTextView.text, info];
    [_infoTextView scrollRangeToVisible:NSMakeRange(_infoTextView.text.length - 1, 0)];
}

@end
