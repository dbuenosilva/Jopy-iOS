//
//  ItemPedidoTableViewCell.h
//  Jopy
//
//  Created by Edson Teco on 21/11/14.
//  Copyright (c) 2014 gwaya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ItemPedido+AddOn.h"

@interface ItemPedidoTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblProduto;
@property (weak, nonatomic) IBOutlet UILabel *lblQuantidade;
@property (weak, nonatomic) IBOutlet UILabel *lblValorItem;
@property (weak, nonatomic) IBOutlet UILabel *lblTotalItem;

- (void)configuraItemPedido:(ItemPedido *)itemPedido;

@end
