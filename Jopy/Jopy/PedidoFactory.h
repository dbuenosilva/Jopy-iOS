//
//  PedidoFactory.h
//  Jopy
//
//  Created by Edson Teco on 18/11/14.
//  Copyright (c) 2014 gwaya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Sessao.h"
#import "Pedido+AddOn.h"

typedef void (^PedidosRetornados)(NSArray *pedidos, NSString *erro);
typedef void (^PedidoAlterado)(NSDictionary *pedido, NSString *erro);
typedef void (^Completion)(void);

@interface PedidoFactory : NSObject

+ (void)pedidosComCompletion:(PedidosRetornados)completion;
+ (void)pedidosDepoisDaData:(NSDate *)data completion:(PedidosRetornados)completion;
+ (void)aprovaPedido:(Pedido *)pedido completion:(PedidoAlterado)completion;
+ (void)rejeitaPedido:(Pedido *)pedido completion:(PedidoAlterado)completion;

@end
