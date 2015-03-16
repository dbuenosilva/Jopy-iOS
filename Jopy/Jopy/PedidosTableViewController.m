//
//  PedidosTableViewController.m
//  Jopy
//
//  Created by Edson Teco on 18/11/14.
//  Copyright (c) 2014 gwaya. All rights reserved.
//

#import "PedidosTableViewController.h"
#import "PedidoTableViewCell.h"
#import "AppDelegate.h"
#import "DetalhePedidoTableViewController.h"

#define kKEY_SEGUE_DETALHE @"detalheSegue"

static NSString * const PedidoCellIdentifier = @"PedidoCell";

@interface PedidosTableViewController () <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) UIActivityIndicatorView *activity;

@end

@implementation PedidosTableViewController

#pragma mark -
#pragma mark Getters overriders

- (AppDelegate *)appDelegate
{
    if (!_appDelegate) {
        _appDelegate = [[UIApplication sharedApplication] delegate];
    }
    return _appDelegate;
}

- (UIActivityIndicatorView *)activity
{
    if (!_activity) {
        _activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _activity.hidesWhenStopped = YES;
    }
    return _activity;
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (!_fetchedResultsController) {
        
        NSFetchRequest *request;
        if (self.modoHistorico) {
            request = [Pedido requestDePedidosDoFornecedor:self.codFornecedorParaExibirHistorico];
            [request setFetchLimit:3];
        }
        else {
            request = [Pedido requestDePedidosComStatus:self.statusPedidoParaExibir aprovador:[Sessao login]];
        }
        // A propriedade statusPedidoParaExibir está definida no Storyboard (Identity Inspector > User Defined Runtime Attributes)
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:self.managedObjectContext
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
        [_fetchedResultsController setDelegate:self];
    }
    return _fetchedResultsController;
}

#pragma mark -
#pragma mark Setters overriders

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
}

#pragma mark -
#pragma mark Designated initializers

#pragma mark -
#pragma mark Metodos publicos

#pragma mark -
#pragma mark Metodos privados

/**
 *  Método para configurar a célula
 *
 *  @param cell      Célula a ser escrita
 *  @param indexPath IndexPath da Célula
 */
- (void)configureCell:(PedidoTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Pedido *pedido = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [cell configuraPedido:pedido];
}

/**
 *  Método para preparar o TableView
 */
- (void)setupTableView
{
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
//    if ([self.statusPedidoParaExibir isEqualToString:PStatusPedidoEmitido]) {
//        self.tableView.separatorColor = COR_AZUL;
//    }
//    else if ([self.statusPedidoParaExibir isEqualToString:PStatusPedidoAprovado]) {
//        self.tableView.separatorColor = COR_VERDE;
//    }
//    else if ([self.statusPedidoParaExibir isEqualToString:PStatusPedidoRejeitado]) {
//        self.tableView.separatorColor = COR_VERMELHO;
//    }
    self.tableView.allowsSelection = YES;
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

/**
 *  Método para configurar os itens da UI
 */
- (void)configuraInterface
{
    [self setupTableView];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];
    // Configura a UI para modo normal
    if (!self.modoHistorico) {
        self.refreshControl = [[UIRefreshControl alloc] init];
        [self.refreshControl setTintColor:[UIColor grayColor]];
        [self.refreshControl addTarget:self action:@selector(sincroniza) forControlEvents:UIControlEventValueChanged];
        [self.tableView addSubview:self.refreshControl];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.activity];
    }
    // Configura UI para modo histórico
    else {
        self.title = @"Histórico";
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Fechar"
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:self
                                                                                action:@selector(fechar:)];
    }
}

/**
 *  Método que envia e obtem dados do servidor
 */
- (void)sincroniza
{
    [self.appDelegate.webServiceDataModel enviaDadosPendentes];
    [self.appDelegate.webServiceDataModel obtemNovosDados];
}

/**
 *  Método que define a mensagem quando não há pedidos a exibir
 */
- (void)defineMensagemSemPedidos
{
    if (self.fetchedResultsController.fetchedObjects.count > 0) {
        self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    else {
        UILabel *lblMensagem = [UILabel new];
        if (self.modoHistorico) {
            lblMensagem.text = [NSString stringWithFormat:@"Nenhum pedido anterior para este fornecedor"];
        }
        else {
            lblMensagem.text = [NSString stringWithFormat:@"Nenhum pedido %@", self.statusPedidoParaExibir];
        }
        lblMensagem.textAlignment = NSTextAlignmentCenter;
        lblMensagem.textColor = COR_CINZA(0.5);
        lblMensagem.numberOfLines = 0;
        lblMensagem.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        lblMensagem.frame = CGRectMake(0, 0, self.tableView.frame.size.width, 66);
        self.tableView.tableHeaderView = lblMensagem;
    }
}

#pragma mark -
#pragma mark ViewController life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configuraInterface];
    
    // Realiza o Fetch
    NSError *error = nil;
    [self.fetchedResultsController performFetch:&error];
    
    [self defineMensagemSemPedidos];
    
    if (error) {
        NSLog(@"%@, %@", error, error.localizedDescription);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    debug(@"%s", __FUNCTION__);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // Registro do observer para ser chamado quando os dados forem atualizados
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(importacaoIniciada:)
                                                 name:WebServiceDataModelImportacaoPedidosIniciadaNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(importacaoConcluida:)
                                                 name:WebServiceDataModelImportacaoPedidosConcluidaNotification object:nil];
    self.navigationController.toolbarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewWillDisappear:animated];
}

#pragma mark -
#pragma mark Storyboards Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kKEY_SEGUE_DETALHE]) {
        DetalhePedidoTableViewController *detalhePedidoTableViewController = segue.destinationViewController;
        detalhePedidoTableViewController.pedido = sender;
        if (self.modoHistorico) {
            NSArray *sections = self.fetchedResultsController.sections;
            id<NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:0];
            detalhePedidoTableViewController.pedidosDoHistorico = sectionInfo.objects;
            detalhePedidoTableViewController.pedido = sender;
            detalhePedidoTableViewController.indicePedidoAtual = [sectionInfo.objects indexOfObject:sender];
            detalhePedidoTableViewController.modoHistorico = YES;
        }
    }
}

#pragma mark -
#pragma mark Target/Actions

- (IBAction)fechar:(id)sender
{
    if (self.modoHistorico) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark -
#pragma mark Delegates

#pragma mark UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sections = self.fetchedResultsController.sections;
    id<NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
    NSUInteger numeroDeLinhas = [sectionInfo numberOfObjects];
    return numeroDeLinhas;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PedidoTableViewCell *cell = (PedidoTableViewCell *)[tableView dequeueReusableCellWithIdentifier:PedidoCellIdentifier forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (self.fetchedResultsController.fetchedObjects.count > 0 && !self.modoHistorico && ![self.statusPedidoParaExibir isEqualToString:PStatusPedidoEmitido]);
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Arquivar";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Pedido *pedido = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [Pedido arquivaPedido:pedido inManagedObjectContext:self.managedObjectContext];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Pedido *pedido = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self performSegueWithIdentifier:kKEY_SEGUE_DETALHE sender:pedido];
}

#pragma mark NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
    [self defineMensagemSemPedidos];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch (type) {
        case NSFetchedResultsChangeInsert: {
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeDelete: {
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeUpdate: {
            [self configureCell:(PedidoTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
        }
        case NSFetchedResultsChangeMove: {
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
    }
}

#pragma mark -
#pragma mark Notification center

/**
 *  Método para mostrar ao usuário que está realizando importação
 *
 *  @param notification Notificação
 */
- (void)importacaoIniciada:(NSNotification *)notification
{
    [self.activity performSelectorOnMainThread:@selector(startAnimating) withObject:nil waitUntilDone:YES];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    // Após 30 segundos, finaliza o spinning que fica na toolbar superior.
    [self.activity performSelector:@selector(stopAnimating) withObject:nil afterDelay:10.0f];
}

/**
 *  Método para mostrar ao usuário que a importação finalizou
 *
 *  @param notification Notificação
 */
- (void)importacaoConcluida:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
        [self.activity performSelector:@selector(stopAnimating) withObject:nil afterDelay:0.5f];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    });
}

@end
