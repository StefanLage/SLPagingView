//
//  ChatController.m
//  TestStoryboard
//
//  Created by Stefan Lage on 12/01/15.
//  Copyright (c) 2015 Stefan Lage. All rights reserved.
//

#import "ChatController.h"

@interface ChatController ()

@property (nonatomic, strong) UIImageView* titleView;

@end

@implementation ChatController

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        
        UIImage *logo = [UIImage imageNamed:@"chat"];
        logo = [logo imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _titleView = [[UIImageView alloc] initWithImage:logo];
        self.navigationItem.titleView = _titleView;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage *logo = [UIImage imageNamed:@"chat"];
    logo = [logo imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _titleView = [[UIImageView alloc] initWithImage:logo];
    self.navigationItem.titleView = self.titleView;
    // Do any additional setup after loading the view, typically from a nib.
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
