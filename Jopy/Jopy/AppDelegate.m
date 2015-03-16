//
//  AppDelegate.m
//  Jopy
//
//  Created by Edson Teco on 13/11/14.
//  Copyright (c) 2014 gwaya. All rights reserved.
//

#import "AppDelegate.h"
#import "Sessao.h"
#import "LoginViewController.h"
#import "PedidosTableViewController.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

@interface AppDelegate ()

@property (nonatomic, strong) UIStoryboard *storyboard;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Fabric with:@[CrashlyticsKit]];

    [self defineAparencia:application];
    
    // Obtem o Storyboard
    self.storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    // Se o usuário NÃO estiver autenticado
    if (![Sessao usuarioAutenticado]) {
        // Abre o login
        LoginViewController *loginViewController = self.storyboard.instantiateInitialViewController;
        loginViewController.managedObjectContext = self.managedObjectContext;
        self.window.rootViewController = loginViewController;
    }
    // Se o usuário já estiver autenticado
    else {
        // Abre a home
        UITabBarController *tabBarController = [self.storyboard instantiateViewControllerWithIdentifier:@"home"] ;
        [self configuraTabs:tabBarController];
        self.window.rootViewController = tabBarController;
    }
    [self.window makeKeyAndVisible];
    
    // Registro do observer para ser chamado quando o usuário não estiver mais autenticado
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(forcaLogoff:)
                                                 name:WebServiceHelperClienteNaoAutenticadoNotification object:nil];

#if !TARGET_IPHONE_SIMULATOR
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                        UIUserNotificationTypeBadge |
                                                        UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                 categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    else {
        // Register for Push Notifications, if running iOS version < 8
        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                         UIRemoteNotificationTypeAlert |
                                                         UIRemoteNotificationTypeSound)];
    }
#endif
    
    NSDictionary *remoteNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    
    //Accept push notification when app is not open
    if (remoteNotif) {
        [self trataRemoteNotification:application userInfo:remoteNotif];
    }
    
    [self monitoraRede];
    
    return YES;
}

- (void)trataRemoteNotification:(UIApplication *)application userInfo:(NSDictionary *)userInfo
{
    debug(@"%@", userInfo);
    
    // App aberto
    if (application.applicationState == UIApplicationStateActive) {
        
        NSDictionary *notificationDict = [userInfo objectForKey:@"aps"];
        NSString *alertString = [notificationDict objectForKey:@"alert"];
        [Sessao showMessage:alertString title:@"Notificação"];
        [self.webServiceDataModel obtemNovosDados];
    }
    // App foi aberto ao tocar na notificação
    else if (application.applicationState == UIApplicationStateInactive) {
        
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [Sessao definirDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    debug(@"%@", error.description);
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [self trataRemoteNotification:application userInfo:userInfo];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [self saveContext];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    if ([Sessao usuarioAutenticado]) {
        application.applicationIconBadgeNumber = 0;
        
        // Atualiza dados com o servidor remoto
        [self.webServiceDataModel enviaDadosPendentes];
        [self.webServiceDataModel obtemNovosDados];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - get overrides

- (WebServiceDataModel *)webServiceDataModel
{
    if (!_webServiceDataModel) {
        _webServiceDataModel = [[WebServiceDataModel alloc] init];
        _webServiceDataModel.managedObjectContext = self.managedObjectContext;
    }
    return _webServiceDataModel;
}

#pragma mark - public

/**
 *  Método para configurar as tabs do TabBar
 *
 *  @param tabBarController TabBarController que deseja ser configurado
 */
- (void)configuraTabs:(UITabBarController *)tabBarController
{
    // Passa o contexto para as viewControllers filhas
    for (id viewController in tabBarController.viewControllers) {
        if ([viewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navigationController = viewController;
            for (id subViewController in navigationController.viewControllers) {
                if ([subViewController isKindOfClass:[PedidosTableViewController class]]) {
                    [subViewController setManagedObjectContext:self.managedObjectContext];
                }
            }
        }
        else {
            if ([viewController respondsToSelector:@selector(setManagedObjectContext:)])
                [viewController setManagedObjectContext:self.managedObjectContext];
        }
    }
}

/**
 *  Método para realizar logoff e mostrar a tela de login
 */
- (void)abreLogin
{
    dispatch_async(dispatch_get_main_queue(), ^{
        // Abre o login
        LoginViewController *loginViewController = self.storyboard.instantiateInitialViewController;
        loginViewController.managedObjectContext = self.managedObjectContext;
        
        if ([self.window.rootViewController isKindOfClass:[loginViewController class]]) {
            [self.window.rootViewController dismissViewControllerAnimated:YES completion:^{
                self.window.rootViewController = loginViewController;
            }];
        }
        else {
            self.window.rootViewController = loginViewController;
        }
    });
}

/**
 *  Método para retornar o endereço da pasta Documents
 *
 *  @return Endereço da pasta Documents
 */
- (NSURL *)applicationDocumentsDirectory
{
    // The directory the application uses to store the Core Data store file. This code uses a directory named "br.com.gwaya.Jopy" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - private

/**
 *  Método para avisar ao usuário que será forçado a fazer logoff
 *
 *  @param notification Notificação
 */
- (void)forcaLogoff:(NSNotification *)notification
{
    if ([Sessao usuarioAutenticado]) {
        [Pedido removeTodosOsPedidosInManagedObjectContext:self.managedObjectContext];
        [Sessao efetuaLogoff];
        [Sessao showMessage:@"Por favor faça login novamente." title:@"Autenticação" completion:^{
            [self abreLogin];
        }];
    }
}

/**
 *  Método que define globalmente a aparencia dos componentes de UI
 */
- (void)defineAparencia:(UIApplication *)application
{
    self.window.backgroundColor = [UIColor whiteColor];
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    
    // TOOLBAR
    [[UIToolbar appearance] setTintColor:COR_TEXTO];
    [[UIToolbar appearance] setBarTintColor:COR_BARRA];
    
    // NAVIGATIONBAR
    [[UINavigationBar appearance] setTintColor:COR_TEXTO];
    [[UINavigationBar appearance] setBarTintColor:COR_BARRA];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : COR_TEXTO}];
    
    // BARBUTTON
    [[UIBarButtonItem appearance] setTintColor:COR_TEXTO];
//    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSFontAttributeName : DEFAULT_FONT(DEFAULT_FONTSIZE)}
//                                                forState:UIControlStateNormal];
    // TABBAR
    [[UITabBar appearance] setTintColor:COR_TEXTO];
    [[UITabBar appearance] setBarTintColor:COR_BARRA];
//    [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName : DEFAULT_FONT(DEFAULT_FONTSIZE-4)}
//                                             forState:UIControlStateNormal];
    // ALERTVIEW
    [[SIAlertView appearance] setTitleColor:COR_AZUL];
    [[SIAlertView appearance] setTitleFont:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]];
    
    [[SIAlertView appearance] setMessageColor:COR_AZUL];
    [[SIAlertView appearance] setMessageFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
    
    [[SIAlertView appearance] setButtonFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
    [[SIAlertView appearance] setCancelButtonColor:COR_AZUL];
    [[SIAlertView appearance] setButtonColor:COR_VERDE];
    [[SIAlertView appearance] setDestructiveButtonColor:[UIColor whiteColor]];
    
    [[SIAlertView appearance] setCornerRadius:10.0f];
    [[SIAlertView appearance] setViewBackgroundColor:[UIColor colorWithWhite:1 alpha:0.9]];
}

/**
 *  Método para monitorar a Rede e quando muda para WIFI ou 3G, envia os pedidos pendentes
 */
- (void)monitoraRede
{
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable: {
                NSLog(@"No Internet Connection");
            }
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi: {
                NSLog(@"WIFI");
                if ([Sessao usuarioAutenticado]) [self.webServiceDataModel enviaDadosPendentes];
            }
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN: {
                NSLog(@"3G");
            }
                break;
            default:
                NSLog(@"Unkown network status");
                break;
        }
    }];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSManagedObjectModel *)managedObjectModel
{
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Jopy" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Jopy.sqlite"];
    debug(@"%@", [storeURL absoluteString]);
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    NSDictionary *options = @{
                              NSMigratePersistentStoresAutomaticallyOption : @YES,
                              NSInferMappingModelAutomaticallyOption : @YES
                              };
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext
{
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext
{
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
