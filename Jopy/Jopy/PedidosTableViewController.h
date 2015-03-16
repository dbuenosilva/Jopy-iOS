//
//  PedidosTableViewController.h
//  Jopy
//
//  Created by Edson Teco on 18/11/14.
//  Copyright (c) 2014 gwaya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebServiceDataModel.h"
#import "PedidoFactory.h"

@interface PedidosTableViewController : UITableViewController

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSString *statusPedidoParaExibir;
@property (nonatomic) BOOL modoHistorico;
@property (strong, nonatomic) NSString *codFornecedorParaExibirHistorico;

@end
