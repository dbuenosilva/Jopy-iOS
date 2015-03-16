//
//  ItemPedido+AddOn.m
//  Jopy
//
//  Created by Edson Teco on 18/11/14.
//  Copyright (c) 2014 gwaya. All rights reserved.
//

#import "ItemPedido+AddOn.h"

@implementation ItemPedido (AddOn)

+ (NSString *)entityName
{
    return @"ItemPedido";
}

/**
 *  Método para inserir/alterar itens de pedido no banco de dados
 *
 *  @param itemPedidoDict       Dicionário com os dados do item de pedido
 *  @param managedObjectContext Contexto
 *
 *  @return Item de Pedido inserido ou alterado
 */
+ (instancetype)insertItemPedidoComDictionary:(NSDictionary *)itemPedidoDict inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    ItemPedido *novoItemPedido = [NSEntityDescription insertNewObjectForEntityForName:self.entityName
                                                   inManagedObjectContext:managedObjectContext];
    novoItemPedido.produto = [WebServiceHelper trataValor:itemPedidoDict[kKEY_API_PEDIDO_COMPRA_RESPONSE_ITEM_PRODUTO]];
    novoItemPedido.obs = [WebServiceHelper trataValor:itemPedidoDict[kKEY_API_PEDIDO_COMPRA_RESPONSE_ITEM_OBS]];
    novoItemPedido.qtde = [WebServiceHelper trataValor:itemPedidoDict[kKEY_API_PEDIDO_COMPRA_RESPONSE_ITEM_QTDE]];
    novoItemPedido.valor = [WebServiceHelper trataValor:itemPedidoDict[kKEY_API_PEDIDO_COMPRA_RESPONSE_ITEM_VALOR]];
    novoItemPedido.total = [WebServiceHelper trataValor:itemPedidoDict[kKEY_API_PEDIDO_COMPRA_RESPONSE_ITEM_TOTAL]];
    
    return novoItemPedido;
}

/**
 *  Método para obter um array de Itens de Pedidos com o Pedido fornecido
 *
 *  @param pedido               Pedido
 *  @param managedObjectContext Contexto
 *
 *  @return Array de Itens do Pedido
 */
+ (NSArray *)itensDoPedido:(Pedido *)pedido inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[self entityName]];
    request.predicate = [NSPredicate predicateWithFormat:@"pedido == %@", pedido];
    
    NSError *error = nil;
    return [managedObjectContext executeFetchRequest:request error:&error];
}

+ (BOOL)removeTodosOsItensDoPedido:(Pedido *)pedido inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSArray *itens = [ItemPedido itensDoPedido:pedido inManagedObjectContext:managedObjectContext];
    for (ItemPedido *item in itens) {
        [managedObjectContext deleteObject:item];
    }
    NSError *error = nil;
    [managedObjectContext save:&error];
    return (error == nil);
}

@end
