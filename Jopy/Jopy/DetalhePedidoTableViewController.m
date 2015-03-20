//
//  DetalhePedidoTableViewController.m
//  Jopy
//
//  Created by Edson Teco on 20/11/14.
//  Copyright (c) 2014 gwaya. All rights reserved.
//

#import "DetalhePedidoTableViewController.h"
#import "ItemPedidoTableViewCell.h"
#import "AppDelegate.h"
#import "PedidoFactory.h"
#import "PedidosTableViewController.h"

#define TV_SECOES 2
#define TV_SESSAO_DADOS 0
#define TV_SESSAO_DADOS_TITULO @"Dados do Pedido"
#define TV_SESSAO_DADOS_REUSE_IDENTIFIER @"DadosCell"
#define TV_SESSAO_DADOS_LINHAS 8
#define TV_SESSAO_DADOS_NUMERO_PEDIDO 0
#define TV_SESSAO_DADOS_NOME_FORNECEDOR 1
#define TV_SESSAO_DADOS_CONDICAO_PAGAMENTO 2
#define TV_SESSAO_DADOS_DATA_EMISSAO 3
#define TV_SESSAO_DADOS_DATA_NECESSIDADE 4
#define TV_SESSAO_DADOS_NOME_SOLICITANTE 5
#define TV_SESSAO_DADOS_CENTRO_DE_CUSTO 6
#define TV_SESSAO_DADOS_VALOR_TOTAL 7

#define TV_SESSAO_ITENS 1
#define TV_SESSAO_ITENS_TITULO @"Itens do Pedido"
#define TV_SESSAO_ITENS_REUSE_IDENTIFIER @"ItensCell"

#define kKEY_SEGUE_HISTORICO @"historicoSegue"

@interface DetalhePedidoTableViewController () <UITextFieldDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) AppDelegate *appDelegate;
@property (strong, nonatomic) UIBarButtonItem *btnBarAprovar;
@property (strong, nonatomic) UIBarButtonItem *btnBarRejeitar;
@property (strong, nonatomic) NSArray *itensPedido;
@property (strong, nonatomic) MBProgressHUD *hudObservacoes;
@property (strong, nonatomic) NSDateFormatter *dateFormat;

@property (strong, nonatomic) UIAlertView *motivoRejeicao;

@property (strong, nonatomic) CAGradientLayer *faixaInferior;
@property (strong, nonatomic) UIButton *btnAprovar;
@property (strong, nonatomic) UIButton *btnRejeitar;
@property (strong, nonatomic) UIView *vwSeparador;

@end

@implementation DetalhePedidoTableViewController

#pragma mark -
#pragma mark Getters overriders

- (AppDelegate *)appDelegate
{
    if (!_appDelegate) {
        _appDelegate = [[UIApplication sharedApplication] delegate];
    }
    return _appDelegate;
}

- (MBProgressHUD *)hudObservacoes
{
    if (!_hudObservacoes) {
        _hudObservacoes = [[MBProgressHUD alloc] initWithWindow:self.appDelegate.window];
        [self.appDelegate.window addSubview:_hudObservacoes];
        _hudObservacoes.mode = MBProgressHUDModeText;
        _hudObservacoes.dimBackground = YES;
        [_hudObservacoes addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fecharHud:)]];
    }
    return _hudObservacoes;
}

- (NSDateFormatter *)dateFormat
{
    if (!_dateFormat) {
        _dateFormat = [[NSDateFormatter alloc] init];
        [_dateFormat setDateFormat:@"dd/MM/yyyy"];
    }
    return _dateFormat;
}

- (UIAlertView *)motivoRejeicao
{
    if (!_motivoRejeicao) {
        _motivoRejeicao = [[UIAlertView alloc] initWithTitle:@"Motivo da Rejeição"
                                                     message:@""
                                                    delegate:self
                                           cancelButtonTitle:@"Cancelar"
                                           otherButtonTitles:@"Confirmar", nil];
        _motivoRejeicao.alertViewStyle = UIAlertViewStylePlainTextInput;
        
        [_motivoRejeicao textFieldAtIndex:0].delegate = self;
        [_motivoRejeicao textFieldAtIndex:0].autocapitalizationType = UITextAutocapitalizationTypeSentences;
        [[_motivoRejeicao textFieldAtIndex:0] setReturnKeyType:UIReturnKeyDone];
        [[_motivoRejeicao textFieldAtIndex:0] setKeyboardAppearance:UIKeyboardAppearanceDefault];
        [_motivoRejeicao textFieldAtIndex:0].enablesReturnKeyAutomatically = YES;
    }
    return _motivoRejeicao;
}

- (CAGradientLayer *)faixaInferior
{
    if (!_faixaInferior) {
        _faixaInferior = [CAGradientLayer layer];
        _faixaInferior.startPoint = CGPointMake(0.0, 0.5);
        _faixaInferior.endPoint = CGPointMake(1.0, 0.5);
        _faixaInferior.colors = [NSArray arrayWithObjects:(id)[COR_AMARELO CGColor], (id)[COR_AMARELO CGColor], nil];
        
        CGRect frame = self.navigationController.toolbar.bounds;
        frame.origin.y = frame.size.height;
        _faixaInferior.frame = frame;
        [_faixaInferior layoutIfNeeded];

        [self.navigationController.toolbar.layer addSublayer:_faixaInferior];
    }
    return _faixaInferior;
}

- (UIButton *)btnAprovar
{
    if (!_btnAprovar) {
        _btnAprovar = [[UIButton alloc] init];
        [_btnAprovar setBackgroundColor:COR_APROVADO(1.0)];
        [_btnAprovar setTitleColor:COR_BRANCO forState:UIControlStateNormal];
        [_btnAprovar setTitle:@"Aprovar" forState:UIControlStateNormal];
        [_btnAprovar addTarget:self action:@selector(aprovar:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnAprovar;
}

- (UIButton *)btnRejeitar
{
    if (!_btnRejeitar) {
        _btnRejeitar = [[UIButton alloc] init];
        [_btnRejeitar setBackgroundColor:COR_REJEITADO(1.0)];
        [_btnRejeitar setTitleColor:COR_BRANCO forState:UIControlStateNormal];
        [_btnRejeitar setTitle:@"Rejeitar" forState:UIControlStateNormal];
        [_btnRejeitar addTarget:self action:@selector(rejeitar:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnRejeitar;
}

- (UIView *)vwSeparador
{
    if (!_vwSeparador) {
        _vwSeparador = [[UIView alloc] init];
        _vwSeparador.backgroundColor = COR_BRANCO;
    }
    return _vwSeparador;
}

#pragma mark -
#pragma mark Setters overriders

#pragma mark -
#pragma mark Designated initializers

#pragma mark -
#pragma mark Metodos publicos

#pragma mark -
#pragma mark Metodos privados

/**
 *  Método para configurar os itens da interface
 */
- (void)configuraInterface
{
    self.tableView.allowsSelection = NO;
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    if (!self.modoHistorico) {
        UIBarButtonItem *btnHistorico = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_history"] style:UIBarButtonItemStylePlain target:self action:@selector(consultarHistorico:)];
        self.navigationItem.rightBarButtonItem = btnHistorico;
    }
}

/**
 *  Método para preencher o título da UI com o nome do fornecedor e montar os textos de motivos
 */
- (void)preencheInformacoesDoPedido
{
    if (!self.modoHistorico) {
        // Se o modo de visualização é normal, o título fica com o nome do fornecedor
        self.navigationItem.title = [self.pedido.nomeForn capitalizedString];

        // Header fica com o Motivo da Rejeição
        if ([self.pedido.statusPedido isEqualToString:PStatusPedidoRejeitado] && self.pedido.motivoRejeicao) {
            self.tableView.tableHeaderView = [self viewCabecalho:COR_VERMELHO
                                                           texto:[NSString stringWithFormat:@"Motivo da Rejeição: %@", self.pedido.motivoRejeicao]
                                              insetY:0];
        }
        else {
            self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
        }
    }
    else {
        // Se o modo de visualização é histórico, o título fica com o contador de pedidos
        self.navigationItem.title = [NSString stringWithFormat:@"Histórico: Pedido %ld de %lu",
                                     ((long)self.indicePedidoAtual + 1),
                                     (unsigned long)self.pedidosDoHistorico.count];
        
        // Header fica com a informação do estado do pedido
        if ([self.pedido.statusPedido isEqualToString:PStatusPedidoRejeitado] && self.pedido.motivoRejeicao) {
            self.tableView.tableHeaderView = [self viewCabecalho:COR_VERMELHO
                                                           texto:[NSString stringWithFormat:@"Motivo da Rejeição: %@", self.pedido.motivoRejeicao]
                                              insetY:0];
        }
        else if ([self.pedido.statusPedido isEqualToString:PStatusPedidoAprovado]) {
            self.tableView.tableHeaderView = [self viewCabecalho:COR_VERDE
                                                           texto:@"Pedido Aprovado"
                                              insetY:15];
        }
        else if ([self.pedido.statusPedido isEqualToString:PStatusPedidoEmitido]) {
            self.tableView.tableHeaderView = [self viewCabecalho:COR_EMITIDO(0.7)
                                                           texto:@"Pedido Pendente"
                                              insetY:15];
        }
        else {
            self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
        }
        
        if ([self.pedido.arquivo boolValue]) {
            UIBarButtonItem *btnRemoverDoArquivo = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_file"] style:UIBarButtonItemStylePlain target:self action:@selector(removerDoArquivo:)];
            self.navigationItem.rightBarButtonItem = btnRemoverDoArquivo;
        }
        else {
            self.navigationItem.rightBarButtonItem = nil;
        }
    }

    // Footer com o Motido do Pedido
    if (self.pedido.motivo) {
        self.tableView.tableFooterView = [self viewRodape];
    }
    else {
        self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    }
}

/**
 *  Método que monta a view que será mostrada no cabeçalho da tableview
 *
 *  @return View
 */
- (UIView *)viewCabecalho:(UIColor *)backgroundColor texto:(NSString *)texto insetY:(CGFloat)dY
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 66)];
    view.backgroundColor = backgroundColor;
    
    UITextView *lblTextoCabecalho = [[UITextView alloc] initWithFrame:CGRectInset(view.frame, 0, dY)];
    lblTextoCabecalho.text = texto;
    lblTextoCabecalho.textAlignment = NSTextAlignmentCenter;
    lblTextoCabecalho.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    lblTextoCabecalho.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    lblTextoCabecalho.textColor = COR_BRANCO;
    lblTextoCabecalho.editable = NO;
    lblTextoCabecalho.backgroundColor = [UIColor clearColor];
    
    [view addSubview:lblTextoCabecalho];
    
    return view;
}

/**
 *  Método que monta a view que será mostrada no rodapé da tableview
 *
 *  @return View
 */
- (UIView *)viewRodape
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 100)];
    
    UITextView *lblMotivo = [[UITextView alloc] initWithFrame:CGRectInset(view.frame, 5, 5)];
    lblMotivo.text = [NSString stringWithFormat:@"Motivo do Pedido: %@", self.pedido.motivo.capitalizedString];
    lblMotivo.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    lblMotivo.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    lblMotivo.editable = NO;
    lblMotivo.backgroundColor = [UIColor clearColor];
    
    [view addSubview:lblMotivo];
    
    return view;
}

/**
 *  Método para configurar a faixa amarela na base do toolbar
 */
- (void)configuraFaixaNoToolbar
{
    CGRect frame = self.navigationController.toolbar.bounds;
    frame.origin.y = frame.size.height - 4.0f;
    self.faixaInferior.frame = frame;
    [self.faixaInferior layoutIfNeeded];
    
//    [self.faixaInferior removeFromSuperlayer];

}

/**
 *  Método para redimensionar e reposicionar os botoes de aprovar e rejeitar dentro do toolbar
 */
- (void)posicionaBotaoAprovarERejeitarNoToolbar
{
    CGRect frame = self.navigationController.toolbar.bounds;
    frame.size.width = frame.size.width/2;
    
    [self.btnAprovar setFrame:frame];
    [self.btnRejeitar setFrame:frame];
    
    [self.btnAprovar layoutIfNeeded];
    [self.btnRejeitar layoutIfNeeded];
}

/**
 *  Método para redimensionar o separador branco no toolbar da tela de histórico
 */
- (void)redimensionaSeparadorNoToolbar
{
    CGRect frame = self.navigationController.toolbar.bounds;
    frame.size.width = 8.0f;
    frame.origin.x = self.navigationController.toolbar.bounds.size.width/2 - 4.0f;
    [self.vwSeparador setFrame:frame];
    [self.vwSeparador layoutIfNeeded];
}

/**
 *  Método para criar e adicionar os botões Aprovar e Rejeitar no toolbar inferior
 */
- (void)montaBotoesDeAcaoNoToolbar
{
    [self.navigationController setToolbarHidden:NO animated:YES];
    [self.navigationController.toolbar setBarStyle:UIBarStyleBlackTranslucent];
    
    if (!self.modoHistorico) {
        if ([self.pedido.statusPedido isEqualToString:PStatusPedidoEmitido]) {
            
            UIBarButtonItem *margem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                    target:nil
                                                                                    action:nil];
            [margem setWidth:-20.0f];
            
            [self posicionaBotaoAprovarERejeitarNoToolbar];
            
            self.btnBarAprovar = [[UIBarButtonItem alloc] initWithCustomView:self.btnAprovar];
            self.btnBarRejeitar = [[UIBarButtonItem alloc] initWithCustomView:self.btnRejeitar];
            
            [self setToolbarItems:@[margem,
                                    self.btnBarRejeitar,
                                    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                    self.btnBarAprovar,
                                    margem] animated:YES];

            [self.navigationController.toolbar setBarTintColor:COR_BRANCO];

        }
        else {
            NSString *statusDoPedido;
            
            if ([self.pedido.statusPedido isEqualToString:PStatusPedidoAprovado]) {
                [self.navigationController.toolbar setBarTintColor:COR_APROVADO(1.0)];
                statusDoPedido = [NSString stringWithFormat:@"Pedido %@", self.pedido.statusPedido];
            }
            if ([self.pedido.statusPedido isEqualToString:PStatusPedidoRejeitado]) {
                [self.navigationController.toolbar setBarTintColor:COR_REJEITADO(1.0)];
                statusDoPedido = [NSString stringWithFormat:@"Pedido %@ em %@", self.pedido.statusPedido, [self.dateFormat stringFromDate:self.pedido.dtRej]];
            }
            
            UIBarButtonItem *btnEnviar = nil;
            if (![self.pedido.enviado boolValue]) {
                btnEnviar = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"732-cloud-upload-toolbar"]
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:([self.pedido.statusPedido isEqualToString:PStatusPedidoAprovado])?@selector(enviaPedidoAprovado):@selector(enviaPedidoRejeitado)];
            }
            else {
                btnEnviar = [[UIBarButtonItem alloc] initWithCustomView:[[UIView alloc] initWithFrame:CGRectZero]];
            }
            
            [self
             setToolbarItems:@[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                               [[UIBarButtonItem alloc] initWithTitle:statusDoPedido style:UIBarButtonItemStylePlain target:nil action:nil],
                               [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                               btnEnviar]
             animated:YES];
        }
    }
    else {
        [self.navigationController.toolbar setBarTintColor:COR_AZUL];
        
        self.btnBarAprovar = [[UIBarButtonItem alloc] initWithTitle:@"Anterior"
                                                           style:UIBarButtonItemStylePlain
                                                          target:self
                                                          action:@selector(anterior:)];
        
        UIBarButtonItem *btnAnterior = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"icon_previous"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStylePlain target:self action:@selector(anterior:)];

        self.btnBarRejeitar = [[UIBarButtonItem alloc] initWithTitle:@"Próximo"
                                                            style:UIBarButtonItemStylePlain
                                                           target:self
                                                           action:@selector(proximo:)];
        
        UIBarButtonItem *btnProximo = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"icon_next"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStylePlain target:self action:@selector(proximo:)];
        
        UIBarButtonItem *btnSeparador = [[UIBarButtonItem alloc] initWithCustomView:self.vwSeparador];

        [self redimensionaSeparadorNoToolbar];
        
        [self.btnBarAprovar setTintColor:COR_BRANCO];
        [btnAnterior setTintColor:COR_BRANCO];
        [self.btnBarRejeitar setTintColor:COR_BRANCO];
        [btnProximo setTintColor:COR_BRANCO];
        
        [self setToolbarItems:@[btnAnterior,
                                self.btnBarAprovar,
                                [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                btnSeparador,
                                [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                self.btnBarRejeitar,
                                btnProximo] animated:YES];
    }
    
    [self configuraFaixaNoToolbar];
}

/**
 *  Método para escrever a célula de dados do pedido
 *
 *  @param indexPath IndexPath do dado a ser escrito
 *
 *  @return Célula preenchida
 */
- (UITableViewCell *)configuraDadosCell:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:TV_SESSAO_DADOS_REUSE_IDENTIFIER forIndexPath:indexPath];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    [numberFormatter setMaximumFractionDigits:2];
    [numberFormatter setMinimumFractionDigits:2];
    [numberFormatter setRoundingMode:NSNumberFormatterRoundHalfDown];
    
    cell.textLabel.minimumScaleFactor = 0.5f;
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.textColor = COR_AZUL;
    
    cell.detailTextLabel.minimumScaleFactor = 0.5f;
    cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
    cell.detailTextLabel.numberOfLines = 2;
    
    switch (indexPath.row) {
        case TV_SESSAO_DADOS_NUMERO_PEDIDO: {
            cell.textLabel.text = @"Pedido";
            cell.detailTextLabel.text = self.pedido.idSistema;
        }
            break;
            
        case TV_SESSAO_DADOS_NOME_FORNECEDOR: {
            cell.textLabel.text = @"Fornecedor";
            cell.detailTextLabel.text = [self.pedido.nomeForn capitalizedString];
        }
            break;
            
        case TV_SESSAO_DADOS_CONDICAO_PAGAMENTO: {
            cell.textLabel.text = @"Pagamento";
            cell.detailTextLabel.text = self.pedido.condPagto.capitalizedString;
        }
            break;
            
        case TV_SESSAO_DADOS_DATA_EMISSAO: {
            cell.textLabel.text = @"Emissão";
            cell.detailTextLabel.text = [self.dateFormat stringFromDate:self.pedido.dtEmi];
        }
            break;
            
        case TV_SESSAO_DADOS_DATA_NECESSIDADE: {
            cell.textLabel.text = @"Necessidade";
            cell.detailTextLabel.text = [self.dateFormat stringFromDate:self.pedido.dtNeces];
        }
            break;
            
        case TV_SESSAO_DADOS_NOME_SOLICITANTE: {
            cell.textLabel.text = @"Solicitante";
            cell.detailTextLabel.text = [self.pedido.solicitante capitalizedString];
        }
            break;
            
        case TV_SESSAO_DADOS_CENTRO_DE_CUSTO: {
            cell.textLabel.text = @"Centro Custo";
            cell.detailTextLabel.text = [self.pedido.centroCusto capitalizedString];
        }
            break;
            
        case TV_SESSAO_DADOS_VALOR_TOTAL: {
            cell.textLabel.text = @"Total";
            cell.detailTextLabel.text = [numberFormatter stringFromNumber:self.pedido.totalPedido];
        }
            break;
            
        default:
            break;
    }
    
    return cell;
}

/**
 *  Método para escrever a célula de item do pedido
 *
 *  @param indexPath IndexPath do item a ser escrito
 *
 *  @return Célula preenchida
 */
- (UITableViewCell *)configuraItensCell:(NSIndexPath *)indexPath
{
    ItemPedidoTableViewCell *cell = (ItemPedidoTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:TV_SESSAO_ITENS_REUSE_IDENTIFIER forIndexPath:indexPath];
    
    ItemPedido *itemPedido = self.itensPedido[indexPath.row];
    [cell configuraItemPedido:itemPedido];
    
    return cell;
}

/**
 *  Método que trata o gesto de TAP para fechar as observações do item de pedido
 *
 *  @param gesture Tap que invocou esse método
 */
- (void)fecharHud:(UIGestureRecognizer *)gesture
{
    [self.hudObservacoes hide:YES];
}

/**
 *  Método para aprovar o pedido no servidor
 */
- (void)enviaPedidoAprovado
{
    [self mostraHudComTexto:@"Aguarde..."];
    
    [PedidoFactory aprovaPedido:self.pedido completion:^(NSDictionary *pedido, NSString *erro) {
        
        [self escondeHud];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (pedido) {
                self.pedido.dtMod = [Pedido dataDeModificacao:pedido];
                self.pedido.enviado = [NSNumber numberWithBool:YES];
            }
            else {
                //[Sessao showMessage:erro title:@"Aprovação"];
            }
            [self.pedido.managedObjectContext save:nil];
            
            [self preencheInformacoesDoPedido];
            [self montaBotoesDeAcaoNoToolbar];
        });
    }];
}

/**
 *  Método para rejeitar o pedido com o motivo informado
 *
 *  @param motivo Texto do motivo da rejeição
 */
- (void)rejeitaPedidoComMotivo:(NSString *)motivo
{
    self.pedido.statusPedido = PStatusPedidoRejeitado;
    self.pedido.motivoRejeicao = motivo;
    self.pedido.dtRej = [NSDate date];
    self.pedido.dtMod = [NSDate date];
    self.pedido.enviado = [NSNumber numberWithBool:NO];
    
    [self enviaPedidoRejeitado];
}

/**
 *  Método para rejeitar o pedido
 */
- (void)enviaPedidoRejeitado
{
    [self mostraHudComTexto:@"Aguarde..."];
    
    [PedidoFactory rejeitaPedido:self.pedido completion:^(NSDictionary *pedido, NSString *erro) {
        
        [self escondeHud];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (pedido) {
                self.pedido.dtMod = [Pedido dataDeModificacao:pedido];
                self.pedido.enviado = [NSNumber numberWithBool:YES];
            }
            else {
                //[Sessao showMessage:erro title:@"Rejeição"];
            }
            [self.pedido.managedObjectContext save:nil];
            
            [self preencheInformacoesDoPedido];
            [self montaBotoesDeAcaoNoToolbar];
        });
    }];
}

#pragma mark -
#pragma mark ViewController life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configuraInterface];
    
    if (self.pedido) {
        self.itensPedido = [self.pedido.itens allObjects];
        [self preencheInformacoesDoPedido];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }

    [self montaBotoesDeAcaoNoToolbar];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    debug(@"%s", __FUNCTION__);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self posicionaBotaoAprovarERejeitarNoToolbar];
    [self configuraFaixaNoToolbar];
    [self redimensionaSeparadorNoToolbar];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self posicionaBotaoAprovarERejeitarNoToolbar];
    [self configuraFaixaNoToolbar];
    [self redimensionaSeparadorNoToolbar];
}

#pragma mark -
#pragma mark Storyboards Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kKEY_SEGUE_HISTORICO]) {
        UINavigationController *navCon = segue.destinationViewController;
        PedidosTableViewController *pedidosTableViewController = [navCon.viewControllers firstObject];
        pedidosTableViewController.managedObjectContext = self.pedido.managedObjectContext;
        pedidosTableViewController.modoHistorico = YES;
        pedidosTableViewController.codFornecedorParaExibirHistorico = self.pedido.codForn;
    }
}

#pragma mark -
#pragma mark Target/Actions

- (IBAction)aprovar:(id)sender
{
    SIAlertView *alert = [[SIAlertView alloc] initWithTitle:@"Aprovar" andMessage:@"Confirma aprovação desse pedido de compra?"];
    [alert addButtonWithTitle:@"Cancelar"
                         type:SIAlertViewButtonTypeCancel
                      handler:^(SIAlertView *alert) {
                          
                      }];
    [alert addButtonWithTitle:@"Confirmar"
                         type:SIAlertViewButtonTypeDefault
                      handler:^(SIAlertView *alert) {
                          
                          self.pedido.statusPedido = PStatusPedidoAprovado;
                          self.pedido.dtMod = [NSDate date];
                          self.pedido.enviado = [NSNumber numberWithBool:NO];
                          
                          [self enviaPedidoAprovado];
                      }];
    alert.transitionStyle = SIAlertViewTransitionStyleFade;
    [alert show];
}

- (IBAction)rejeitar:(id)sender
{
    [self.motivoRejeicao show];
}

- (IBAction)consultarHistorico:(id)sender
{
    [self performSegueWithIdentifier:kKEY_SEGUE_HISTORICO sender:self];
}

- (IBAction)anterior:(id)sender
{
    self.indicePedidoAtual--;
    if (self.indicePedidoAtual < 0) self.indicePedidoAtual = self.pedidosDoHistorico.count-1;
    
    self.pedido = [self.pedidosDoHistorico objectAtIndex:self.indicePedidoAtual];
    self.itensPedido = [self.pedido.itens allObjects];
    [self preencheInformacoesDoPedido];
    [self.tableView reloadData];
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}

- (IBAction)proximo:(id)sender
{
    self.indicePedidoAtual++;
    if (self.indicePedidoAtual > self.pedidosDoHistorico.count-1) self.indicePedidoAtual = 0;
    
    self.pedido = [self.pedidosDoHistorico objectAtIndex:self.indicePedidoAtual];
    self.itensPedido = [self.pedido.itens allObjects];
    [self preencheInformacoesDoPedido];
    [self.tableView reloadData];
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}

- (IBAction)removerDoArquivo:(id)sender
{
    SIAlertView *alert = [[SIAlertView alloc] initWithTitle:@"Desarquivar"
                                                 andMessage:@"Deseja desarquivar esse pedido? Ele voltará a aparecer nas listagens"];
    [alert addButtonWithTitle:@"Desarquivar"
                         type:SIAlertViewButtonTypeDefault
                      handler:^(SIAlertView *alert) {
                          [Pedido desarquivaPedido:self.pedido inManagedObjectContext:self.pedido.managedObjectContext];
                          [self preencheInformacoesDoPedido];
                      }];
    [alert addButtonWithTitle:@"Manter"
                         type:SIAlertViewButtonTypeCancel
                      handler:^(SIAlertView *alert) {
                          
                      }];
    alert.transitionStyle = SIAlertViewTransitionStyleFade;
    [alert show];
}

#pragma mark -
#pragma mark Delegates

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    ItemPedido *itemPedido = self.itensPedido[indexPath.row];
    if (itemPedido.obs.length > 0) {
        self.hudObservacoes.detailsLabelText = itemPedido.obs;
        [self.hudObservacoes show:YES];
    }
}

#pragma mark UIAlertViewDelegate

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    return YES; //([self.motivoRejeicao textFieldAtIndex:0].text.length > 0);
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self rejeitaPedidoComMotivo:[self.motivoRejeicao textFieldAtIndex:0].text];
    }
    [self.motivoRejeicao textFieldAtIndex:0].text = @"";
}

#pragma mark -
#pragma mark Notification center

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return TV_SECOES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case TV_SESSAO_DADOS:
            return TV_SESSAO_DADOS_LINHAS;
            break;

        case TV_SESSAO_ITENS:
            return self.itensPedido.count;
            break;
            
        default:
            return 0;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case TV_SESSAO_DADOS:
            return 32.0f;
            break;
            
        case TV_SESSAO_ITENS:
            return 32.0f;
            break;
            
        default:
            return 0.0f;
            break;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *viewTitulo = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 34.0f)];
    viewTitulo.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    UIView *faixaAmarela = [[UIView alloc] initWithFrame:CGRectMake(0, 32.0f, self.tableView.frame.size.width*2, 2)];
    faixaAmarela.backgroundColor = COR_AMARELO;
    [viewTitulo addSubview:faixaAmarela];
    
    UILabel *lblTitulo = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.tableView.frame.size.width-20, 32.0f)];
    lblTitulo.textAlignment = NSTextAlignmentLeft;
    lblTitulo.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    lblTitulo.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    lblTitulo.textColor = COR_CINZA(1.0);
    lblTitulo.backgroundColor = [UIColor clearColor];

    [viewTitulo addSubview:lblTitulo];
    
    switch (section) {
        case TV_SESSAO_DADOS:
        {
            lblTitulo.text = [TV_SESSAO_DADOS_TITULO uppercaseString];
            return viewTitulo;
        }
            break;
            
        case TV_SESSAO_ITENS:
        {
            lblTitulo.text = [TV_SESSAO_ITENS_TITULO uppercaseString];
            return viewTitulo;
        }
            break;
            
        default:
            return [[UIView alloc] initWithFrame:CGRectZero];
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    switch (section) {
        case TV_SESSAO_DADOS:
            return 32.0f;
            
        default:
            return 0.0f;
            break;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    switch (section) {
        case TV_SESSAO_DADOS: {
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 24)];
            
            UILabel *lblMotivo = [[UILabel alloc] initWithFrame:CGRectInset(view.frame, 5, 5)];
            lblMotivo.text = [NSString stringWithFormat:@"Data da última modificação: %@", [self.dateFormat stringFromDate:self.pedido.dtMod]];
            lblMotivo.numberOfLines = 1;
            lblMotivo.adjustsFontSizeToFitWidth = YES;
            lblMotivo.contentScaleFactor = 0.5f;
            lblMotivo.textAlignment = NSTextAlignmentCenter;
            lblMotivo.textColor = [UIColor grayColor];
            lblMotivo.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
            lblMotivo.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            lblMotivo.backgroundColor = [UIColor clearColor];
            
            [view addSubview:lblMotivo];
            
            return view;
        }
            break;
            
        default:
            return nil;
            break;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    switch (section) {
        case TV_SESSAO_DADOS:
            return [NSString stringWithFormat:@"Data da última modificação: %@", [self.dateFormat stringFromDate:self.pedido.dtMod]];
            break;
            
        default:
            return @"";
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case TV_SESSAO_DADOS:
            return 44.0f;
            break;
            
        case TV_SESSAO_ITENS:
            return 120.0f;
            break;
            
        default:
            return 44.0f;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case TV_SESSAO_DADOS:
            return [self configuraDadosCell:indexPath];
            break;

        case TV_SESSAO_ITENS:
            return [self configuraItensCell:indexPath];
            break;
            
        default:
            return nil;
            break;
    }
}

@end
