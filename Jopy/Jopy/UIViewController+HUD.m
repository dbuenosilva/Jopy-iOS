//
//  UIViewController+HUD.m
//  Transparencia
//
//  Created by Edson Teco on 12/07/14.
//  Copyright (c) 2014 Transparenciapp. All rights reserved.
//

#import "UIViewController+HUD.h"

@implementation UIViewController (HUD)

MBProgressHUD *_hud;

- (MBProgressHUD *)hud
{
    if (!_hud) {
        _hud = [[MBProgressHUD alloc] initWithView:self.view];
        _hud.minShowTime = 0.5;
//        _hud.labelFont = DEFAULT_FONT(DEFAULT_FONTSIZE);
//        _hud.labelColor = DEFAULT_TINTCOLOR;
        [_hud setDimBackground:NO];
        [_hud setColor:[UIColor colorWithWhite:0.0f alpha:0.8f]];
        
        _hud.removeFromSuperViewOnHide = YES;
    }
    _hud.mode = MBProgressHUDModeIndeterminate;
    return _hud;
}

- (void)mostraHudComTexto:(NSString *)texto
{
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [self hud];
        [self.view addSubview:hud];
        hud.labelText = texto;
        [hud show:YES];
    });
}

- (void)mostraHudComProgresso:(CGFloat)progresso texto:(NSString *)texto
{
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [self hud];
        [self.view addSubview:hud];
        hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
        hud.labelText = texto;
        hud.progress = progresso;
        [hud show:YES];
    });
}

- (void)mostraHudComTexto:(NSString *)texto eEscondeDepoisDe:(CGFloat)delay
{
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [self hud];
        [self.view addSubview:hud];
        hud.labelText = texto;
        hud.mode = MBProgressHUDModeText;
        [hud show:YES];
        [hud hide:YES afterDelay:delay];
    });
}

- (void)defineTextoNoHud:(NSString *)texto
{
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [self hud];
        hud.labelText = texto;
    });
}

- (void)escondeHudComTexto:(NSString *)texto
{
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [self hud];
        hud.labelText = texto;
        hud.mode = MBProgressHUDModeText;
        [hud hide:YES afterDelay:3.0f];
    });
}

- (void)escondeHud
{
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [self hud];
        [hud hide:YES];
        [hud removeFromSuperview];
    });
}



@end
