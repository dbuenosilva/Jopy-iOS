//
//  PedidoTableViewCell.m
//  Jopy
//
//  Created by Edson Teco on 18/11/14.
//  Copyright (c) 2014 gwaya. All rights reserved.
//

#import "PedidoTableViewCell.h"

@implementation PedidoTableViewCell

#pragma mark -
#pragma mark Getters overriders

#pragma mark -
#pragma mark Setters overriders

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

#pragma mark -
#pragma mark Designated initializers

- (void)awakeFromNib
{
    // Initialization code
}

#pragma mark -
#pragma mark Metodos publicos

/**
 *  Método para configurar a celula do tableview com os dados do Pedido
 *
 *  @param pedido Pedido que deseja ser mostrado
 */
- (void)configuraPedido:(Pedido *)pedido
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd/MM/yyyy"];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    [numberFormatter setMaximumFractionDigits:2];
    [numberFormatter setMinimumFractionDigits:2];
    [numberFormatter setRoundingMode:NSNumberFormatterRoundHalfDown];
    
    self.lblData.text = [dateFormat stringFromDate:pedido.dtNeces];
    self.lblFornecedor.text = [pedido.nomeForn capitalizedString];
    self.lblTotal.text = [numberFormatter stringFromNumber:pedido.totalPedido];
    
    self.backgroundColor = [UIColor whiteColor];

    if ([pedido.statusPedido isEqualToString:PStatusPedidoEmitido]) {
        self.vwStatusPedido.backgroundColor = COR_EMITIDO(1.0);
        self.backgroundColor = COR_EMITIDO(0.1);
    }
    else if ([pedido.statusPedido isEqualToString:PStatusPedidoAprovado]) {
        self.vwStatusPedido.backgroundColor = COR_APROVADO(1.0);
        self.backgroundColor = COR_APROVADO(0.1);
    }
    else if ([pedido.statusPedido isEqualToString:PStatusPedidoRejeitado]) {
        self.vwStatusPedido.backgroundColor = COR_REJEITADO(1.0);
        self.backgroundColor = COR_REJEITADO(0.1);
    }
}

#pragma mark -
#pragma mark Metodos privados

#pragma mark -
#pragma mark Target/Actions

#pragma mark -
#pragma mark Delegates

#pragma mark -
#pragma mark Notification center

@end
