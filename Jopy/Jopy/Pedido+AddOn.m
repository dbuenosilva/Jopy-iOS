//
//  Pedido+AddOn.m
//  Jopy
//
//  Created by Edson Teco on 18/11/14.
//  Copyright (c) 2014 gwaya. All rights reserved.
//

#import "Pedido+AddOn.h"
#import "ItemPedido+AddOn.h"

@implementation Pedido (AddOn)

+ (NSString *)entityName
{
    return @"Pedido";
}

/**
 *  Método para inserir/alterar pedidos no banco de dados
 *
 *  @param pedidoDict           Dicionário com os dados do pedido
 *  @param managedObjectContext Contexto
 *
 *  @return Pedido inserido ou alterado
 */
+ (instancetype)insertPedidoComDictionary:(NSDictionary *)pedidoDict inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSString *idPedido = [WebServiceHelper trataValor:pedidoDict[kKEY_API_PEDIDO_COMPRA_RESPONSE_ID]];
    
    Pedido *novoPedido = [Pedido pedidoComId:idPedido inManagedObjectContext:managedObjectContext];
    if (!novoPedido) {
        debug(@"Pedido novo: %@", idPedido);
        novoPedido = [NSEntityDescription insertNewObjectForEntityForName:self.entityName
                                                   inManagedObjectContext:managedObjectContext];
        novoPedido.idPedido = idPedido;
    }
    else {
        debug(@"Pedido já existente: %@", idPedido);
    }
    novoPedido.idSistema = [WebServiceHelper trataValor:pedidoDict[kKEY_API_PEDIDO_COMPRA_RESPONSE_ID_SISTEMA]];
    novoPedido.aprovadores = [WebServiceHelper trataValor:pedidoDict[kKEY_API_PEDIDO_COMPRA_RESPONSE_APROVADORES]];
    novoPedido.statusPedido = [WebServiceHelper trataValor:pedidoDict[kKEY_API_PEDIDO_COMPRA_RESPONSE_STATUS_PEDIDO]];
    if ([novoPedido.statusPedido isEqualToString:PStatusPedidoEmitido]) {
        novoPedido.enviado = @NO;
    }
    else {
        novoPedido.enviado = @YES;
    }
    debug(@"- %@", novoPedido.statusPedido);
    novoPedido.nomeForn = [WebServiceHelper trataValor:pedidoDict[kKEY_API_PEDIDO_COMPRA_RESPONSE_NOME_FORNECEDOR]];
    novoPedido.cpfCnpjForn = [WebServiceHelper trataValor:pedidoDict[kKEY_API_PEDIDO_COMPRA_RESPONSE_CPF_CNPJ_FORNECEDOR]];
    novoPedido.codForn = [WebServiceHelper trataValor:pedidoDict[kKEY_API_PEDIDO_COMPRA_RESPONSE_COD_FORNECEDOR]];
    novoPedido.centroCusto = [WebServiceHelper trataValor:pedidoDict[kKEY_API_PEDIDO_COMPRA_RESPONSE_CENTRO_DE_CUSTO]];
    novoPedido.idSolicitante = [WebServiceHelper trataValor:pedidoDict[kKEY_API_PEDIDO_COMPRA_RESPONSE_SOLICITANTE_ID]];
    novoPedido.solicitante = [WebServiceHelper trataValor:pedidoDict[kKEY_API_PEDIDO_COMPRA_RESPONSE_SOLICITANTE]];
    novoPedido.motivo = [WebServiceHelper trataValor:pedidoDict[kKEY_API_PEDIDO_COMPRA_RESPONSE_MOTIVO]];
    novoPedido.motivoRejeicao = [WebServiceHelper trataValor:pedidoDict[kKEY_API_PEDIDO_COMPRA_RESPONSE_MOTIVO_REJEICAO]];
    novoPedido.totalPedido = [WebServiceHelper trataValor:pedidoDict[kKEY_API_PEDIDO_COMPRA_RESPONSE_TOTAL_PEDIDO]];
    novoPedido.obs = [WebServiceHelper trataValor:pedidoDict[kKEY_API_PEDIDO_COMPRA_RESPONSE_OBS]];
    novoPedido.condPagto = [WebServiceHelper trataValor:pedidoDict[kKEY_API_PEDIDO_COMPRA_RESPONSE_CONDICAO_PAGAMENTO]];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];

    NSString *data = [WebServiceHelper trataValor:pedidoDict[kKEY_API_PEDIDO_COMPRA_RESPONSE_DATA_EMISSAO]];
    novoPedido.dtEmi = (data)?[dateFormat dateFromString:data]:[NSDate date];
                        
    novoPedido.dtMod = [Pedido dataDeModificacao:pedidoDict];
                        
    data = [WebServiceHelper trataValor:pedidoDict[kKEY_API_PEDIDO_COMPRA_RESPONSE_DATA_NECESSIDADE]];
    novoPedido.dtNeces = (data)?[dateFormat dateFromString:data]:[NSDate date];
    
    data = [WebServiceHelper trataValor:pedidoDict[kKEY_API_PEDIDO_COMPRA_RESPONSE_DATA_REJEICAO]];
    novoPedido.dtRej = (data)?[dateFormat dateFromString:data]:nil;
    
    // Remove todos os itens antes de inserir novamente
    for (ItemPedido *item in novoPedido.itens) {
        [managedObjectContext deleteObject:item];
    }
    
    NSArray *itens = [WebServiceHelper trataValor:pedidoDict[kKEY_API_PEDIDO_COMPRA_RESPONSE_ITENS]];
    for (NSDictionary *itemDict in itens) {
        ItemPedido *novoItemPedido = [ItemPedido insertItemPedidoComDictionary:itemDict inManagedObjectContext:managedObjectContext];
        novoItemPedido.pedido = novoPedido;
    }
    
    return novoPedido;
}

/**
 *  Método que obtem o dicionário do Pedido (API) e obtém a data de modificação
 *
 *  @param dict Pedido em formato dicionário
 *
 *  @return Data de Modificação
 */
+ (NSDate *)dataDeModificacao:(NSDictionary *)dict
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    
    NSString *data = [WebServiceHelper trataValor:dict[kKEY_API_PEDIDO_COMPRA_RESPONSE_DATA_MODIFICACAO]];
    return (data)?[dateFormat dateFromString:data]:[NSDate date];
}

/**
 *  Método para obter um Pedido a partir de um idPedido
 *
 *  @param idPedido             idPedido do Pedido
 *  @param managedObjectContext Contexto
 *
 *  @return Pedido
 */
+ (Pedido *)pedidoComId:(NSString *)idPedido inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    Pedido *pedido = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[self entityName]];
    request.predicate = [NSPredicate predicateWithFormat:@"idPedido == %@", idPedido];
    
    NSError *error = nil;
    NSArray *encontrados = [managedObjectContext executeFetchRequest:request error:&error];
    
    if (!encontrados || ([encontrados count] >= 1)) {
        pedido = [encontrados firstObject];
    }
    return pedido;
}

/**
 *  Método para criar o request que obtém um array com todos os Pedidos
 *
 *  @return Request
 */
+ (NSFetchRequest *)requestDePedidos
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[self entityName]];
    return request;
}

/**
 *  Método para criar o request que obtém um array de Pedidos com o status fornecido
 *
 *  @param status   Status do Pedido
 *
 *  @return Request
 */
+ (NSFetchRequest *)requestDePedidosComStatus:(NSString *)status aprovador:(NSString *)aprovador
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[self entityName]];
    request.predicate = [NSPredicate predicateWithFormat:@"statusPedido == %@ AND arquivo == NO AND aprovadores contains[cd] %@", status, aprovador];
    if ([status isEqualToString:PStatusPedidoAprovado]) {
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"dtMod" ascending:NO]];
    }
    else {
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"dtNeces" ascending:YES]];
    }
    return request;
}

/**
 *  Método para criar o request que obtém um array de Pedidos de um fornecedor (historico)
 *
 *  @param codFornecedor Código do fornecedor
 *
 *  @return Request
 */
+ (NSFetchRequest *)requestDePedidosDoFornecedor:(NSString *)codFornecedor
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[self entityName]];
    request.predicate = [NSPredicate predicateWithFormat:@"statusPedido != %@ AND statusPedido != %@ AND codForn == %@", PStatusPedidoDeletado, PStatusPedidoEmitido, codFornecedor];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"dtNeces" ascending:NO]];
    return request;
}

/**
 *  Método para criar o request que obtém os pedidos que não foram enviados ainda
 *
 *  @return Request
 */
+ (NSFetchRequest *)requestDePedidosPendentesDeEnvio
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[self entityName]];
    request.predicate = [NSPredicate predicateWithFormat:@"statusPedido != %@ AND enviado == NO", PStatusPedidoEmitido];
    return request;
}

/**
 *  Método para criar o request que obtém a ultima data de modificação dos pedidos
 *
 *  @return Request
 */
+ (NSFetchRequest *)requestDaUltimaDataDeModificacao
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[self entityName]];
    NSExpression *keyPathExpression = [NSExpression expressionForKeyPath:@"dtMod"];
    NSExpression *maxDateExpression = [NSExpression expressionForFunction:@"max:"
                                                      arguments:[NSArray arrayWithObject:keyPathExpression]];
    NSExpressionDescription *d = [[NSExpressionDescription alloc] init];
    [d setName:@"maxDate"];
    [d setExpression:maxDateExpression];
    [d setExpressionResultType:NSDateAttributeType];
    
    [request setPropertiesToFetch:[NSArray arrayWithObject:d]];
    return request;
}

/**
 *  Método para obter a ultima data de modificação dos pedidos
 *
 *  @param managedObjectContext Contexto
 *
 *  @return Ultima data de modificação
 */
+ (NSDate *)ultimaDataDeModificacaoInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    // Obtem quantos pedidos há no banco de dados
    NSArray *todosOsPedidos = [Pedido pedidosInManagedObjectContext:managedObjectContext];
    // Se não houver nenhum, retorna a data base de 30 dias atrás
    if (todosOsPedidos.count == 0) {
        return [self trintaDiasAtras];
    }
    // Se houver pedidos no banco de dados, pega a última data de modificação
    else {
        NSError *error = nil;
        NSDate *data = [self trintaDiasAtras];
        NSArray *objects = [managedObjectContext executeFetchRequest:[Pedido requestDaUltimaDataDeModificacao] error:&error];
        if (error) {
            debug(@"%@", error.localizedDescription);
        }
        if (objects.count > 0) {
            data = [[objects lastObject] valueForKey:@"dtMod"];
        }
        return data;
    }
}

/**
 *  Método para retornar a data de 30 dias atrás
 *
 *  @return NSDate de 30 dias atrás
 */
+ (NSDate *)trintaDiasAtras
{
    int daysToAdd = -30;
    return [[NSDate date] dateByAddingTimeInterval:60*60*24*daysToAdd];
}

/**
 *  Método para obter um array de Pedidos com o status fornecido
 *
 *  @param status               Status do Pedido
 *  @param managedObjectContext Contexto
 *
 *  @return Array de Pedidos
 */
+ (NSArray *)pedidosComStatus:(NSString *)status aprovador:(NSString *)aprovador inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSError *error = nil;
    NSArray *retorno = [managedObjectContext executeFetchRequest:[Pedido requestDePedidosComStatus:status aprovador:aprovador] error:&error];
    if (error) {
        debug(@"%@", error.localizedDescription);
    }
    return retorno;
}

/**
 *  Método para obter um array de Pedidos pendentes de envio
 *
 *  @param managedObjectContext Contexto
 *
 *  @return Array de Pedidos
 */
+ (NSArray *)pedidosPendentesDeEnvioInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSError *error = nil;
    NSArray *retorno = [managedObjectContext executeFetchRequest:[Pedido requestDePedidosPendentesDeEnvio] error:&error];
    if (error) {
        debug(@"%@", error.localizedDescription);
    }
    return retorno;
}

/**
 *  Método para obter um array com todos os Pedidos
 *
 *  @param managedObjectContext Contexto
 *
 *  @return Array de Pedidos
 */
+ (NSArray *)pedidosInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSError *error = nil;
    NSArray *retorno = [managedObjectContext executeFetchRequest:[Pedido requestDePedidos] error:&error];
    if (error) {
        debug(@"%@", error.localizedDescription);
    }
    return retorno;
}

/**
 *  Método para arquivar um pedido
 *
 *  @param pedido               Pedido que deseja arquivar
 *  @param managedObjectContext Contexto
 */
+ (void)arquivaPedido:(Pedido *)pedido inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSError *error = nil;
    pedido.arquivo = [NSNumber numberWithBool:YES];
    if (![managedObjectContext save:&error]) {
        debug(@"%@", error.localizedDescription);
    }
}

/**
 *  Método para desarquivar um pedido
 *
 *  @param pedido               Pedido que deseja desarquivar
 *  @param managedObjectContext Contexto
 */
+ (void)desarquivaPedido:(Pedido *)pedido inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSError *error = nil;
    pedido.arquivo = [NSNumber numberWithBool:NO];
    if (![managedObjectContext save:&error]) {
        debug(@"%@", error.localizedDescription);
    }
}

/**
 *  Método para remover todos os pedidos do banco de dados (desativado)
 *
 *  @return BOOL sucesso
 */
+ (BOOL)removeTodosOsPedidosInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
//    return YES;
    
    NSArray *todosOsPedidos = [Pedido pedidosInManagedObjectContext:managedObjectContext];
    for (Pedido *pedido in todosOsPedidos) {
        if ([ItemPedido removeTodosOsItensDoPedido:pedido inManagedObjectContext:managedObjectContext]) {
            [managedObjectContext deleteObject:pedido];
        }
    }
    NSError *error = nil;
    [managedObjectContext save:&error];
    return (error == nil);
}

@end
