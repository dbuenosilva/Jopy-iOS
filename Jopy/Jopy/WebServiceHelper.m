//
//  WebServiceHelper.m
//  Jopy
//
//  Created by Edson Teco on 13/11/14.
//  Copyright (c) 2014 gwaya. All rights reserved.
//

#import "WebServiceHelper.h"

NSString * const WebServiceHelperServicoIndisponivelNotification = @"br.com.gwaya.WebServiceHelperServicoIndisponivelNotification";
NSString * const WebServiceHelperClienteNaoAutenticadoNotification = @"br.com.gwaya.WebServiceHelperClienteNaoAutenticadoNotification";
NSString * const WebServiceHelperTimeOutNotification = @"br.com.gwaya.WebServiceHelperTimeOutNotification";

@implementation WebServiceHelper

+ (instancetype)sharedClient
{
    static WebServiceHelper *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *url = API_URL_BASE;
        _sharedClient = [[WebServiceHelper alloc] initWithBaseURL:[NSURL URLWithString:url]];
    });
    return _sharedClient;
}

/**
 *  Método para verificar se o retorno do JSON é NSNull e converte para nil
 *
 *  @param valor valor a ser verificado
 *
 *  @return Retorna o mesmo valor ou nil se for NSNull
 */
+ (id)trataValor:(id)valor
{
    return ([valor isKindOfClass:[NSNull class]]) ? nil : valor;
}

/**
 *  Método para interpretar a resposta da API
 *
 *  @param responseObject Objeto de resposta vindo do servidor
 *  @param completion     completion com resultado
 */
+ (void)trataRespostaAPI:(id)responseObject completion:(void (^)(bool sucesso, id retorno, NSString *mensagem))completion
{
    if ([responseObject isKindOfClass:[NSDictionary class]]) {
        NSDictionary *retorno = [NSDictionary dictionaryWithDictionary:responseObject];
        if ([retorno objectForKey:kKEY_API_RESPONSE_STATUS] == [NSNumber numberWithBool:YES]) {
            id ret = [retorno objectForKey:kKEY_API_RESPONSE_PEDIDO];
            id msg = [retorno objectForKey:kKEY_API_RESPONSE_MENSAGEM];
            if (![msg isKindOfClass:[NSString class]]) {
                msg = nil;
            }
            completion(YES, ret, msg);
        }
        else {
            id msg = [retorno objectForKey:kKEY_API_RESPONSE_MENSAGEM];
            if (![msg isKindOfClass:[NSString class]]) {
                msg = nil;
            }
            completion(NO, nil, msg);
        }
    }
}

/**
 *  Método para tratar o erro HTTP e retornar mensagens amigávies
 *
 *  @param response Objeto NSHTTPURLResponse para verificar o erro
 *  @param error    Objeto NSError para verificar o erro
 *
 *  @return Mensagem para ser apresentada ao usuário
 */
+ (NSString *)trataErroHTTP:(NSHTTPURLResponse *)response error:(NSError *)error
{
    debug(@"HTTP STATUS: %ld - Error: %@", (long)response.statusCode, error.localizedDescription);
    
    if (response.statusCode == 400 ||
        response.statusCode == 404 ||
        response.statusCode == 500) {
        [[NSNotificationCenter defaultCenter] postNotificationName:WebServiceHelperServicoIndisponivelNotification object:response];
        return [NSString stringWithFormat:@"Serviço indisponível temporariamente. (%ld)", (long)response.statusCode-400];
    }
    else if (response.statusCode == 408) {
        [[NSNotificationCenter defaultCenter] postNotificationName:WebServiceHelperTimeOutNotification object:response];
        return @"Tempo esgotado. Verifique sua conexão com a internet.";
    }
    else if (response.statusCode == 401 ||
             response.statusCode == 403) {
        [[NSNotificationCenter defaultCenter] postNotificationName:WebServiceHelperClienteNaoAutenticadoNotification object:response];
        return @"Falha na autenticação. Por favor faça login novamente.";
    }
    else if (error) {
        if (error.code == -999) {
            return @"";
        }
        else if (error.code == -1004) {
            return @"Serviço indisponível temporariamente.";
        }
        else {
            return [NSString stringWithFormat:@"Serviço indisponível temporariamente. (%ld)", (long)error.code];
        }
    }
    return @"";
}

@end
