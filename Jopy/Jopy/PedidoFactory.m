//
//  PedidoFactory.m
//  Jopy
//
//  Created by Edson Teco on 18/11/14.
//  Copyright (c) 2014 gwaya. All rights reserved.
//

#import "PedidoFactory.h"

@implementation PedidoFactory

#pragma mark -
#pragma mark Getters overriders

#pragma mark -
#pragma mark Setters overriders

#pragma mark -
#pragma mark Designated initializers

#pragma mark -
#pragma mark Metodos publicos

+ (void)pedidosDepoisDaData:(NSDate *)data completion:(PedidosRetornados)completion
{
    NSString *authorization = [NSString stringWithFormat:@"%@ %@", [Sessao tokenType], [Sessao accessToken]];
    
    NSDateFormatter *dateFormat;
    dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    
    NSDictionary *parametros = @{ kKEY_API_PEDIDO_COMPRA_GET_FILTRO_DATA : [dateFormat stringFromDate:data] };
    debug(@"%@", parametros);
    
    [[WebServiceHelper sharedClient].requestSerializer setValue:authorization forHTTPHeaderField:kKEY_API_HEADER];
    [[WebServiceHelper sharedClient]
     GET:kKEY_API_PEDIDO_COMPRA_GET
     parameters:parametros
     success:^(NSURLSessionDataTask *task, id responseObject) {
         
         NSString *mensagemRetorno = [WebServiceHelper trataErroHTTP:(NSHTTPURLResponse *)task.response error:nil];
         if (mensagemRetorno.length == 0) {
             if ([responseObject isKindOfClass:[NSDictionary class]]) {
                 NSArray *pedidos = [(NSDictionary *)responseObject objectForKey:kKEY_API_PEDIDO_COMPRA_RESPONSE_PEDIDOS];
                 completion(pedidos, nil);
             }
             else {
                 completion(nil, @"Não foi possível obter resposta do servidor.");
             }
         }
         else {
             completion(nil, mensagemRetorno);
         }
         
     } failure:^(NSURLSessionDataTask *task, NSError *error) {
         
         completion(nil, [WebServiceHelper trataErroHTTP:(NSHTTPURLResponse *)task.response error:error]);
         
     }];
}

/**
 *  Método para obter pedidos do servidor
 *
 *  @param completion Bloco para ser executado ao final da execução deste método. Retorna Array de pedidos e uma mensagem no caso de erro
 */
+ (void)pedidosComCompletion:(PedidosRetornados)completion
{
    [PedidoFactory pedidosDepoisDaData:[NSDate date] completion:completion];
}

/**
 *  Método para aprovar um pedido
 *
 *  @param pedido     Pedido que deseja ser aprovado
 *  @param completion Bloco para ser executado ao final da execução desse método. Retorna o Pedido aprovado e uma mensagem no caso de erro
 */
+ (void)aprovaPedido:(Pedido *)pedido completion:(PedidoAlterado)completion
{
    NSDictionary *parametros = @{kKEY_API_PEDIDO_COMPRA_PUT_STATUS_PEDIDO : PStatusPedidoAprovado};
    
    [self alteraPedidoComParametros:parametros idPedido:pedido.idPedido completion:completion];
}

/**
 *  Método para rejeitar um pedido
 *
 *  @param pedido     Pedido que deseja ser rejeitado
 *  @param completion Bloco para ser executado ao final da execução desse método. Retorna o Pedido aprovado e uma mensagem no caso de erro
 */
+ (void)rejeitaPedido:(Pedido *)pedido completion:(PedidoAlterado)completion
{
    NSDateFormatter *dateFormat;
    dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];

    if (!pedido.dtRej) {
        completion(nil, @"Pedido não pode ser rejeitado (data inválida)");
        return;
    }
    if (!pedido.motivoRejeicao) {
        pedido.motivoRejeicao = @"";
    }
    NSDictionary *parametros = @{kKEY_API_PEDIDO_COMPRA_PUT_STATUS_PEDIDO : PStatusPedidoRejeitado,
                                 kKEY_API_PEDIDO_COMPRA_PUT_DATA_REJEICAO : [dateFormat stringFromDate:pedido.dtRej],
                                 kKEY_API_PEDIDO_COMPRA_PUT_MOTIVO_REJEICAO : pedido.motivoRejeicao};
    
    [self alteraPedidoComParametros:parametros idPedido:pedido.idPedido completion:completion];
}

#pragma mark -
#pragma mark Metodos privados

/**
 *  Método para alterar um pedido no servidor
 *
 *  @param parametros Dicionário com os campos e valores a serem alterados
 *  @param idPedido   idPedido a ser alterado
 *  @param completion Bloco para ser executado ao final da execução desse método. Retorna o Pedido aprovado e uma mensagem no caso de erro
 */
+ (void)alteraPedidoComParametros:(NSDictionary *)parametros idPedido:(NSString *)idPedido completion:(PedidoAlterado)completion
{
    NSString *authorization = [NSString stringWithFormat:@"%@ %@", [Sessao tokenType], [Sessao accessToken]];
    NSString *url = [NSString stringWithFormat:@"%@/%@", kKEY_API_PEDIDO_COMPRA_PUT, idPedido];
    
    [WebServiceHelper sharedClient].requestSerializer = [AFJSONRequestSerializer serializer];
    [[WebServiceHelper sharedClient].requestSerializer setValue:authorization forHTTPHeaderField:kKEY_API_HEADER];
    [[WebServiceHelper sharedClient]
     PUT:url
     parameters:parametros
     success:^(NSURLSessionDataTask *task, id responseObject) {
         
         NSString *mensagemRetorno = [WebServiceHelper trataErroHTTP:(NSHTTPURLResponse *)task.response error:nil];
         if (mensagemRetorno.length == 0) {
             
             [WebServiceHelper trataRespostaAPI:responseObject completion:^(bool sucesso, id retorno, NSString *mensagem) {
                 if (sucesso) {
                     if ([retorno isKindOfClass:[NSDictionary class]]) {
                         completion(retorno, nil);
                     }
                     else {
                         completion(nil, @"Não foi possível obter resposta do servidor.");
                     }
                 }
                 else {
                     if (mensagem) {
                         completion(nil, mensagem);
                     }
                     else {
                         completion(nil, @"Não foi possível obter resposta do servidor.");
                     }
                 }
             }];
         }
         else {
             completion(nil, mensagemRetorno);
         }
         
     } failure:^(NSURLSessionDataTask *task, NSError *error) {
         
         completion(nil, [WebServiceHelper trataErroHTTP:(NSHTTPURLResponse *)task.response error:error]);
         
     }];
}

#pragma mark -
#pragma mark Notification center

@end
