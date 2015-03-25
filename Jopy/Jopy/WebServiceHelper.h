//
//  WebServiceHelper.h
//  Jopy
//
//  Created by Edson Teco on 13/11/14.
//  Copyright (c) 2014 gwaya. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kKEY_API_HEADER @"Authorization"
#define kKEY_API_RESPONSE_PEDIDO @"pedido"
#define kKEY_API_RESPONSE_STATUS @"status"
#define kKEY_API_RESPONSE_MENSAGEM @"mensagem"

#define kKEY_API_AUTENTICACAO_POST @"/oauth/token"
#define kKEY_API_AUTENTICACAO_POST_GRANT_TYPE @"grant_type"
#define kKEY_API_AUTENTICACAO_POST_CLIENT_ID @"client_id"
#define kKEY_API_AUTENTICACAO_POST_CLIENT_SECRET @"client_secret"
#define kKEY_API_AUTENTICACAO_POST_USERNAME @"username"
#define kKEY_API_AUTENTICACAO_POST_PASSWORD @"password"

#define kKEY_API_REGISTRO_POST_DEVICE_TYPE @"deviceType"
#define kKEY_API_REGISTRO_POST_DEVICE_KEY @"deviceKey"
#define kKEY_API_REGISTRO_POST_OS_TYPE @"osType"
#define kKEY_API_REGISTRO_POST_OS_VERSION @"osVersion"
#define kKEY_API_REGISTRO_POST_APP_VERSION @"AppVersion"

#define kKEY_API_AUTENTICACAO_RESPONSE_ACCESS_TOKEN @"access_token"
#define kKEY_API_AUTENTICACAO_RESPONSE_REFRESH_TOKEN @"refresh_token"
#define kKEY_API_AUTENTICACAO_RESPONSE_EXPIRES_IN @"expires_in"
#define kKEY_API_AUTENTICACAO_RESPONSE_TOKEN_TYPE @"token_type"

#define kKEY_API_RECUPERA_SENHA_POST @"/api/v1/oauth/esqueceu"
#define kKEY_API_RECUPERA_SENHA_USERNAME @"username"

#define kKEY_API_PEDIDO_COMPRA_GET @"/api/v1/pedidocompra"
#define kKEY_API_PEDIDO_COMPRA_GET_FILTRO_STATUS_PEDIDO @"statusPedido"
#define kKEY_API_PEDIDO_COMPRA_GET_FILTRO_COD_FORNECEDOR @"codForn"
#define kKEY_API_PEDIDO_COMPRA_GET_FILTRO_DATA @"gte"

#define kKEY_API_PEDIDO_COMPRA_RESPONSE_PEDIDOS @"pedidos"
#define kKEY_API_PEDIDO_COMPRA_RESPONSE_ID @"_id"
#define kKEY_API_PEDIDO_COMPRA_RESPONSE_ID_SISTEMA @"idSistema"
#define kKEY_API_PEDIDO_COMPRA_RESPONSE_APROVADORES @"aprovadores"          // '123456|123457|123458'
#define kKEY_API_PEDIDO_COMPRA_RESPONSE_STATUS_PEDIDO @"statusPedido"       // enum: ['emitido', 'aprovado', 'rejeitado']
#define kKEY_API_PEDIDO_COMPRA_RESPONSE_NOME_FORNECEDOR @"nomeForn"         // 'Cimentos ABC'
#define kKEY_API_PEDIDO_COMPRA_RESPONSE_CPF_CNPJ_FORNECEDOR @"cpfCnpjForn"  // '57.589.748/0001-99'
#define kKEY_API_PEDIDO_COMPRA_RESPONSE_COD_FORNECEDOR @"codForn"           // '1' -> protheus
#define kKEY_API_PEDIDO_COMPRA_RESPONSE_DATA_EMISSAO @"dtEmi"               // '' -> quando omitida data corrente do servidor
#define kKEY_API_PEDIDO_COMPRA_RESPONSE_DATA_NECESSIDADE @"dtNeces"         // '' -> quando omitida data corrente do servidor
#define kKEY_API_PEDIDO_COMPRA_RESPONSE_DATA_REJEICAO @"dtRej"              // '' -> data da rejeicao
#define kKEY_API_PEDIDO_COMPRA_RESPONSE_CENTRO_DE_CUSTO @"centroCusto"      // 'Centro de Custo'
#define kKEY_API_PEDIDO_COMPRA_RESPONSE_CONDICAO_PAGAMENTO @"condPagto"     // ''
#define kKEY_API_PEDIDO_COMPRA_RESPONSE_SOLICITANTE_ID @"idSolicitante"     // '1' -> id usuario protheus
#define kKEY_API_PEDIDO_COMPRA_RESPONSE_SOLICITANTE @"solicitante"          // 'Zé'
#define kKEY_API_PEDIDO_COMPRA_RESPONSE_MOTIVO @"motivo"                    // 'Motivo da solicitação'
#define kKEY_API_PEDIDO_COMPRA_RESPONSE_MOTIVO_REJEICAO @"motivoRejeicao"   // 'Motivo da rejeição'
#define kKEY_API_PEDIDO_COMPRA_RESPONSE_TOTAL_PEDIDO @"totalPedido"         // 6.60
#define kKEY_API_PEDIDO_COMPRA_RESPONSE_OBS @"obs"                          // 'Observação Observação'
#define kKEY_API_PEDIDO_COMPRA_RESPONSE_DATA_MODIFICACAO @"dtMod"           // '' -> quando omitida data corrente do servidor
#define kKEY_API_PEDIDO_COMPRA_RESPONSE_DATA_APROVACAO @"dtAprov"           // '' -> quando omitida data corrente do servidor
#define kKEY_API_PEDIDO_COMPRA_RESPONSE_ITENS @"itens"
#define kKEY_API_PEDIDO_COMPRA_RESPONSE_ITEM_ID @"_id"
#define kKEY_API_PEDIDO_COMPRA_RESPONSE_ITEM_PRODUTO @"produto"             // 'Produto abc'
#define kKEY_API_PEDIDO_COMPRA_RESPONSE_ITEM_OBS @"obs"                     // ''
#define kKEY_API_PEDIDO_COMPRA_RESPONSE_ITEM_QTDE @"qtde"                   // 2
#define kKEY_API_PEDIDO_COMPRA_RESPONSE_ITEM_VALOR @"valor"                 // 1.80
#define kKEY_API_PEDIDO_COMPRA_RESPONSE_ITEM_TOTAL @"total"                 // 3.60

#define kKEY_API_PEDIDO_COMPRA_PUT @"/api/v1/pedidocompra"
#define kKEY_API_PEDIDO_COMPRA_PUT_STATUS_PEDIDO @"statusPedido" // ['emitido', 'aprovado', 'rejeitado']
#define kKEY_API_PEDIDO_COMPRA_PUT_DATA_REJEICAO @"dtRej"
#define kKEY_API_PEDIDO_COMPRA_PUT_MOTIVO_REJEICAO @"motivoRejeicao"
#define kKEY_API_PEDIDO_COMPRA_PUT_DATA_APROVACAO @"dtAprov"

#define kKEY_API_USER_INFO_GET @"/api/v1/userinfo"
#define kKEY_API_ABOUT_GET @"/api/v1/about"
#define kKEY_API_LOGOUT_GET @"/api/v1/logout"

FOUNDATION_EXPORT NSString * const WebServiceHelperServicoIndisponivelNotification;
FOUNDATION_EXPORT NSString * const WebServiceHelperClienteNaoAutenticadoNotification;
FOUNDATION_EXPORT NSString * const WebServiceHelperTimeOutNotification;

@interface WebServiceHelper : AFHTTPSessionManager

+ (instancetype)sharedClient;
+ (id)trataValor:(id)valor;
+ (void)trataRespostaAPI:(id)responseObject completion:(void (^)(bool sucesso, id retorno, NSString *mensagem))completion;
+ (NSString *)trataErroHTTP:(NSHTTPURLResponse *)response error:(NSError *)error;

@end
