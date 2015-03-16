//
//  Pedido.h
//  Jopy
//
//  Created by Edson Teco on 24/11/14.
//  Copyright (c) 2014 gwaya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ItemPedido;

@interface Pedido : NSManagedObject

@property (nonatomic, retain) NSString * aprovadores;
@property (nonatomic, retain) NSString * centroCusto;
@property (nonatomic, retain) NSString * codForn;
@property (nonatomic, retain) NSString * cpfCnpjForn;
@property (nonatomic, retain) NSDate * dtEmi;
@property (nonatomic, retain) NSDate * dtMod;
@property (nonatomic, retain) NSDate * dtNeces;
@property (nonatomic, retain) NSNumber * enviado;
@property (nonatomic, retain) NSNumber * arquivo;
@property (nonatomic, retain) NSString * idPedido;
@property (nonatomic, retain) NSString * idSistema;
@property (nonatomic, retain) NSString * idSolicitante;
@property (nonatomic, retain) NSString * motivo;
@property (nonatomic, retain) NSString * motivoRejeicao;
@property (nonatomic, retain) NSString * nomeForn;
@property (nonatomic, retain) NSString * obs;
@property (nonatomic, retain) NSString * solicitante;
@property (nonatomic, retain) NSString * statusPedido;
@property (nonatomic, retain) NSNumber * totalPedido;
@property (nonatomic, retain) NSString * condPagto;
@property (nonatomic, retain) NSDate * dtRej;
@property (nonatomic, retain) NSSet *itens;
@end

@interface Pedido (CoreDataGeneratedAccessors)

- (void)addItensObject:(ItemPedido *)value;
- (void)removeItensObject:(ItemPedido *)value;
- (void)addItens:(NSSet *)values;
- (void)removeItens:(NSSet *)values;

@end
