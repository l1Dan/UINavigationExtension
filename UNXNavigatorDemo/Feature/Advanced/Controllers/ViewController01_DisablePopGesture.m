//
//  ViewController01_DisablePopGesture.m
//  UNXNavigatorDemo
//
//  Created by Leo Lee on 2020/10/26.
//

#import <UNXNavigator/UNXNavigator.h>

#import "ViewController01_DisablePopGesture.h"

@interface ViewController01_DisablePopGesture ()

@end

@implementation ViewController01_DisablePopGesture

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (BOOL)unx_disableInteractivePopGesture {
    return YES;
}

@end