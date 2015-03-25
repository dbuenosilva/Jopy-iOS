//
//  Pedido+AddOn.h
//  Jopy
//
//  Created by Edson Teco on 18/11/14.
//  Copyright (c) 2014 gwaya. All rights reserved.
//

#import "Pedido.h"

#define PStatusPedidoEmitido @"emitido"
#define PStatusPedidoAprovado @"aprovado"
#define PStatusPedidoRejeitado @"rejeitado"
#define PStatusPedidoDeletado @"deletado"

@interface Pedido (AddOn)

+ (instancetype)insertPedidoComDictionary:(NSDictionary *)pedidoDict inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (NSDate *)dataDeModificacao:(NSDictionary *)dict;
+ (Pedido *)pedidoComId:(NSString *)idPedido inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (NSFetchRequest *)requestDePedidosComStatus:(NSString *)status aprovador:(NSString *)aprovador;
+ (NSFetchRequest *)requestDePedidosDoFornecedor:(NSString *)codFornecedor;
+ (NSFetchRequest *)requestDePedidosPendentesDeEnvio;
+ (NSFetchRequest *)requestDaUltimaDataDeModificacao;
+ (NSFetchRequest *)requestDePedidos;
+ (NSArray *)pedidosComStatus:(NSString *)status aprovador:(NSString *)aprovador inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (NSArray *)pedidosPendentesDeEnvioInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (NSDate *)ultimaDataDeModificacaoInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (NSArray *)pedidosInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (void)arquivaPedido:(Pedido *)pedido inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (void)desarquivaPedido:(Pedido *)pedido inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (BOOL)removeTodosOsPedidosInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
