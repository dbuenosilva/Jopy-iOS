//
//  PedidoTableViewCell.h
//  Jopy
//
//  Created by Edson Teco on 18/11/14.
//  Copyright (c) 2014 gwaya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Pedido+AddOn.h"

@interface PedidoTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblData;
@property (weak, nonatomic) IBOutlet UILabel *lblFornecedor;
@property (weak, nonatomic) IBOutlet UILabel *lblTotal;
@property (weak, nonatomic) IBOutlet UIView *vwStatusPedido;

- (void)configuraPedido:(Pedido *)pedido;

@end
