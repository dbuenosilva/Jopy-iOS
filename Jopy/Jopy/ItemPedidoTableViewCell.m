//
//  ItemPedidoTableViewCell.m
//  Jopy
//
//  Created by Edson Teco on 21/11/14.
//  Copyright (c) 2014 gwaya. All rights reserved.
//

#import "ItemPedidoTableViewCell.h"

@implementation ItemPedidoTableViewCell

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
- (void)configuraItemPedido:(ItemPedido *)itemPedido
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    [numberFormatter setMaximumFractionDigits:2];
    [numberFormatter setMinimumFractionDigits:2];
    [numberFormatter setRoundingMode:NSNumberFormatterRoundHalfDown];
    
    self.lblProduto.text = [itemPedido.produto capitalizedString];
    self.lblQuantidade.text = [NSString stringWithFormat:@"Qtde: %@", itemPedido.qtde];
    self.lblValorItem.text = [numberFormatter stringFromNumber:itemPedido.valor];
    self.lblTotalItem.text = [numberFormatter stringFromNumber:itemPedido.total];

    if (itemPedido.obs.length > 0) {
        [self setTintColor:COR_AZUL];
    }
    else {
        [self setTintColor:COR_CINZA(0.5)];
    }
    self.accessoryType = UITableViewCellAccessoryDetailButton;

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
