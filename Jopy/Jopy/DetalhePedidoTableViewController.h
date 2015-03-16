//
//  DetalhePedidoTableViewController.h
//  Jopy
//
//  Created by Edson Teco on 20/11/14.
//  Copyright (c) 2014 gwaya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Pedido+AddOn.h"

@interface DetalhePedidoTableViewController : UITableViewController

@property (strong, nonatomic) Pedido *pedido;
@property (nonatomic) BOOL modoHistorico;
@property (strong, nonatomic) NSArray *pedidosDoHistorico;
@property (nonatomic) NSInteger indicePedidoAtual;

@end
