//
//  ItemPedido+AddOn.h
//  Jopy
//
//  Created by Edson Teco on 18/11/14.
//  Copyright (c) 2014 gwaya. All rights reserved.
//

#import "ItemPedido.h"

@interface ItemPedido (AddOn)

+ (instancetype)insertItemPedidoComDictionary:(NSDictionary *)itemPedidoDict inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (NSArray *)itensDoPedido:(Pedido *)pedido inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (BOOL)removeTodosOsItensDoPedido:(Pedido *)pedido inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
