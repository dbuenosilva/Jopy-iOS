//
//  WebServiceDataModel.m
//  Jopy
//
//  Created by Edson Teco on 18/11/14.
//  Copyright (c) 2014 gwaya. All rights reserved.
//

#import "WebServiceDataModel.h"
#import "PedidoFactory.h"

NSString* const WebServiceDataModelImportacaoPedidosConcluidaNotification = @"br.com.gwaya.WebServiceDataModelImportacaoPedidosConcluidaNotification";
NSString* const WebServiceDataModelImportacaoPedidosIniciadaNotification = @"br.com.gwaya.WebServiceDataModelImportacaoPedidosIniciadaNotification";
NSString* const WebServiceDataModelEnvioDePedidosConcluidoNotification = @"br.com.gwaya.WebServiceDataModelEnvioDePedidosConcluidoNotification";
NSString* const WebServiceDataModelEnvioDePedidosIniciadoNotification = @"br.com.gwaya.WebServiceDataModelEnvioDePedidosIniciadoNotification";

@implementation WebServiceDataModel

#pragma mark -
#pragma mark Getters overriders

#pragma mark -
#pragma mark Setters overriders

- (void)setEstaPegandoDados:(BOOL)estaPegandoDados
{
    _estaPegandoDados = estaPegandoDados;
    if (estaPegandoDados) {
        [[NSNotificationCenter defaultCenter] postNotificationName:WebServiceDataModelImportacaoPedidosIniciadaNotification
                                                            object:self];
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:WebServiceDataModelImportacaoPedidosConcluidaNotification
                                                            object:self];
    }
}

- (void)setEstaEnviandoDados:(BOOL)estaEnviandoDados
{
    _estaEnviandoDados = estaEnviandoDados;
    if (estaEnviandoDados) {
        [[NSNotificationCenter defaultCenter] postNotificationName:WebServiceDataModelEnvioDePedidosIniciadoNotification
                                                            object:self];
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:WebServiceDataModelEnvioDePedidosConcluidoNotification
                                                            object:self];
    }
}

#pragma mark -
#pragma mark Designated initializers

#pragma mark -
#pragma mark Metodos publicos

/**
 *  Método para iniciar o processo de importacao dos dados usando multithreads e coredata. So e permitido a inicializacao de uma rotina de atualizacao por vez
 */
- (void)obtemNovosDados
{
    if (!self.estaPegandoDados || self.estaPegandoDados == NO) {
        
        debug(@"Obtendo Dados...");
        
        self.estaPegandoDados = YES;
        
        NSDate *ultimaDataDeModificacao = [Pedido ultimaDataDeModificacaoInManagedObjectContext:self.managedObjectContext];
        
        [PedidoFactory pedidosDepoisDaData:ultimaDataDeModificacao completion:^(NSArray *pedidos, NSString *erro) {
            
            if (pedidos.count > 0) {
                
                NSManagedObjectContext *temporaryContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
                temporaryContext.parentContext = self.managedObjectContext;
                
                [temporaryContext performBlock:^{
                    
                    for (NSDictionary *pedidoDict in pedidos) {
                        [Pedido insertPedidoComDictionary:pedidoDict inManagedObjectContext:temporaryContext];
                    }
                    if ([temporaryContext hasChanges]) {
                        NSError *error;
                        if (![temporaryContext save:&error]) {
                            debug(@"ERRO: %@", error.localizedDescription);
                        }
                        [temporaryContext reset];
                    }
                    
                    [self.managedObjectContext performBlock:^{
                        
                        if ([self.managedObjectContext hasChanges]) {
                            NSError *error;
                            if (![self.managedObjectContext save:&error]) {
                                debug(@"ERRO: %@", error.localizedDescription);
                            }
                            [self.managedObjectContext reset];
                        }
                        [Sessao definirDataHoraUltimoAcessoAoServidor:[NSDate date]];
                        
                        self.estaPegandoDados = NO;
                        debug(@"Fim Obtendo");
                    }];
                }];
            }
            else {
                self.estaPegandoDados = NO;
                debug(@"Sem novos pedidos (%@)", erro);
            }
        }];
    }
    else {
        self.estaPegandoDados = NO;
        debug(@"Desculpe. Impossivel iniciar import neste momento...");
    }
}

- (void)enviaDadosPendentes
{
    if (!self.estaEnviandoDados || self.estaEnviandoDados == NO) {

        debug(@"Enviando Dados...");
        
        self.estaEnviandoDados = YES;

        NSManagedObjectContext *temporaryContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        temporaryContext.parentContext = self.managedObjectContext;
        
        [temporaryContext performBlock:^{
            
            NSArray *pedidos = [Pedido pedidosPendentesDeEnvioInManagedObjectContext:temporaryContext];
            for (Pedido *pedidoParaEnviar in pedidos) {
                
                debug(@"Enviando Pedido %@", pedidoParaEnviar.statusPedido);
                
                if ([pedidoParaEnviar.statusPedido isEqualToString:PStatusPedidoAprovado]) {
                    [PedidoFactory aprovaPedido:pedidoParaEnviar completion:^(NSDictionary *pedido, NSString *erro) {
                        if (pedido) {
                            Pedido *pedidoEnviado = [Pedido pedidoComId:[WebServiceHelper trataValor:pedido[kKEY_API_PEDIDO_COMPRA_RESPONSE_ID]] inManagedObjectContext:temporaryContext];
                            pedidoEnviado.enviado = [NSNumber numberWithBool:YES];

                            [self salvaContexto:temporaryContext];
                            
                            [self.managedObjectContext performBlock:^{
                                [self salvaContexto:self.managedObjectContext];
                                [Sessao definirDataHoraUltimoAcessoAoServidor:[NSDate date]];
                            }];
                            
                            debug(@"Ok");
                        }
                        else {
                            debug(@"Erro: %@", erro);
                        }
                    }];
                }
                else if ([pedidoParaEnviar.statusPedido isEqualToString:PStatusPedidoRejeitado]) {
                    [PedidoFactory rejeitaPedido:pedidoParaEnviar completion:^(NSDictionary *pedido, NSString *erro) {
                        if (pedido) {
                            Pedido *pedidoEnviado = [Pedido pedidoComId:[WebServiceHelper trataValor:pedido[kKEY_API_PEDIDO_COMPRA_RESPONSE_ID]] inManagedObjectContext:temporaryContext];
                            pedidoEnviado.enviado = [NSNumber numberWithBool:YES];
                            
                            [self salvaContexto:temporaryContext];
                            
                            [self.managedObjectContext performBlock:^{
                                [self salvaContexto:self.managedObjectContext];
                                [Sessao definirDataHoraUltimoAcessoAoServidor:[NSDate date]];
                            }];
                            
                            debug(@"Ok");
                        }
                        else {
                            debug(@"Erro: %@", erro);
                        }
                    }];
                }
            }
            
            self.estaEnviandoDados = NO;
            debug(@"Fim Enviando");
        }];
    }
    else {
        self.estaEnviandoDados = NO;
        debug(@"Desculpe. Impossivel iniciar envio neste momento...");
    }
}

#pragma mark -
#pragma mark Metodos privados

- (void)salvaContexto:(NSManagedObjectContext *)managedObjectContext
{
    if ([managedObjectContext hasChanges]) {
        NSError *error;
        if (![managedObjectContext save:&error]) {
            debug(@"ERRO: %@", error.localizedDescription);
        }
        [managedObjectContext reset];
    }
}

#pragma mark -
#pragma mark Notification center

@end
