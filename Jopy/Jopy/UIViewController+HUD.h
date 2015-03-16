//
//  UIViewController+HUD.h
//  Transparencia
//
//  Created by Edson Teco on 12/07/14.
//  Copyright (c) 2014 Transparenciapp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface UIViewController (HUD) 

- (MBProgressHUD *)hud;
- (void)mostraHudComTexto:(NSString *)texto;
- (void)mostraHudComTexto:(NSString *)texto eEscondeDepoisDe:(CGFloat)delay;
- (void)mostraHudComProgresso:(CGFloat)progresso texto:(NSString *)texto;
- (void)defineTextoNoHud:(NSString *)texto;
- (void)escondeHud;
- (void)escondeHudComTexto:(NSString *)texto;

@end
