//
//  OpcoesTableViewController.m
//  Jopy
//
//  Created by Edson Teco on 19/11/14.
//  Copyright (c) 2014 gwaya. All rights reserved.
//

#import "OpcoesTableViewController.h"
#import "AppDelegate.h"
#import "Sessao.h"
#import "Pedido+AddOn.h"

#define TV_SECOES 1
#define TV_SESSAO_OPCOES 0
#define TV_SESSAO_OPCOES_TITULO @""
#define TV_SESSAO_OPCOES_REUSE_IDENTIFIER @"OpcoesCell"
#define TV_SESSAO_OPCOES_LINHAS 1
#define TV_SESSAO_OPCOES_LOGOFF 0
#define TV_SESSAO_OPCOES_DATA_HORA_ULTIMO_ACESSO_SERVIDOR 1


@interface OpcoesTableViewController ()

@property (strong, nonatomic) AppDelegate *appDelegate;
@property (weak, nonatomic) IBOutlet UITextView *txtDetalhes;

@end

@implementation OpcoesTableViewController

#pragma mark -
#pragma mark Getters overriders

- (AppDelegate *)appDelegate
{
    if (!_appDelegate) {
        _appDelegate = [[UIApplication sharedApplication] delegate];
    }
    return _appDelegate;
}

#pragma mark -
#pragma mark Setters overriders

#pragma mark -
#pragma mark Designated initializers

#pragma mark -
#pragma mark Metodos publicos

#pragma mark -
#pragma mark Metodos privados

#pragma mark -
#pragma mark ViewController life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *versao = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *versaoBundle = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    
    self.txtDetalhes.text = [NSString stringWithFormat:@"Versão %@ (%@)", versao, versaoBundle];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    debug(@"%s", __FUNCTION__);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark Storyboards Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
}

#pragma mark -
#pragma mark Target/Actions

#pragma mark -
#pragma mark Delegates

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case TV_SESSAO_OPCOES:
        {
            switch (indexPath.row) {
                case TV_SESSAO_OPCOES_LOGOFF: {
                    [Pedido removeTodosOsPedidosInManagedObjectContext:self.appDelegate.managedObjectContext];
                    [Sessao efetuaLogoff];
                    [self.appDelegate abreLogin];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
}

#pragma mark -
#pragma mark Notification center

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return TV_SECOES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case TV_SESSAO_OPCOES:
            return TV_SESSAO_OPCOES_LINHAS;
            break;
            
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TV_SESSAO_OPCOES_REUSE_IDENTIFIER forIndexPath:indexPath];
    
    switch (indexPath.row) {
        case TV_SESSAO_OPCOES_LOGOFF: {
            cell.imageView.image = [UIImage imageNamed:@"icon_logoff-1"];
            cell.textLabel.text =  @"Sair";
        }
            break;

        case TV_SESSAO_OPCOES_DATA_HORA_ULTIMO_ACESSO_SERVIDOR:
            cell.textLabel.text = [NSString stringWithFormat:@"Último acesso: %@", [Sessao dataHoraUltimoAcessoAoServidor]];
            break;
            
        default:
            break;
    }
    
    return cell;
}

@end
