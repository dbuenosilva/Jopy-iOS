//
//  Sessao.h
//  Jopy
//
//  Created by Edson Teco on 13/11/14.
//  Copyright (c) 2014 gwaya. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kKEY_SESSAO_LOGIN @"br.com.gwaya.sessao.login"
#define kKEY_SESSAO_ACCESS_TOKEN @"br.com.gwaya.sessao.accessToken"
#define kKEY_SESSAO_TOKEN_TYPE @"br.com.gwaya.sessao.tokenType"
#define kKEY_SESSAO_DATA_HORA_ULTIMO_ACESSO_SERVIDOR @"br.com.gwaya.sessao.dataHoraUltimoAcessoAoServidor"
#define kKEY_SESSAO_DEVICE_TOKEN @"br.com.gwaya.sessao.deviceToken"

FOUNDATION_EXPORT NSString * const SessaoInformacoesSalvasNotification;

@interface Sessao : NSObject

+ (NSString *)login;
+ (NSString *)accessToken;
+ (NSString *)tokenType;
+ (NSString *)dataHoraUltimoAcessoAoServidor;
+ (NSString *)deviceToken;

+ (void)definirLogin:(NSString *)login;
+ (void)definirAccessToken:(NSString *)accessToken;
+ (void)definirTokenType:(NSString *)tokenType;
+ (void)definirDataHoraUltimoAcessoAoServidor:(NSDate *)dataHoraUltimoAcessoAoServidor;
+ (void)definirDeviceToken:(NSData *)deviceToken;

+ (void)showMessage:(NSString *)message;
+ (void)showMessage:(NSString *)message title:(NSString *)title;
+ (void)showMessage:(NSString *)message title:(NSString *)title completion:(void (^)())completion;

+ (void)efetuaLogin:(NSString *)login senha:(NSString *)senha completion:(void (^)(bool sucesso, NSString *mensagem))completion;
+ (void)efetuaLogoff;
+ (BOOL)usuarioAutenticado;
+ (void)recuperaSenha:(NSString *)login completion:(void (^)(bool sucesso, NSString *mensagem))completion;

@end
