//
//  TabBarViewController.m
//  Jopy
//
//  Created by Edson Teco on 14/01/15.
//  Copyright (c) 2015 gwaya. All rights reserved.
//

#import "TabBarViewController.h"

@interface TabBarViewController ()

@end

@implementation TabBarViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSArray *iconesDoTabBar = @[@[@"icon_pendentes", @"icon_pendentes_select"],
                                @[@"icon_aprovados", @"icon_aprovados_select"],
                                @[@"icon_rejeitados", @"icon_rejeitados_select"],
                                @[@"icon_options", @"icon_options_select"]];

    NSInteger conjuntoDeIcones = 0;
    
    for (UITabBarItem *tabBarItem in self.tabBar.items) {
        
        NSArray *icones = [iconesDoTabBar objectAtIndex:conjuntoDeIcones];
        
        UIImage *unselectedImage = [UIImage imageNamed:icones[0]];
        UIImage *selectedImage = [UIImage imageNamed:icones[1]];
        
        [tabBarItem setImage:[unselectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        [tabBarItem setSelectedImage:[selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];

        conjuntoDeIcones++;
    }
    
}

@end
