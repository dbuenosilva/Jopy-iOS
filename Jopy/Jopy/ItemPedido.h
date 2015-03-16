//
//  ItemPedido.h
//  Jopy
//
//  Created by Edson Teco on 24/11/14.
//  Copyright (c) 2014 gwaya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Pedido;

@interface ItemPedido : NSManagedObject

@property (nonatomic, retain) NSString * produto;
@property (nonatomic, retain) NSNumber * qtde;
@property (nonatomic, retain) NSNumber * total;
@property (nonatomic, retain) NSNumber * valor;
@property (nonatomic, retain) NSString * obs;
@property (nonatomic, retain) Pedido *pedido;

@end
