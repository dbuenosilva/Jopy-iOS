//
//  WebServiceDataModel.h
//  Jopy
//
//  Created by Edson Teco on 18/11/14.
//  Copyright (c) 2014 gwaya. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString* const WebServiceDataModelImportacaoPedidosConcluidaNotification;
FOUNDATION_EXPORT NSString* const WebServiceDataModelImportacaoPedidosIniciadaNotification;

typedef void (^Completion)(void);

@interface WebServiceDataModel : NSObject

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) BOOL estaPegandoDados;
@property (nonatomic) BOOL estaEnviandoDados;

- (void)obtemNovosDados;
- (void)enviaDadosPendentes;

@end
