//
//  Sessao.m
//  Jopy
//
//  Created by Edson Teco on 13/11/14.
//  Copyright (c) 2014 gwaya. All rights reserved.
//

#import "Sessao.h"

NSString * const SessaoInformacoesSalvasNotification = @"br.com.gwaya.SessaoInformacoesSalvasNotification";

@implementation Sessao

#pragma mark -
#pragma mark Metodos publicos

/**
 *  Método para retornar o último login do usuário salvo anteriormente
 *
 *  @return login do usuário
 */
+ (NSString *)login
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kKEY_SESSAO_LOGIN];
}
/**
 *  Método para salvar o login do usuário
 *
 *  @param login Login do usuário
 */
+ (void)definirLogin:(NSString *)login
{
    [Sessao salvar:login comAChave:kKEY_SESSAO_LOGIN];
}

/**
 *  Método para retornar o token de login obtido ao realizar a autenticação
 *
 *  @return token de login
 */
+ (NSString *)accessToken
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kKEY_SESSAO_ACCESS_TOKEN];
}
/**
 *  Método para salvar o token de login obtido ao realizar a autenticação
 *
 *  @param tokenLogin Token de Login
 */
+ (void)definirAccessToken:(NSString *)accessToken
{
    [Sessao salvar:accessToken comAChave:kKEY_SESSAO_ACCESS_TOKEN];
}

/**
 *  Método para retornar o tipo do token obtido ao realizar a autenticação
 *
 *  @return tipo do token
 */
+ (NSString *)tokenType
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kKEY_SESSAO_TOKEN_TYPE];
}
/**
 *  Método para salvar o tipo do token obtido ao realizar a autenticação
 *
 *  @param tokenType Tipo do token
 */
+ (void)definirTokenType:(NSString *)tokenType
{
    [Sessao salvar:tokenType comAChave:kKEY_SESSAO_TOKEN_TYPE];
}

/**
 *  Método para retornar a data e hora do último acesso ao servidor
 *
 *  @return Data e hora já formatados
 */
+ (NSString *)dataHoraUltimoAcessoAoServidor
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd/MM/yyyy hh:mm"];
    
    NSDate *dataHora = [[NSUserDefaults standardUserDefaults] objectForKey:kKEY_SESSAO_DATA_HORA_ULTIMO_ACESSO_SERVIDOR];
    return [dateFormat stringFromDate:dataHora];
}
/**
 *  Método para salvar a data e hora do último acesso ao servidor
 *
 *  @param dataHoraUltimoAcessoAoServidor Data e hora (NSDate)
 */
+ (void)definirDataHoraUltimoAcessoAoServidor:(NSDate *)dataHoraUltimoAcessoAoServidor
{
    [Sessao salvar:dataHoraUltimoAcessoAoServidor comAChave:kKEY_SESSAO_DATA_HORA_ULTIMO_ACESSO_SERVIDOR];
}

/**
 *  Método para retornar o token para push notifications
 *
 *  @return Device Token
 */
+ (NSString *)deviceToken
{
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:kKEY_SESSAO_DEVICE_TOKEN];
    return (token)?token:@"";
}
/**
 *  Método para salvar o token para push notifications
 *
 *  @param deviceToken Device Token que o APNS retorna em formato NSData
 */
+ (void)definirDeviceToken:(NSData *)deviceToken
{
    NSString *deviceKey = [[[[deviceToken description]
                             stringByReplacingOccurrencesOfString:@"<"withString:@""]
                            stringByReplacingOccurrencesOfString:@">" withString:@""]
                           stringByReplacingOccurrencesOfString: @" " withString: @""];
    [Sessao salvar:deviceKey comAChave:kKEY_SESSAO_DEVICE_TOKEN];
}

/**
 *  Método para apresentar um Alert ao usuário com um botão OK
 *
 *  @param message Mensagem que deseja ser apresentada
 */
+ (void)showMessage:(NSString *)message
{
    [Sessao showMessage:message title:@"Jopy"];
}

/**
 *  Método para apresentar um Alert ao usuário com um botão OK
 *
 *  @param message Mensagem que deseja ser apresentada
 *  @param title   Título do Alert
 */
+ (void)showMessage:(NSString *)message title:(NSString *)title
{
    [Sessao showMessage:message title:title completion:nil];
}

/**
 *  Método para apresentar um Alert ao usuário com um botão OK
 *
 *  @param message    Mensagem que deseja ser apresentada
 *  @param title      Título do Alert
 *  @param completion Bloco para ser executado ao pressionar OK
 */
+ (void)showMessage:(NSString *)message title:(NSString *)title completion:(void (^)())completion
{
    dispatch_async(dispatch_get_main_queue(), ^(void){
        SIAlertView *alert = [[SIAlertView alloc] initWithTitle:title andMessage:message];
        [alert addButtonWithTitle:@"Ok"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alert) {
                              if (completion) completion();
                          }];
        alert.transitionStyle = SIAlertViewTransitionStyleFade;
        [alert show];
    });
}

/**
 *  Método que efetua o login do usuário no servidor remoto e obtem o token de login
 *
 *  @param usuario    Nome de usuário para login
 *  @param senha      Senha
 *  @param completion Bloco para ser executado ao final da execução deste método
 */
+ (void)efetuaLogin:(NSString *)login senha:(NSString *)senha completion:(void (^)(bool sucesso, NSString *mensagem))completion
{
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *deviceType = [[UIDevice currentDevice] model];
    NSString *osVersion = [[UIDevice currentDevice] systemVersion];
    
    NSDictionary *dadosParaLogin = @{
                                     kKEY_API_AUTENTICACAO_POST_USERNAME : login,
                                     kKEY_API_AUTENTICACAO_POST_PASSWORD : senha,
                                     
                                     kKEY_API_REGISTRO_POST_DEVICE_TYPE : deviceType,
                                     kKEY_API_REGISTRO_POST_DEVICE_KEY : [Sessao deviceToken],
                                     kKEY_API_REGISTRO_POST_OS_TYPE : @"ios",
                                     kKEY_API_REGISTRO_POST_OS_VERSION : osVersion,
                                     kKEY_API_REGISTRO_POST_APP_VERSION :  appVersion
                                     };
    
    [[WebServiceHelper sharedClient].requestSerializer setValue:@"" forHTTPHeaderField:kKEY_API_HEADER];
    [[WebServiceHelper sharedClient]
     POST:kKEY_API_AUTENTICACAO_POST
     parameters:dadosParaLogin
     success:^(NSURLSessionDataTask *task, id responseObject) {
         
         NSString *mensagemRetorno = [WebServiceHelper trataErroHTTP:(NSHTTPURLResponse *)task.response error:nil];
         if (mensagemRetorno.length == 0) {
             if ([responseObject isKindOfClass:[NSDictionary class]]) {
                 // salva as informações de login para uso da API
                 [Sessao salvaInformacoesDeLogin:login resposta:(NSDictionary *)responseObject];
                 completion(YES, nil);
             }
             else {
                 completion(NO, @"Não foi possível obter resposta do servidor.");
             }
         }
         else {
             completion(NO, mensagemRetorno);
         }
         
    } failure:^(NSURLSessionDataTask *task, NSError *error) {

        completion(NO, [WebServiceHelper trataErroHTTP:(NSHTTPURLResponse *)task.response error:error]);
        
    }];
}

/**
 *  Método que efetua logoff do usuário
 */
+ (void)efetuaLogoff
{
    NSString *authorization = [NSString stringWithFormat:@"%@ %@", [Sessao tokenType], [Sessao accessToken]];
    
    [[WebServiceHelper sharedClient].requestSerializer setValue:authorization forHTTPHeaderField:kKEY_API_HEADER];
    [[WebServiceHelper sharedClient]
     GET:kKEY_API_LOGOUT_GET
     parameters:nil
     success:^(NSURLSessionDataTask *task, id responseObject) {
         
         [Sessao apagaInformacoesDeLogin];
         
     } failure:^(NSURLSessionDataTask *task, NSError *error) {
         
         debug(@"Falha ao tentar realizar logoff");
         [Sessao apagaInformacoesDeLogin];
         
     }];
}

/**
 *  Método que retorna YES ou NO se o usuário está logado
 *
 *  @return YES para logado, NO para não logado
 */
+ (BOOL)usuarioAutenticado
{
    NSString *token = [Sessao accessToken];
//    debug(@"Authorization: %@ %@", [Sessao tokenType], [Sessao accessToken]);
    return (token.length > 0);
}

/**
 *  Método que inicia o processo para o usuário recuperar a senha
 *
 *  @param login      Login do usuário que pretende recuperar a senha
 *  @param completion Bloco para ser executado ao final da execução deste método
 */
+ (void)recuperaSenha:(NSString *)login completion:(void (^)(bool sucesso, NSString *mensagem))completion
{
    NSDictionary *dadosParaRecuperarSenha = @{ kKEY_API_RECUPERA_SENHA_USERNAME : login };
    
    [[WebServiceHelper sharedClient].requestSerializer setValue:@"" forHTTPHeaderField:kKEY_API_HEADER];
    [[WebServiceHelper sharedClient]
     POST:kKEY_API_RECUPERA_SENHA_POST
     parameters:dadosParaRecuperarSenha
     success:^(NSURLSessionDataTask *task, id responseObject) {
         
         NSString *mensagemRetorno = [WebServiceHelper trataErroHTTP:(NSHTTPURLResponse *)task.response error:nil];
         if (mensagemRetorno.length == 0) {
             if ([responseObject isKindOfClass:[NSDictionary class]]) {
                 [WebServiceHelper trataRespostaAPI:responseObject completion:^(bool sucesso, id retorno, NSString *mensagem) {
                     completion(sucesso, mensagem);
                 }];
             }
             else {
                 completion(NO, @"Não foi possível obter resposta do servidor.");
             }
         }
         else {
             completion(NO, mensagemRetorno);
         }
         
     } failure:^(NSURLSessionDataTask *task, NSError *error) {
         
         completion(NO, [WebServiceHelper trataErroHTTP:(NSHTTPURLResponse *)task.response error:error]);
         
     }];
}

#pragma mark -
#pragma mark Metodos privados

/**
 *  Método privado para salvar as informações de login
 *
 *  @param dadosDeLogin Retorno JSON da API após realizar login
 */
+ (void)salvaInformacoesDeLogin:(NSString *)login resposta:(NSDictionary *)dadosDeLogin
{
    [Sessao definirAccessToken:dadosDeLogin[kKEY_API_AUTENTICACAO_RESPONSE_ACCESS_TOKEN]];
    [Sessao definirTokenType:dadosDeLogin[kKEY_API_AUTENTICACAO_RESPONSE_TOKEN_TYPE]];
}

/**
 *  Método privado para limpar as informações de login
 */
+ (void)apagaInformacoesDeLogin
{
    [Sessao definirAccessToken:nil];
    [Sessao definirTokenType:nil];
}

/**
 *  Salva no NSUserDefaults
 *
 *  @param dado  Informacao a ser salva
 *  @param chave Chave a ser usada para este dado
 */
+ (void)salvar:(id)dado comAChave:(NSString *)chave
{
    if ([dado isKindOfClass:[NSNull class]]) return;
    
    [[NSUserDefaults standardUserDefaults] setObject:dado forKey:chave];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self notificaGravacaoDeDados:chave];
}

/**
 *  Salva valor Boolean no NSUserDefaults
 *
 *  @param dado  Informacao BOOL a ser salva
 *  @param chave Chave a ser usada para este dado
 */
+ (void)salvarBool:(BOOL)dado comAChave:(NSString *)chave
{
    [[NSUserDefaults standardUserDefaults] setBool:dado forKey:chave];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self notificaGravacaoDeDados:chave];
}

#pragma mark -
#pragma mark Notification center

/**
 *  Notifica que o default foi salvo
 */
+ (void)notificaGravacaoDeDados:(NSString *)chave
{
    NSDictionary *userInfo = @{@"chave" : chave};
    NSNotification *note = [NSNotification notificationWithName:SessaoInformacoesSalvasNotification object:nil userInfo:userInfo];
    [[NSNotificationCenter defaultCenter] postNotification:note];
}

@end
