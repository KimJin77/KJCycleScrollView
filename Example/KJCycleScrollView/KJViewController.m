//
//  KJViewController.m
//  KJCycleScrollView
//
//  Created by KimJin77 on 07/15/2017.
//  Copyright (c) 2017 KimJin77. All rights reserved.
//

#import "KJViewController.h"
#import <KJCycleScrollView/KJCycleScrollView.h>


@interface KJViewController ()

@end

@implementation KJViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:5];
    for (int i = 0; i < 5; i++) {
        KJCycleModel *model = [[KJCycleModel alloc] init];
        model.imageName = [NSString stringWithFormat:@"%d", i+1];
        model.tapHandler = ^{
            NSLog(@"Do something");
        };
        [arr addObject:model];
    }
    
    KJCycleView *view = [[KJCycleView alloc] initWithFrame:self.view.bounds];
    view.dataSource = arr;
    [self.view addSubview:view];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
