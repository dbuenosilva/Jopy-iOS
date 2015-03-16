//
//  AppDelegate.h
//  Jopy
//
//  Created by Edson Teco on 13/11/14.
//  Copyright (c) 2014 gwaya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "WebServiceDataModel.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) WebServiceDataModel *webServiceDataModel;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (void)configuraTabs:(UITabBarController *)tabBarController;
- (void)abreLogin;

@end

